#!/bin/bash
set -e

VERSION_CODE=$(awk -F'=' '/CURRENT_PROJECT_VERSION/{gsub(/ /, "", $2); print $2}' Skip.env)
LOCALES=("en-US" "en-GB")
CHANGELOG=$(cz changelog --dry-run -t ./scripts/changelog-template.j2 $(cz version -p))

for LOCALE in "${LOCALES[@]}"; do
  ANDROID_DIR="./Android/fastlane/metadata/android/${LOCALE}/changelogs"
  DARWIN_DIR="./Darwin/fastlane/metadata/${LOCALE}"
  mkdir -p "${ANDROID_DIR}"
  mkdir -p "${DARWIN_DIR}"
  echo "${CHANGELOG}" > "${ANDROID_DIR}/${VERSION_CODE}.txt"
  echo "${CHANGELOG}" > "${DARWIN_DIR}/release_notes.txt"
done

echo "${CHANGELOG}"
