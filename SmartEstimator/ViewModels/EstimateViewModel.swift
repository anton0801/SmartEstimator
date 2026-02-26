import SwiftUI
import Combine

class EstimateViewModel: ObservableObject {
    @Published var estimates: [RoomEstimate] = []
    private let persistence = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        persistence.$estimates
            .receive(on: RunLoop.main)
            .assign(to: \.estimates, on: self)
            .store(in: &cancellables)
    }

    func save(_ estimate: RoomEstimate)     { persistence.save(estimate: estimate) }
    func delete(_ estimate: RoomEstimate)   { persistence.delete(estimate: estimate) }
    func duplicate(_ estimate: RoomEstimate){ persistence.duplicate(estimate: estimate) }

    func exportPDF(for estimate: RoomEstimate, currency: String) -> Data {
        PDFExportService.generatePDF(for: estimate, currency: currency)
    }
}
