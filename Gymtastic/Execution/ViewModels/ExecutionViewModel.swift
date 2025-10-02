//
//  ExecutionViewModel.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import Foundation

/// ViewModel for workout execution
@Observable
final class ExecutionViewModel {
    // MARK: - Properties
    var session: ExecutionSession?
    var errorMessage: String?
    var isLoading = false
    
    private let service: ExecutionServiceProtocol
    
    // MARK: - Initialization
    init(service: ExecutionServiceProtocol) {
        self.service = service
    }
    
    // MARK: - Execution Control
    
    @MainActor
    func startWorkout(_ workout: Workout) async {
        isLoading = true
        errorMessage = nil
        
        do {
            session = try await service.startWorkout(workout)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func nextItem() async {
        guard let currentSession = session else { return }
        
        do {
            session = try await service.nextItem(session: currentSession)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func pauseWorkout() async {
        guard let currentSession = session else { return }
        session = await service.pauseWorkout(session: currentSession)
    }
    
    @MainActor
    func resumeWorkout() async {
        guard let currentSession = session else { return }
        session = await service.resumeWorkout(session: currentSession)
    }
    
    @MainActor
    func stopWorkout() async -> WorkoutSummary? {
        guard let currentSession = session else { return nil }
        
        let summary = await service.stopWorkout(session: currentSession)
        session = nil
        return summary
    }
    
    @MainActor
    func completeWorkout() async -> WorkoutSummary? {
        guard let currentSession = session else { return nil }
        
        let summary = await service.completeWorkout(session: currentSession)
        session = nil
        return summary
    }
    
    // MARK: - Progress Tracking
    
    var progress: WorkoutProgress? {
        guard let currentSession = session else { return nil }
        return service.getProgress(for: currentSession)
    }
    
    var upcomingItems: [WorkoutSequenceItem] {
        guard let currentSession = session else { return [] }
        return service.getUpcomingItems(for: currentSession, count: 5)
    }
    
    var currentItem: WorkoutSequenceItem? {
        session?.currentItem
    }
    
    var isWorkoutComplete: Bool {
        guard let currentSession = session else { return false }
        return service.isWorkoutComplete(session: currentSession)
    }
    
    var isActive: Bool {
        session?.status == .active
    }
    
    var isPaused: Bool {
        session?.status == .paused
    }
    
    var elapsedTime: String {
        guard let currentSession = session else { return "0:00" }
        let elapsed = currentSession.elapsedTime
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Helpers
    
    func clearError() {
        errorMessage = nil
    }
}

