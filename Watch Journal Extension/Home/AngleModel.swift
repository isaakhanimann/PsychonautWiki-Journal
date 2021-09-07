import SwiftUI

struct AngleModel {

    let ingestionPoint: Angle
    let onsetStart: Angle
    let peakStart: Angle
    let peakEnd: Angle
    let offsetEnd: Angle

    init(ingestion: Ingestion) {
        self.ingestionPoint = AngleModel.getAngle(from: ingestion.timeUnwrapped)

        let durations = ingestion.substanceCopy!.getDuration(for: ingestion.administrationRouteUnwrapped)!
        let weight = ingestion.horizontalWeight

        let ingestionTime = ingestion.timeUnwrapped
        let onsetStartTime = ingestionTime.addingTimeInterval(durations.onset!.oneValue(at: 0.5))
        let peakStartTime = onsetStartTime.addingTimeInterval(durations.comeup!.oneValue(at: 0.5))
        let peakEndTime = peakStartTime.addingTimeInterval(durations.peak!.oneValue(at: weight))
        let offsetEndTime = peakStartTime.addingTimeInterval(durations.offset!.oneValue(at: weight))

        self.onsetStart = AngleModel.getAngle(from: ingestion.timeUnwrapped)
        self.peakStart = AngleModel.getAngle(from: peakStartTime)
        self.peakEnd = AngleModel.getAngle(from: peakEndTime)
        self.offsetEnd = AngleModel.getAngle(from: offsetEndTime)
    }

    private static func getAngle(from date: Date) -> Angle {
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)

        let timeInSeconds = TimeInterval(hour * 60 * 60 + minute * 60 + second)
        let secondsInClock: TimeInterval = 43200

        return Angle(degrees: timeInSeconds / secondsInClock * 360)
    }
}
