import SwiftUI

struct ChatListView: View {
    var showsBackButton: Bool = false
    var onBack: (() -> Void)? = nil
    var onSelectConversation: ((Int, String, Int?, Int?) -> Void)? = nil

    @StateObject private var viewModel = ChatListViewModel()
    @State private var internalPath: [ChatRoute] = []

    var body: some View {
        Group {
            if onSelectConversation != nil {
                listContent
            } else {
                NavigationStack(path: $internalPath) {
                    listContent
                        .navigationDestination(for: ChatRoute.self) { route in
                            threadDestination(for: route)
                        }
                }
            }
        }
        .onAppear { Task { await viewModel.load() } }
        .onChange(of: internalPath.count) { _, count in
            if count == 0, onSelectConversation == nil {
                Task { await viewModel.refresh() }
            }
        }
    }

    private var listContent: some View {
        VStack(spacing: 0) {
            navBar
            content
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack(spacing: 8) {
            if showsBackButton {
                BackButton(action: { onBack?() })
            }
            Text("Messages")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hex: "#1A1A2E"))
            Spacer()
            Image(systemName: "square.and.pencil")
                .font(.system(size: 18))
                .foregroundStyle(AppTheme.primaryBlue)
        }
        .padding(.horizontal, showsBackButton ? 8 : 20)
        .padding(.vertical, 14)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.conversations.isEmpty {
            loadingView
        } else if viewModel.conversations.isEmpty {
            emptyState
        } else {
            conversationList
        }
    }

    private var loadingView: some View {
        VStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { _ in
                SkeletonConversationRow()
                Divider()
                    .padding(.leading, 78)
            }
            Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(hex: "#EBF0FF"))
                    .frame(width: 96, height: 96)
                Image(systemName: "message.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(AppTheme.primaryBlue)
            }
            Text("No Messages Available")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(hex: "#1A1A2E"))
            Text("Start a conversation by tapping\n\"Chat\" on any listing.")
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "#6B7280"))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var conversationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.conversations) { conv in
                    Button {
                        openConversation(conv)
                    } label: {
                        ConversationRowView(
                            conversation: conv,
                            myUserId: viewModel.myUserId
                        )
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .padding(.leading, 78)
                }
            }
        }
        .scrollIndicators(.hidden)
        .refreshable { await viewModel.refresh() }
    }

    private func openConversation(_ conv: ChatConversation) {
        guard let cid = viewModel.conversationId(for: conv) else { return }
        let name = viewModel.otherName(for: conv)
        let postId = conv.postId ?? conv.post?.id
        let otherUserId = ChatViewModel.otherUserId(
            from: conv,
            myId: viewModel.myUserId
        )

        if let onSelectConversation {
            onSelectConversation(cid, name, postId, otherUserId)
        } else {
            internalPath.append(.thread(
                conversationId: cid,
                otherName: name,
                postId: postId,
                otherUserId: otherUserId
            ))
        }
    }

    @ViewBuilder
    private func threadDestination(for route: ChatRoute) -> some View {
        switch route {
        case .thread(let id, let name, let postId, let otherUserId):
            ChatView(
                conversationId: id,
                otherName: name,
                postId: postId,
                otherUserId: otherUserId
            )
        }
    }
}

// MARK: - Skeleton Row

private struct SkeletonConversationRow: View {
    @State private var opacity: Double = 0.4

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: "#E5E7EB"))
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "#E5E7EB"))
                    .frame(width: 140, height: 14)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "#E5E7EB"))
                    .frame(width: 200, height: 12)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}

// MARK: - Route

enum ChatRoute: Hashable {
    case thread(
        conversationId: Int,
        otherName: String,
        postId: Int? = nil,
        otherUserId: Int? = nil
    )
}
