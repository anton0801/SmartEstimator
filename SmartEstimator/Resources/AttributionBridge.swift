import Foundation
import Combine

final class AttributionBridge: NSObject {
    var onTracking: (([AnyHashable: Any]) -> Void)?
    var onNavigation: (([AnyHashable: Any]) -> Void)?
    
    private var trackingBuffer: [AnyHashable: Any] = [:]
    private var navigationBuffer: [AnyHashable: Any] = [:]
    private var mergeTimer: Timer?
    private let completedKey = "se_attribution_completed"
    
    func receiveTracking(_ data: [AnyHashable: Any]) {
        trackingBuffer = data
        scheduleMerge()
        if !navigationBuffer.isEmpty { merge() }
    }
    
    func receiveNavigation(_ data: [AnyHashable: Any]) {
        guard !isCompleted() else { return }
        navigationBuffer = data
        onNavigation?(data)
        mergeTimer?.invalidate()
        if !trackingBuffer.isEmpty { merge() }
    }
    
    private func scheduleMerge() {
        mergeTimer?.invalidate()
        mergeTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in self?.merge() }
    }
    
    private func merge() {
        var result = trackingBuffer
        navigationBuffer.forEach { key, value in
            let prefixedKey = "deep_\(key)"
            if result[prefixedKey] == nil { result[prefixedKey] = value }
        }
        onTracking?(result)
    }
    
    private func isCompleted() -> Bool {
        UserDefaults.standard.bool(forKey: completedKey)
    }
}
