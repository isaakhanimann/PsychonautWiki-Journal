import Foundation
import CoreData

extension ExperiencesTab {
    struct ExperienceSection: Identifiable, Comparable {
        static func < (lhs: ExperienceSection, rhs: ExperienceSection) -> Bool {
            lhs.year > rhs.year
        }
        // swiftlint:disable identifier_name
        var id: Int {
            year
        }
        let year: Int
        let experiences: [Experience]
    }
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        @Published var sections: [ExperienceSection] = []
        @Published var selection: Experience?
        @Published var hasExperiences = false
        @Published var searchText = "" {
            didSet {
                setupFetchRequestPredicateAndFetch()
            }
        }
        private var experiences: [Experience] = []
        private let experienceFetchController: NSFetchedResultsController<Experience>!

        override init() {
            let fetchRequest = Experience.fetchRequest()
            fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.creationDate, ascending: false) ]
            experienceFetchController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: PersistenceController.shared.viewContext,
                sectionNameKeyPath: nil, cacheName: nil
            )
            super.init()
            experienceFetchController.delegate = self
            do {
                try experienceFetchController.performFetch()
                self.experiences = experienceFetchController?.fetchedObjects ?? []
                self.hasExperiences = !experiences.isEmpty
                self.sections = ViewModel.getSections(experiences: experiences)
            } catch {
                NSLog("Error: could not fetch Experiences")
            }
        }

        private static func getSections(experiences: [Experience]) -> [ExperienceSection] {
            var sections: [ExperienceSection] = []
            var groupedByYear: [Int: [Experience]]
            groupedByYear = Dictionary(grouping: experiences) { exp in
                exp.year
            }
            for (expYear, expsInYear) in groupedByYear {
                sections.append(ExperienceSection(year: expYear, experiences: expsInYear.sorted()))
            }
            return sections.sorted()
        }

        private func setupFetchRequestPredicateAndFetch() {
            if searchText == "" {
                experienceFetchController?.fetchRequest.predicate = nil
            } else {
                let predicateTitle = NSPredicate(
                    format: "title CONTAINS[cd] %@",
                    searchText as CVarArg
                )
                let predicateSubstance = NSPredicate(
                    format: "%K.%K CONTAINS[cd] %@",
                    #keyPath(Experience.ingestions),
                    #keyPath(Ingestion.substanceName),
                    searchText as CVarArg
                )
                let predicateCompound = NSCompoundPredicate(
                    orPredicateWithSubpredicates: [predicateTitle, predicateSubstance]
                )
                experienceFetchController?.fetchRequest.predicate = predicateCompound
            }
            try? experienceFetchController?.performFetch()
            self.experiences = experienceFetchController?.fetchedObjects ?? []
            sections = Self.getSections(experiences: experiences)
        }

        public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            guard let exps = controller.fetchedObjects as? [Experience] else {return}
            self.experiences = exps
            self.hasExperiences = !exps.isEmpty
            self.sections = ViewModel.getSections(experiences: exps)
        }

        func addExperience() {
            let viewContext = PersistenceController.shared.viewContext
            let experience = Experience(context: viewContext)
            let now = Date()
            experience.creationDate = now
            experience.title = now.asDateString
            try? viewContext.save()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.selection = experience
            }
        }

        func delete(experience: Experience) {
            let viewContext = PersistenceController.shared.viewContext
            viewContext.delete(experience)
            if viewContext.hasChanges {
                try? viewContext.save()
            }
        }
    }
}
