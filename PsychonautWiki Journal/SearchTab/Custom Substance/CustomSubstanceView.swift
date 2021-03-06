import SwiftUI

struct CustomSubstanceView: View {

    @ObservedObject var customSubstance: CustomSubstance
    @Environment(\.presentationMode) private var presentationMode
    @State private var isShowingConfirmation = false
    @EnvironmentObject private var sheetViewModel: SheetViewModel

    var body: some View {
        List {
            Section("Units") {
                Text(customSubstance.unitsUnwrapped)
            }
            Section {
                HStack {
                    Spacer()
                    Button {
                        isShowingConfirmation.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .foregroundColor(.red)
                    Spacer()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("Ingest") {
                    sheetViewModel.sheetToShow = .addIngestionFromCustom(custom: customSubstance)
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this substance?",
            isPresented: $isShowingConfirmation
        ) {
            Button("Delete Substance", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
                PersistenceController.shared.viewContext.delete(customSubstance)
                PersistenceController.shared.saveViewContext()
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle(customSubstance.nameUnwrapped)
    }
}
