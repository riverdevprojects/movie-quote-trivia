import SwiftUI
import FirebaseCore

@main
struct MovieQuoteTriviaApp: App {
    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
