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

            var factory = new ConnectionFactory()
            {
                HostName = "localhost",      // RabbitMQ radi u Dockeru na tvojoj ma�ini
                Port = 5672,                 // Standardni AMQP port
                UserName = "guest",          // Default username
                Password = "guest",          // Default password
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
            emailMessage.Subject = "Welcome to CineMatic!";
            emailMessage.Body = new TextPart("html")
            {
                Text = $@"
                    <html>
                    <body>
                        <h2>Welcome to CineMatic, {user.Name}!</h2>
                        <p>We are thrilled to have you join our cinema community.</p>
                        <p>Your registration was successful, and now you have access to exclusive movie screenings.</p>
                        <p>Feel free to explore and start booking your favorite movies!</p>
                        <p>See you at the movies,</p>
                        <p><strong>The CineMatic Team</strong></p>
                    </body>
                    </html>"
            };

            using (var client = new SmtpClient())
            {
                var smtpServer = _configuration["Email:SmtpServer"];
                var smtpPort = int.Parse(_configuration["Email:SmtpPort"]);
                var emailUsername = _configuration["Email:Username"];
                var emailPassword = _configuration["Email:Password"];

                try
                {
                    await client.ConnectAsync(smtpServer, smtpPort, MailKit.Security.SecureSocketOptions.StartTls);
                    await client.AuthenticateAsync(emailUsername, emailPassword);
                    await client.SendAsync(emailMessage);
                    _logger.LogInformation("Email sent successfully to {Email}.", user.Email);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to send email to {Email}.", user.Email);
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
