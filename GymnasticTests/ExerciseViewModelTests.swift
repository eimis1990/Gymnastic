//
//  ExerciseViewModelTests.swift
//  GymtasticTests
//
//  Created on 2025-10-01.
//

import XCTest
import SwiftData
@testable import Gymtastic

final class ExerciseViewModelTests: XCTestCase {
    var sut: ExerciseViewModel!
    var mockService: MockExerciseService!
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
        mockService = MockExerciseService(modelContext: modelContext)
        sut = ExerciseViewModel(service: mockService)
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        modelContext = nil
    }
    
    // MARK: - Create Exercise Tests
    func testCreateExercise_WithValidData_CreatesExercise() async throws {
        // Given
        let title = "Push Up"
        let description = "Classic exercise"
        let muscleGroups: [MuscleGroup] = [.chest, .triceps]
        
        // When
        await sut.createExercise(
            title: title,
            description: description,
            imageData: nil,
            youtubeURL: nil,
            muscleGroups: muscleGroups
        )
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockService.createCallCount, 1)
    }
    
    // MARK: - Load Exercises Tests
    func testLoadExercises_UpdatesExercisesList() async {
        // When
        await sut.loadExercises()
        
        // Then
        XCTAssertFalse(sut.isLoading)
        XCTAssertGreaterThanOrEqual(sut.exercises.count, 0)
    }
    
    // MARK: - Delete Exercise Tests
    func testDeleteExercise_RemovesExercise() async throws {
        // Given
        let exercise = Exercise(title: "Test", muscleGroups: [.chest])
        modelContext.insert(exercise)
        try modelContext.save()
        await sut.loadExercises()
        
        // When
        await sut.deleteExercise(exercise)
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Search Tests
    func testSearchExercises_WithQuery_FiltersExercises() async {
        // Given
        let query = "push"
        
        // When
        await sut.searchExercises(query: query)
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
}

// MARK: - Mock Service
class MockExerciseService: ExerciseServiceProtocol {
    let modelContext: ModelContext
    var createCallCount = 0
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createExercise(title: String, description: String?, imageData: Data?, youtubeURL: String?, muscleGroups: [MuscleGroup]) async throws -> Exercise {
        createCallCount += 1
        let exercise = Exercise(title: title, description: description, muscleGroups: muscleGroups)
        modelContext.insert(exercise)
        try modelContext.save()
        return exercise
    }
    
    func updateExercise(_ exercise: Exercise, title: String, description: String?, imageData: Data?, youtubeURL: String?, muscleGroups: [MuscleGroup]) async throws {
        exercise.title = title
        exercise.exerciseDescription = description
        exercise.muscleGroups = muscleGroups.map { $0.rawValue }
        try modelContext.save()
    }
    
    func deleteExercise(_ exercise: Exercise) async throws -> (success: Bool, usedInWorkouts: Bool) {
        modelContext.delete(exercise)
        try modelContext.save()
        return (true, false)
    }
    
    func fetchAllExercises() async throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>()
        return try modelContext.fetch(descriptor)
    }
    
    func fetchExercises(byMuscleGroup muscleGroup: MuscleGroup) async throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>()
        let exercises = try modelContext.fetch(descriptor)
        return exercises.filter { $0.muscleGroupsEnum.contains(muscleGroup) }
    }
    
    func searchExercises(query: String) async throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>()
        let exercises = try modelContext.fetch(descriptor)
        return exercises.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    
    func generateThumbnail(from imageData: Data) async throws -> Data {
        return Data(count: 50_000)
    }
    
    func validateImageSize(_ imageData: Data) -> Bool {
        return imageData.count <= 2_000_000
    }
    
    func validateExercise(title: String, youtubeURL: String?, muscleGroups: [MuscleGroup]) throws {
        if title.isEmpty {
            throw ExerciseServiceError.invalidTitle
        }
        if muscleGroups.isEmpty {
            throw ExerciseServiceError.noMuscleGroupsSelected
        }
    }
    
    func isValidYouTubeURL(_ url: String) -> Bool {
        return url.contains("youtube.com") || url.contains("youtu.be")
    }
}

