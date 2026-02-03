import SwiftUI

@MainActor
class DataStore: ObservableObject {
    static let shared = DataStore()

    @Published var categories: [Category] = []
    @Published var acts: [Act] = []

    init() {
        loadData()
    }

    // MARK: - Queries

    func actsForCategory(_ categoryID: String) -> [Act] {
        acts.filter { $0.categoryID == categoryID }
    }

    func searchActs(_ query: String) -> [Act] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return [] }

        return acts.filter { act in
            act.title.lowercased().contains(trimmed)
            || act.code.lowercased().contains(trimmed)
            || act.notes.lowercased().contains(trimmed)
        }
    }

    // MARK: - Load Data

    private func loadData() {
        categories = [
            Category(
                id: "soins_courants",
                name: "Soins courants",
                icon: "heart.fill",
                color: .pastelRose,
                gradientColors: [.pastelRose, .pastelRoseDeep]
            ),
            Category(
                id: "perfusions",
                name: "Perfusions",
                icon: "ivfluid.bag.fill",
                color: .pastelLavande,
                gradientColors: [.pastelLavande, .pastelLavandeDeep]
            ),
            Category(
                id: "pansements",
                name: "Pansements",
                icon: "bandage.fill",
                color: .pastelMenthe,
                gradientColors: [.pastelMenthe, .pastelMentheDeep]
            ),
            Category(
                id: "hygiene",
                name: "Hygiène",
                icon: "hands.and.sparkles.fill",
                color: .pastelCiel,
                gradientColors: [.pastelCiel, .pastelCielDeep]
            ),
            Category(
                id: "surveillance",
                name: "Surveillance",
                icon: "waveform.path.ecg",
                color: .pastelSoleil,
                gradientColors: [.pastelSoleil, .pastelSoleilDeep]
            ),
            Category(
                id: "prelevements",
                name: "Prélèvements",
                icon: "syringe.fill",
                color: .pastelPeche,
                gradientColors: [.pastelPeche, .pastelPecheDeep]
            )
        ]

        acts = [
            // Soins courants
            Act(categoryID: "soins_courants", title: "Injection sous-cutanée", code: "AMI", coef: 1, notes: "Injection SC simple"),
            Act(categoryID: "soins_courants", title: "Injection intramusculaire", code: "AMI", coef: 1, notes: "Injection IM"),
            Act(categoryID: "soins_courants", title: "Injection intraveineuse directe", code: "AMI", coef: 2, notes: "IV directe isolée"),
            Act(categoryID: "soins_courants", title: "Pansement simple", code: "AMI", coef: 2, notes: "Plaie superficielle"),
            Act(categoryID: "soins_courants", title: "Prise de sang", code: "AMI", coef: 1.5, notes: "Prélèvement veineux"),

            // Perfusions
            Act(categoryID: "perfusions", title: "Perfusion IV courte (< 1h)", code: "AMI", coef: 3, notes: "Durée < 1 heure"),
            Act(categoryID: "perfusions", title: "Perfusion IV longue (> 1h)", code: "AMI", coef: 4, notes: "Durée > 1 heure"),
            Act(categoryID: "perfusions", title: "Surveillance de perfusion", code: "AMI", coef: 2, notes: "Passage de surveillance"),
            Act(categoryID: "perfusions", title: "Perfusion sous-cutanée", code: "AMI", coef: 3, notes: "Hypodermoclyse"),

            // Pansements
            Act(categoryID: "pansements", title: "Pansement lourd et complexe", code: "AMI", coef: 4, notes: "Escarre, ulcère étendu"),
            Act(categoryID: "pansements", title: "Pansement d'ulcère", code: "AMI", coef: 3, notes: "Ulcère de jambe"),
            Act(categoryID: "pansements", title: "Pansement de brûlure", code: "AMI", coef: 3, notes: "Brûlure étendue"),
            Act(categoryID: "pansements", title: "Ablation de fils ou agrafes", code: "AMI", coef: 2, notes: "Retrait sutures"),

            // Hygiène
            Act(categoryID: "hygiene", title: "Toilette complète au lit", code: "AMI", coef: 2.5, notes: "Patient dépendant"),
            Act(categoryID: "hygiene", title: "Aide à la douche", code: "AMI", coef: 1.5, notes: "Patient semi-autonome"),
            Act(categoryID: "hygiene", title: "Soins de nursing", code: "NR", coef: 0, notes: "Non remboursable"),

            // Surveillance
            Act(categoryID: "surveillance", title: "Surveillance hebdomadaire", code: "AMI", coef: 1, notes: "Patient chronique"),
            Act(categoryID: "surveillance", title: "Prise de constantes", code: "AMI", coef: 1, notes: "TA, pouls, température"),
            Act(categoryID: "surveillance", title: "Glycémie capillaire", code: "AMI", coef: 1, notes: "Dextro"),

            // Prélèvements
            Act(categoryID: "prelevements", title: "Prélèvement sanguin", code: "AMI", coef: 1.5, notes: "Prise de sang"),
            Act(categoryID: "prelevements", title: "Prélèvement urinaire", code: "AMI", coef: 1, notes: "ECBU"),
            Act(categoryID: "prelevements", title: "Prélèvement nasal", code: "AMI", coef: 1, notes: "Écouvillon naso-pharyngé")
        ]
    }
}
