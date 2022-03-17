import SwiftUI

struct PresetChooseDoseView: View {

    let preset: Preset
    let dismiss: (AddResult) -> Void
    let experience: Experience?
    @State private var dose = 1.0
    @State private var doseText = "1"

    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section("Choose Dose") {
                    HStack {
                        TextField("Enter Dose", text: $doseText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        Text(preset.unitsUnwrapped)
                    }
                    .font(.title)
                    .onChange(of: doseText) { _ in
                        if let doseUnwrapped = Double(doseText) {
                            dose = doseUnwrapped
                        }
                    }
                }
                ForEach(preset.componentsUnwrapped) { com in
                    DoseConversionSectionView(
                        presetComponent: com,
                        presetDose: $dose
                    )
                }
                bottomPadding
            }
            NavigationLink(
                destination: PresetChooseTimeAndColorsView(
                    preset: preset,
                    dose: dose,
                    dismiss: dismiss,
                    experience: experience
                ),
                label: {
                    Text("Next")
                        .primaryButtonText()
                }
            )
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss(.cancelled)
                }
            }
        }
        .navigationTitle(preset.nameUnwrapped)
    }

    var bottomPadding: some View {
        Section(header: Text("")) {
            EmptyView()
        }
    }
}

struct PresetChooseDoseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PresetChooseDoseView(
                preset: PreviewHelper.shared.preset,
                dismiss: { _ in },
                experience: nil
            )
        }
    }
}