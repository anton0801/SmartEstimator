import Foundation


final class PushBridge: NSObject {
    func process(payload: [AnyHashable: Any]) {
        guard let url = extractURL(from: payload) else { return }
        UserDefaults.standard.set(url, forKey: "temp_url")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "temp_url_timestamp")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            NotificationCenter.default.post(name: Notification.Name("LoadTempURL"), object: nil, userInfo: ["temp_url": url])
        }
    }
    
    private func extractURL(from payload: [AnyHashable: Any]) -> String? {
        if let url = payload["url"] as? String { return url }
        if let data = payload["data"] as? [String: Any], let url = data["url"] as? String { return url }
        if let aps = payload["aps"] as? [String: Any], let data = aps["data"] as? [String: Any], let url = data["url"] as? String { return url }
        if let custom = payload["custom"] as? [String: Any], let url = custom["target_url"] as? String { return url }
        return nil
    }
}
