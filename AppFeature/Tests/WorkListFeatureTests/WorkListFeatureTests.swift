import AppCore
import ComposableArchitecture
import Foundation
import WorkDetailFeature
import XCTest

@testable import WorkListFeature

final class WorkListFeatureTests: XCTestCase {
    @MainActor
    func testWorkTappedSelectsDetail() async {
        let work = Work(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
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
    func testAllWorksSelectionClearsDetail() async {
        let work = Work(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
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

        await store.send(.sidebarSelectionChanged(.allWorks)) {
            $0.selectedSidebarItem = .allWorks
            $0.detail = nil
        }
    }
}
