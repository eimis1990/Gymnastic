//
//  ActiveExerciseCardView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI

struct ActiveExerciseCardView: View {
    let item: WorkoutSequenceItem
    let currentSet: Int?
    let isOnSetBreak: Bool
    let remainingBreakTime: Int?
    let remainingRegularBreakTime: Int?
    let onSeeVideo: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            switch item {
            case .exercise(let workoutItem):
                exerciseContent(workoutItem)
            case .break(let breakItem):
                breakContent(breakItem)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.gymYellow.opacity(0.1), Color.gymYellow.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    @ViewBuilder
    private func exerciseContent(_ item: WorkoutItem) -> some View {
        // Exercise Image
        if let exercise = item.exercise {
            // If on set break, show break timer
            if isOnSetBreak, let remainingTime = remainingBreakTime {
                setBreakView(duration: remainingTime)
            } else {
                // Normal exercise view
                if let imageData = exercise.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                }
                
                // Exercise Title
                Text(exercise.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // Current Set Indicator
                if let set = currentSet, let totalSets = item.sets {
                    Text("Set \(set) of \(totalSets)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gymYellow)
                        .padding(.vertical, 4)
                }
                
                // Configuration
                HStack(spacing: 20) {
                    switch item.configurationType {
                    case .repetitions:
                        VStack {
                            Image(systemName: "repeat")
                                .font(.title2)
                            Text("\(item.repsPerSet ?? 0)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Reps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let totalSets = item.sets {
                            Divider()
                                .frame(height: 50)
                            
                            VStack {
                                Image(systemName: "square.stack.3d.up")
                                    .font(.title2)
                                Text("\(totalSets)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("Total Sets")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let rest = item.restBetweenSetsSeconds, rest > 0 {
                            Divider()
                                .frame(height: 50)
                            
                            VStack {
                                Image(systemName: "timer")
                                    .font(.title2)
                                Text("\(rest)s")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("Rest")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                    case .time:
                        VStack {
                            Image(systemName: "clock")
                                .font(.title2)
                            Text("\(item.durationSeconds ?? 0)s")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("Duration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // See Video Button
                if exercise.youtubeURL != nil {
                    Button(action: onSeeVideo) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("See Video")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func setBreakView(duration: Int) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "timer.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Rest Between Sets")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("\(duration)")
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
                .monospacedDigit()
            
            Text("seconds remaining")
                .font(.body)
                .foregroundColor(.secondary)
            
            if let set = currentSet {
                Text("Get ready for Set \(set + 1)")
                    .font(.headline)
                    .foregroundColor(.gymYellow)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    @ViewBuilder
    private func breakContent(_ breakItem: Break) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "timer.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Break Time")
                .font(.title)
                .fontWeight(.bold)
            
            if let remainingTime = remainingRegularBreakTime {
                Text("\(remainingTime)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .monospacedDigit()
                
                Text("seconds remaining")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                Text(breakItem.formattedDuration)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
            }
            
            Text("Take a breather!")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // Exercise - normal view
        ActiveExerciseCardView(
            item: .exercise(WorkoutItem(
                exercise: Exercise(title: "Push Up", muscleGroups: [.chest]),
                position: 0,
                configurationType: .repetitions,
                sets: 3,
                repsPerSet: 12,
                restBetweenSetsSeconds: 60
            )),
            currentSet: 1,
            isOnSetBreak: false,
            remainingBreakTime: nil,
            remainingRegularBreakTime: nil,
            onSeeVideo: {}
        )
        
        // Exercise - on set break
        ActiveExerciseCardView(
            item: .exercise(WorkoutItem(
                exercise: Exercise(title: "Push Up", muscleGroups: [.chest]),
                position: 0,
                configurationType: .repetitions,
                sets: 3,
                repsPerSet: 12,
                restBetweenSetsSeconds: 60
            )),
            currentSet: 1,
            isOnSetBreak: true,
            remainingBreakTime: 45,
            remainingRegularBreakTime: nil,
            onSeeVideo: {}
        )
        
        // Regular break with countdown
        ActiveExerciseCardView(
            item: .break(Break(durationSeconds: 120, position: 1)),
            currentSet: nil,
            isOnSetBreak: false,
            remainingBreakTime: nil,
            remainingRegularBreakTime: 90,
            onSeeVideo: {}
        )
    }
    .padding()
}

