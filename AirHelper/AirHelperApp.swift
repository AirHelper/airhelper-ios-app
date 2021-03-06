import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import NMapsMap

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        KakaoSDKCommon.initSDK(appKey: "3df859b83685d15b26e624611933bd30", loggingEnable:true)
        NMFAuthManager.shared().clientId = "aoikqbnbpq"
        
        return true
    }
    
    static var orientationLock = UIInterfaceOrientationMask.portrait
}


@main
struct AirHelperApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL(perform: { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}
