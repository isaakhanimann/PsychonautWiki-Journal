import SwiftUI

struct ChooseTimeAndColor: View {

    let substance: Substance
    let administrationRoute: AdministrationRoute
    let dose: Double?
    let units: String?
    @EnvironmentObject private var sheetViewModel: SheetViewModel
    @EnvironmentObject private var toastViewModel: ToastViewModel
    @EnvironmentObject private var addIngestionContext: AddIngestionSheetContext
    @StateObject var viewModel = ViewModel()
    @State private var hasPressedDismiss = false

    var body: some View {
        if !hasPressedDismiss {
            ZStack(alignment: .bottom) {
                Form {
                    Section("Choose Time") {
                        DatePicker(
                            "Time",
                            selection: $viewModel.selectedTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                    }
                    Section("Choose Color") {
                        ColorPicker(selectedColor: $viewModel.selectedColor)
                    }
                }
                Button("Add Ingestion") {
                    viewModel.addIngestion(to: addIngestionContext.experience)
                    dismissSheet()
                    toastViewModel.showSuccessToast()
                }
                .buttonStyle(.primary)
                .padding()
            }
            .task {
                viewModel.substance = substance
                viewModel.administrationRoute = administrationRoute
                viewModel.dose = dose ?? 0
                viewModel.units = units
                viewModel.setDefaultColor()
            }
            .navigationBarTitle("Ingestion Time")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismissSheet()
                    }
                }
            }
        } else {
            Text("Please Swipe Down To Dismiss")
        }
    }

    private func dismissSheet() {
        sheetViewModel.dismiss()
        // this is here because there is a SwiftUI bug that sometimes prevents the sheet from being dismissable
        // the delay makes sure that one can't see the UI change in case the sheet is being dismissed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            hasPressedDismiss = true
        }
    }
}
