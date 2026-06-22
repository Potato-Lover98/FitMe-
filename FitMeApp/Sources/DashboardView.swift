import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "applewatch.radiowaves.left.and.right")
                .font(.system(size: 64))
                .foregroundStyle(.red)

            Text("FitMe+")
                .font(.largeTitle.bold())

            Text("FitMe+ runs entirely on Apple Watch.")
                .font(.headline)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                Label("Open the **Watch** app on your iPhone", systemImage: "1.circle.fill")
                Label("Tap **Available Apps**", systemImage: "2.circle.fill")
                Label("Find **FitMe+** and tap **Install**", systemImage: "3.circle.fill")
            }
            .font(.subheadline)
            .padding()
            .background(.gray.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button {
                if let url = URL(string: "https://apps.apple.com/app/id") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("Open App Store", systemImage: "arrow.up.forward.app")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(.white)
    }
}

#Preview {
    DashboardView()
}