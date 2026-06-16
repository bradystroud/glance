import SwiftUI

struct WeatherScene: View {
    let weather: Weather?

    var body: some View {
        if let w = weather {
            VStack(alignment: .leading, spacing: 18) {
                Text(AppSettings.placeName)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(Theme.secondary)
                current(w)
                if !w.hourly.isEmpty { hourly(w) }
                if !w.daily.isEmpty { daily(w) }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .foregroundStyle(Theme.primary)
        } else {
            ProgressView()
                .tint(Theme.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: Current conditions + stat grid

    private func current(_ w: Weather) -> some View {
        HStack(alignment: .center, spacing: 32) {
            HStack(spacing: 22) {
                Image(systemName: w.symbol)
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 104))
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(w.temperature.rounded()))°")
                        .font(.system(size: 92, weight: .bold, design: .rounded))
                    Text(w.summary)
                        .font(.title2)
                        .foregroundStyle(Theme.secondary)
                    Text("Feels like \(Int(w.apparent.rounded()))°")
                        .font(.headline)
                        .foregroundStyle(Theme.secondary)
                }
            }
            Spacer()
            statGrid(w)
        }
    }

    private func statGrid(_ w: Weather) -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 18) {
            stat("Humidity", "\(w.humidity)%", "humidity.fill")
            stat("Wind", "\(Int(w.windSpeed.rounded())) km/h", "wind")
            stat("UV index", "\(Int(w.uvIndex.rounded()))", "sun.max.fill")
            stat("Rain", "\(w.precipChance)%", "drop.fill")
            stat("Sunrise", time(w.sunrise), "sunrise.fill")
            stat("Sunset", time(w.sunset), "sunset.fill")
        }
        .frame(width: 360)
    }

    private func stat(_ label: String, _ value: String, _ icon: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon).font(.title3).foregroundStyle(Theme.accent)
            Text(value).font(.title3.weight(.semibold)).monospacedDigit()
            Text(label).font(.caption).foregroundStyle(Theme.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Hourly strip

    private func hourly(_ w: Weather) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(w.hourly.enumerated()), id: \.element.id) { index, h in
                VStack(spacing: 8) {
                    Text(index == 0 ? "Now" : hour(h.date))
                        .font(.subheadline)
                        .foregroundStyle(Theme.secondary)
                    Image(systemName: h.symbol)
                        .symbolRenderingMode(.multicolor)
                        .font(.title2)
                    Text("\(Int(h.temp.rounded()))°")
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: Multi-day forecast

    private func daily(_ w: Weather) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(w.daily.enumerated()), id: \.element.id) { index, d in
                HStack {
                    Text(index == 0 ? "Today" : weekday(d.date))
                        .font(.title3.weight(.medium))
                        .frame(width: 130, alignment: .leading)
                    Image(systemName: d.symbol)
                        .symbolRenderingMode(.multicolor)
                        .font(.title3)
                        .frame(width: 44)
                    Spacer()
                    Text("\(Int(d.low.rounded()))°")
                        .foregroundStyle(Theme.secondary)
                        .frame(width: 56, alignment: .trailing)
                        .monospacedDigit()
                    Text("\(Int(d.high.rounded()))°")
                        .font(.title3.weight(.semibold))
                        .frame(width: 56, alignment: .trailing)
                        .monospacedDigit()
                }
                .padding(.vertical, 9)
                if index < w.daily.count - 1 {
                    Divider().overlay(Theme.stroke)
                }
            }
        }
    }

    // MARK: Formatting

    private func hour(_ date: Date) -> String {
        date.formatted(.dateTime.hour())
    }
    private func weekday(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide))
    }
    private func time(_ date: Date?) -> String {
        guard let date else { return "—" }
        return date.formatted(.dateTime.hour().minute())
    }
}
