import SwiftUI

struct RadarData: Identifiable {
    let id = UUID()
    let flavor: String
    let intensity: Double // Normalized 0–100
}

struct RadarChartView: View {
    let data: [RadarData]
    let top6Flavors: [String]
    private let numberOfAxes = 6
    private let maxRadius: CGFloat = 100

    var body: some View {
        ZStack {
            RadarGrid(numberOfAxes: numberOfAxes, maxRadius: maxRadius)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)

            // Fill the area with light brown
            Path { path in
                let center = CGPoint(x: maxRadius, y: maxRadius)
                for (index, item) in data.enumerated() {
                    let angle = 2 * .pi * Double(index) / Double(numberOfAxes)
                    let radius = maxRadius * (item.intensity / 100)
                    let x = center.x + radius * cos(CGFloat(angle))
                    let y = center.y - radius * sin(CGFloat(angle))
                    let point = CGPoint(x: x, y: y)

                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.closeSubpath()
            }
            .fill(Color(red: 205/255, green: 133/255, blue: 63/255).opacity(0.3)) // Light brown fill

            // Stroke the same area with dark brown
            Path { path in
                let center = CGPoint(x: maxRadius, y: maxRadius)
                for (index, item) in data.enumerated() {
                    let angle = 2 * .pi * Double(index) / Double(numberOfAxes)
                    let radius = maxRadius * (item.intensity / 100)
                    let x = center.x + radius * cos(CGFloat(angle))
                    let y = center.y - radius * sin(CGFloat(angle))
                    let point = CGPoint(x: x, y: y)

                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.closeSubpath()
            }
            .stroke(Color(red: 101/255, green: 67/255, blue: 33/255), lineWidth: 2) // Dark brown stroke

            // Optional: Draw dots at points (you can remove this if you don’t want them)
            Path { path in
                let center = CGPoint(x: maxRadius, y: maxRadius)
                for (index, item) in data.enumerated() {
                    let angle = 2 * .pi * Double(index) / Double(numberOfAxes)
                    let radius = maxRadius * (item.intensity / 100)
                    let x = center.x + radius * cos(CGFloat(angle))
                    let y = center.y - radius * sin(CGFloat(angle))
                    path.addEllipse(in: CGRect(x: x - 2, y: y - 2, width: 4, height: 4))
                }
            }
            .fill(Color(red: 101/255, green: 67/255, blue: 33/255)) // Match dot color to stroke

            // Flavor labels
            ForEach(data.indices, id: \.self) { index in
                let angle = 2 * .pi * Double(index) / Double(numberOfAxes)
                let labelRadius = maxRadius + 20
                let x = maxRadius + labelRadius * cos(CGFloat(angle))
                let y = maxRadius - labelRadius * sin(CGFloat(angle))

                Text(data[index].flavor)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .position(x: x, y: y)
            }
        }
        .frame(width: maxRadius * 2, height: maxRadius * 2)
    }
}

struct RadarGrid: Shape {
    let numberOfAxes: Int
    let maxRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)

        // Axes
        for i in 0..<numberOfAxes {
            let angle = 2 * .pi * Double(i) / Double(numberOfAxes)
            let x = center.x + maxRadius * cos(CGFloat(angle))
            let y = center.y - maxRadius * sin(CGFloat(angle))
            path.move(to: center)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        // Concentric circles
        for radius in stride(from: maxRadius / 4, through: maxRadius, by: maxRadius / 4) {
            path.addEllipse(in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
        }

        return path
    }
}

