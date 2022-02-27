import SwiftUI

struct TimeLabels: View {

    let startTime: Date
    let endTime: Date
    let totalWidth: CGFloat

    var body: some View {
        ZStack {
            ForEach(getFullHoursBetweenStartAndEnd(), id: \.self) { date in
                getLabel(for: date)
            }
        }
    }

    func getLabel(for date: Date) -> some View {
        let fraction = startTime.distance(to: date) / startTime.distance(to: endTime)
        assert(fraction >= 0 && fraction <= 1)

        let xOffset = fraction * totalWidth

        var hour = Calendar.current.component(.hour, from: date)
        if hour == 0 {
            hour = 24
        }
        return Text("\(hour)")
            .offset(x: xOffset, y: 0)
            .foregroundColor(.secondary)
            .font(.footnote)
    }

    func getFullHoursBetweenStartAndEnd() -> [Date] {
        var fullHours = [Date]()

        let calendar = Calendar.current

        let rangeInHours = startTime.distance(to: endTime) / (60*60)

        let pixelsPerLabel: CGFloat = 20
        let numLabels = totalWidth / pixelsPerLabel
        let timeStepInHours = (rangeInHours / numLabels).rounded(.up)
        let timeStepInSec: TimeInterval = timeStepInHours*60*60

        var checkTime = startTime.addingTimeInterval(timeStepInSec)

        while checkTime < endTime {
            var components = DateComponents()

            components.year = calendar.component(.year, from: checkTime)
            components.month = calendar.component(.month, from: checkTime)
            components.day = calendar.component(.day, from: checkTime)
            components.hour = calendar.component(.hour, from: checkTime)
            components.minute = 0
            components.second = 0

            let newTime = calendar.date(from: components) ?? Date()
            fullHours.append(newTime)

            checkTime.addTimeInterval(timeStepInSec)
        }

        return fullHours
    }
}

struct TimeLabels_Previews: PreviewProvider {
    static var previews: some View {
        TimeLabels(startTime: Date(), endTime: Date().addingTimeInterval(5*60*60), totalWidth: 300)
    }
}