import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedWelcome") private var hasCompletedWelcome = false

    var body: some View {
        if hasCompletedWelcome {
            NavigationStack {
                DashboardView()
            }
        } else {
            WelcomeCarousel(hasCompleted: $hasCompletedWelcome)
        }
    }
}

#Preview {
    ContentView()
}