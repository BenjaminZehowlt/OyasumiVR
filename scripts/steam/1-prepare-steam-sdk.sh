#!/bin/sh
### Script for preparing the Steam SDK for deployment
### USED BY build-steam-release.yml GITHUB ACTIONS WORKFLOW.
### DO NOT RUN MANUALLY

# Clean up pre-existing files
rm -rf SteamSDK
# Unzip the SteamWorks SDK
unzip scripts/steam/lib/steamworks_sdk_157.zip -d SteamSDK
# Create Depot folders
mkdir -p SteamSDK/sdk/tools/ContentBuilder/content/Win64
mkdir -p SteamSDK/sdk/tools/ContentBuilder/content/Win64_CN
# Include WebView2 Installer
mkdir -p SteamSDK/sdk/tools/ContentBuilder/content/Win64/WebView2
mkdir -p SteamSDK/sdk/tools/ContentBuilder/content/Win64_CN/WebView2
curl -L https://go.microsoft.com/fwlink/p/?LinkId=2124703 --output SteamSDK/sdk/tools/ContentBuilder/content/Win64/WebView2/WebView2RuntimeInstaller.exe
cp SteamSDK/sdk/tools/ContentBuilder/content/Win64/WebView2/WebView2RuntimeInstaller.exe SteamSDK/sdk/tools/ContentBuilder/content/Win64_CN/WebView2/WebView2RuntimeInstaller.exe
# Include DotNet Hosting Bundle Installer
mkdir -p SteamSDK/sdk/tools/ContentBuilder/content/Win64/DotNet
mkdir -p SteamSDK/sdk/tools/ContentBuilder/content/Win64_CN/DotNet
curl -L https://download.visualstudio.microsoft.com/download/pr/d489c5d0-4d0f-4622-ab93-b0f2a3e92eed/101a2fae29a291956d402377b941f401/dotnet-hosting-7.0.11-win.exe --output SteamSDK/sdk/tools/ContentBuilder/content/Win64/DotNet/dotnet-hosting-7.0.11-win.exe
cp SteamSDK/sdk/tools/ContentBuilder/content/Win64/DotNet/dotnet-hosting-7.0.11-win.exe SteamSDK/sdk/tools/ContentBuilder/content/Win64_CN/DotNet/dotnet-hosting-7.0.11-win.exe
# Clear default scripts
rm SteamSDK/sdk/tools/ContentBuilder/scripts/*
# Copy over scripts
cp scripts/steam/scripts/*.vdf SteamSDK/sdk/tools/ContentBuilder/scripts/
cp scripts/steam/install-scripts/*.vdf SteamSDK/sdk/tools/ContentBuilder/content/Win64/
cp scripts/steam/install-scripts/*.vdf SteamSDK/sdk/tools/ContentBuilder/content/Win64_CN/
# Replace variables
sed -i "s/APP_VERSION/$APP_VERSION/" SteamSDK/sdk/tools/ContentBuilder/scripts/*.vdf
sed -i "s/STEAM_APP_ID/$STEAM_APP_ID/" SteamSDK/sdk/tools/ContentBuilder/scripts/*.vdf
# Setup Steam authentication
cd SteamSDK/sdk/tools/ContentBuilder/builder
mkdir config
echo "$STEAM_CONFIG_VDF" | base64 -d > "config/config.vdf"
chmod 777 "config/config.vdf"
