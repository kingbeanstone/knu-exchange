import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1. Firebase 설정 (반드시 최상단에서 호출)
        FirebaseApp.configure()

        // 2. Messaging 대리자 설정
        Messaging.messaging().delegate = self

        // 3. 알림 권한 요청 및 UNUserNotificationCenter 대리자 설정
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
                print("FCM: Notification Permission granted: \(granted)")
            }
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        // 4. 원격 알림 등록
        application.registerForRemoteNotifications()

        // Flutter 플러그인 등록 (FCM 플러그인 등 포함)
        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 5. APNs 토큰 등록 (Firebase에 전달)
    // 이 메서드가 호출되어야 Firebase에서 기기를 식별할 수 있습니다.
    override func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    // 6. FCM 등록 토큰 수신 및 갱신 시 호출
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM: Firebase registration token: \(String(describing: fcmToken))")

        // 필요 시 토큰을 앱 내부의 다른 위치로 전달
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }

    // 7. 포그라운드(앱이 켜진 상태)에서 알림이 올 때 표시 설정
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 배너, 소리, 배지 모두 표시하도록 설정
        completionHandler([[.alert, .sound, .badge]])
    }
}