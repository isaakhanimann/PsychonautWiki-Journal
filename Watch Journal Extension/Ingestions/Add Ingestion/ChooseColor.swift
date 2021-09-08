import SwiftUI

struct ChooseColor: View {

    let substance: Substance
    let administrationRoute: Roa.AdministrationRoute
    let dose: Double
    let dismiss: () -> Void
    let experience: Experience

    @Environment(\.managedObjectContext) var moc

    @State private var selectedColor: Ingestion.IngestionColor

    init(
        substance: Substance,
        administrationRoute: Roa.AdministrationRoute,
        dose: Double,
        dismiss: @escaping () -> Void,
        experience: Experience
    ) {
        self.substance = substance
        self.administrationRoute = administrationRoute
        self.dose = dose
        self.dismiss = dismiss
        self.experience = experience

        self._selectedColor = State(wrappedValue: Ingestion.IngestionColor.allCases.randomElement()!)
        let defaults = UserDefaults.standard
        let savedObject = defaults.object(forKey: substance.nameUnwrapped)
        if let savedColorString = savedObject as? String {
            if let savedColor = Ingestion.IngestionColor(rawValue: savedColorString) {
                self._selectedColor = State(wrappedValue: savedColor)
            }
        }
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Color")) {
                    LazyVGrid(columns: colorColumns) {
                        ForEach(Ingestion.IngestionColor.allCases, id: \.self, content: colorButton)
                    }
                    .padding(.vertical)
                }

            }
            Button("Add Ingestion", action: addIngestion)
                .padding()
        }

        .navigationBarTitle("Choose Color")
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.cancellationAction) {
                Button("Cancel", action: dismiss)
            }
        }
    }

    private func addIngestion() {
        let ingestion = Ingestion(context: moc)
        ingestion.experience = experience
        ingestion.time = Date()
        ingestion.dose = dose
        ingestion.administrationRoute = administrationRoute.rawValue
        ingestion.substanceCopy = SubstanceCopy(basedOn: substance, context: moc)
        ingestion.color = selectedColor.rawValue
        substance.lastUsedDate = Date()
        substance.category!.file!.lastUsedSubstance = substance

        try? moc.save()
        let defaults = UserDefaults.standard
        defaults.setValue(selectedColor.rawValue, forKey: substance.nameUnwrapped)
        dismiss()
    }

    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]

    private func colorButton(for color: Ingestion.IngestionColor) -> some View {
        ZStack {
            Color.from(ingestionColor: color)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)

            if color == selectedColor {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            selectedColor = color
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            color == selectedColor
                ? [.isButton, .isSelected]
                : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(color.rawValue))
    }
}

struct ChooseTimeAndColor_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        return ChooseColor(
            substance: helper.substance,
            administrationRoute: helper.substance.administrationRoutesUnwrapped.first!,
            dose: 10,
            dismiss: {},
            experience: helper.experiences.first!
        )
    }
}