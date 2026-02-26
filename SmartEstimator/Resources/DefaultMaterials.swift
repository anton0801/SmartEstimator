import Foundation

struct DefaultMaterials {
    static let catalog: [Material] = [
        // Paint
        Material(name: "Interior Wall Paint",    category: .paint,    unitLabel: "L",      coveragePerUnit: 7.0,  pricePerUnit: 14.99, brand: "Generic"),
        Material(name: "Ceiling Paint",          category: .paint,    unitLabel: "L",      coveragePerUnit: 8.0,  pricePerUnit: 12.49, brand: "Generic"),
        Material(name: "Latex Paint Premium",    category: .paint,    unitLabel: "L",      coveragePerUnit: 9.0,  pricePerUnit: 19.99, brand: "Premium"),
        Material(name: "Exterior Facade Paint",  category: .paint,    unitLabel: "L",      coveragePerUnit: 6.5,  pricePerUnit: 22.50, brand: "Generic"),
        // Primer
        Material(name: "Universal Primer",       category: .primer,   unitLabel: "L",      coveragePerUnit: 10.0, pricePerUnit: 8.99,  brand: "Generic"),
        Material(name: "Deep Penetrating Primer",category: .primer,   unitLabel: "L",      coveragePerUnit: 8.0,  pricePerUnit: 11.99, brand: "Pro"),
        // Wallpaper
        Material(name: "Standard Wallpaper",     category: .wallpaper,unitLabel: "roll",   coveragePerUnit: 5.0,  pricePerUnit: 18.00, brand: "Generic"),
        Material(name: "Vinyl Wallpaper",        category: .wallpaper,unitLabel: "roll",   coveragePerUnit: 5.0,  pricePerUnit: 28.00, brand: "DuraWall"),
        Material(name: "Non-woven Wallpaper",    category: .wallpaper,unitLabel: "roll",   coveragePerUnit: 5.5,  pricePerUnit: 34.00, brand: "Premium"),
        // Tiles
        Material(name: "Ceramic Floor Tiles 60×60",   category: .tiles, unitLabel: "m²",  coveragePerUnit: 1.0,  pricePerUnit: 24.99, brand: "Generic"),
        Material(name: "Porcelain Wall Tiles 30×60",  category: .tiles, unitLabel: "m²",  coveragePerUnit: 1.0,  pricePerUnit: 32.99, brand: "Premium"),
        Material(name: "Mosaic Tiles",                category: .tiles, unitLabel: "m²",  coveragePerUnit: 1.0,  pricePerUnit: 45.00, brand: "Artisan"),
        Material(name: "Large Format Tiles 80×80",    category: .tiles, unitLabel: "m²",  coveragePerUnit: 1.0,  pricePerUnit: 54.00, brand: "Premium"),
        // Laminate
        Material(name: "Laminate Flooring 8mm",  category: .laminate, unitLabel: "m²",    coveragePerUnit: 1.0,  pricePerUnit: 18.00, brand: "Generic"),
        Material(name: "Laminate Flooring 12mm", category: .laminate, unitLabel: "m²",    coveragePerUnit: 1.0,  pricePerUnit: 26.00, brand: "HardFloor"),
        Material(name: "Herringbone Laminate",   category: .laminate, unitLabel: "m²",    coveragePerUnit: 1.0,  pricePerUnit: 38.00, brand: "Premium"),
        // Linoleum
        Material(name: "Commercial Linoleum 2mm",category: .linoleum, unitLabel: "m²",    coveragePerUnit: 1.0,  pricePerUnit: 12.00, brand: "Generic"),
        Material(name: "Residential Linoleum 3mm",category: .linoleum,unitLabel: "m²",    coveragePerUnit: 1.0,  pricePerUnit: 16.00, brand: "FlexFloor"),
        // Drywall
        Material(name: "Standard Drywall 12.5mm",category: .drywall,  unitLabel: "sheet", coveragePerUnit: 2.88, pricePerUnit: 11.50, brand: "Generic"),
        Material(name: "Moisture-Resistant Drywall",category: .drywall,unitLabel: "sheet",coveragePerUnit: 2.88, pricePerUnit: 16.00, brand: "AquaBoard"),
        Material(name: "Fire-Rated Drywall",     category: .drywall,  unitLabel: "sheet", coveragePerUnit: 2.88, pricePerUnit: 18.50, brand: "FireStop"),
        // Plaster
        Material(name: "Finishing Plaster 25kg", category: .plaster,  unitLabel: "bag",   coveragePerUnit: 7.0,  pricePerUnit: 14.00, brand: "Generic"),
        Material(name: "Lightweight Plaster 25kg",category: .plaster, unitLabel: "bag",   coveragePerUnit: 9.0,  pricePerUnit: 17.00, brand: "EasyMix"),
        // Putty
        Material(name: "Wall Putty 20kg",        category: .putty,    unitLabel: "bucket",coveragePerUnit: 15.0, pricePerUnit: 19.00, brand: "Generic"),
        Material(name: "Fine Surface Putty 20kg",category: .putty,    unitLabel: "bucket",coveragePerUnit: 18.0, pricePerUnit: 23.00, brand: "SmoothFinish"),
        // Adhesive
        Material(name: "Tile Adhesive C1 25kg",  category: .adhesive, unitLabel: "bag",   coveragePerUnit: 4.5,  pricePerUnit: 12.00, brand: "Generic"),
        Material(name: "Flex Tile Adhesive C2 25kg",category: .adhesive,unitLabel: "bag", coveragePerUnit: 5.0,  pricePerUnit: 18.00, brand: "FlexBond"),
        Material(name: "Wallpaper Adhesive 500g",category: .adhesive, unitLabel: "pack",  coveragePerUnit: 20.0, pricePerUnit: 8.50,  brand: "StickWell"),
    ]
}
