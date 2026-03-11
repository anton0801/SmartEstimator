import SwiftUI
import Combine

class ApplicationState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "onboarding_complete") }
    }
    @Published var currency: String {
        didSet { UserDefaults.standard.set(currency, forKey: "currency") }
    }
    @Published var wastePercentage: Double {
        didSet { UserDefaults.standard.set(wastePercentage, forKey: "waste_pct") }
    }

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "onboarding_complete")
        self.currency = UserDefaults.standard.string(forKey: "currency") ?? "USD"
        let wPct = UserDefaults.standard.double(forKey: "waste_pct")
        self.wastePercentage = wPct == 0 ? 10.0 : wPct
    }
}
