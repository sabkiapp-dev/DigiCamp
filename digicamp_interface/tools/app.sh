#!/bin/bash
# Command to get all dependencies
flutter pub get

# To generate localization files
read -p "Would you like to generate localized files[Y/N]: " choice
case $choice in
  YES|yes|Y|y)
    flutter gen-l10n
  ;;
  NO|no|N|n)
    echo "Skipped"
  ;;
esac

# Command to generate splash screen
read -p "Would you like to generate splash screen[Y/N]: " choice
case $choice in
  YES|yes|Y|y)
    flutter pub run flutter_native_splash:create --path=flutter_native_splash.yaml
  ;;
  NO|no|N|n)
    echo "Skipped"
  ;;
esac

# Command to generate launcher icons
read -p "Would you like to generate launcher icons[Y/N]: " choice
case $choice in
  YES|yes|Y|y)
    flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons.yaml
  ;;
  NO|no|N|n)
    echo "Skipped"
  ;;
esac

# Uncomment the below given line to change app package name
read -p "Would you like to change app package name[Y/N]: " choice
case $choice in
  YES|yes|Y|y)
    read -p "Enter package name: " packageName
    flutter pub run change_app_package_name:main $packageName
  ;;
  NO|no|N|n)
    echo "Skipped"
  ;;
esac

# Uncomment the below given line to change app package name
read -p "Would you like to run build_runner to generate assets[Y/N]: " choice
case $choice in
  YES|yes|Y|y)
    flutter packages pub run build_runner build --delete-conflicting-outputs
  ;;
  NO|no|N|n)
    echo "Skipped"
  ;;
esac