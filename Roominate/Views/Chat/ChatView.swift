import PhotosUI
import SwiftUI
import UIKit

struct ChatView: View {
    let conversationId: Int
    let otherName: String
    let postId: Int?
    let otherUserId: Int?

    @StateObject private var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool
    @State private var scrollProxy: ScrollViewProxy?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showBlockConfirmation = false
    @State private var showDetailsSheet = false

    init(
        conversationId: Int,
        otherName: String,
        postId: Int? = nil,
        otherUserId: Int? = nil
    ) {
        self.conversationId = conversationId
        self.otherName = otherName
        self.postId = postId
        self.otherUserId = otherUserId
        _viewModel = StateObject(wrappedValue: ChatViewModel(
            conversationId: conversationId,
            otherName: otherName,
            postId: postId,
            otherUserId: otherUserId
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar
            messagesArea
            inputBar
        }
        .background(Color(hex: "#F7F8FA").ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            await viewModel.loadMessages()
            viewModel.subscribeReverb()
        }
        .onDisappear {
            viewModel.unsubscribeReverb()
        }
        .onChange(of: viewModel.messages.count) { _, _ in
            scrollToBottom()
        }
        .onChange(of: selectedPhotoItem) { _, item in
            guard let item else { return }
            Task {
                defer { selectedPhotoItem = nil }
                guard let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data),
                      let compressed = ImageCompressor.chatJPEGData(from: image) else {
                    return
                }
                await viewModel.sendImage(compressed)
            }
        }
        .overlay {
            if showBlockConfirmation {
                BlockUserConfirmationDialog(
                    isBlocking: viewModel.isBlocking,
                    onCancel: { showBlockConfirmation = false },
                    onConfirm: {
                        Task {
                            let didBlock = await viewModel.blockUser()
                            if didBlock {
                                showBlockConfirmation = false
                                dismiss()
                            }
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showDetailsSheet) {
            if let details = viewModel.postDetails {
                ChatDetailsSheet(
                    details: details,
                    isShortlisting: viewModel.isShortlisting,
                    isShortlisted: viewModel.isDealGrabbed,
                    onShortlist: {
                        Task { await viewModel.shortlist() }
                    },
                    onDismiss: { showDetailsSheet = false }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .alert("Couldn't send", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Please try again.")
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack(spacing: 10) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#4776E6"), Color(hex: "#8E54E9")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 38)
                Text(String(otherName.prefix(1)).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(otherName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: "#1A1A2E"))
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: "#22C55E"))
                        .frame(width: 7, height: 7)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(hex: "#6B7280"))
                }
            }

            Spacer()

            HStack(spacing: 4) {
                navIconButton(systemName: "nosign.circle") {
                    showBlockConfirmation = true
                }
                navIconButton(systemName: "info.circle") {
                    showDetailsSheet = true
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(alignment: .bottom) { Divider() }
    }

    private func navIconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 22))
                .foregroundStyle(AppTheme.primaryBlue)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Messages Area

    private var messagesArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    Color.clear.frame(height: 4)

                    if viewModel.isLoading {
                        skeletonBubbles
                    } else if viewModel.messages.isEmpty && viewModel.postDetails == nil {
                        emptyThreadState
                    } else {
                        if let details = viewModel.postDetails {
                            ChatPropertyCardView(details: details) {
                                showDetailsSheet = true
                            }
                            .padding(.horizontal, 14)
                        }

                        ForEach(Array(viewModel.messages.reversed().enumerated()), id: \.offset) { _, msg in
                            MessageBubbleView(
                                message: msg,
                                isSentByMe: viewModel.isSentByMe(msg)
                            )
                            .padding(.horizontal, 14)
                        }
                    }

                    Color.clear
                        .frame(height: 4)
                        .id("bottom")
                }
                .padding(.vertical, 8)
            }
            .scrollIndicators(.hidden)
            .onTapGesture { isInputFocused = false }
            .onAppear { scrollProxy = proxy }
        }
    }

    private var emptyThreadState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 36))
                .foregroundStyle(AppTheme.primaryBlue.opacity(0.5))
            Text("No messages yet. Say hi 👋")
                .font(.system(size: 15))
                .foregroundStyle(Color(hex: "#6B7280"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var skeletonBubbles: some View {
        VStack(spacing: 14) {
            ForEach(0..<5, id: \.self) { i in
                HStack {
                    if i % 2 == 0 { Spacer(minLength: 80) }
                    SkeletonBubble(isRight: i % 2 == 0)
                    if i % 2 != 0 { Spacer(minLength: 80) }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 20)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 10) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundStyle(viewModel.isSending ? Color(hex: "#D1D5DB") : Color(hex: "#9EA3B0"))
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isSending)

                ZStack(alignment: .leading) {
                    if viewModel.inputText.isEmpty {
                        Text("Send a message...")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(hex: "#9EA3B0"))
                            .padding(.horizontal, 4)
                    }
                    TextField("", text: $viewModel.inputText, axis: .vertical)
                        .font(.system(size: 15))
                        .appTextInputStyle()
                        .lineLimit(1...5)
                        .focused($isInputFocused)
                        .padding(.horizontal, 4)
                }
                .frame(minHeight: 36)

                sendButton
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white)
        }
    }

    private var sendButton: some View {
        Button {
            isInputFocused = false
            Task { await viewModel.sendMessage() }
        } label: {
            ZStack {
                Circle()
                    .fill(
                        viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color(hex: "#E5E7EB")
                            : AppTheme.primaryBlue
                    )
                    .frame(width: 38, height: 38)
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color(hex: "#9EA3B0")
                            : .white
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSending || viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .animation(.easeInOut(duration: 0.15), value: viewModel.inputText.isEmpty)
    }

    // MARK: - Helpers

    private func scrollToBottom() {
        withAnimation(.easeOut(duration: 0.25)) {
            scrollProxy?.scrollTo("bottom", anchor: .bottom)
        }
    }
}

// MARK: - Skeleton Bubble

private struct SkeletonBubble: View {
    let isRight: Bool
    @State private var opacity: Double = 0.4
    let width: CGFloat = CGFloat.random(in: 120...200)

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(hex: isRight ? "#DBEAFE" : "#E5E7EB"))
            .frame(width: width, height: 38)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    opacity = 1.0
                }
            }
    }
}
