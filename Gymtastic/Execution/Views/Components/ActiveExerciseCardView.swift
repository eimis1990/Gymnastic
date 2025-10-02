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
    let progressText: String
    let elapsedTime: String
    let percentComplete: Double
    let onSeeVideo: () -> Void
    
    var body: some View {
        switch item {
        case .exercise(let workoutItem):
            exerciseContent(workoutItem)
        case .break(let breakItem):
            breakContent(breakItem)
        }
    }
    
    @ViewBuilder
    private func exerciseContent(_ item: WorkoutItem) -> some View {
        // Exercise Image
        if let exercise = item.exercise {
            // If on set break, show break timer
            if isOnSetBreak, let remainingTime = remainingBreakTime {
                setBreakView(duration: remainingTime)
            } else {
                VStack(spacing: 0) {
                    // Exercise Image - Full Width, 4:3 aspect ratio
                    GeometryReader { geometry in
                        if let imageData = exercise.imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.width * 0.75) // 4:3 ratio
                                .clipped()
                        } else {
                            // Placeholder if no image
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: geometry.size.width, height: geometry.size.width * 0.75) // 4:3 ratio
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    .frame(height: UIScreen.main.bounds.width * 0.75) // Match the 4:3 ratio height for full width
                    
                    // Overlapping info card - Full Width (outside image container)
                    VStack(alignment: .leading, spacing: 12) {
                        // Title
                        Text(exercise.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Description if available
                        if let description = exercise.exerciseDescription, !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(2)
                        }
                        
                        // Set Indicator
                        if let set = currentSet, let totalSets = item.sets {
                            Text("Set \(set) of \(totalSets)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.gymAccent)
                        }
                        
                        // Stats
                        HStack(spacing: 16) {
                            switch item.configurationType {
                            case .repetitions:
                                // Reps
                                HStack(spacing: 4) {
                                    Text("\(item.repsPerSet ?? 0)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Text("reps")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                if let totalSets = item.sets {
                                    // Separator
                                    Circle()
                                        .fill(Color.white.opacity(0.5))
                                        .frame(width: 4, height: 4)
                                    
                                    // Sets
                                    HStack(spacing: 4) {
                                        Text("\(totalSets)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        Text("sets")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                
                                if let rest = item.restBetweenSetsSeconds, rest > 0 {
                                    // Separator
                                    Circle()
                                        .fill(Color.white.opacity(0.5))
                                        .frame(width: 4, height: 4)
                                    
                                    // Rest
                                    HStack(spacing: 4) {
                                        Text("\(rest)s")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                        Text("rest")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                
                            case .time:
                                // Duration
                                HStack(spacing: 4) {
                                    Text("\(item.durationSeconds ?? 0)s")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Text("duration")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Rectangle()
                            .fill(Color.black.opacity(0.75))
                            .background(
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                            )
                    )
                    
                    // Custom Progress Line
                    VStack(spacing: 12) {
                        // Progress bar - 10px height
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 10)
                                
                                // Progress fill
                                Rectangle()
                                    .fill(Color.gymAccent)
                                    .frame(width: geometry.size.width * percentComplete, height: 10)
                            }
                        }
                        .frame(height: 10)
                        
                        // Text below the line
                        HStack {
                            Text(progressText)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(elapsedTime)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
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
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
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
                    .foregroundColor(.gymAccent)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.info.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.info.opacity(0.3), lineWidth: 2)
        )
        .padding(.horizontal, 20)
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
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.info.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.info.opacity(0.3), lineWidth: 2)
        )
        .padding(.horizontal, 20)
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
            progressText: "Exercise 1 of 4",
            elapsedTime: "0:45",
            percentComplete: 0.25,
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
            progressText: "Exercise 1 of 4",
            elapsedTime: "1:15",
            percentComplete: 0.5,
            onSeeVideo: {}
        )
        
        // Regular break with countdown
        ActiveExerciseCardView(
            item: .break(Break(durationSeconds: 120, position: 1)),
            currentSet: nil,
            isOnSetBreak: false,
            remainingBreakTime: nil,
            remainingRegularBreakTime: 90,
            progressText: "Exercise 2 of 4",
            elapsedTime: "2:30",
            percentComplete: 0.75,
            onSeeVideo: {}
        )
    }
    .padding()
}

