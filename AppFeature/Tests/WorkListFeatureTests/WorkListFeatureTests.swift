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
            $0.selectedWorkID = work.id
            $0.detail = WorkDetailFeature.State(work: work)
        }
    }
}
