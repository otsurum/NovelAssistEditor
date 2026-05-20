import AppCore
import CharacterCardListFeature
import ComposableArchitecture
import Foundation
import StoryListFeature
import WorkDetailFeature

@Reducer
public struct WorkListFeature {
    public enum SidebarSelection: Hashable {
        case allWorks
        case work(Work.ID)
    }

    public enum WorkContentSelection: Hashable {
        case general
        case characters
        case story
    }

    @ObservableState
    public struct State: Equatable {
        public var works: [Work] = []
        public var isLoading = false
        public var isShowingCreateModal = false
        public var createModalForm = CreateModalFormState()
        public var errorMessage: String?
        public var selectedSidebarItem: SidebarSelection = .allWorks
        public var selectedWorkContent: WorkContentSelection = .general
        public var detail: WorkDetailFeature.State?
        public var characterCardList: CharacterCardListFeature.State?
        public var storyList: StoryListFeature.State?

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
        case characterCardList(CharacterCardListFeature.Action)
        case storyList(StoryListFeature.Action)
        case showCreateModal
        case hideCreateModal
        case createWork
        case createWorkFailed(message: String)
        case createCharacterResponse(Result<Work, FailureReason>)
        case createChapterResponse(Result<Work, FailureReason>)
        case updateChapterBodyResponse(Result<Work, FailureReason>)
        case workTapped(Work)
        case sidebarSelectionChanged(SidebarSelection?)
        case workContentSelectionChanged(WorkContentSelection?)
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

    private struct ChapterBodySaveID: Hashable {
        let workID: Work.ID
        let chapterID: Chapter.ID
    }

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
                state.characterCardList?.characters = updatedWork.characters
                state.storyList?.work = updatedWork
                return .none

            case .detail:
                return .none

            case let .workTapped(work):
                state.select(work)
                return .none

            case let .sidebarSelectionChanged(selection):
                state.select(selection ?? .allWorks)
                return .none

            case let .workContentSelectionChanged(selection):
                state.selectedWorkContent = selection ?? .general
                return .none

            case let .characterCardList(.delegate(.characterCreated(character))):
                guard
                    case let .work(id) = state.selectedSidebarItem,
                    let work = state.works.first(where: { $0.id == id })
                else {
                    return .none
                }

                var updatedWork = work
                updatedWork.characters.append(character)
                updatedWork.updatedAt = .now
                let workToSave = updatedWork
                state.errorMessage = nil

                return .run { [workListClient] send in
                    do {
                        try await workListClient.update(workToSave)
                        await send(.createCharacterResponse(.success(workToSave)))
                    } catch {
                        await send(.createCharacterResponse(.failure(FailureReason(error.localizedDescription))))
                    }
                }

            case .characterCardList:
                return .none

            case let .storyList(.delegate(.chapterCreated(chapter))):
                guard
                    case let .work(id) = state.selectedSidebarItem,
                    let work = state.works.first(where: { $0.id == id })
                else {
                    return .none
                }

                var updatedWork = work
                updatedWork.story.chapters.append(chapter)
                updatedWork.updatedAt = .now
                let workToSave = updatedWork
                state.errorMessage = nil

                return .run { [workListClient] send in
                    do {
                        try await workListClient.update(workToSave)
                        await send(.createChapterResponse(.success(workToSave)))
                    } catch {
                        await send(.createChapterResponse(.failure(FailureReason(error.localizedDescription))))
                    }
                }

            case let .storyList(.delegate(.chapterBodySaveRequested(chapter))):
                guard
                    case let .work(id) = state.selectedSidebarItem,
                    let work = state.works.first(where: { $0.id == id }),
                    let chapterIndex = work.story.chapters.firstIndex(where: { $0.id == chapter.id })
                else {
                    return .none
                }

                var updatedWork = work
                updatedWork.story.chapters[chapterIndex] = chapter
                updatedWork.updatedAt = .now
                let workToSave = updatedWork
                let saveID = ChapterBodySaveID(workID: id, chapterID: chapter.id)
                state.updateWorkInList(workToSave)
                state.storyList?.work = workToSave
                if state.detail?.isEditing != true {
                    state.detail = WorkDetailFeature.State(work: workToSave)
                }
                state.errorMessage = nil

                return .run { [workListClient] send in
                    do {
                        try await workListClient.update(workToSave)
                        await send(.updateChapterBodyResponse(.success(workToSave)))
                    } catch {
                        await send(.updateChapterBodyResponse(.failure(FailureReason(error.localizedDescription))))
                    }
                }
                .cancellable(id: saveID, cancelInFlight: true)

            case .storyList:
                return .none

            case let .createCharacterResponse(.success(updatedWork)):
                state.applyUpdatedWork(updatedWork)
                state.selectedWorkContent = .characters
                state.errorMessage = nil
                return .none

            case let .createCharacterResponse(.failure(reason)):
                state.errorMessage = reason.message
                return .none

            case let .createChapterResponse(.success(updatedWork)):
                state.applyUpdatedWork(updatedWork)
                state.selectedWorkContent = .story
                state.errorMessage = nil
                return .none

            case let .createChapterResponse(.failure(reason)):
                state.errorMessage = reason.message
                return .none

            case let .updateChapterBodyResponse(.success(updatedWork)):
                if
                    let editingChapter = state.storyList?.textEditor?.chapter,
                    let savedChapter = updatedWork.story.chapters.first(where: { $0.id == editingChapter.id }),
                    savedChapter.body != editingChapter.body
                {
                    return .none
                }

                state.updateWorkInList(updatedWork)
                if state.selectedSidebarItem == .work(updatedWork.id) {
                    state.storyList?.work = updatedWork
                    state.characterCardList?.characters = updatedWork.characters
                    if state.detail?.isEditing != true {
                        state.detail = WorkDetailFeature.State(work: updatedWork)
                    }
                }
                state.errorMessage = nil
                return .none

            case let .updateChapterBodyResponse(.failure(reason)):
                state.errorMessage = reason.message
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
        .ifLet(\.characterCardList, action: \.characterCardList) {
            CharacterCardListFeature()
        }
        .ifLet(\.storyList, action: \.storyList) {
            StoryListFeature()
        }
    }
}

private extension WorkListFeature.State {
    mutating func select(_ work: Work?) {
        guard let work else {
            select(.allWorks)
            return
        }

        selectedSidebarItem = .work(work.id)
        selectedWorkContent = .general
        detail = WorkDetailFeature.State(work: work)
        characterCardList = CharacterCardListFeature.State(characters: work.characters)
        storyList = StoryListFeature.State(work: work)
    }

    mutating func select(_ selection: WorkListFeature.SidebarSelection) {
        switch selection {
        case .allWorks:
            selectedSidebarItem = .allWorks
            selectedWorkContent = .general
            detail = nil
            characterCardList = nil
            storyList = nil

        case let .work(id):
            guard let work = works.first(where: { $0.id == id }) else {
                selectedSidebarItem = .allWorks
                selectedWorkContent = .general
                detail = nil
                characterCardList = nil
                storyList = nil
                return
            }

            selectedSidebarItem = .work(id)
            selectedWorkContent = .general
            detail = WorkDetailFeature.State(work: work)
            characterCardList = CharacterCardListFeature.State(characters: work.characters)
            storyList = StoryListFeature.State(work: work)
        }
    }

    mutating func reconcileSelection() {
        switch selectedSidebarItem {
        case .allWorks:
            selectedWorkContent = .general
            detail = nil
            characterCardList = nil
            storyList = nil
            return

        case let .work(id):
            guard let selectedWork = works.first(where: { $0.id == id }) else {
                select(.allWorks)
                return
            }

            if detail?.isEditing == true, detail?.work.id == selectedWork.id {
                return
            }

            detail = WorkDetailFeature.State(work: selectedWork)
            characterCardList = CharacterCardListFeature.State(characters: selectedWork.characters)
            storyList = StoryListFeature.State(work: selectedWork)
        }
    }

    mutating func updateWorkInList(_ updatedWork: Work) {
        if let index = works.firstIndex(where: { $0.id == updatedWork.id }) {
            works[index] = updatedWork
        }
    }

    mutating func applyUpdatedWork(_ updatedWork: Work) {
        updateWorkInList(updatedWork)

        if selectedSidebarItem == .work(updatedWork.id) {
            detail = WorkDetailFeature.State(work: updatedWork)
            characterCardList = CharacterCardListFeature.State(characters: updatedWork.characters)
            storyList = StoryListFeature.State(work: updatedWork)
        }
    }
}
