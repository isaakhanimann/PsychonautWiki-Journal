import SwiftUI
import ClockKit

struct AddFaceView: View {

    @State private var isLoading = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image("X-Large_email")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 10)

                Button {
                    isLoading = true
                    addFaceWrapper(withName: "X-Large")
                } label: {
                    Image(colorScheme == .dark ? "Add Watch Face Dark" : "Add Watch Face Light")

                }

                Spacer()

            }

            if isLoading {
                ProgressView()
            }
        }
    }

    private func addFaceWrapper(withName: String) {
        if let watchfaceURL = Bundle.main.url(forResource: withName, withExtension: "watchface") {
            CLKWatchFaceLibrary().addWatchFace(at: watchfaceURL, completionHandler: { (error: Error?) in
                if let nsError = error as NSError?,
                   nsError.code == CLKWatchFaceLibrary.ErrorCode.faceNotAvailable.rawValue {
                    print(nsError)
                }
                isLoading = false
            })
        }
    }
}

struct AddFaceView_Previews: PreviewProvider {
    static var previews: some View {
        AddFaceView()
    }
}