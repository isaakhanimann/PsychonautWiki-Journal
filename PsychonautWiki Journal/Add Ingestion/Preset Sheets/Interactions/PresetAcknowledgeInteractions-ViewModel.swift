import Foundation
import Algorithms

extension PresetAcknowledgeInteractionsView {

    class ViewModel: ObservableObject, InteractionAlertable {

        @Published var dangerousIngestions: [Ingestion] = []
        @Published var unsafeIngestions: [Ingestion] = []
        @Published var uncertainIngestions: [Ingestion] = []
        @Published var isShowingAlert = false
        @Published var isShowingNext = false

        func hideAlert() {
            isShowingAlert.toggle()
        }

        func showNext() {
            isShowingNext.toggle()
        }

        func checkInteractionsWith(preset: Preset) {
            let recentIngestions = PersistenceController.shared.getRecentIngestions()
            setInteractionIngestions(from: recentIngestions, substances: preset.substances)
        }

        func setInteractionIngestions(from ingestions: [Ingestion], substances: [Substance]) {
            let chunkedIngestions = ingestions.chunked { ing in
                ing.getInteraction(with: substances)
            }
            for chunk in chunkedIngestions {
                let type = chunk.0
                let sameTypeIngs = getDistinctSubstanceLatestIngestion(from: chunk.1)
                switch type {
                case .none:
                    break
                case .uncertain:
                    self.uncertainIngestions = sameTypeIngs
                case .unsafe:
                    self.unsafeIngestions = sameTypeIngs
                case .dangerous:
                    self.dangerousIngestions = sameTypeIngs
                }
            }
        }

        func getDistinctSubstanceLatestIngestion(from ingestions: Array<Ingestion>.SubSequence) -> [Ingestion] {
            let sortedIngestions  = ingestions.sorted().reversed()
            var distinctIngestions = [Ingestion]()
            var seenSubstanceNames: Set<String> = []
            for ingestion in sortedIngestions {
                let name = ingestion.substanceNameUnwrapped
                if !seenSubstanceNames.contains(name) {
                    distinctIngestions.append(ingestion)
                    seenSubstanceNames.insert(name)
                }
            }
            return distinctIngestions
        }

        func pressNext() {
            if !dangerousIngestions.isEmpty || !unsafeIngestions.isEmpty || !uncertainIngestions.isEmpty {
                isShowingAlert = true
            } else {
                isShowingNext = true
            }
        }
    }
}