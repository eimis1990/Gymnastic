//
//  ExecutionService.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import Foundation

/// Service for managing workout execution
final class ExecutionService: ExecutionServiceProtocol {
    
    // MARK: - Execution Control
    
    func startWorkout(_ workout: Workout) async throws -> ExecutionSession {
        // Validate workout
        guard !workout.items.isEmpty else {
            throw ExecutionServiceError.workoutNotValid
        }
        
        var session = ExecutionSession(
            id: UUID(),
            workout: workout,
            startTime: Date(),
            currentItemIndex: 0,
            completedItemIndices: [],
            status: .active,
            pausedAt: nil,
            currentSet: nil,
            isOnSetBreak: false,
            setBreakStartTime: nil,
            setBreakDuration: nil,
            regularBreakStartTime: nil
        )
        
        // Initialize set tracking if first item is a repetition-based exercise
        if case .exercise(let item) = session.currentItem,
           item.configurationType == .repetitions,
           let sets = item.sets, sets > 1 {
            session.currentSet = 1
        }
        
        // Start timer if first item is a regular break
        if case .break = session.currentItem {
            session.regularBreakStartTime = Date()
        }
        
        return session
    }
    
    func nextItem(session: ExecutionSession) async throws -> ExecutionSession {
        guard session.status == .active else {
            throw ExecutionServiceError.sessionNotActive
        }
        
        var updatedSession = session
        
        // If currently on a set break, complete the break and move to next set
        if updatedSession.isOnSetBreak {
            updatedSession.isOnSetBreak = false
            updatedSession.setBreakStartTime = nil
            updatedSession.setBreakDuration = nil
            if let currentSet = updatedSession.currentSet {
                updatedSession.currentSet = currentSet + 1
            }
            return updatedSession
        }
        
        // Check if current item is a multi-set exercise
        if case .exercise(let item) = session.currentItem,
           item.configurationType == .repetitions,
           let sets = item.sets,
           let currentSet = session.currentSet,
           currentSet < sets {
            // Start break between sets
            if let restDuration = item.restBetweenSetsSeconds, restDuration > 0 {
                updatedSession.isOnSetBreak = true
                updatedSession.setBreakStartTime = Date()
                updatedSession.setBreakDuration = restDuration
                return updatedSession
            } else {
                // No break, just move to next set
                updatedSession.currentSet = currentSet + 1
                return updatedSession
            }
        }
        
        // Move to next item in sequence
        let totalItems = session.workout.orderedSequence.count
        let nextIndex = session.currentItemIndex + 1
        
        guard nextIndex <= totalItems else {
            throw ExecutionServiceError.cannotAdvance
        }
        
        updatedSession.completedItemIndices.append(session.currentItemIndex)
        updatedSession.currentItemIndex = nextIndex
        updatedSession.currentSet = nil
        updatedSession.isOnSetBreak = false
        updatedSession.setBreakStartTime = nil
        updatedSession.setBreakDuration = nil
        updatedSession.regularBreakStartTime = nil
        
        // Initialize set tracking for next item if it's a multi-set exercise
        if case .exercise(let item) = updatedSession.currentItem,
           item.configurationType == .repetitions,
           let sets = item.sets, sets > 1 {
            updatedSession.currentSet = 1
        }
        
        // Start timer if next item is a regular break
        if case .break = updatedSession.currentItem {
            updatedSession.regularBreakStartTime = Date()
        }
        
        return updatedSession
    }
    
    func pauseWorkout(session: ExecutionSession) async -> ExecutionSession {
        var updatedSession = session
        updatedSession.status = .paused
        updatedSession.pausedAt = Date()
        return updatedSession
    }
    
    func resumeWorkout(session: ExecutionSession) async -> ExecutionSession {
        var updatedSession = session
        updatedSession.status = .active
        updatedSession.pausedAt = nil
        return updatedSession
    }
    
    func stopWorkout(session: ExecutionSession) async -> WorkoutSummary {
        let endTime = Date()
        let totalDuration = endTime.timeIntervalSince(session.startTime)
        
        // Count only completed exercises (not breaks)
        let completedExercises = countCompletedExercises(in: session)
        let totalExercises = session.workout.items.count
        
        return WorkoutSummary(
            workoutTitle: session.workout.title,
            startTime: session.startTime,
            endTime: endTime,
            totalDuration: totalDuration,
            completedExercises: completedExercises,
            totalExercises: totalExercises,
            wasCompleted: false
        )
    }
    
    func completeWorkout(session: ExecutionSession) async -> WorkoutSummary {
        let endTime = Date()
        let totalDuration = endTime.timeIntervalSince(session.startTime)
        let totalExercises = session.workout.items.count
        
        return WorkoutSummary(
            workoutTitle: session.workout.title,
            startTime: session.startTime,
            endTime: endTime,
            totalDuration: totalDuration,
            completedExercises: totalExercises,
            totalExercises: totalExercises,
            wasCompleted: true
        )
    }
    
    // MARK: - Progress Tracking
    
    func getProgress(for session: ExecutionSession) -> WorkoutProgress {
        let totalItems = session.workout.orderedSequence.count
        let completedItems = session.completedItemIndices.count
        let remainingItems = totalItems - session.currentItemIndex
        let percentComplete = totalItems > 0 ? Double(completedItems) / Double(totalItems) : 0.0
        
        let elapsedTime = session.elapsedTime
        let estimatedTotal = Double(session.workout.estimatedDuration)
        let estimatedRemaining = max(0, estimatedTotal - elapsedTime)
        
        return WorkoutProgress(
            currentIndex: session.currentItemIndex,
            totalItems: totalItems,
            completedItems: completedItems,
            remainingItems: remainingItems,
            percentComplete: percentComplete,
            elapsedTime: elapsedTime,
            estimatedRemainingTime: estimatedRemaining
        )
    }
    
    func getUpcomingItems(for session: ExecutionSession, count: Int) -> [WorkoutSequenceItem] {
        let sequence = session.workout.orderedSequence
        let startIndex = session.currentItemIndex + 1
        let endIndex = min(startIndex + count, sequence.count)
        
        guard startIndex < sequence.count else {
            return []
        }
        
        return Array(sequence[startIndex..<endIndex])
    }
    
    func isWorkoutComplete(session: ExecutionSession) -> Bool {
        let totalItems = session.workout.orderedSequence.count
        return session.currentItemIndex >= totalItems
    }
    
    // MARK: - Private Helpers
    
    private func countCompletedExercises(in session: ExecutionSession) -> Int {
        let sequence = session.workout.orderedSequence
        var count = 0
        
        for index in session.completedItemIndices {
            guard index < sequence.count else { continue }
            if case .exercise = sequence[index] {
                count += 1
            }
        }
        
        return count
    }
}

