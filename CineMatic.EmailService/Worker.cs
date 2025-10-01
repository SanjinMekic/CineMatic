using MimeKit;
using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using System.Text.Json;
using System.Text;
using MailKit.Net.Smtp;

namespace CineMatic.EmailService
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;
        private readonly IConnection _connection;
        private readonly IModel _channel;
        private readonly IConfiguration _configuration;

        public Worker(ILogger<Worker> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;

            //var factory = new ConnectionFactory()
            //{
            //    HostName = "localhost",      // RabbitMQ radi u Dockeru na tvojoj masini
            //    Port = 5672,                 // Standardni AMQP port
            //    UserName = "guest",          // Default username
            //    Password = "guest",          // Default password
            //    RequestedHeartbeat = TimeSpan.FromSeconds(60),
            //    AutomaticRecoveryEnabled = true
            //};

            var factory = new ConnectionFactory()
            {
                HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "rabbitmq",
                UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest",
                Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest",
                RequestedHeartbeat = TimeSpan.FromSeconds(60),
                AutomaticRecoveryEnabled = true
            };

            int retryCount = 0;
            const int maxRetries = 5;
            while (retryCount < maxRetries)
            {
                try
                {
                    _connection = factory.CreateConnection();
                    _channel = _connection.CreateModel();
                    _channel.QueueDeclare(queue: "user-registration",
                                        durable: false,
                                        exclusive: false,
                                        autoDelete: false,
                                        arguments: null);
                    break;
                }
                catch (Exception ex)
                {
                    retryCount++;
                    if (retryCount == maxRetries)
                        throw;
                    _logger.LogWarning(ex, "Failed to connect to RabbitMQ. Attempt {RetryCount} of {MaxRetries}. Retrying in 5 seconds...", retryCount, maxRetries);
                    Thread.Sleep(5000);
                }
            }
        }

        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            stoppingToken.ThrowIfCancellationRequested();

            var consumer = new EventingBasicConsumer(_channel);
            consumer.Received += (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                SendEmailAsync(message).Wait();
            };

            _channel.BasicConsume(queue: "user-registration",
                                 autoAck: true,
                                 consumer: consumer);

            return Task.CompletedTask;
        }

        private async Task SendEmailAsync(string message)
        {
            var user = JsonSerializer.Deserialize<UserRegistrationMessage>(message);
            if (user == null || string.IsNullOrEmpty(user.Email))
            {
                _logger.LogError("Invalid message format.");
                return;
            }

            var emailMessage = new MimeMessage();
            emailMessage.From.Add(new MailboxAddress("CineMatic", "noreply@cinematic.com"));
            emailMessage.To.Add(new MailboxAddress(user.Name, user.Email));

            // 📌 Sadržaj na osnovu role
            string subject;
            string body;

            switch (user.Role)
            {
                case 1: // Obicni korisnik
                    subject = "Dobrodosli u CineMatic!";
                    body = $@"
                <html>
                <body>
                    <h2>Dobrodosli u CineMatic, {user.Name}!</h2>
                    <p>Drago nam je sto ste se pridruzili nasoj kino zajednici.</p>
                    <p>Vasa registracija je uspjesna i sada imate pristup nasim filmskim projekcijama.</p>
                    <p>Istrazite ponudu i pocnite rezervisati svoje omiljene filmove!</p>
                    <p>Vidimo se u kinu,</p>
                    <p><strong>Vas CineMatic tim</strong></p>
                </body>
                </html>";
                    break;

                case 2: // Admin
                    subject = "Dobrodosli, CineMatic Administrator!";
                    body = $@"
                <html>
                <body>
                    <h2>Pozdrav, Admin {user.Name},</h2>
                    <p>Vas administratorski racun u CineMatic sistemu je uspjesno kreiran.</p>
                    <p>Sada mozete upravljati korisnicima, filmovima i projekcijama.</p>
                    <p><strong>Vase korisnicko ime je: {user.korisnickoIme}</strong></p>
                    <p><strong>Vasa lozinka za prijavu je: {user.Password}</strong></p>
                    <p>Iz sigurnosnih razloga obavezno promijenite lozinku nakon prve prijave.</p>
                    <p><strong>Vas CineMatic tim</strong></p>
                </body>
                </html>";
                    break;

                case 3: // Blagajnik
                    subject = "Dobrodosli, CineMatic Blagajnik!";
                    body = $@"
                <html>
                <body>
                    <h2>Pozdrav, {user.Name},</h2>
                    <p>Vas blagajnicki racun u CineMatic sistemu je uspjesno kreiran.</p>
                    <p>Sada mozete upravljati prodajom karata i pomagati nasim posjetiocima.</p>
                    <p><strong>Vase korisnicko ime je: {user.korisnickoIme}</strong></p>
                    <p><strong>Vasa lozinka za prijavu je: {user.Password}</strong></p>
                    <p>Iz sigurnosnih razloga obavezno promijenite lozinku nakon prve prijave.</p>
                    <p><strong>Vas CineMatic tim</strong></p>
                </body>
                </html>";
                    break;

                default: // fallback
                    subject = "CineMatic Registracija";
                    body = $@"
                <html>
                <body>
                    <h2>Dobrodosli, {user.Name}!</h2>
                    <p>Vas CineMatic racun je uspjesno kreiran.</p>
                    <p><strong>Vas CineMatic tim</strong></p>
                </body>
                </html>";
                    break;
            }

            emailMessage.Subject = subject;
            emailMessage.Body = new TextPart("html") { Text = body };

            using (var client = new SmtpClient())
            {
                var smtpServer = Environment.GetEnvironmentVariable("EMAIL_SMTP_SERVER") ?? _configuration["Email:SmtpServer"];
                var smtpPort = int.Parse(Environment.GetEnvironmentVariable("EMAIL_SMTP_PORT") ?? _configuration["Email:SmtpPort"]);
                var emailUsername = Environment.GetEnvironmentVariable("EMAIL_USERNAME") ?? _configuration["Email:Username"];
                var emailPassword = Environment.GetEnvironmentVariable("EMAIL_PASSWORD");

                try
                {
                    await client.ConnectAsync(smtpServer, smtpPort, MailKit.Security.SecureSocketOptions.StartTls);
                    await client.AuthenticateAsync(emailUsername, emailPassword);
                    await client.SendAsync(emailMessage);
                    _logger.LogInformation("Email uspjesno poslan na {Email}.", user.Email);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Slanje emaila nije uspjelo na {Email}.", user.Email);
                }
                finally
                {
                    await client.DisconnectAsync(true);
                }
            }
        }

        public override Task StopAsync(CancellationToken cancellationToken)
        {
            _channel.Close();
            _connection.Close();
            return base.StopAsync(cancellationToken);
        }
    }
}
