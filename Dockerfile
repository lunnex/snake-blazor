#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["BlazorApp3/BlazorApp3.csproj", "BlazorApp3/"]
RUN dotnet restore "./BlazorApp3/BlazorApp3.csproj"
COPY . .
WORKDIR "/src/BlazorApp3"
RUN dotnet build "./BlazorApp3.csproj" -c $BUILD_CONFIGURATION -o /app/build

COPY wait-for-db.sh /wait-for-db.sh
ENTRYPOINT ["sh", "/wait-for-db.sh", "dotnet", "BlazorApp3.dll"]

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./BlazorApp3.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BlazorApp3.dll"]