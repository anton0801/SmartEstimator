import SwiftUI

struct AddMaterialView: View {
    var editingMaterial: Material? = nil
    let onSave: (Material) -> Void
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var unitLabel: String = "m²"
    @State private var coveragePerUnit: String = "1.0"
    @State private var pricePerUnit: String = ""
    @State private var selectedCategory: MaterialCategory = .custom

    let unitOptions = ["m²", "L", "kg", "roll", "sheet", "bag", "pack", "bucket", "piece"]

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(pricePerUnit) != nil &&
        Double(coveragePerUnit) != nil
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.seSurface.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            SEFormField(label: "Material Name *", placeholder: "e.g. Oak Parquet", text: $name)
                            SEFormField(label: "Brand", placeholder: "Optional", text: $brand)
                        }
                        .seCard().padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Category").font(SEFont.caption()).foregroundColor(.seSubtext)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(MaterialCategory.allCases, id: \.self) { cat in
                                    Button {
                                        withAnimation { selectedCategory = cat }
                                    } label: {
                                        VStack(spacing: 4) {
                                            Image(systemName: cat.icon).font(.system(size: 16))
                                            Text(cat.rawValue)
                                                .font(.system(size: 10, design: .rounded))
                                                .lineLimit(1).minimumScaleFactor(0.7)
                                        }
                                        .foregroundColor(selectedCategory == cat ? .white : .seNavy)
                                        .padding(.vertical, 8).frame(maxWidth: .infinity)
                                        .background(selectedCategory == cat ? Color.seNavy : Color.seNavy.opacity(0.06))
                                        .cornerRadius(10)
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                            }
                        }
                        .seCard().padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Unit").font(SEFont.caption()).foregroundColor(.seSubtext)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(unitOptions, id: \.self) { opt in
                                            Button {
                                                withAnimation { unitLabel = opt }
                                            } label: {
                                                Text(opt).font(SEFont.caption())
                                                    .foregroundColor(unitLabel == opt ? .white : .seNavy)
                                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                                    .background(unitLabel == opt ? Color.seNavy : Color.seNavy.opacity(0.08))
                                                    .cornerRadius(20)
                                            }
                                            .buttonStyle(ScaleButtonStyle())
                                        }
                                    }
                                }
                            }
                            HStack(spacing: 12) {
                                SEFormField(label: "Coverage (m²/unit) *", placeholder: "1.0",
                                            text: $coveragePerUnit, keyboard: .decimalPad)
                                SEFormField(label: "Price per \(unitLabel) *", placeholder: "0.00",
                                            text: $pricePerUnit, keyboard: .decimalPad)
                            }
                        }
                        .seCard().padding(.horizontal, 20)

                        Button {
                            var mat = editingMaterial ?? Material(
                                name: "", category: .custom, unitLabel: "", coveragePerUnit: 0, pricePerUnit: 0
                            )
                            mat.name = name.trimmingCharacters(in: .whitespaces)
                            mat.brand = brand.trimmingCharacters(in: .whitespaces)
                            mat.category = selectedCategory
                            mat.unitLabel = unitLabel
                            mat.coveragePerUnit = Double(coveragePerUnit) ?? 1
                            mat.pricePerUnit = Double(pricePerUnit) ?? 0
                            mat.isCustom = true
                            onSave(mat)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Label(editingMaterial != nil ? "Update Material" : "Add to Library",
                                  systemImage: "plus.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SEPrimaryButtonStyle()).disabled(!isValid)
                        .padding(.horizontal, 20).padding(.bottom, 30)
                    }
                    .padding(.top, 12)
                }
            }
            .navigationTitle(editingMaterial != nil ? "Edit Material" : "New Material")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }.foregroundColor(.seNavy)
                }
            }
            .onAppear {
                if let m = editingMaterial {
                    name = m.name; brand = m.brand; unitLabel = m.unitLabel
                    coveragePerUnit = String(m.coveragePerUnit)
                    pricePerUnit = String(m.pricePerUnit)
                    selectedCategory = m.category
                }
            }
        }
    }
}

struct SEFormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(SEFont.caption()).foregroundColor(.seSubtext)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard).font(SEFont.body())
                .padding(10).background(Color.seSurface).cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.seNavy.opacity(0.12)))
        }
        .frame(maxWidth: .infinity)
    }
}
