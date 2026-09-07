$ErrorActionPreference = 'Stop'

Write-Host 'Preparing Al-Dhiyaa Gallery Flutter platforms...' -ForegroundColor Cyan
flutter create . --platforms=android,web,windows --org com.aldhiyaa --project-name al_dhiyaa_gallery
flutter pub get

# Android application label and package defaults are finalized by the release workflow.
Write-Host 'Bootstrap complete.' -ForegroundColor Green
Write-Host 'Run: flutter run' -ForegroundColor Yellow
Write-Host 'Release APK: flutter build apk --release' -ForegroundColor Yellow
Write-Host 'Play Store bundle: flutter build appbundle --release' -ForegroundColor Yellow
