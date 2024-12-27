#!/bin/bash

export SECRET_KEY="12345678"
export CERTIFICATE_PASSWORD="12345"

gpg --quiet --batch --yes --decrypt --passphrase="${SECRET_KEY}" --output .github/deployment/profile.mobileprovision .github/deployment/profile.mobileprovision.gpg
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp .github/deployment/profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/

gpg --quiet --batch --yes --decrypt --passphrase="${SECRET_KEY}" --output .github/deployment/certificate.p12 .github/deployment/certificate.p12.gpg
security create-keychain -p "" build.keychain
security import .github/deployment/certificate.p12 -t agg -k ~/Library/Keychains/build.keychain -P "${CERTIFICATE_PASSWORD}" -A
security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain
security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain

sudo xcode-select -switch /Applications/Xcode_16.0.app
/usr/bin/xcodebuild -version

buildNumber=$(($GITHUB_RUN_NUMBER + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "EssentialApp/EssentialApp/Info.plist"

xcodebuild clean archive \
-sdk iphoneos \
-workspace EssentialApp.xcworkspace \
-configuration "Release" \
-scheme "EssentialApp" \
-derivedDataPath "DerivedData" \
-archivePath "DerivedData/Archive/EssentialApp.xcarchive"

