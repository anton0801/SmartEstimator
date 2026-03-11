import SwiftUI

struct MaterialPickerView: View {
    @ObservedObject var vm: NewEstimateViewModel
    @EnvironmentObject var appState: ApplicationState
    @State private var showAddSheet = false
    @State private var searchText = ""
    @State private var selectedCategory: MaterialCategory? = nil

    var allMaterials: [Material] { PersistenceMainService.shared.allMaterials() }

    var filtered: [Material] {
        allMaterials.filter { m in
            (searchText.isEmpty || m.name.localizedCaseInsensitiveContains(searchText)) &&
            (selectedCategory == nil || m.category == selectedCategory)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.seSubtext)
                TextField("Search materials...", text: $searchText)
                    .font(SEFont.body())
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.seSubtext)
                    }
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryChip(label: "All", isSelected: selectedCategory == nil) {
                        withAnimation { selectedCategory = nil }
                    }
                    ForEach(MaterialCategory.allCases, id: \.self) { cat in
                        CategoryChip(label: cat.rawValue, icon: cat.icon,
                                     isSelected: selectedCategory == cat) {
                            withAnimation { selectedCategory = selectedCategory == cat ? nil : cat }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 8)

            // Selected chips
            if !vm.selectedItems.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Added (\(vm.selectedItems.count))")
                        .font(SEFont.caption()).foregroundColor(.seSubtext).padding(.horizontal, 20)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(vm.selectedItems) { item in
                                HStack(spacing: 4) {
                                    Text(item.material.name)
                                        .font(SEFont.caption()).foregroundColor(.seNavy).lineLimit(1)
                                    Button {
                                        withAnimation { vm.selectedItems.removeAll { $0.id == item.id } }
                                    } label: {
                                        Image(systemName: "xmark").font(.system(size: 10)).foregroundColor(.seSubtext)
                                    }
                                }
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.seAmber.opacity(0.12))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 4)
            }

            // Material list
            List {
                ForEach(Array(filtered.enumerated()), id: \.element.id) { i, mat in
                    MaterialRow(material: mat, currency: appState.currency) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            vm.addMaterial(mat, wastePercentage: appState.wastePercentage)
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.seSurface)
                    .staggerAppear(index: i)
                }
            }
            .listStyle(.plain)
            .background(Color.seSurface)

            // Bottom actions
            HStack(spacing: 12) {
                Button { showAddSheet = true } label: {
                    Label("Custom", systemImage: "plus").frame(maxWidth: .infinity)
                }
                .buttonStyle(SESecondaryButtonStyle())

                Button { vm.goNext() } label: {
                    Label("Review Estimate", systemImage: "arrow.right").frame(maxWidth: .infinity)
                }
                .buttonStyle(SEPrimaryButtonStyle())
                .disabled(vm.selectedItems.isEmpty)
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(Color.white.shadow(color: Color.seNavy.opacity(0.08), radius: 8, y: -4))
        }
        .sheet(isPresented: $showAddSheet) {
            AddMaterialView(onSave: { mat in
                PersistenceMainService.shared.save(material: mat)
                vm.addMaterial(mat, wastePercentage: appState.wastePercentage)
            })
        }
    }
}

struct MaterialRow: View {
    let material: Material
    let currency: String
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(material.category == .custom ? Color.seAmber.opacity(0.12) : Color.seNavy.opacity(0.06))
                    .frame(width: 42, height: 42)
                Image(systemName: material.category.icon)
                    .font(.system(size: 18))
                    .foregroundColor(material.category == .custom ? .seAmber : .seNavy)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(material.name).font(SEFont.subheadline()).foregroundColor(.seText)
                HStack(spacing: 4) {
                    Text(material.category.rawValue)
                    if !material.brand.isEmpty { Text("· \(material.brand)") }
                }
                .font(SEFont.caption()).foregroundColor(.seSubtext)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(currency)\(String(format: "%.2f", material.pricePerUnit))")
                    .font(SEFont.subheadline()).foregroundColor(.seNavy)
                Text("per \(material.unitLabel)").font(SEFont.caption()).foregroundColor(.seSubtext)
            }
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill").font(.system(size: 26)).foregroundColor(.seAmber)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.vertical, 4)
    }
}

struct CategoryChip: View {
    let label: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon { Image(systemName: icon).font(.system(size: 12)) }
                Text(label).font(SEFont.caption())
            }
            .foregroundColor(isSelected ? .white : .seNavy)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(isSelected ? Color.seNavy : Color.seNavy.opacity(0.08))
            .cornerRadius(20)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
