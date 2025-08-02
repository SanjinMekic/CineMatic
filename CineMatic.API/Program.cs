using CineMatic.Services;
using CineMatic.Services.Database;
using Mapster;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<ISjedi�tumService, Sjedi�tumService>();
builder.Services.AddTransient<I�anroviService, �anroviService>();
builder.Services.AddTransient<IDobneRestrikcijeService, DobneRestrikcijeService>();
builder.Services.AddTransient<IFAQKategorijeService, FAQKategorijeService>();
builder.Services.AddTransient<IFAQsService, FAQsService>();
builder.Services.AddTransient<IKorisniciService, KorisniciService>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var connectionString = builder.Configuration.GetConnectionString("CineMaticConnection");
builder.Services.AddDbContext<Ib210083Context>(options => options.UseSqlServer(connectionString));
builder.Services.AddMapster();
TypeAdapterConfig.GlobalSettings.Default.IgnoreNullValues(true);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
