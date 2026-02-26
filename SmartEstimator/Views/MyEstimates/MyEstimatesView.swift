import SwiftUI

struct MyEstimatesView: View {
    @EnvironmentObject var estimateVM: EstimateViewModel
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedEstimate: RoomEstimate? = nil

    var filtered: [RoomEstimate] {
        guard !searchText.isEmpty else { return estimateVM.estimates }
        return estimateVM.estimates.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()

                if estimateVM.estimates.isEmpty {
                    EmptyEstimatesView()
                } else {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.seSubtext)
                            TextField("Search estimates...", text: $searchText).font(SEFont.body())
                        }
                        .padding(10).background(Color.white).cornerRadius(12)
                        .padding(.horizontal, 20).padding(.vertical, 8)

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(estimateVM.estimates.count) Estimates")
                                    .font(SEFont.headline()).foregroundColor(.white)
                                Text("Total: \(appState.currency)\(String(format: "%.2f", estimateVM.estimates.reduce(0) { $0 + $1.totalCost }))")
                                    .font(SEFont.caption()).foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 32)).foregroundColor(.white.opacity(0.3))
                        }
                        .padding(16)
                        .background(LinearGradient.seNavyGradient)
                        .padding(.horizontal, 20).cornerRadius(14).padding(.bottom, 8)

                        List {
                            ForEach(Array(filtered.enumerated()), id: \.element.id) { i, est in
                                EstimateRowCard(estimate: est, currency: appState.currency,
                                               onDuplicate: { estimateVM.duplicate(est) },
                                               onDelete: { estimateVM.delete(est) })
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowBackground(Color.seSurface)
                                .listRowSeparator(.hidden)
                                .staggerAppear(index: i)
                                .onTapGesture { selectedEstimate = est }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("My Estimates")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedEstimate) { est in
                EstimateDetailView(estimate: est)
                    .environmentObject(appState)
                    .environmentObject(estimateVM)
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct EstimateRowCard: View {
    let estimate: RoomEstimate
    let currency: String
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(estimate.roomType.color.opacity(0.12)).frame(width: 52, height: 52)
                Image(systemName: estimate.roomType.icon)
                    .font(.system(size: 22)).foregroundColor(estimate.roomType.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(estimate.name).font(SEFont.headline()).foregroundColor(.seText).lineLimit(1)
                HStack(spacing: 6) {
                    Text(estimate.roomType.rawValue).font(SEFont.caption()).foregroundColor(.seSubtext)
                    Text("·").foregroundColor(.seSubtext)
                    Text(estimate.createdAt, style: .date).font(SEFont.caption()).foregroundColor(.seSubtext)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(currency)\(String(format: "%.2f", estimate.totalCost))")
                    .font(SEFont.headline()).foregroundColor(.seNavy)
                Text("\(estimate.items.count) items").font(SEFont.caption()).foregroundColor(.seSubtext)
            }
        }
        .padding(14).background(Color.white).cornerRadius(16)
        .shadow(color: Color.seNavy.opacity(0.06), radius: 8, y: 2)
        .contextMenu {
            Button { onDuplicate() } label: { Label("Duplicate", systemImage: "doc.on.doc") }
            Button(role: .destructive) { onDelete() } label: { Label("Delete", systemImage: "trash") }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) { onDelete() } label: { Label("Delete", systemImage: "trash") }
            Button { onDuplicate() } label: { Label("Copy", systemImage: "doc.on.doc") }
                .tint(.seNavyLight)
        }
    }
}

struct EmptyEstimatesView: View {
    @State private var animating = false
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle().fill(Color.seAmber.opacity(0.1)).frame(width: 120, height: 120)
                    .scaleEffect(animating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animating)
                Image(systemName: "folder.badge.plus").font(.system(size: 50)).foregroundColor(.seAmber)
            }
            .onAppear { animating = true }
            Text("No Estimates Yet").font(SEFont.title2()).foregroundColor(.seText)
            Text("Create your first estimate from the\nNew Estimate tab")
                .font(SEFont.body()).foregroundColor(.seSubtext).multilineTextAlignment(.center)
        }
        .padding()
    }
}
