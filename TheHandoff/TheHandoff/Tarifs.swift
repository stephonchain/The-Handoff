import Foundation

struct Tarifs {
    // Tarifs de base NGAP (au 01/07/2025)
    static let amiBase: Double = 3.15
    static let mciBase: Double = 5.00
    static let ifdBase: Double = 2.75

    static func calculatePrice(for act: Act) -> String {
        if act.code == "NR" {
            return "Non remb."
        }

        let price: Double
        switch act.code {
        case "AMI":
            price = amiBase * act.coef
        case "MCI":
            price = mciBase * act.coef
        case "IFD":
            price = ifdBase * act.coef
        default:
            price = amiBase * act.coef
        }

        return String(format: "%.2f €", price)
    }
}
