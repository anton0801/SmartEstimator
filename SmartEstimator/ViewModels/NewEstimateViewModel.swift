import SwiftUI
import Combine

enum NewEstimateStep: Int, CaseIterable {
    case roomType  = 0
    case areaInput = 1
    case materials = 2
    case summary   = 3
}

class NewEstimateViewModel: ObservableObject {
    @Published var currentStep: NewEstimateStep = .roomType

    // Room
    @Published var selectedRoomType: RoomType = .livingRoom
    @Published var customRoomName: String = ""

    // Area
    @Published var length: String = ""
    @Published var width:  String = ""
    @Published var height: String = ""
    @Published var usePhotoArea: Bool = false
    @Published var photoAreaSqM: Double = 0
    @Published var capturedImage: UIImage? = nil
    @Published var cornerPoints: [CGPoint] = []
    @Published var imageViewSize: CGSize = .zero

    // Materials
    @Published var selectedItems: [EstimateItem] = []

    // Estimate meta
    @Published var estimateName: String = ""
    @Published var estimateNotes: String = ""

    // Computed
    var computedLength: Double { Double(length) ?? 0 }
    var computedWidth:  Double { Double(width)  ?? 0 }
    var computedHeight: Double { Double(height) ?? 3 }

    var effectiveAreaSqM: Double {
        if usePhotoArea && photoAreaSqM > 0 { return photoAreaSqM }
        return computedLength * computedWidth
    }

    var wallAreaSqM: Double {
        2 * (computedLength + computedWidth) * computedHeight
    }

    var isAreaValid: Bool { effectiveAreaSqM > 0.1 }

    var roomName: String {
        selectedRoomType == .custom ? customRoomName : selectedRoomType.rawValue
    }

    func calculatePhotoArea() {
        guard cornerPoints.count == 4 else { return }
        let pts = cornerPoints
        var area: CGFloat = 0
        let n = pts.count
        for i in 0..<n {
            let j = (i + 1) % n
            area += pts[i].x * pts[j].y
            area -= pts[j].x * pts[i].y
        }
        area = abs(area) / 2
        let totalPixels = imageViewSize.width * imageViewSize.height
        guard totalPixels > 0 else { return }
        let fraction = area / totalPixels
        if computedLength > 0 && computedWidth > 0 {
            photoAreaSqM = computedLength * computedWidth * Double(fraction) * 4
        } else {
            photoAreaSqM = Double(fraction) * 30
        }
        photoAreaSqM = min(max(photoAreaSqM, 0.5), 200)
    }

    func addMaterial(_ material: Material, wastePercentage: Double) {
        let item = EstimateItem(material: material, areaSqM: effectiveAreaSqM, wastePercentage: wastePercentage)
        selectedItems.append(item)
    }

    func removeItem(at offsets: IndexSet) {
        selectedItems.remove(atOffsets: offsets)
    }

    func buildEstimate() -> RoomEstimate {
        RoomEstimate(
            name: estimateName.isEmpty ? "\(roomName) Estimate" : estimateName,
            roomType: selectedRoomType,
            length: computedLength,
            width: computedWidth,
            height: computedHeight,
            items: selectedItems,
            notes: estimateNotes
        )
    }

    func reset() {
        currentStep = .roomType
        selectedRoomType = .livingRoom; customRoomName = ""
        length = ""; width = ""; height = ""
        usePhotoArea = false; photoAreaSqM = 0; capturedImage = nil
        cornerPoints = []; imageViewSize = .zero
        selectedItems = []
        estimateName = ""; estimateNotes = ""
    }

    func goNext() {
        if let next = NewEstimateStep(rawValue: currentStep.rawValue + 1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { currentStep = next }
        }
    }

    func goBack() {
        if let prev = NewEstimateStep(rawValue: currentStep.rawValue - 1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { currentStep = prev }
        }
    }
}
