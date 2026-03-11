import AppsFlyerLib
import Combine
import Firebase
import WebKit
import FirebaseMessaging

protocol NetworkService {
    func fetchAttribution(deviceID: String) async throws -> [String: Any]
    func fetchEndpoint(tracking: [String: String]) async throws -> String
}

final class HTTPNetwork: NetworkService {
    
    private let session: URLSession = {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = 30
        cfg.timeoutIntervalForResource = 90
        cfg.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        cfg.urlCache = nil
        return URLSession(configuration: cfg)
    }()
    
    func fetchAttribution(deviceID: String) async throws -> [String: Any] {
        var comps = URLComponents(string: "https://gcdsdk.appsflyer.com/install_data/v4.0/id\(SmartConfig.appID)")
        comps?.queryItems = [
            .init(name: "devkey", value: SmartConfig.devKey),
            .init(name: "device_id", value: deviceID)
        ]
        guard let url = comps?.url else { throw NetworkError.badURL }
        
        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw NetworkError.failed
        }
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkError.decode
        }
        return dict
    }
    
    private var ua: String = WKWebView().value(forKey: "userAgent") as? String ?? ""
    
    func fetchEndpoint(tracking: [String: String]) async throws -> String {
        guard let url = URL(string: "https://smartestiimator.com/config.php") else {
            throw NetworkError.badURL
        }
        
        var body: [String: Any] = tracking.mapValues { $0 as Any }
        body["os"] = "iOS"
        body["af_id"] = AppsFlyerLib.shared().getAppsFlyerUID()
        body["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        body["firebase_project_id"] = FirebaseApp.app()?.options.gcmSenderID
        body["store_id"] = "id\(SmartConfig.appID)"
        body["push_token"] = UserDefaults.standard.string(forKey: "push_token") ?? Messaging.messaging().fcmToken
        body["locale"] = Locale.preferredLanguages.first.map { String($0.prefix(2)).uppercased() } ?? "EN"
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(ua, forHTTPHeaderField: "User-Agent")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // UNIQUE retry: [13, 26, 52]
        let delays: [Double] = [13.0, 26.0, 52.0]
        var last: Error?
        
        for (i, delay) in delays.enumerated() {
            do {
                let (data, resp) = try await session.data(for: req)
                guard let http = resp as? HTTPURLResponse else { throw NetworkError.failed }
                
                if (200...299).contains(http.statusCode) {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          json["ok"] as? Bool == true,
                          let dest = json["url"] as? String else { throw NetworkError.decode }
                    return dest
                } else if http.statusCode == 429 {
                    try await Task.sleep(nanoseconds: UInt64(delay * Double(i + 1) * 1_000_000_000))
                    continue
                } else {
                    throw NetworkError.failed
                }
            } catch {
                last = error
                if i < delays.count - 1 {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        throw last ?? NetworkError.failed
    }
}

enum NetworkError: Error { case badURL, failed, decode }

