import Foundation

enum WeatherService {
    static func fetch(latitude: Double, longitude: Double) async -> Weather? {
        var c = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        c.queryItems = [
            .init(name: "latitude", value: String(latitude)),
            .init(name: "longitude", value: String(longitude)),
            .init(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m"),
            .init(name: "hourly", value: "temperature_2m,weather_code"),
            .init(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max"),
            .init(name: "timezone", value: "auto"),
            .init(name: "forecast_days", value: "6"),
        ]
        guard let url = c.url,
              let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let cur = json["current"] as? [String: Any],
              let daily = json["daily"] as? [String: Any] else { return nil }

        // Open-Meteo returns naive local times (timezone=auto) → parse in device-local tz.
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm"   // hourly, sunrise, sunset
        let dayFmt = DateFormatter()
        dayFmt.dateFormat = "yyyy-MM-dd"        // daily rows are date-only

        let temp = cur["temperature_2m"] as? Double ?? 0
        let apparent = cur["apparent_temperature"] as? Double ?? temp
        let code = cur["weather_code"] as? Int ?? 0
        let humidity = cur["relative_humidity_2m"] as? Int ?? 0
        let wind = cur["wind_speed_10m"] as? Double ?? 0

        // Daily forecast
        let dayCodes = daily["weather_code"] as? [Int] ?? []
        let highs = daily["temperature_2m_max"] as? [Double] ?? []
        let lows = daily["temperature_2m_min"] as? [Double] ?? []
        let dayTimes = daily["time"] as? [String] ?? []
        let sunrises = daily["sunrise"] as? [String] ?? []
        let sunsets = daily["sunset"] as? [String] ?? []
        let uvs = daily["uv_index_max"] as? [Double] ?? []
        let precips = daily["precipitation_probability_max"] as? [Int] ?? []

        var days: [DayForecast] = []
        let dayCount = min(highs.count, min(lows.count, dayCodes.count))
        for i in 0..<dayCount {
            let date = (i < dayTimes.count ? dayFmt.date(from: dayTimes[i]) : nil) ?? Date()
            days.append(DayForecast(id: i, date: date, high: highs[i], low: lows[i], code: dayCodes[i]))
        }

        // Hourly forecast — next 8 hours from now
        var hours: [HourForecast] = []
        if let hourly = json["hourly"] as? [String: Any],
           let times = hourly["time"] as? [String],
           let temps = hourly["temperature_2m"] as? [Double],
           let codes = hourly["weather_code"] as? [Int] {
            let parsed = times.map { fmt.date(from: $0) ?? .distantPast }
            let now = Date()
            let start = parsed.firstIndex(where: { $0 >= now }) ?? 0
            let end = min(start + 8, min(temps.count, codes.count))
            if start < end {
                for i in start..<end {
                    hours.append(HourForecast(id: i, date: parsed[i], temp: temps[i], code: codes[i]))
                }
            }
        }

        return Weather(
            temperature: temp,
            apparent: apparent,
            code: code,
            humidity: humidity,
            windSpeed: wind,
            high: highs.first ?? temp,
            low: lows.first ?? temp,
            sunrise: sunrises.first.flatMap { fmt.date(from: $0) },
            sunset: sunsets.first.flatMap { fmt.date(from: $0) },
            uvIndex: uvs.first ?? 0,
            precipChance: precips.first ?? 0,
            hourly: hours,
            daily: days
        )
    }
}
