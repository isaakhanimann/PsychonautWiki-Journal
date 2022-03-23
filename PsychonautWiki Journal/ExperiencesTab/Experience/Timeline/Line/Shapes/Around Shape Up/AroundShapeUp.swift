import SwiftUI

struct AroundShapeUp: Shape {

    let ingestionWithTimelineContext: IngestionWithTimelineContext
    let lineWidth: Double
    let roaDuration: RoaDuration
    let ingestionTime: Date

    var viewModel: ViewModel? {
        ViewModel(
            timelineContext: ingestionWithTimelineContext,
            lineWidth: lineWidth,
            roaDuration: roaDuration,
            ingestionTime: ingestionTime
        )
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let viewModelUnwrap = viewModel else {
            assertionFailure("AroundShapeModelUp view model could not be created")
            return path
        }
        let halfLineWidth = viewModelUnwrap.lineWidth/2
        let insets = UIEdgeInsets(
            top: Double(viewModelUnwrap.insetIndex) * viewModelUnwrap.lineWidth,
            left: halfLineWidth,
            bottom: 0,
            right: halfLineWidth
        )
        let drawRect = rect.inset(by: insets)
        // Start
        var destination = viewModelUnwrap.bottomLeft.toCGPoint(inside: drawRect)
        path.move(to: destination)
        // Bottom Line
        destination = viewModelUnwrap.bottomRight.toCGPoint(inside: drawRect)
        path.addLine(to: destination)
        // Curve Up
        destination = viewModelUnwrap.curveToTopRight.endPoint.toCGPoint(inside: drawRect)
        var control1 = viewModelUnwrap.curveToTopRight.controlPoint0.toCGPoint(inside: drawRect)
        var control2 = viewModelUnwrap.curveToTopRight.controlPoint1.toCGPoint(inside: drawRect)
        path.addCurve(to: destination, control1: control1, control2: control2)
        // Top Line
        destination = viewModelUnwrap.topLeft.toCGPoint(inside: drawRect)
        path.addLine(to: destination)
        // Curve Down
        destination = viewModelUnwrap.curveToBottomLeft.endPoint.toCGPoint(inside: drawRect)
        control1 = viewModelUnwrap.curveToBottomLeft.controlPoint0.toCGPoint(inside: drawRect)
        control2 = viewModelUnwrap.curveToBottomLeft.controlPoint1.toCGPoint(inside: drawRect)
        path.addCurve(to: destination, control1: control1, control2: control2)
        return path
    }
}
