import SwiftUI
import UIKit

extension View {
    /// Dismisses the keyboard when the user taps anywhere outside a text field.
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
}
