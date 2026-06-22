import SwiftUI

struct WelcomeCarousel: View {
    @Binding var hasCompleted: Bool
    @State private var currentIndex = 0

    private let pages: WelcomePage = [
        WelcomePage(
            icon: "heart.text.square.fill",
            iconColor: .red,
            title: "Welcome to FitMe+",
            subtitle: "Your health, on your wrist.",
            description: "Track blood pressure, temperature, heart rate, SpO₂ and more — all in one place."
        ),
        WelcomePage(
            icon: "stethoscope",
            iconColor: .blue,
            title: "Smart Vitals",
            subtitle: "Understand every reading.",
            description: "Tap any vital to see what it means, your risk level, and related conditions — explained simply."
        ),
        WelcomePage(
            icon: "brain.head.profile",
            iconColor: .purple,
            title: "On-Device AI",
            subtitle: "Fever & risk engine.",
            description: "A custom ML model runs entirely on your Watch — no cloud, fully private, instant insights."
        ),
        WelcomePage(
            icon: "bell.badge.fill",
            iconColor: .orange,
            title: "Stay Notified",
            subtitle: "Alerts that matter.",
            description: "Get warned about high BP, fever onset, low SpO₂, and irregular rhythms before they escalate."
        ),
    ]

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(pages.enumerated()), id: \.offset) { idx, page in
                WelcomePageView(page: page, isLast: idx == pages.count - 1) {
                    hasCompleted = true
                }
                .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}

struct WelcomePage: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
}

struct WelcomePageView: View {
    let page: WelcomePage
    let isLast: Bool
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 56))
                .foregroundStyle(page.iconColor)
            Text(page.title)
                .font(.title3.bold())
            Text(page.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(page.description)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
            Spacer()
            if isLast {
                Button(action: onStart) {
                    Text("Get Started")
                        .font(.caption.bold())
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(.red)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            Spacer()
                .frame(height: 20)
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    WelcomeCarousel(hasCompleted: .constant(false))
}