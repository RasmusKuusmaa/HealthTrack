# iOS flavors

`Flutter/Flavors/{Dev,Staging,Production}.xcconfig` define `APP_DISPLAY_NAME`
and the per-flavor `PRODUCT_BUNDLE_IDENTIFIER` suffix; `Info.plist` already
reads `$(APP_DISPLAY_NAME)`. `Debug.xcconfig` and `Release.xcconfig` include
the dev/production configs by default so plain (non-flavored) builds still
resolve these variables.

Wiring `--flavor staging` end-to-end on iOS additionally requires duplicating
the Xcode build configurations and schemes (Xcode's own flavor docs require
this to be done in the Xcode GUI — https://docs.flutter.dev/deployment/flavors).
That step needs Xcode on macOS and hasn't been done yet since this project is
being built on Windows. Android flavors (`dev`/`staging`/`production`) are
fully wired and buildable today.
