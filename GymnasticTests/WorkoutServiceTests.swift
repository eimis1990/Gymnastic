//
//  WorkoutServiceTests.swift
//  GymtasticTests
//
//  Created on 2025-10-01.
//

import XCTest
import SwiftData
@testable import Gymtastic

final class WorkoutServiceTests: XCTestCase {
    var sut: WorkoutService!
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!
    
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
        
        modelContainer = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        
        modelContext = ModelContext(modelContainer)
        sut = WorkoutService(modelContext: modelContext)
    }
    
    override func tearDown() {
        sut = nil
        modelContext = nil
        modelContainer = nil
    }
    
    // MARK: - TC-W01: Create Empty Workout
    func testCreateWorkout_WithTitle_CreatesEmptyWorkout() async throws {
        // Given
        let title = "Chest Day"
        
        // When
        let workout = try await sut.createWorkout(title: title)
        
        // Then
        XCTAssertEqual(workout.title, title)
        XCTAssertEqual(workout.items.count, 0)
        XCTAssertEqual(workout.breaks.count, 0)
        XCTAssertNotNil(workout.id)
    }
    
    // MARK: - TC-W02: Add Rep-Based Exercise to Workout
    func testAddExercise_RepBased_AddsToWorkout() async throws {
        // Given
        let workout = try await sut.createWorkout(title: "Test Workout")
        let exercise = Exercise(title: "Push Up", muscleGroups: [.chest])
        modelContext.insert(exercise)
        try modelContext.save()
        
        // When
        let item = try await sut.addExercise(
            exercise,
            to: workout,
            configurationType: .repetitions,
            sets: 3,
            repsPerSet: 10,
            restBetweenSets: 60,
            duration: nil
        )
        
        // Then
        XCTAssertEqual(item.sets, 3)
        XCTAssertEqual(item.repsPerSet, 10)
        XCTAssertEqual(item.restBetweenSetsSeconds, 60)
        XCTAssertEqual(item.position, 0)
        XCTAssertEqual(workout.items.count, 1)
    }
    
    // MARK: - TC-W03: Add Time-Based Exercise to Workout
    func testAddExercise_TimeBased_AddsToWorkout() async throws {
        // Given
        let workout = try await sut.createWorkout(title: "Test Workout")
        let exercise = Exercise(title: "Plank", muscleGroups: [.core])
        modelContext.insert(exercise)
        try modelContext.save()
        
        // When
        let item = try await sut.addExercise(
            exercise,
            to: workout,
            configurationType: .time,
            sets: nil,
            repsPerSet: nil,
            restBetweenSets: nil,
            duration: 60
        )
        
        // Then
        XCTAssertEqual(item.durationSeconds, 60)
        XCTAssertEqual(item.configurationType, .time)
    }
    
    // MARK: - TC-W04: Add Break to Workout
    func testAddBreak_ToWorkout_AddsBreak() async throws {
        // Given
        let workout = try await sut.createWorkout(title: "Test Workout")
        
        // When
        let breakItem = try await sut.addBreak(duration: 120, to: workout, at: 0)
        
        // Then
        XCTAssertEqual(breakItem.durationSeconds, 120)
        XCTAssertEqual(breakItem.position, 0)
        XCTAssertEqual(workout.breaks.count, 1)
    }
    
    // MARK: - TC-W05: Reorder Exercises in Workout
    func testReorderSequence_UpdatesPositions() async throws {
        // Given
        let workout = try await sut.createWorkout(title: "Test Workout")
        let ex1 = Exercise(title: "Ex1", muscleGroups: [.chest])
        let ex2 = Exercise(title: "Ex2", muscleGroups: [.back])
        let ex3 = Exercise(title: "Ex3", muscleGroups: [.legs])
        modelContext.insert(ex1)
        modelContext.insert(ex2)
        modelContext.insert(ex3)
        
        let item1 = try await sut.addExercise(ex1, to: workout, configurationType: .time,
                                              sets: nil, repsPerSet: nil, restBetweenSets: nil, duration: 30)
        let item2 = try await sut.addExercise(ex2, to: workout, configurationType: .time,
                                              sets: nil, repsPerSet: nil, restBetweenSets: nil, duration: 30)
        let item3 = try await sut.addExercise(ex3, to: workout, configurationType: .time,
                                              sets: nil, repsPerSet: nil, restBetweenSets: nil, duration: 30)
        
        // When (move item at index 0 to index 2)
        try await sut.reorderSequence(from: IndexSet(integer: 0), to: 2, in: workout)
        
        // Then
        XCTAssertEqual(workout.items[0].id, item2.id)
        XCTAssertEqual(workout.items[1].id, item3.id)
        XCTAssertEqual(workout.items[2].id, item1.id)
    }
    
    // MARK: - TC-W06: Remove Exercise from Workout
    func testRemoveExercise_FromWorkout_RemovesAndUpdatesPositions() async throws {
        // Given
        let workout = try await sut.createWorkout(title: "Test Workout")
        let ex1 = Exercise(title: "Ex1", muscleGroups: [.chest])
        let ex2 = Exercise(title: "Ex2", muscleGroups: [.back])
        modelContext.insert(ex1)
        modelContext.insert(ex2)
        
        let item1 = try await sut.addExercise(ex1, to: workout, configurationType: .time,
                                              sets: nil, repsPerSet: nil, restBetweenSets: nil, duration: 30)
        let item2 = try await sut.addExercise(ex2, to: workout, configurationType: .time,
                                              sets: nil, repsPerSet: nil, restBetweenSets: nil, duration: 30)
        
        // When
        try await sut.removeExercise(item1, from: workout)
        
        // Then
        XCTAssertEqual(workout.items.count, 1)
        XCTAssertEqual(workout.items[0].id, item2.id)
        XCTAssertEqual(workout.items[0].position, 0)
    }
    
    // MARK: - TC-W07: Calculate Workout Duration
    func testCalculateEstimatedDuration_ReturnsCorrectDuration() {
        // Given
        let workout = Workout(title: "Test Workout")
        let ex1 = Exercise(title: "Ex1", muscleGroups: [.chest])
        let item1 = WorkoutItem(exercise: ex1, position: 0, configurationType: .repetitions,
                                sets: 3, repsPerSet: 10, restBetweenSetsSeconds: 60)
        let breakItem = Break(durationSeconds: 120, position: 1)
        workout.items.append(item1)
        workout.breaks.append(breakItem)
        
        // When
        let duration = sut.calculateEstimatedDuration(workout)
        
        // Then
        let expectedExerciseDuration = (10 * 3 * 3) + (60 * 3) // reps * sets + rest
        let expectedTotal = expectedExerciseDuration + 120
        XCTAssertEqual(duration, expectedTotal)
    }
    
    // MARK: - TC-W08: Create Workout with Empty Title
    func testCreateWorkout_WithEmptyTitle_ThrowsError() async {
        // When/Then
        await XCTAssertThrowsError(
            try await sut.createWorkout(title: "")
        ) { error in
            XCTAssertEqual(error as? WorkoutServiceError, .invalidTitle)
        }
    }
    
    // MARK: - TC-W09: Add Exercise with Invalid Sets
    func testAddExercise_WithInvalidSets_ThrowsError() async {
        // Given
        let workout = Workout(title: "Test")
        let exercise = Exercise(title: "Test", muscleGroups: [.chest])
        modelContext.insert(workout)
        modelContext.insert(exercise)
        
        // When/Then
        await XCTAssertThrowsError(
            try await sut.addExercise(
                exercise,
                to: workout,
                configurationType: .repetitions,
                sets: 0, // Invalid
                repsPerSet: 10,
                restBetweenSets: 60,
                duration: nil
            )
        ) { error in
            guard case .invalidSetsValue = error as? WorkoutServiceError else {
                XCTFail("Wrong error type")
                return
            }
        }
    }
    
    // MARK: - TC-W10: Validate Empty Workout for Execution
    func testValidateWorkoutForExecution_WithNoExercises_ThrowsError() {
        // Given
        let workout = Workout(title: "Empty Workout")
        
        // When/Then
        XCTAssertThrowsError(
            try sut.validateWorkoutForExecution(workout)
        ) { error in
            XCTAssertEqual(error as? WorkoutServiceError, .noExercisesInWorkout)
        }
    }
    
    // MARK: - TC-W11: Add Break with Invalid Duration
    func testAddBreak_WithInvalidDuration_ThrowsError() async {
        // Given
        let workout = Workout(title: "Test")
        modelContext.insert(workout)
        
        // When/Then
        await XCTAssertThrowsError(
            try await sut.addBreak(duration: 0, to: workout, at: 0)
        ) { error in
            guard case .invalidBreakDuration = error as? WorkoutServiceError else {
                XCTFail("Wrong error type")
                return
            }
        }
    }
}

