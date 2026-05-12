@testable import AppCore
import ComposableArchitecture
@testable import WorkDetailFeature
import XCTest

final class WorkDetailFeatureTests: XCTestCase {
    @MainActor
    func testStartEditing() async {
        let work = Work(
            title: "Test Work",
            summary: "Test Summary"
        )

        let store = TestStore(
            initialState: WorkDetailFeature.State(work: work),
            reducer: { WorkDetailFeature() }
        )

        await store.send(.startEditing) {
            $0.isEditing = true
        }
    }

    @MainActor
    func testCancelEditing() async {
        var state = WorkDetailFeature.State(
            work: Work(title: "Test Work")
        )
        state.isEditing = true
        state.errorMessage = "Some error"

        let store = TestStore(
            initialState: state,
            reducer: { WorkDetailFeature() }
        )

        await store.send(.cancelEditing) {
            $0.isEditing = false
            $0.errorMessage = nil
        }
    }

    @MainActor
    func testUpdateFormTitle() async {
        let work = Work(title: "Original Title")

        let store = TestStore(
            initialState: WorkDetailFeature.State(work: work),
            reducer: { WorkDetailFeature() }
        )

        await store.send(.updateFormTitle("New Title")) {
            $0.editFormState.title = "New Title"
        }
    }

    @MainActor
    func testFormValidation() {
        let work = Work(title: "Test")
        var state = WorkDetailFeature.State(work: work)
        state.editFormState.title = ""

        XCTAssertFalse(state.editFormState.isFormValid)

        state.editFormState.title = "Valid Title"
        XCTAssertTrue(state.editFormState.isFormValid)
    }
}
