import SwiftUI

/// A reusable dismiss button matching the native iOS style (like Apple Reminders).
/// Plain xmark icon, medium weight, secondary color — no circle, no background material.
struct DismissButton: View {
    let action: () -> Void

    var body: some View {
        Button(role: .close, action: action)
    }
}

#Preview {
    DismissButton(action: {})
        .padding()
}
