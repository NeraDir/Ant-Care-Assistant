

import SwiftUI
import AppsFlyerLib

@main
struct EeirgeOneSevenOneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .dark
        }
        AppsFlyerLib.shared().appsFlyerDevKey = hrthrj
        AppsFlyerLib.shared().appleAppID = appIdVova
        AppsFlyerLib.shared().isDebug = false
        
    }

    var body: some Scene {
        WindowGroup {
            Orehuthudrghu()
        }
    }
}
