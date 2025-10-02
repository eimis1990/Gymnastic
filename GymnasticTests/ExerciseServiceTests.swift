//
//  ExerciseServiceTests.swift
//  GymtasticTests
//
//  Created on 2025-10-01.
//

import XCTest
import SwiftData
@testable import Gymtastic

final class ExerciseServiceTests: XCTestCase {
    var sut: ExerciseService!
    var modelContext: ModelContext!
    var modelContainer: ModelContainer!
    
    override func setUp() async throws {
        // Setup in-memory SwiftData for testing
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
        sut = ExerciseService(modelContext: modelContext)
    }
    
    override func tearDown() {
        sut = nil
        modelContext = nil
        modelContainer = nil
    }
    
    // MARK: - TC-E01: Create Exercise with Valid Data
    func testCreateExercise_WithValidData_CreatesExercise() async throws {
        // Given
        let title = "Push Up"
        let description = "Classic bodyweight exercise"
        let muscleGroups: [MuscleGroup] = [.chest, .triceps]
        
        // When
        let exercise = try await sut.createExercise(
            title: title,
            description: description,
            imageData: nil,
            youtubeURL: nil,
            muscleGroups: muscleGroups
        )
        
        // Then
        XCTAssertEqual(exercise.title, title)
        XCTAssertEqual(exercise.exerciseDescription, description)
        XCTAssertEqual(exercise.muscleGroupsEnum, muscleGroups)
        XCTAssertNotNil(exercise.id)
        XCTAssertNotNil(exercise.createdAt)
    }
    
    // MARK: - TC-E02: Create Exercise with Image
    func testCreateExercise_WithImage_CreatesExerciseWithThumbnail() async throws {
        // Given
        let title = "Squat"
        let imageData = Data(count: 100_000) // 100KB mock image
        
        // When
        let exercise = try await sut.createExercise(
            title: title,
            description: nil,
            imageData: imageData,
            youtubeURL: nil,
            muscleGroups: [.legs]
        )
        
        // Then
        XCTAssertNotNil(exercise.imageData)
        XCTAssertNotNil(exercise.thumbnailData)
        if let thumbnailData = exercise.thumbnailData {
            XCTAssertLessThan(thumbnailData.count, 100_000) // Thumbnail should be smaller
        }
    }
    
    // MARK: - TC-E03: Update Exercise
    func testUpdateExercise_WithValidData_UpdatesExercise() async throws {
        // Given
        let exercise = try await sut.createExercise(
            title: "Push Up",
            description: nil,
            imageData: nil,
            youtubeURL: nil,
            muscleGroups: [.chest]
        )
        let newTitle = "Updated Push Up"
        let createdAt = exercise.createdAt
        
        // When
        try await sut.updateExercise(
            exercise,
            title: newTitle,
            description: "New description",
            imageData: nil,
            youtubeURL: nil,
            muscleGroups: [.chest, .core]
        )
        
        // Then
        XCTAssertEqual(exercise.title, newTitle)
        XCTAssertEqual(exercise.exerciseDescription, "New description")
        XCTAssertNotEqual(exercise.updatedAt, createdAt)
    }
    
    // MARK: - TC-E04: Delete Unused Exercise
    func testDeleteExercise_WhenUnused_DeletesSuccessfully() async throws {
        // Given
        let exercise = try await sut.createExercise(
            title: "Plank",
            description: nil,
            imageData: nil,
            youtubeURL: nil,
            muscleGroups: [.core]
        )
        
        // When
        let result = try await sut.deleteExercise(exercise)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertFalse(result.usedInWorkouts)
    }
    
    // MARK: - TC-E05: Search Exercises
    func testSearchExercises_WithQuery_ReturnsMatchingExercises() async throws {
        // Given
        _ = try await sut.createExercise(title: "Push Up", description: nil, imageData: nil,
                                         youtubeURL: nil, muscleGroups: [.chest])
        _ = try await sut.createExercise(title: "Pull Up", description: nil, imageData: nil,
                                         youtubeURL: nil, muscleGroups: [.back])
        _ = try await sut.createExercise(title: "Squat", description: nil, imageData: nil,
                                         youtubeURL: nil, muscleGroups: [.legs])
        
        // When
        let results = try await sut.searchExercises(query: "up")
        
        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.contains { $0.title == "Push Up" })
        XCTAssertTrue(results.contains { $0.title == "Pull Up" })
    }
    
    // MARK: - TC-E06: Create Exercise with Empty Title
    func testCreateExercise_WithEmptyTitle_ThrowsError() async {
        // Given
        let title = ""
        
        // When/Then
        await XCTAssertThrowsError(
            try await sut.createExercise(
                title: title,
                description: nil,
                imageData: nil,
                youtubeURL: nil,
                muscleGroups: [.chest]
            )
        ) { error in
            XCTAssertEqual(error as? ExerciseServiceError, .invalidTitle)
        }
    }
    
    // MARK: - TC-E07: Create Exercise with Invalid YouTube URL
    func testCreateExercise_WithInvalidYouTubeURL_ThrowsError() async {
        // Given
        let youtubeURL = "not-a-valid-url"
        
        // When/Then
        await XCTAssertThrowsError(
            try await sut.createExercise(
                title: "Test",
                description: nil,
                imageData: nil,
                youtubeURL: youtubeURL,
                muscleGroups: [.chest]
            )
        ) { error in
            XCTAssertEqual(error as? ExerciseServiceError, .invalidYouTubeURL)
        }
    }
    
    // MARK: - TC-E08: Create Exercise with No Muscle Groups
    func testCreateExercise_WithNoMuscleGroups_ThrowsError() async {
        // When/Then
        await XCTAssertThrowsError(
            try await sut.createExercise(
                title: "Test",
                description: nil,
                imageData: nil,
                youtubeURL: nil,
                muscleGroups: []
            )
        ) { error in
            XCTAssertEqual(error as? ExerciseServiceError, .noMuscleGroupsSelected)
        }
    }
    
    // MARK: - TC-E09: Create Exercise with Oversized Image
    func testCreateExercise_WithOversizedImage_ThrowsError() async {
        // Given
        let largeImageData = Data(count: 3_000_000) // 3MB
        
        // When/Then
        await XCTAssertThrowsError(
            try await sut.createExercise(
                title: "Test",
                description: nil,
                imageData: largeImageData,
                youtubeURL: nil,
                muscleGroups: [.chest]
            )
        ) { error in
            guard case .imageTooLarge = error as? ExerciseServiceError else {
                XCTFail("Wrong error type")
                return
            }
        }
    }
    
    // MARK: - TC-E10: Delete Exercise Used in Workouts
    func testDeleteExercise_WhenUsedInWorkouts_ReturnsWarning() async throws {
        // Given
        let exercise = try await sut.createExercise(
            title: "Test",
            description: nil,
            imageData: nil,
            youtubeURL: nil,
            muscleGroups: [.chest]
        )
        
        // Create a workout with this exercise
        let workout = Workout(title: "Test Workout")
        let workoutItem = WorkoutItem(
            exercise: exercise,
            position: 0,
            configurationType: .repetitions,
            sets: 3,
            repsPerSet: 10,
            restBetweenSetsSeconds: 60
        )
        workout.items.append(workoutItem)
        modelContext.insert(workout)
        try modelContext.save()
        
        // When
        let result = try await sut.deleteExercise(exercise)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertTrue(result.usedInWorkouts)
    }
}

// Helper extension for async XCTAssertThrowsError
extension XCTestCase {
    func XCTAssertThrowsError<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}

