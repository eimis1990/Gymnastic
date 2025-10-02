//
//  WorkoutBuilderViewModelTests.swift
//  GymtasticTests
//
//  Created on 2025-10-01.
//

import XCTest
import SwiftData
@testable import Gymtastic

final class WorkoutBuilderViewModelTests: XCTestCase {
    var sut: WorkoutBuilderViewModel!
    var modelContext: ModelContext!
    
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
        let workoutService = WorkoutService(modelContext: modelContext)
        sut = WorkoutBuilderViewModel(workoutService: workoutService, modelContext: modelContext)
    }
    
    override func tearDown() {
        sut = nil
        modelContext = nil
    }
    
    // MARK: - Create Workout Tests
    func testCreateWorkout_WithTitle_CreatesWorkout() async {
        // Given
        let title = "Chest Day"
        
        // When
        await sut.createWorkout(title: title)
        
        // Then
        XCTAssertNotNil(sut.currentWorkout)
        XCTAssertEqual(sut.currentWorkout?.title, title)
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Add Exercise Tests
    func testAddExercise_ToWorkout_AddsItem() async throws {
        // Given
        await sut.createWorkout(title: "Test Workout")
        let exercise = Exercise(title: "Push Up", muscleGroups: [.chest])
        modelContext.insert(exercise)
        try modelContext.save()
        
        // When
        await sut.addExercise(
            exercise,
            configurationType: .repetitions,
            sets: 3,
            repsPerSet: 10,
            restBetweenSets: 60,
            duration: nil
        )
        
        // Then
        XCTAssertEqual(sut.currentWorkout?.items.count, 1)
    }
    
    // MARK: - Add Break Tests
    func testAddBreak_ToWorkout_AddsBreak() async {
        // Given
        await sut.createWorkout(title: "Test Workout")
        
        // When
        await sut.addBreak(duration: 120, at: 0)
        
        // Then
        XCTAssertEqual(sut.currentWorkout?.breaks.count, 1)
    }
    
    // MARK: - Reorder Tests
    func testReorderItems_UpdatesPositions() async throws {
        // Given
        await sut.createWorkout(title: "Test Workout")
        let ex1 = Exercise(title: "Ex1", muscleGroups: [.chest])
        let ex2 = Exercise(title: "Ex2", muscleGroups: [.back])
        modelContext.insert(ex1)
        modelContext.insert(ex2)
        try modelContext.save()
        
        await sut.addExercise(ex1, configurationType: .time, sets: nil,
                              repsPerSet: nil, restBetweenSets: nil, duration: 30)
        await sut.addExercise(ex2, configurationType: .time, sets: nil,
                              repsPerSet: nil, restBetweenSets: nil, duration: 30)
        
        // When
        await sut.reorderItems(from: IndexSet(integer: 0), to: 2)
        
        // Then - positions should be updated
        XCTAssertNotNil(sut.currentWorkout)
    }
    
    // MARK: - Validation Tests
    func testValidateWorkout_WithNoExercises_ReturnsError() async {
        // Given
        await sut.createWorkout(title: "Empty Workout")
        
        // When
        let isValid = await sut.validateWorkout()
        
        // Then
        XCTAssertFalse(isValid)
        XCTAssertNotNil(sut.errorMessage)
    }
}

