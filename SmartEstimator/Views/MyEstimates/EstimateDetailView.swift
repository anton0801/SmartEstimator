import SwiftUI

struct EstimateDetailView: View {
    @State var estimate: RoomEstimate
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var estimateVM: EstimateViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showShareSheet = false
    @State private var pdfData: Data? = nil
    @State private var isEditing = false
    @State private var editedName: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Header card
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle().fill(estimate.roomType.color.opacity(0.15)).frame(width: 60, height: 60)
                                    Image(systemName: estimate.roomType.icon)
                                        .font(.system(size: 28)).foregroundColor(estimate.roomType.color)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    if isEditing {
                                        TextField("Name", text: $editedName)
                                            .font(SEFont.headline()).textFieldStyle(.roundedBorder)
                                    } else {
                                        Text(estimate.name).font(SEFont.headline()).foregroundColor(.seText)
                                    }
                                    Text("\(estimate.roomType.rawValue) · \(estimate.createdAt, style: .date)")
                                        .font(SEFont.caption()).foregroundColor(.seSubtext)
                                }
                                Spacer()
                            }
                            Divider()
                            HStack {
                                StatBadge(label: "Floor", value: "\(String(format: "%.2f", estimate.areaSqM)) m²", icon: "square.dashed")
                                Spacer()
                                StatBadge(label: "Walls", value: "\(String(format: "%.2f", estimate.wallAreaSqM)) m²", icon: "rectangle.portrait")
                                Spacer()
                                StatBadge(label: "Total", value: "\(appState.currency)\(String(format: "%.2f", estimate.totalCost))", icon: "dollarsign.circle", accent: true)
                            }
                        }
                        .seCard().padding(.horizontal, 20)

                        // Items table
                        VStack(spacing: 0) {
                            HStack {
                                Text("Materials").font(SEFont.headline()).foregroundColor(.seText)
                                Spacer()
                                Text("\(estimate.items.count) items").font(SEFont.caption()).foregroundColor(.seSubtext)
                            }
                            .padding(16)
                            Divider()

                            ForEach(Array(estimate.items.enumerated()), id: \.element.id) { i, item in
                                HStack(spacing: 12) {
                                    Image(systemName: item.material.category.icon)
                                        .font(.system(size: 16)).foregroundColor(.seNavy).frame(width: 28)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.material.name).font(SEFont.subheadline()).foregroundColor(.seText)
                                        Text("\(item.unitsNeeded) \(item.material.unitLabel) incl. \(Int(item.wastePercentage))% waste")
                                            .font(SEFont.caption()).foregroundColor(.seSubtext)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("\(appState.currency)\(String(format: "%.2f", item.totalCost))")
                                            .font(SEFont.subheadline()).foregroundColor(.seNavy)
                                        Text("@\(appState.currency)\(String(format: "%.2f", item.material.pricePerUnit))/\(item.material.unitLabel)")
                                            .font(.system(size: 10, design: .rounded)).foregroundColor(.seSubtext)
                                    }
                                }
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(i % 2 == 0 ? Color.white : Color.seSurface)

                                if i < estimate.items.count - 1 { Divider().padding(.horizontal, 16) }
                            }

                            Divider()
                            HStack {
                                Text("Grand Total").font(SEFont.headline()).foregroundColor(.seNavy)
                                Spacer()
                                Text("\(appState.currency)\(String(format: "%.2f", estimate.totalCost))")
                                    .font(.system(.title3, design: .rounded).bold()).foregroundColor(.seAmber)
                            }
                            .padding(16).background(Color.seAmber.opacity(0.06))
                        }
                        .background(Color.white).cornerRadius(16)
                        .shadow(color: Color.seNavy.opacity(0.06), radius: 8, y: 2)
                        .padding(.horizontal, 20)

                        if !estimate.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Notes", systemImage: "note.text")
                                    .font(SEFont.caption()).foregroundColor(.seSubtext)
                                Text(estimate.notes).font(SEFont.body()).foregroundColor(.seText)
                            }
                            .seCard().padding(.horizontal, 20)
                        }

                        VStack(spacing: 10) {
                            Button {
                                pdfData = PDFExportService.generatePDF(for: estimate, currency: appState.currency)
                                showShareSheet = true
                            } label: {
                                Label("Export PDF", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SEPrimaryButtonStyle())

                            Button {
                                estimateVM.duplicate(estimate)
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Label("Duplicate Estimate", systemImage: "doc.on.doc").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SESecondaryButtonStyle())

                            Button(role: .destructive) {
                                estimateVM.delete(estimate)
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .frame(maxWidth: .infinity).foregroundColor(.seError)
                            }
                            .buttonStyle(SESecondaryButtonStyle())
                        }
                        .padding(.horizontal, 20).padding(.bottom, 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle("").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        if isEditing { estimate.name = editedName; estimateVM.save(estimate) }
                        else { editedName = estimate.name }
                        isEditing.toggle()
                    }
                    .font(SEFont.headline()).foregroundColor(.seAmber)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { presentationMode.wrappedValue.dismiss() }.foregroundColor(.seNavy)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let data = pdfData { ShareSheet(items: [data]) }
            }
        }
    }
}

struct StatBadge: View {
    let label: String
    let value: String
    let icon: String
    var accent: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 16)).foregroundColor(accent ? .seAmber : .seSubtext)
            Text(value).font(SEFont.headline()).foregroundColor(accent ? .seAmber : .seNavy)
            Text(label).font(SEFont.caption()).foregroundColor(.seSubtext)
        }
    }
}
