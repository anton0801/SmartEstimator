import SwiftUI
import Combine

class MaterialLibraryViewModel: ObservableObject {
    @Published var allMaterials: [Material] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: MaterialCategory? = nil

    private let persistence = PersistenceService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        persistence.$customMaterials
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.reload() }
            .store(in: &cancellables)
        reload()
    }

    func reload() { allMaterials = persistence.allMaterials() }

    var filtered: [Material] {
        allMaterials.filter { mat in
            let matchesSearch = searchText.isEmpty ||
                mat.name.localizedCaseInsensitiveContains(searchText) ||
                mat.brand.localizedCaseInsensitiveContains(searchText)
            let matchesCat = selectedCategory == nil || mat.category == selectedCategory
            return matchesSearch && matchesCat
        }
    }

    func saveMaterial(_ m: Material)  { persistence.save(material: m) }
    func deleteMaterial(_ m: Material) {
        guard m.isCustom else { return }
        persistence.delete(material: m)
    }
}
