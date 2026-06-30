import Combine
import SwiftUI

// MARK: - Notification Preferences Model

struct NotificationPreferences {
    var newListing: Bool = false
    var message: Bool = true
    var wishListed: Bool = true

    var selectAll: Bool {
        get { newListing && message && wishListed }
        set {
            newListing = newValue
            message = newValue
            wishListed = newValue
        }
    }
}

// MARK: - ViewModel

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var preferences = NotificationPreferences()
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var didSave = false

    // Toggles "Select All" and propagates to individual prefs
    func toggleSelectAll(_ value: Bool) {
        preferences.selectAll = value
    }

    // Persists preferences – extend with a real API call when the endpoint is available
    func save() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        // TODO: replace with actual API call, e.g.:
        // try await notificationService.updatePreferences(preferences)
        do {
            try await Task.sleep(nanoseconds: 500_000_000)
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - View

struct NotificationsView: View {
    let onBack: () -> Void

    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        profileEditContainer(title: Strings.Profile.notification, onBack: onBack) {
            VStack(alignment: .leading, spacing: 32) {
                headingSection
                togglesSection
                updateButton
            }
        }
        .alert("Error", isPresented: errorBinding) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? Strings.Error.generic)
        }
        .alert(Strings.Profile.notificationUpdated, isPresented: $viewModel.didSave) {
            Button("OK", role: .cancel) { onBack() }
        }
    }

    // MARK: - Subviews

    private var headingSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Strings.Profile.manageNotification)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text(Strings.Profile.manageNotificationSubtitle)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var togglesSection: some View {
        VStack(spacing: 0) {
            notificationToggleRow(
                title: Strings.Profile.selectAll,
                isOn: Binding(
                    get: { viewModel.preferences.selectAll },
                    set: { viewModel.toggleSelectAll($0) }
                )
            )
            Divider().padding(.leading, 16)

            notificationToggleRow(
                title: Strings.Profile.newListing,
                isOn: $viewModel.preferences.newListing
            )
            Divider().padding(.leading, 16)

            notificationToggleRow(
                title: Strings.Profile.messageNotification,
                isOn: $viewModel.preferences.message
            )
            Divider().padding(.leading, 16)

            notificationToggleRow(
                title: Strings.Profile.wishListed,
                isOn: $viewModel.preferences.wishListed
            )
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.infoCardBorder, lineWidth: 1)
        )
    }

    private var updateButton: some View {
        Button {
            Task { await viewModel.save() }
        } label: {
            ZStack {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(Strings.Profile.update)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.buttonHeight)
            .background(AppTheme.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaving)
    }

    // MARK: - Helper

    private func notificationToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.system(size: AppTheme.Profile.menuTitleSize))
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(AppTheme.primaryBlue)
        }
        .padding(.horizontal, 16)
        .frame(height: AppTheme.Profile.menuRowHeight)
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

#Preview {
    NotificationsView(onBack: {})
}
