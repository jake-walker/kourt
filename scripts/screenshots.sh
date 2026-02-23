#!/bin/bash
set -xe
APP_ID=xyz.jakewalker.kourt
FLOW=maestro/flow.yaml
maestro test -e APP_ID=${APP_ID} --platform ios ${FLOW}
mkdir -p Darwin/fastlane/screenshots/en-US
mv CurrentMatch.png Darwin/fastlane/screenshots/en-US/1_en-US.png
mv MatchHistory.png Darwin/fastlane/screenshots/en-US/2_en-US.png
mv Home.png Darwin/fastlane/screenshots/en-US/3_en-US.png
mv Players.png Darwin/fastlane/screenshots/en-US/4_en-US.png
mv CreateSession.png Darwin/fastlane/screenshots/en-US/5_en-US.png

maestro test -e APP_ID=${APP_ID} --platform android ${FLOW}
mkdir -p Android/fastlane/metadata/android/en-US/images/phoneScreenshots
mv CurrentMatch.png Android/fastlane/metadata/android/en-US/images/phoneScreenshots/1_en-US.png
mv MatchHistory.png Android/fastlane/metadata/android/en-US/images/phoneScreenshots/2_en-US.png
mv Home.png Android/fastlane/metadata/android/en-US/images/phoneScreenshots/3_en-US.png
mv Players.png Android/fastlane/metadata/android/en-US/images/phoneScreenshots/4_en-US.png
mv CreateSession.png Android/fastlane/metadata/android/en-US/images/phoneScreenshots/5_en-US.png
