import AppCore
import ComposableArchitecture
import Foundation

@Reducer
public struct WorkDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public var work: Work
        public var isEditing = false
        public var editFormState = EditFormState()
        public var errorMessage: String?

        public init(work: Work) {
            self.work = work
            editFormState = EditFormState(
                title: work.title,
                summary: work.summary ?? "",
                styleMemo: work.styleMemo ?? "",
                theme: work.theme ?? ""
            )
        }
    }

    public struct EditFormState: Equatable {
        public var title: String = ""
        public var summary: String = ""
        public var styleMemo: String = ""
        public var theme: String = ""

        public init(
            title: String = "",
            summary: String = "",
            styleMemo: String = "",
            theme: String = ""
        ) {
            self.title = title
            self.summary = summary
            self.styleMemo = styleMemo
            self.theme = theme
        }

        public var isFormValid: Bool {
            !title.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    public enum Action: Equatable {
        case startEditing
        case cancelEditing
        case saveChanges
        case updateFormTitle(String)
        case updateFormSummary(String)
        case updateFormStyleMemo(String)
        case updateFormTheme(String)
        case updateWorkResponse(UpdateWorkResponse)
    }

    public enum UpdateWorkResponse: Equatable {
        case success(Work)
        case failure(FailureReason)
    }

    public struct FailureReason: Error, Equatable, Sendable {
        public let message: String

        public init(_ message: String) {
            self.message = message
        }
    }

    @Dependency(\.workDetailClient) var workDetailClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startEditing:
                state.isEditing = true
                state.editFormState = EditFormState(
                    title: state.work.title,
                    summary: state.work.summary ?? "",
                    styleMemo: state.work.styleMemo ?? "",
                    theme: state.work.theme ?? ""
                )
                return .none

            case .cancelEditing:
                state.isEditing = false
                state.errorMessage = nil
                return .none

            case .saveChanges:
                let updatedWork = Work(
                    id: state.work.id,
                    title: state.editFormState.title,
                    summary: state.editFormState.summary.isEmpty ? nil : state.editFormState.summary,
                    styleMemo: state.editFormState.styleMemo.isEmpty ? nil : state.editFormState.styleMemo,
                    theme: state.editFormState.theme.isEmpty ? nil : state.editFormState.theme,
                    characters: state.work.characters,
                    createdAt: state.work.createdAt,
                    updatedAt: .now
                )

                return .run { [workDetailClient] send in
                    do {
                        try await workDetailClient.update(updatedWork)
                        await send(.updateWorkResponse(.success(updatedWork)))
                    } catch {
                        await send(.updateWorkResponse(.failure(FailureReason(error.localizedDescription))))
                    }
                }

            case let .updateWorkResponse(.success(updatedWork)):
                state.work = updatedWork
                state.isEditing = false
                state.errorMessage = nil
                return .none

            case let .updateWorkResponse(.failure(error)):
                state.errorMessage = error.message
                return .none

            case let .updateFormTitle(title):
                state.editFormState.title = title
                return .none

            case let .updateFormSummary(summary):
                state.editFormState.summary = summary
                return .none

            case let .updateFormStyleMemo(styleMemo):
                state.editFormState.styleMemo = styleMemo
                return .none

            case let .updateFormTheme(theme):
                state.editFormState.theme = theme
                return .none
            }
        }
    }
}
