import SwiftUI

struct VitalDetailView: View {
    let card: VitalCard

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                header

                riskGauge

                whatItMeans

                relatedConditions

                recommendation

                miniChart
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle(card.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: card.icon)
                .font(.system(size: 36))
                .foregroundStyle(card.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(card.value)
                    .font(.title.bold())
                Text(card.unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Image(systemName: card.source.icon)
                    .font(.caption)
                    .foregroundStyle(card.source == .sensor ? .green : .secondary)
                Text(card.source.label)
                    .font(.caption2)
                    .foregroundStyle(card.source == .sensor ? .green : .secondary)
            }
        }
        .padding(8)
    }

    private var riskGauge: some View {
        VStack(spacing: 6) {
            Text("Risk Level")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(card.summary.riskLevel)
                .font(.title3.bold())
                .foregroundStyle(card.summary.riskColor)
            Text("\(card.summary.riskScore)%")
                .font(.caption)
                .foregroundStyle(card.summary.riskColor)

            RoundedRectangle(cornerRadius: 4)
                .fill(card.summary.riskColor)
                .frame(height: 6)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.gray.opacity(0.3))
                        .frame(width: max(0, 120 - CGFloat(card.summary.riskScore) * 1.2))
                }
                .frame(maxWidth: .infinity)
        }
        .padding(10)
        .background(.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var whatItMeans: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("What This Means", systemImage: "info.circle.fill")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text(card.summary.whatItMeans)
                .font(.caption2)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var relatedConditions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Related Conditions", systemImage: "cross.case.fill")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            ForEach(card.summary.relatedConditions, id: \.self) { condition in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                        .foregroundStyle(.orange)
                        .padding(.top, 4)
                    Text(condition)
                        .font(.caption2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var recommendation: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Recommendation", systemImage: "lightbulb.fill")
                .font(.caption.bold())
                .foregroundStyle(.yellow)
            Text(card.summary.recommendation)
                .font(.caption2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.yellow.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var miniChart: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Last 10 Hours", systemImage: "chart.bar.fill")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            HStack(alignment: .bottom, spacing: 4) {
                ForEach([0.4, 0.55, 0.35, 0.65, 0.5, 0.8, 0.6, 0.7, 0.45, 0.55], id: \.self) { h in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [card.color, card.color.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: max(8, CGFloat(h) * 80))
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 80)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        VitalDetailView(card: VitalCard.mockData[0])
    }
}