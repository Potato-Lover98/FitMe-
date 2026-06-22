import SwiftUI

struct DashboardView: View {
    @State private var viewModel = SensorViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                sourceBanner

                ForEach(viewModel.cards) { card in
                    NavigationLink(destination: VitalDetailView(card: card)) {
                        VitalCardView(card: card)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Today")
        .task {
            await viewModel.requestHealthKitAndLoad()
        }
        .onDisappear {
            viewModel.loadMockData()
        }
    }

    @ViewBuilder
    private var sourceBanner: some View {
        if viewModel.isRefreshing {
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.6)
                Text("Reading sensors...")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 4)
        } else if viewModel.isLive {
            HStack(spacing: 4) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.caption2)
                    .foregroundStyle(.green)
                Text("Live sensor data")
                    .font(.caption2)
                    .foregroundStyle(.green)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 4)
        } else if viewModel.authorizationNeeded {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
                Text("Showing mock data — HealthKit unavailable")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 4)
        }
    }
}

struct VitalCardView: View {
    let card: VitalCard

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: card.icon)
                .font(.title2)
                .foregroundStyle(card.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(card.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(card.value)
                        .font(.title3.bold())
                    Text(card.unit)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: card.source.icon)
                        .font(.system(size: 7))
                        .foregroundStyle(card.source == .sensor ? .green : .secondary)
                    Text(card.status.label)
                        .font(.caption2.bold())
                        .foregroundStyle(card.status.color)
                }
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(10)
        .background(.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}