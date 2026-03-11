import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import AppTrackingTransparency
import UserNotifications
import AppsFlyerLib

final class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    private let attributionBridge = AttributionBridge()
    private let pushBridge = PushBridge()
    private var trackingBridge: TrackingBridge?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        attributionBridge.onTracking = { [weak self] in self?.broadcastTracking($0) }
        attributionBridge.onNavigation = { [weak self] in self?.broadcastNavigation($0) }
        trackingBridge = TrackingBridge(bridge: attributionBridge)
        
        initializeFirebase()
        initializePush()
        initializeTracking()
        
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            pushBridge.process(payload: notification)
        }
        
        observeLifecycle()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    private func initializeFirebase() {
        FirebaseApp.configure()
        Auth.auth().signInAnonymously()
    }
    
    private func initializePush() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func initializeTracking() {
        trackingBridge?.configure()
    }
    
    private func observeLifecycle() {
        NotificationCenter.default.addObserver(self, selector: #selector(becameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func becameActive() {
        trackingBridge?.start()
    }
    
    private func broadcastTracking(_ data: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name("ConversionDataReceived"), object: nil, userInfo: ["conversionData": data])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pushBridge.process(payload: userInfo)
        completionHandler(.newData)
    }
    
    private func broadcastNavigation(_ data: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name("deeplink_values"), object: nil, userInfo: ["deeplinksData": data])
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, error in
            guard error == nil, let token = token else { return }
            UserDefaults.standard.set(token, forKey: "fcm_token")
            UserDefaults.standard.set(token, forKey: "push_token")
            UserDefaults(suiteName: "group.smart.cache")?.set(token, forKey: "shared_fcm_token")
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "fcm_timestamp")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        pushBridge.process(payload: notification.request.content.userInfo)
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        pushBridge.process(payload: response.notification.request.content.userInfo)
        completionHandler()
    }
}

final class TrackingBridge: NSObject, AppsFlyerLibDelegate, DeepLinkDelegate {
    private var bridge: AttributionBridge
    
    init(bridge: AttributionBridge) {
        self.bridge = bridge
    }
    
    func configure() {
        let sdk = AppsFlyerLib.shared()
        sdk.appsFlyerDevKey = SmartConfig.devKey
        sdk.appleAppID = SmartConfig.appID
        sdk.delegate = self
        sdk.deepLinkDelegate = self
        sdk.isDebug = false
    }
    
    func start() {
        if #available(iOS 14.0, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                    UserDefaults.standard.set(status.rawValue, forKey: "att_status")
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "att_timestamp")
                }
            }
        } else {
            AppsFlyerLib.shared().start()
        }
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        bridge.receiveTracking(data)
    }
    
    func onConversionDataFail(_ error: Error) {
        var data: [AnyHashable: Any] = [:]
        data["error"] = true
        data["error_description"] = error.localizedDescription
        bridge.receiveTracking(data)
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard case .found = result.status, let deepLink = result.deepLink else { return }
        bridge.receiveNavigation(deepLink.clickEvent)
    }
}

struct SmartConfig {
    static let appID = "6758240851"
    static let devKey = "oi7aE3fukWTyBKy6kHtXTF"
}
