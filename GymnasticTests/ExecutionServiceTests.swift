//
//  ExecutionServiceTests.swift
//  GymtasticTests
//
//  Created on 2025-10-01.
//

import XCTest
import SwiftData
@testable import Gymtastic

final class ExecutionServiceTests: XCTestCase {
    var sut: ExecutionService!
    var modelContext: ModelContext!
    var testWorkout: Workout!
    
    override func setUp() async throws {
        let schema = Schema([
            Exercise.self,
            Workout.self,
            WorkoutItem.self,
            Break.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        let modelContainer = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        
        modelContext = ModelContext(modelContainer)
        sut = ExecutionService()
        
        // Create test workout
        testWorkout = Workout(title: "Test Workout")
        let exercise1 = Exercise(title: "Push Up", muscleGroups: [.chest])
        let exercise2 = Exercise(title: "Squat", muscleGroups: [.legs])
        let item1 = WorkoutItem(exercise: exercise1, position: 0, configurationType: .repetitions,
                                sets: 3, repsPerSet: 10, restBetweenSetsSeconds: 60)
        let item2 = WorkoutItem(exercise: exercise2, position: 1, configurationType: .repetitions,
                                sets: 4, repsPerSet: 12, restBetweenSetsSeconds: 90)
        testWorkout.items = [item1, item2]
        modelContext.insert(testWorkout)
    }
    
    override func tearDown() {
        sut = nil
        modelContext = nil
        testWorkout = nil
    }
    
    // MARK: - TC-X01: Start Workout Execution
    func testStartWorkout_CreatesActiveSession() async throws {
        // When
        let session = try await sut.startWorkout(testWorkout)
        
        // Then
        XCTAssertEqual(session.workout.id, testWorkout.id)
        XCTAssertEqual(session.currentItemIndex, 0)
        XCTAssertEqual(session.status, .active)
        XCTAssertNotNil(session.startTime)
        XCTAssertEqual(session.completedItemIndices.count, 0)
    }
    
    // MARK: - TC-X02: Advance to Next Item
    func testNextItem_AdvancesCurrentIndex() async throws {
        // Given
        var session = try await sut.startWorkout(testWorkout)
        
        // When
        session = try await sut.nextItem(session: session)
        
        // Then
        XCTAssertEqual(session.currentItemIndex, 1)
        XCTAssertEqual(session.completedItemIndices, [0])
    }
    
    // MARK: - TC-X03: Complete Workout
    func testCompleteWorkout_ReturnsCompleteSummary() async throws {
        // Given
        var session = try await sut.startWorkout(testWorkout)
        session = try await sut.nextItem(session: session)
        session = try await sut.nextItem(session: session)
        
        // When
        let summary = await sut.completeWorkout(session: session)
        
        // Then
        XCTAssertTrue(summary.wasCompleted)
        XCTAssertEqual(summary.completedExercises, 2)
        XCTAssertEqual(summary.totalExercises, 2)
        XCTAssertGreaterThan(summary.totalDuration, 0)
    }
    
    // MARK: - TC-X04: Get Progress
    func testGetProgress_ReturnsCorrectProgress() async throws {
        // Given
        var session = try await sut.startWorkout(testWorkout)
        session = try await sut.nextItem(session: session)
        
        // When
        let progress = sut.getProgress(for: session)
        
        // Then
        XCTAssertEqual(progress.currentIndex, 1)
        XCTAssertEqual(progress.totalItems, 2)
        XCTAssertEqual(progress.completedItems, 1)
        XCTAssertEqual(progress.remainingItems, 1)
    }
    
    // MARK: - TC-X09: Start Empty Workout
    func testStartWorkout_WithNoExercises_ThrowsError() async {
        // Given
        let emptyWorkout = Workout(title: "Empty")
        
        // When/Then
        await XCTAssertThrowsError(
            try await sut.startWorkout(emptyWorkout)
        ) { error in
            XCTAssertEqual(error as? ExecutionServiceError, .workoutNotValid)
        }
    }
}

