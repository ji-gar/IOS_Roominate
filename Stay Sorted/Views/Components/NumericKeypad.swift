import SwiftUI

struct NumericKeypad: View {
    let onDigit: (String) -> Void
    let onDelete: () -> Void

    private let rows: [[String?]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [nil, "0", "delete"]
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(rows[rowIndex].indices, id: \.self) { columnIndex in
                        keypadButton(for: rows[rowIndex][columnIndex])
                    }
                }
            }
        }
        .background(AppTheme.keypadBackground)
    }

    @ViewBuilder
    private func keypadButton(for value: String?) -> some View {
        Button {
            switch value {
            case "delete":
                onDelete()
            case let digit?:
                onDigit(digit)
            default:
                break
            }
        } label: {
            Group {
                if value == "delete" {
                    Image(systemName: "delete.left")
                        .font(.system(size: 22, weight: .medium))
                } else if let value {
                    Text(value)
                        .font(.system(size: 28, weight: .semibold))
                } else {
                    Color.clear
                }
            }
            .foregroundStyle(AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .disabled(value == nil)
    }
}
