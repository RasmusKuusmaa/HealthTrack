package com.healthtrack.healthtrack

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // Opts into Android's own state restoration (the OS killing and later
    // recreating this Activity, e.g. under memory pressure) so Flutter's
    // RestorationScope has something to restore from. See
    // https://docs.flutter.dev/cookbook/persistence/restore-state.
    override fun shouldRestoreAndSaveState(): Boolean {
        return true
    }
}
