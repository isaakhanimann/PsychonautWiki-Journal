import SwiftUI

struct ExperienceView: View {

    @ObservedObject var experience: Experience

    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var calendarWrapper: CalendarWrapper
    @EnvironmentObject var connectivity: Connectivity

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>

    @State private var selectedTitle: String
    @State private var isShowingAddIngestionSheet = false
    @State private var writtenText: String
    @State private var isKeyboardShowing = false

    var body: some View {
        List {
            Section(header: Text("Title")) {
                TextField("Title", text: $selectedTitle)
            }
            Section(header: ingestionHeader) {
                ForEach(experience.sortedIngestionsUnwrapped, content: IngestionRow.init)
                    .onDelete(perform: deleteIngestions)

                if experience.sortedIngestionsUnwrapped.isEmpty {
                    Button(action: addIngestion) {
                        Label("Add Ingestion", systemImage: "plus")
                            .foregroundColor(.accentColor)
                    }
                }
            }

            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Section(
                    header: Text("Timeline"),
                    footer: Text("Source: PsychonautWiki onset, comeup, peak & offset")
                ) {
                    HorizontalScaleView {
                        TimeLineContent(sortedIngestions: experience.sortedIngestionsUnwrapped)
                    }
                    .frame(height: 270)
                    .padding(.bottom, 5)
                    .listRowInsets(EdgeInsets())
                }
            }

            Section(header: Text("Notes")) {
                ZStack {
                    TextEditor(text: $writtenText)
                        .frame(minHeight: 200, alignment: .leading)
                        .foregroundColor(self.writtenText == placeholderString ? .secondary : .primary)
                        .onTapGesture {
                            if self.writtenText == placeholderString {
                                self.writtenText = ""
                            }
                        }
                    Text(writtenText).opacity(0).padding(.all, 8)
                }

            }

            if connectivity.activationState == .activated && connectivity.isWatchAppInstalled {
                SyncSection(experience: experience)
            }

            if connectivity.isPaired && !connectivity.isComplicationEnabled {
                NavigationLink(destination: AddFaceView()) {
                    Label("Add Watch Face", systemImage: "applewatch.watchface")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(selectedTitle)
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                if isKeyboardShowing {
                    Button {
                        hideKeyboard()
                        save()
                    } label: {
                        Text("Done")
                            .font(.callout)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation {
                isKeyboardShowing = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation {
                isKeyboardShowing = false
                if writtenText == "" {
                    writtenText = placeholderString
                }
            }
        }
        .onChange(of: selectedTitle) { _ in update() }
        .onChange(of: writtenText) { _ in update() }
        .onDisappear(perform: save)
        .sheet(isPresented: $isShowingAddIngestionSheet) {
            ChooseSubstanceView(
                substancesFile: storedFile.first!,
                dismiss: {isShowingAddIngestionSheet.toggle()},
                experience: experience
            )
            .environment(\.managedObjectContext, self.moc)
            .environmentObject(calendarWrapper)
            .environmentObject(connectivity)

            .accentColor(Color.blue)
        }
    }

    private func addIngestion() {
        isShowingAddIngestionSheet.toggle()
    }

    init(experience: Experience) {
        self.experience = experience
        _selectedTitle = State(wrappedValue: experience.titleUnwrapped)
        let initialText = experience.textUnwrapped
        _writtenText = State(wrappedValue: initialText == "" ? placeholderString : initialText)
    }

    private let placeholderString = "Enter some notes here"

    private func deleteIngestions(at offsets: IndexSet) {
        for offset in offsets {
            let ingestion = experience.sortedIngestionsUnwrapped[offset]
            connectivity.sendIngestionDelete(for: ingestion.identifier)
            moc.delete(ingestion)
        }
        save()
    }

    var ingestionHeader: some View {
        HStack {
            Text("Ingestions")
            Spacer()
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Button(action: addIngestion) {
                    Label("Add Ingestion", systemImage: "plus")
                        .labelStyle(IconOnlyLabelStyle())
                }
            }
        }
    }

    private func save() {
        if moc.hasChanges {
            calendarWrapper.createOrUpdateEventBeforeMocSave(from: experience)
            do {
                try moc.save()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    private func update() {
        experience.objectWillChange.send()
        experience.title = selectedTitle
        if writtenText != placeholderString {
            experience.text = writtenText
        }
    }
}

struct ExperienceView_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        ExperienceView(experience: helper.experiences.first!)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(Connectivity())
            .environmentObject(CalendarWrapper())
            .accentColor(Color.blue)
    }
}
