import SwiftUI

struct IngestionRow: View {

    @ObservedObject var ingestion: Ingestion

    var body: some View {
        NavigationLink(destination: EditIngestionView(ingestion: ingestion)) {
            HStack {
                Image(systemName: "circle.fill")
                    .font(.title2)
                    .foregroundColor(ingestion.swiftUIColorUnwrapped)
                VStack(alignment: .leading) {
                    Text(ingestion.substanceNameUnwrapped)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("\(ingestion.doseInfoString) \(ingestion.administrationRouteUnwrapped.rawValue)")
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(ingestion.timeUnwrapped, format: Date.FormatStyle().hour().minute())
                    .foregroundColor(.primary)
            }
        }
    }
}

struct IngestionRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            IngestionRow(ingestion: PreviewHelper.shared.experiences.first!.sortedIngestionsUnwrapped.first!)
        }
        .accentColor(Color.blue)
    }
}
