FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY LilyMarket.Api/LilyMarket.Api.csproj LilyMarket.Api/
RUN dotnet restore LilyMarket.Api/LilyMarket.Api.csproj

COPY LilyMarket.Api/ LilyMarket.Api/

WORKDIR /src/LilyMarket.Api
RUN dotnet publish LilyMarket.Api.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

COPY --from=build /app/publish .

RUN mkdir -p /app/wwwroot/uploads/auction-covers

EXPOSE 5157

ENTRYPOINT ["dotnet", "LilyMarket.Api.dll"]