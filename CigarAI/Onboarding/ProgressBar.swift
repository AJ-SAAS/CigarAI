import SwiftUI

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .frame(width: 20, height: 5)
                    .foregroundColor(step < currentStep ? Color.blue : Color.gray.opacity(0.5))
            }
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(currentStep: 3, totalSteps: 9)
            .previewLayout(.sizeThatFits)
    }
}
