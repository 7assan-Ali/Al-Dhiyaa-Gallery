#!/usr/bin/env bash
set -euo pipefail

echo 'Preparing Al-Dhiyaa Gallery Flutter platforms...'
flutter create . --platforms=android,web,windows --org com.aldhiyaa --project-name al_dhiyaa_gallery
flutter pub get

echo 'Bootstrap complete.'
echo 'Run: flutter run'
echo 'Release APK: flutter build apk --release'
echo 'Play Store bundle: flutter build appbundle --release'
