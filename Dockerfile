FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5199
ENV ASPNETCORE_URLS=http://+:5199
ENV STRIPE_SECRET_KEY=""

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore "CineMatic.API/CineMatic.API.csproj"
RUN dotnet build "CineMatic.API/CineMatic.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CineMatic.API/CineMatic.API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

RUN mkdir -p /app/Images && \
	chmod 777 /app/Images

COPY CineMatic.API/Images/. /app/Images/

ENTRYPOINT ["dotnet", "CineMatic.API.dll"]
