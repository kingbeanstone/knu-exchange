import UIKit
import Flutter
import Firebase
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1. Firebase 초기화
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // 2. Messaging 대리자 설정 (FCM 토큰 관리를 위해 필수)
        Messaging.messaging().delegate = self

        // 3. UNUserNotificationCenter 대리자 설정 (포그라운드 알림 처리용)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        // 4. 원격 알림 등록 시작 (APNs 토큰 발급 트리거)
        application.registerForRemoteNotifications()

        // Flutter 플러그인 연결 (FCM, Naver Map 등 모든 플러그인 작동 보장)
        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // 5. [중요] Apple 서버로부터 받은 APNs 토큰을 Firebase에 수동으로 전달
    // 이 메서드가 호출되어야 Firebase에서 기기를 식별할 수 있습니다.
    override func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    // 알림 등록 실패 시 로그 출력
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("FCM: iOS Remote Notification Registration Failed: \(error.localizedDescription)")
        super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
}

// 6. FCM 대리자(MessagingDelegate) 구현
// 새로운 토큰이 생성되거나 갱신될 때 맥북 Xcode 콘솔에 출력됩니다.
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // 이 로그를 맥북 Xcode 콘솔에서 확인하여 토큰을 복사하세요!
        print("FCM: Firebase registration token: \(String(describing: fcmToken))")

        // 필요 시 토큰 정보를 앱 내부 시스템으로 전달
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}

