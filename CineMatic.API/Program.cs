using CineMatic.API;
using CineMatic.API.Filters;
using CineMatic.Services;
using CineMatic.Services.Database;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using RabbitMQ.Client;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(5219); // http bez https-a
});

builder.Services.AddSingleton<IConnectionFactory>(sp =>
{
    var hostname = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
    return new ConnectionFactory()
    {
        HostName = hostname,
        RequestedHeartbeat = TimeSpan.FromSeconds(60),
        AutomaticRecoveryEnabled = true
    };
});

// Add services to the container.
builder.Services.AddTransient<ISjedištumService, SjedištumService>();
builder.Services.AddTransient<IŽanroviService, ŽanroviService>();
builder.Services.AddTransient<IDobneRestrikcijeService, DobneRestrikcijeService>();
builder.Services.AddTransient<IFAQKategorijeService, FAQKategorijeService>();
builder.Services.AddTransient<IFAQsService, FAQsService>();
builder.Services.AddTransient<IKorisniciService, KorisniciService>();
builder.Services.AddTransient<IKategorijeHraneIpićaService, KategorijeHraneIpićaService>();
builder.Services.AddTransient<ISaleService, SaleService>();
builder.Services.AddTransient<IHraneIpićaService, HraneIpićaService>();
builder.Services.AddTransient<IGlumciService, GlumciService>();
builder.Services.AddTransient<IRežiseriService, RežiseriService>();
builder.Services.AddTransient<IUlogeService, UlogeService>();
builder.Services.AddTransient<INačiniPrikazivanjaService, NačiniPrikazivanjaService>();
builder.Services.AddTransient<IRecenzijeService, RecenzijeService>();
builder.Services.AddTransient<IFilmoviService, FilmoviService>();
builder.Services.AddTransient<IProjekcijeService, ProjekcijeService>();
builder.Services.AddTransient<IProjekcijeSjedištumService, ProjekcijeSjedištumService>();
builder.Services.AddTransient<IRezervacijeService, RezervacijeService>();
builder.Services.AddTransient<IIzvjestajiService, IzvjestajiService>();

var stripeSecretKey = builder.Configuration["Stripe:SecretKey"];
builder.Services.AddTransient(sp => new UplateService(stripeSecretKey, sp.GetRequiredService<Ib210083Context>()));

builder.Services.AddHttpContextAccessor();

builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
if (builder.Environment.IsDevelopment())
{
    builder.Services.AddSwaggerGen(c =>
    {
        c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
        {
            Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
            Scheme = "basic"
        });

        c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
        {
            {
                new OpenApiSecurityScheme
                {
                    Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
                },
                new string[]{}
            }
        });
    });
}

var connectionString = builder.Configuration.GetConnectionString("CineMaticConnection");
builder.Services.AddDbContext<Ib210083Context>(options => options.UseSqlServer(connectionString));
builder.Services.AddMapster();
TypeAdapterConfig.GlobalSettings.Default.IgnoreNullValues(true);

builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();
