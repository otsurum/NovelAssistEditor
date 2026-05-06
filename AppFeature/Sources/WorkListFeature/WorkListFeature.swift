import AppCore
import ComposableArchitecture
import Foundation
import WorkDetailFeature

@Reducer
public struct WorkListFeature {
    @ObservableState
    public struct State: Equatable {
        public var works: [Work] = []
        public var isLoading = false
        public var isShowingCreateModal = false
        public var createModalForm = CreateModalFormState()
        public var errorMessage: String?
        public var selectedWorkID: Work.ID?
        public var detail: WorkDetailFeature.State?

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
        case detail(WorkDetailFeature.Action)
        case showCreateModal
        case hideCreateModal
        case createWork
        case createWorkFailed(message: String)
        case workTapped(Work)
        case workSelected(Work.ID?)
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
                state.errorMessage = nil
                state.reconcileSelection()
                return .none

            case let .worksResponse(.failure(reason)):
                state.isLoading = false
                state.errorMessage = reason.message
                return .none

            case let .detail(.updateWorkResponse(.success(updatedWork))):
                state.updateWorkInList(updatedWork)
                return .none

            case .detail:
                return .none

            case let .workTapped(work):
                state.select(work)
                return .none

            case let .workSelected(workID):
                state.selectWork(id: workID)
                return .none

            case .createWork:
                let work = Work(
                    title: state.createModalForm.title,
                    summary: state.createModalForm.summary.isEmpty ? nil : state.createModalForm.summary,
                    styleMemo: state.createModalForm.styleMemo.isEmpty ? nil : state.createModalForm.styleMemo,
                    theme: state.createModalForm.theme.isEmpty ? nil : state.createModalForm.theme
                )
                state.isShowingCreateModal = false
                state.createModalForm = CreateModalFormState()
                state.errorMessage = nil

                return .run { [workListClient] send in
                    do {
                        try await workListClient.create(work)
                        // 永続化成功後にリストを再取得して state を更新
                        let works = try await workListClient.fetchWorks()
                        await send(.worksResponse(.success(works)))
                    } catch {
                        await send(.createWorkFailed(message: error.localizedDescription))
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
                state.errorMessage = errorMessage
                return .none
            }
        }
        .ifLet(\.detail, action: \.detail) {
            WorkDetailFeature()
        }
    }
}

private extension WorkListFeature.State {
    mutating func select(_ work: Work?) {
        selectedWorkID = work?.id
        detail = work.map(WorkDetailFeature.State.init(work:))
    }

    mutating func selectWork(id: Work.ID?) {
        guard let id, let work = works.first(where: { $0.id == id }) else {
            select(nil)
            return
        }

        select(work)
    }

    mutating func reconcileSelection() {
        let nextSelectionID = selectedWorkID.flatMap { selectedID in
            works.contains(where: { $0.id == selectedID }) ? selectedID : nil
        } ?? works.first?.id

        guard let nextSelectionID,
              let selectedWork = works.first(where: { $0.id == nextSelectionID })
        else {
            select(nil)
            return
        }

        selectedWorkID = nextSelectionID
        if detail?.isEditing == true, detail?.work.id == selectedWork.id {
            return
        }

        detail = WorkDetailFeature.State(work: selectedWork)
    }

    mutating func updateWorkInList(_ updatedWork: Work) {
        if let index = works.firstIndex(where: { $0.id == updatedWork.id }) {
            works[index] = updatedWork
        }
    }
}
