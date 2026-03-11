import SwiftUI

struct MaterialLibraryView: View {
    @EnvironmentObject var libraryVM: MaterialLibraryViewModel
    @EnvironmentObject var appState: ApplicationState
    @State private var showAddSheet = false
    @State private var editingMaterial: Material? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.seSubtext)
                        TextField("Search materials, brands...", text: $libraryVM.searchText).font(SEFont.body())
                        if !libraryVM.searchText.isEmpty {
                            Button { libraryVM.searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.seSubtext)
                            }
                        }
                    }
                    .padding(10).background(Color.white).cornerRadius(12)
                    .padding(.horizontal, 20).padding(.vertical, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryChip(label: "All", isSelected: libraryVM.selectedCategory == nil) {
                                withAnimation { libraryVM.selectedCategory = nil }
                            }
                            ForEach(MaterialCategory.allCases, id: \.self) { cat in
                                CategoryChip(label: cat.rawValue, icon: cat.icon,
                                             isSelected: libraryVM.selectedCategory == cat) {
                                    withAnimation { libraryVM.selectedCategory = libraryVM.selectedCategory == cat ? nil : cat }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 8)

                    HStack {
                        Text("\(libraryVM.filtered.count) materials")
                            .font(SEFont.caption()).foregroundColor(.seSubtext)
                        Spacer()
                    }
                    .padding(.horizontal, 20).padding(.bottom, 4)

                    List {
                        ForEach(Array(libraryVM.filtered.enumerated()), id: \.element.id) { i, mat in
                            LibraryMaterialRow(material: mat, currency: appState.currency)
                                .staggerAppear(index: i)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowBackground(Color.seSurface)
                                .listRowSeparator(.hidden)
                                .onTapGesture { if mat.isCustom { editingMaterial = mat } }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    if mat.isCustom {
                                        Button(role: .destructive) { libraryVM.deleteMaterial(mat) } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        Button { editingMaterial = mat } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.seNavyLight)
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Materials Library").navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus.circle.fill").font(.system(size: 22)).foregroundColor(.seAmber)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddMaterialView(onSave: { libraryVM.saveMaterial($0) })
            }
            .sheet(item: $editingMaterial) { mat in
                AddMaterialView(editingMaterial: mat, onSave: { libraryVM.saveMaterial($0) })
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct LibraryMaterialRow: View {
    let material: Material
    let currency: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(material.isCustom ? Color.seAmber.opacity(0.12) : Color.seNavy.opacity(0.06))
                    .frame(width: 44, height: 44)
                Image(systemName: material.category.icon)
                    .font(.system(size: 18))
                    .foregroundColor(material.isCustom ? .seAmber : .seNavy)
            }
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(material.name).font(SEFont.subheadline()).foregroundColor(.seText)
                    if material.isCustom {
                        Text("CUSTOM").font(.system(size: 9, weight: .bold, design: .rounded)).foregroundColor(.seAmber)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Color.seAmber.opacity(0.12)).cornerRadius(4)
                    }
                }
                HStack(spacing: 4) {
                    Text(material.category.rawValue)
                    if !material.brand.isEmpty { Text("· \(material.brand)") }
                }
                .font(SEFont.caption()).foregroundColor(.seSubtext)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(currency)\(String(format: "%.2f", material.pricePerUnit))")
                    .font(SEFont.headline()).foregroundColor(.seNavy)
                Text("per \(material.unitLabel)").font(SEFont.caption()).foregroundColor(.seSubtext)
                Text("Covers \(String(format: "%.1f", material.coveragePerUnit)) m²/unit")
                    .font(.system(size: 10, design: .rounded)).foregroundColor(.seSubtext)
            }
        }
        .padding(12).background(Color.white).cornerRadius(14)
        .shadow(color: Color.seNavy.opacity(0.05), radius: 5, y: 1)
    }
}
