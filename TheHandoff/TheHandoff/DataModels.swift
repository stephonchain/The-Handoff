import SwiftUI

// MARK: - Category

struct Category: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let gradientColors: [Color]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Act

struct Act: Identifiable, Hashable {
    let id: UUID
    let categoryID: String
    let title: String
    let code: String
    let coef: Double
    let notes: String

    init(id: UUID = UUID(), categoryID: String, title: String, code: String, coef: Double, notes: String = "") {
        self.id = id
        self.categoryID = categoryID
        self.title = title
        self.code = code
        self.coef = coef
        self.notes = notes
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Act, rhs: Act) -> Bool {
        lhs.id == rhs.id
    }
}
