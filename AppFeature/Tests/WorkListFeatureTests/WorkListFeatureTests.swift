import AppCore
import ComposableArchitecture
import Foundation
import WorkDetailFeature
@testable import WorkListFeature
import XCTest

final class WorkListFeatureTests: XCTestCase {
    @MainActor
    func testShowAndHideCreateModal() async {
        let store = TestStore(
            initialState: WorkListFeature.State(),
            reducer: { WorkListFeature() }
        )

        await store.send(.showCreateModal) {
            $0.isShowingCreateModal = true
        }

        await store.send(.hideCreateModal) {
            $0.isShowingCreateModal = false
            $0.createModalForm = WorkListFeature.CreateModalFormState()
        }
    }

    @MainActor
    func testWorkTappedSelectsDetail() async throws {
        let work = try Work(
            id: XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000001")),
            title: "Test Work",
            summary: "Test Summary"
        )

        let store = TestStore(
            initialState: WorkListFeature.State(),
            reducer: { WorkListFeature() }
        )

        await store.send(.workTapped(work)) {
            $0.selectedSidebarItem = .work(work.id)
            $0.detail = WorkDetailFeature.State(work: work)
        }
    }

    @MainActor
    func testAllWorksSelectionClearsDetail() async throws {
        let work = try Work(
            id: XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000001")),
            title: "Test Work"
        )

        var state = WorkListFeature.State()
        state.works = [work]
        state.selectedSidebarItem = .work(work.id)
        state.selectedWorkContent = .characters
        state.detail = WorkDetailFeature.State(work: work)

        let store = TestStore(
            initialState: state,
            reducer: { WorkListFeature() }
        )

        await store.send(.sidebarSelectionChanged(.allWorks)) {
            $0.selectedSidebarItem = .allWorks
            $0.selectedWorkContent = .general
            $0.detail = nil
        }
    }

    @MainActor
    func testCharactersContentSelectionKeepsDetail() async throws {
        let work = try Work(
            id: XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000001")),
            title: "Test Work"
        )

        var state = WorkListFeature.State()
        state.works = [work]
        state.selectedSidebarItem = .work(work.id)
        state.detail = WorkDetailFeature.State(work: work)

        let store = TestStore(
            initialState: state,
            reducer: { WorkListFeature() }
        )

        await store.send(.workContentSelectionChanged(.characters)) {
            $0.selectedWorkContent = .characters
        }
    }

    @MainActor
    func testWorkSelectionResetsContentSelectionToGeneral() async throws {
        let work = try Work(
            id: XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000001")),
            title: "Test Work"
        )

        var state = WorkListFeature.State()
        state.works = [work]
        state.selectedWorkContent = .characters

        let store = TestStore(
            initialState: state,
            reducer: { WorkListFeature() }
        )

        await store.send(.sidebarSelectionChanged(.work(work.id))) {
            $0.selectedSidebarItem = .work(work.id)
            $0.selectedWorkContent = .general
            $0.detail = WorkDetailFeature.State(work: work)
        }
    }

    @MainActor
    func testCreateCharacterResponseUpdatesSelectedWork() async throws {
        let character = try AppCore.Character(
            id: XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000101")),
            name: "Test Character",
            personality: "Calm"
        )
        let work = try Work(
            id: XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000001")),
            title: "Test Work"
        )
        let updatedWork = Work(
            id: work.id,
            title: work.title,
            characters: [character],
            createdAt: work.createdAt,
            updatedAt: Date(timeIntervalSince1970: 1_000)
        )

        var state = WorkListFeature.State()
        state.works = [work]
        state.selectedSidebarItem = .work(work.id)
        state.selectedWorkContent = .characters
        state.detail = WorkDetailFeature.State(work: work)

        let store = TestStore(
            initialState: state,
            reducer: { WorkListFeature() }
        )

        await store.send(.createCharacterResponse(.success(updatedWork))) {
            $0.works = [updatedWork]
            $0.detail = WorkDetailFeature.State(work: updatedWork)
            $0.errorMessage = nil
        }
    }
}
