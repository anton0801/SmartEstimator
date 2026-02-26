import PDFKit
import UIKit
import SwiftUI

class PDFExportService {
    static func generatePDF(for estimate: RoomEstimate, currency: String) -> Data {
        let pageWidth: CGFloat  = 595
        let pageHeight: CGFloat = 842
        let margin: CGFloat     = 40

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        return renderer.pdfData { ctx in
            ctx.beginPage()

            let navy  = UIColor(Color.seNavy)
            let amber = UIColor(Color.seAmber)
            let gray  = UIColor.systemGray
            let black = UIColor.black
            let white = UIColor.white

            var y: CGFloat = margin

            // Header bar
            navy.setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: pageWidth, height: 80))

            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: white
            ]
            "Smart Estimator".draw(at: CGPoint(x: margin, y: 26), withAttributes: titleAttr)

            let dateStr = DateFormatter.localizedString(from: estimate.createdAt, dateStyle: .medium, timeStyle: .none)
            let subAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: white.withAlphaComponent(0.7)
            ]
            dateStr.draw(at: CGPoint(x: margin, y: 52), withAttributes: subAttr)

            y = 100

            // Estimate name
            let nameTitleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: navy
            ]
            estimate.name.draw(at: CGPoint(x: margin, y: y), withAttributes: nameTitleAttr)
            y += 28

            // Room info
            let infoAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: gray
            ]
            let info = "\(estimate.roomType.rawValue)  ·  \(String(format: "%.2f", estimate.length))m × \(String(format: "%.2f", estimate.width))m  ·  Area: \(String(format: "%.2f", estimate.areaSqM)) m²"
            info.draw(at: CGPoint(x: margin, y: y), withAttributes: infoAttr)
            y += 24

            // Amber divider
            amber.setFill()
            UIRectFill(CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: 2))
            y += 14

            // Table header
            let colMat:   CGFloat = margin
            let colQty:   CGFloat = pageWidth - margin - 240
            let colUnit:  CGFloat = pageWidth - margin - 160
            let colTotal: CGFloat = pageWidth - margin - 80

            let hAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .bold),
                .foregroundColor: navy
            ]
            "Material".draw(at: CGPoint(x: colMat, y: y), withAttributes: hAttr)
            "Qty".draw(at: CGPoint(x: colQty, y: y), withAttributes: hAttr)
            "Unit Price".draw(at: CGPoint(x: colUnit, y: y), withAttributes: hAttr)
            "Total".draw(at: CGPoint(x: colTotal, y: y), withAttributes: hAttr)
            y += 20

            UIColor.lightGray.setFill()
            UIRectFill(CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: 0.5))
            y += 8

            let rowAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: black
            ]
            let subRowAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: gray
            ]

            for (i, item) in estimate.items.enumerated() {
                if i % 2 == 0 {
                    UIColor(white: 0.97, alpha: 1).setFill()
                    UIRectFill(CGRect(x: margin, y: y - 4, width: pageWidth - margin * 2, height: 36))
                }
                item.material.name.draw(at: CGPoint(x: colMat, y: y), withAttributes: rowAttr)
                item.material.brand.draw(at: CGPoint(x: colMat, y: y + 14), withAttributes: subRowAttr)
                "\(item.unitsNeeded) \(item.material.unitLabel)".draw(at: CGPoint(x: colQty, y: y), withAttributes: rowAttr)
                "\(currency)\(String(format: "%.2f", item.material.pricePerUnit))".draw(at: CGPoint(x: colUnit, y: y), withAttributes: rowAttr)
                "\(currency)\(String(format: "%.2f", item.totalCost))".draw(at: CGPoint(x: colTotal, y: y), withAttributes: rowAttr)
                y += 36

                if y > pageHeight - 100 {
                    ctx.beginPage()
                    y = margin
                }
            }

            y += 10
            UIColor.lightGray.setFill()
            UIRectFill(CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: 0.5))
            y += 12

            let totalAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                .foregroundColor: navy
            ]
            let totalLabelAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: navy
            ]
            "Grand Total:".draw(at: CGPoint(x: margin, y: y), withAttributes: totalLabelAttr)
            let totalStr = "\(currency)\(String(format: "%.2f", estimate.totalCost))"
            let totalSize = totalStr.size(withAttributes: totalAttr)
            totalStr.draw(at: CGPoint(x: pageWidth - margin - totalSize.width, y: y), withAttributes: totalAttr)

            // Footer
            let footerAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9),
                .foregroundColor: UIColor.lightGray
            ]
            "Generated by Smart Estimator  ·  Prices include waste buffer"
                .draw(at: CGPoint(x: margin, y: pageHeight - 30), withAttributes: footerAttr)
        }
    }
}
