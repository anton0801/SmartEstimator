import SwiftUI

struct EstimateSummaryView: View {
    @ObservedObject var vm: NewEstimateViewModel
    @EnvironmentObject var appState: AppState
    @StateObject private var estimateVM = EstimateViewModel()
    @State private var showShareSheet = false
    @State private var pdfData: Data? = nil
    @State private var saved = false
    @State private var showSaveAlert = false

    var estimate: RoomEstimate { vm.buildEstimate() }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {

                // Name field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Estimate Name").font(SEFont.caption()).foregroundColor(.seSubtext)
                    TextField("e.g. Master Bedroom Renovation", text: $vm.estimateName)
                        .font(SEFont.body()).padding(12)
                        .background(Color.white).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.seNavy.opacity(0.12)))
                }
                .seCard().padding(.horizontal, 20)

                // Room overview
                HStack(spacing: 16) {
                    ZStack {
                        Circle().fill(vm.selectedRoomType.color.opacity(0.15)).frame(width: 52, height: 52)
                        Image(systemName: vm.selectedRoomType.icon)
                            .font(.system(size: 24)).foregroundColor(vm.selectedRoomType.color)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vm.roomName).font(SEFont.headline()).foregroundColor(.seText)
                        Text("\(String(format: "%.2f", vm.computedLength))m × \(String(format: "%.2f", vm.computedWidth))m = \(String(format: "%.2f", vm.effectiveAreaSqM)) m²")
                            .font(SEFont.caption()).foregroundColor(.seSubtext)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total").font(SEFont.caption()).foregroundColor(.seSubtext)
                        Text("\(appState.currency)\(String(format: "%.2f", estimate.totalCost))")
                            .font(SEFont.title2()).foregroundColor(.seAmber)
                    }
                }
                .seCard().padding(.horizontal, 20)

                // Materials table
                VStack(spacing: 0) {
                    HStack {
                        Text("Material").font(SEFont.caption()).foregroundColor(.seSubtext).frame(maxWidth: .infinity, alignment: .leading)
                        Text("Qty").font(SEFont.caption()).foregroundColor(.seSubtext).frame(width: 50, alignment: .center)
                        Text("Price").font(SEFont.caption()).foregroundColor(.seSubtext).frame(width: 70, alignment: .trailing)
                        Text("Total").font(SEFont.caption()).foregroundColor(.seSubtext).frame(width: 70, alignment: .trailing)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color.seNavy.opacity(0.04))

                    Divider()

                    ForEach(Array(vm.selectedItems.enumerated()), id: \.element.id) { i, item in
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.material.name).font(SEFont.caption()).foregroundColor(.seText).lineLimit(2)
                                    Text("+\(Int(item.wastePercentage))% waste")
                                        .font(.system(size: 10, design: .rounded)).foregroundColor(.seSubtext)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Text("\(item.unitsNeeded) \(item.material.unitLabel)")
                                    .font(SEFont.caption()).foregroundColor(.seNavy).frame(width: 50, alignment: .center)
                                Text("\(appState.currency)\(String(format: "%.2f", item.material.pricePerUnit))")
                                    .font(SEFont.caption()).foregroundColor(.seSubtext).frame(width: 70, alignment: .trailing)
                                Text("\(appState.currency)\(String(format: "%.2f", item.totalCost))")
                                    .font(SEFont.caption()).foregroundColor(.seNavy).fontWeight(.semibold).frame(width: 70, alignment: .trailing)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .background(i % 2 == 0 ? Color.white : Color.seSurface)

                            if i < vm.selectedItems.count - 1 { Divider().padding(.horizontal, 16) }
                        }
                    }

                    Divider()
                    HStack {
                        Text("Grand Total").font(SEFont.headline()).foregroundColor(.seNavy)
                        Spacer()
                        Text("\(appState.currency)\(String(format: "%.2f", estimate.totalCost))")
                            .font(.system(.title3, design: .rounded).bold()).foregroundColor(.seAmber)
                    }
                    .padding(16)
                    .background(Color.seAmber.opacity(0.06))
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.seNavy.opacity(0.06), radius: 10, y: 3)
                .padding(.horizontal, 20)

                // Notes
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes (optional)").font(SEFont.caption()).foregroundColor(.seSubtext)
                    TextEditor(text: $vm.estimateNotes)
                        .font(SEFont.body()).frame(height: 70).padding(8)
                        .background(Color.white).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.seNavy.opacity(0.12)))
                }
                .seCard().padding(.horizontal, 20)

                // Actions
                VStack(spacing: 10) {
                    Button {
                        estimateVM.save(estimate)
                        saved = true; showSaveAlert = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    } label: {
                        HStack {
                            Image(systemName: saved ? "checkmark.circle.fill" : "square.and.arrow.down")
                            Text(saved ? "Saved!" : "Save Estimate")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SEPrimaryButtonStyle()).disabled(saved)

                    Button {
                        pdfData = PDFExportService.generatePDF(for: estimate, currency: appState.currency)
                        showShareSheet = true
                    } label: {
                        Label("Export PDF", systemImage: "doc.richtext").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SESecondaryButtonStyle())

                    Button { vm.reset() } label: {
                        Label("New Estimate", systemImage: "plus").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SESecondaryButtonStyle())
                }
                .padding(.horizontal, 20).padding(.bottom, 20)
            }
            .padding(.vertical, 12)
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfData { ShareSheet(items: [data]) }
        }
        .alert("Estimate Saved", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your estimate has been saved to My Estimates.")
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
