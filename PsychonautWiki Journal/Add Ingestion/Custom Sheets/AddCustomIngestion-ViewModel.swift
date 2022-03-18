import Foundation
import CoreData

extension AddCustomIngestionView {
    class ViewModel: ObservableObject {

        @Published var selectedDoseText = ""
        @Published var selectedTime = Date()
        @Published var selectedColor = IngestionColor.allCases.randomElement() ?? IngestionColor.blue
        @Published var selectedAdministrationRoute = AdministrationRoute.oral
        @Published var lastExperience: Experience?
        var selectedDose: Double? {
            Double(selectedDoseText)
        }
        var customSubstance: CustomSubstance?

        func addIngestion(to experience: Experience) {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let ingestion = createIngestion()
                experience.addToIngestions(ingestion)
                try? context.save()
            }
        }

        func addIngestionToNewExperience() {
            let context = PersistenceController.shared.viewContext
            context.performAndWait {
                let newExperience = Experience(context: context)
                let now = Date()
                newExperience.creationDate = now
                newExperience.title = now.asDateString
                let ingestion = createIngestion()
                newExperience.addToIngestions(ingestion)
                try? context.save()
            }
        }

        private func createIngestion() -> Ingestion {
            let context = PersistenceController.shared.viewContext
            let ingestion = Ingestion(context: context)
            ingestion.identifier = UUID()
            ingestion.time = selectedTime
            ingestion.dose = selectedDose ?? 0
            ingestion.units = customSubstance?.units
            ingestion.administrationRoute = selectedAdministrationRoute.rawValue
            ingestion.substanceName = customSubstance?.name
            ingestion.color = selectedColor.rawValue
            return ingestion
        }
    }
}