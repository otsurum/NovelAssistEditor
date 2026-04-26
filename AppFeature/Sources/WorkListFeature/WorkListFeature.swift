import AppCore
import ComposableArchitecture
import Foundation

@Reducer
public struct WorkListFeature {
    @ObservableState
    public struct State: Equatable {
        public var works: [Work] = []
        public var isLoading = false
        public var isShowingCreateModal = false
        public var createModalForm = CreateModalFormState()
        public var errorMessage: String?

        public init() {}
    }

    public struct CreateModalFormState: Equatable {
        public var title: String = ""
        public var summary: String = ""
        public var styleMemo: String = ""
        public var theme: String = ""

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case showCreateModal
        case hideCreateModal
        case createWork
        case createWorkFailed(String)
        case worksResponse(Result<[Work], FailureReason>)
        case updateFormTitle(String)
        case updateFormSummary(String)
        case updateFormStyleMemo(String)
        case updateFormTheme(String)
    }

    public struct FailureReason: Error, Equatable, Sendable {
        public let message: String

        public init(_ message: String) {
            self.message = message
        }
    }

    @Dependency(\.workListClient) var workListClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { [workListClient] send in
                    do {
                        let works = try await workListClient.fetchWorks()
                        await send(.worksResponse(.success(works)))
                    } catch {
                        await send(
                            .worksResponse(
                                .failure(FailureReason(error.localizedDescription))
                            )
                        )
                    }
                }

            case .showCreateModal:
                state.isShowingCreateModal = true
                return .none

            case .hideCreateModal:
                state.isShowingCreateModal = false
                state.createModalForm = CreateModalFormState()
                return .none

            case let .worksResponse(.success(works)):
                state.isLoading = false
                state.works = works
                return .none

            case .worksResponse(.failure):
                state.isLoading = false
                return .none

            case .createWork:
                let work = Work(
                    title: state.createModalForm.title,
                    summary: state.createModalForm.summary.isEmpty ? nil : state.createModalForm.summary,
                    styleMemo: state.createModalForm.styleMemo.isEmpty ? nil : state.createModalForm.styleMemo,
                    theme: state.createModalForm.theme.isEmpty ? nil : state.createModalForm.theme
                )
                state.works.append(work)
                state.isShowingCreateModal = false
                state.createModalForm = CreateModalFormState()
                state.errorMessage = nil

                return .run { [workListClient] send in
                    do {
                        try await workListClient.create(work)
                    } catch {
                        // エラーが発生した場合、作品を削除してエラーメッセージを表示
                        await send(.createWorkFailed(error.localizedDescription))
                    }
                }

            case let .updateFormTitle(title):
                state.createModalForm.title = title
                return .none

            case let .updateFormSummary(summary):
                state.createModalForm.summary = summary
                return .none

            case let .updateFormStyleMemo(styleMemo):
                state.createModalForm.styleMemo = styleMemo
                return .none

            case let .updateFormTheme(theme):
                state.createModalForm.theme = theme
                return .none

            case let .createWorkFailed(errorMessage):
                // エラーが発生した場合、最後に追加した作品を削除
                if !state.works.isEmpty {
                    state.works.removeLast()
                }
                state.errorMessage = errorMessage
                return .none
            }
        }
    }
}
