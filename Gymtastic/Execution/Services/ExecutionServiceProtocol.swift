//
//  ExecutionServiceProtocol.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import Foundation

/// Execution status
enum ExecutionStatus {
    case active
    case paused
    case completed
    case stopped
}

/// Execution session
struct ExecutionSession: Identifiable {
    let id: UUID
    let workout: Workout
    let startTime: Date
    var currentItemIndex: Int
    var completedItemIndices: [Int]
    var status: ExecutionStatus
    var pausedAt: Date?
    
    // Set tracking for repetition-based exercises
    var currentSet: Int? // Current set number (1-based)
    var isOnSetBreak: Bool = false // True when resting between sets
    var setBreakStartTime: Date? // When the break between sets started
    var setBreakDuration: Int? // Duration in seconds for the current set break
    
    // Break tracking for regular breaks between exercises
    var regularBreakStartTime: Date? // When a regular break item started
    
    var currentItem: WorkoutSequenceItem? {
        let sequence = workout.orderedSequence
        guard currentItemIndex < sequence.count else { return nil }
        return sequence[currentItemIndex]
    }
    
    var elapsedTime: TimeInterval {
        if let pausedAt = pausedAt {
            return pausedAt.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
    
    var remainingBreakTime: Int? {
        guard isOnSetBreak,
              let breakStart = setBreakStartTime,
              let duration = setBreakDuration else {
            return nil
        }
        let elapsed = Date().timeIntervalSince(breakStart)
        let remaining = max(0, duration - Int(elapsed))
        return remaining
    }
    
    var remainingRegularBreakTime: Int? {
        guard case .break(let breakItem) = currentItem,
              let breakStart = regularBreakStartTime else {
            return nil
        }
        let elapsed = Date().timeIntervalSince(breakStart)
        let remaining = max(0, breakItem.durationSeconds - Int(elapsed))
        return remaining
    }
}

/// Workout progress information
struct WorkoutProgress {
    let currentIndex: Int
    let totalItems: Int
    let completedItems: Int
    let remainingItems: Int
    let percentComplete: Double
    let elapsedTime: TimeInterval
    let estimatedRemainingTime: TimeInterval
    
    var progressText: String {
        "Exercise \(currentIndex + 1) of \(totalItems)"
    }
}

/// Workout completion summary
struct WorkoutSummary {
    let workoutTitle: String
    let startTime: Date
    let endTime: Date
    let totalDuration: TimeInterval
    let completedExercises: Int
    let totalExercises: Int
    let wasCompleted: Bool // true if finished, false if stopped early
    
    var formattedDuration: String {
        let minutes = Int(totalDuration) / 60
        let seconds = Int(totalDuration) % 60
        return "\(minutes)m \(seconds)s"
    }
}

/// Service error types for execution operations
enum ExecutionServiceError: LocalizedError, Equatable {
    case workoutNotValid
    case sessionNotActive
    case alreadyCompleted
    case cannotAdvance
    case noCurrentItem
    
    var errorDescription: String? {
        switch self {
        case .workoutNotValid:
            return "Workout cannot be started (no exercises)"
        case .sessionNotActive:
            return "Session is not active"
        case .alreadyCompleted:
            return "Workout already completed"
        case .cannotAdvance:
            return "Cannot advance to next item"
        case .noCurrentItem:
            return "No current item in session"
        }
    }
}

/// Protocol defining execution service operations
protocol ExecutionServiceProtocol {
    // MARK: - Execution Control
    
    /// Starts workout execution
    func startWorkout(_ workout: Workout) async throws -> ExecutionSession
    
    /// Advances to next item in workout
    func nextItem(session: ExecutionSession) async throws -> ExecutionSession
    
    /// Pauses workout execution
    func pauseWorkout(session: ExecutionSession) async -> ExecutionSession
    
    /// Resumes paused workout
    func resumeWorkout(session: ExecutionSession) async -> ExecutionSession
    
    /// Stops workout execution
    func stopWorkout(session: ExecutionSession) async -> WorkoutSummary
    
    /// Completes workout execution
    func completeWorkout(session: ExecutionSession) async -> WorkoutSummary
    
    // MARK: - Progress Tracking
    
    /// Gets current progress
    func getProgress(for session: ExecutionSession) -> WorkoutProgress
    
    /// Gets upcoming items
    func getUpcomingItems(for session: ExecutionSession, count: Int) -> [WorkoutSequenceItem]
    
    /// Checks if workout is complete
    func isWorkoutComplete(session: ExecutionSession) -> Bool
}

