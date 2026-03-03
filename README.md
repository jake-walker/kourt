# Kourt

<a href="https://apple.co/4rLVXYN"><img alt="Download on the App Store" src="https://static.jakewalker.xyz/Download_on_the_App_Store_Badge_US-UK_RGB_blk_092917.svg" /></a>

Kourt is a free and open-source matchmaking app for iOS and Android, designed to handle group rotations for court sports like badminton, tennis, squash, and any other game played on a court.

The app simplifies organizing sessions by generating fair match lists from a group of players. It ensures everyone gets a turn to play and provides a balanced rotation, taking the guesswork and arguments out of "who plays next."

## iPhone Screenshots

<img alt="iPhone Screenshot" src="Darwin/fastlane/screenshots/en-US/1_en-US.png" style="width: 18%" /> <img alt="iPhone Screenshot" src="Darwin/fastlane/screenshots/en-US/2_en-US.png" style="width: 18%" /> <img alt="iPhone Screenshot" src="Darwin/fastlane/screenshots/en-US/3_en-US.png" style="width: 18%" /> <img alt="iPhone Screenshot" src="Darwin/fastlane/screenshots/en-US/4_en-US.png" style="width: 18%" /> <img alt="iPhone Screenshot" src="Darwin/fastlane/screenshots/en-US/5_en-US.png" style="width: 18%" />

## Android Screenshots

<img alt="Android Screenshot" src="Android/fastlane/metadata/android/en-US/images/phoneScreenshots/1_en-US.png" style="width: 18%" /> <img alt="Android Screenshot" src="Android/fastlane/metadata/android/en-US/images/phoneScreenshots/2_en-US.png" style="width: 18%" /> <img alt="Android Screenshot" src="Android/fastlane/metadata/android/en-US/images/phoneScreenshots/3_en-US.png" style="width: 18%" /> <img alt="Android Screenshot" src="Android/fastlane/metadata/android/en-US/images/phoneScreenshots/4_en-US.png" style="width: 18%" /> <img alt="Android Screenshot" src="Android/fastlane/metadata/android/en-US/images/phoneScreenshots/5_en-US.png" style="width: 18%" />

## TestFlight

## Development

Kourt is built using [Skip](https://skip.dev), a toolchain for creating dual-platform iOS and Android apps from a single Swift codebase.

### CI/CD

Releases are handled automatically via GitHub Actions.

## Getting Started

### Building

This project is both a stand-alone Swift Package Manager module, as well as an Xcode project that builds and translates the project into a Kotlin Gradle project for Android using the `skipstone` plugin.

Building the module requires that Skip be installed using [Homebrew](https://brew.sh):

```bash
brew install skiptools/skip/skip
```

This will also install the necessary Skip prerequisites: Kotlin, Gradle, and the Android build tools. Installation prerequisites can be confirmed by running `skip checkup`. The project can be validated with `skip verify`.

### Running

Xcode and Android Studio must be installed to run the app in the iOS simulator or Android emulator. An Android emulator must already be running (launchable from Android Studio's Device Manager).

1. Open `Project.xcworkspace` in Xcode.
2. Launch the **Kourt App** target.

To run both platforms simultaneously, Xcode runs a "Launch Android APK" script that deploys the Skip app to a running Android emulator or connected device. iOS logs appear in the Xcode console; Android logs can be viewed in Android Studio's Logcat or via `adb logcat`.

### Testing

The module can be tested using the standard `swift test` command or by running the test target for the macOS destination in Xcode. This runs both Swift tests and transpiled Kotlin JUnit tests (via Robolectric).

For platform parity testing, run:

```bash
skip test
```

## Contributing

Contributions are welcome! Please ensure all Pull Requests target the `main` branch.

## License

This software is licensed under the [GNU General Public License v3.0](LICENSE.txt).
