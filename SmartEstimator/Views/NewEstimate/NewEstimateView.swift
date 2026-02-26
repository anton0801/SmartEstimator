import SwiftUI

struct NewEstimateView: View {
    @StateObject private var vm = NewEstimateViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()

                VStack(spacing: 0) {
                    SEProgressBar(step: vm.currentStep.rawValue, total: NewEstimateStep.allCases.count)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    HStack {
                        if vm.currentStep != .roomType {
                            Button { vm.goBack() } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.seNavy)
                            }
                            .padding(.trailing, 8)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(stepTitle)
                                .font(SEFont.title2())
                                .foregroundColor(.seText)
                            Text(stepSubtitle)
                                .font(SEFont.caption())
                                .foregroundColor(.seSubtext)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .animation(.easeInOut, value: vm.currentStep)

                    Group {
                        switch vm.currentStep {
                        case .roomType:
                            RoomTypePickerView(vm: vm)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal:   .move(edge: .leading).combined(with: .opacity)
                                ))
                        case .areaInput:
                            AreaInputView(vm: vm)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal:   .move(edge: .leading).combined(with: .opacity)
                                ))
                        case .materials:
                            MaterialPickerView(vm: vm)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal:   .move(edge: .leading).combined(with: .opacity)
                                ))
                        case .summary:
                            EstimateSummaryView(vm: vm)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal:   .move(edge: .leading).combined(with: .opacity)
                                ))
                        }
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.currentStep)

                    Spacer(minLength: 80)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    var stepTitle: String {
        switch vm.currentStep {
        case .roomType:  return "Room Type"
        case .areaInput: return "Measure Area"
        case .materials: return "Add Materials"
        case .summary:   return "Estimate Summary"
        }
    }
    var stepSubtitle: String {
        switch vm.currentStep {
        case .roomType:  return "Select what you're renovating"
        case .areaInput: return "Enter dimensions or use photo"
        case .materials: return "Pick materials to calculate"
        case .summary:   return "Review and save your estimate"
        }
    }
}

struct SEProgressBar: View {
    let step: Int
    let total: Int
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.seNavy.opacity(0.1)).frame(height: 4)
                Capsule()
                    .fill(LinearGradient.seAmberGradient)
                    .frame(width: geo.size.width * CGFloat(step + 1) / CGFloat(total), height: 4)
                    .animation(.spring(response: 0.4), value: step)
            }
        }
        .frame(height: 4)
    }
}
