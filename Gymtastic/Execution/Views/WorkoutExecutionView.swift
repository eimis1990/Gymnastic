//
//  WorkoutExecutionView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI

struct WorkoutExecutionView: View {
    let workout: Workout
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: ExecutionViewModel
    @State private var showStopAlert = false
    @State private var showVideoPlayer = false
    @State private var showSummary = false
    @State private var summary: WorkoutSummary?
    @State private var timerTick: Int = 0
    
    init(workout: Workout) {
        self.workout = workout
        _viewModel = State(initialValue: ExecutionViewModel(service: ExecutionService()))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let _ = viewModel.session {
                    executionContent
                } else {
                    ZStack {
                        Color.appBackground
                            .ignoresSafeArea()
                        Text("Loading...")
                            .foregroundColor(.textPrimary)
                    }
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle(workout.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showStopAlert = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isPaused {
                        Button("Resume") {
                            Task {
                                await viewModel.resumeWorkout()
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    } else if viewModel.isActive {
                        Button("Pause") {
                            Task {
                                await viewModel.pauseWorkout()
                            }
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .alert("Stop Workout?", isPresented: $showStopAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Stop", role: .destructive) {
                    Task {
                        summary = await viewModel.stopWorkout()
                        showSummary = true
                    }
                }
            } message: {
                Text("Are you sure you want to stop this workout? Your progress will not be saved.")
            }
            .sheet(isPresented: $showVideoPlayer) {
                if case .exercise(let item) = viewModel.currentItem,
                   let exercise = item.exercise,
                   let urlString = exercise.youtubeURL,
                   let url = URL(string: urlString) {
                    YouTubeBottomSheet(url: url)
                }
            }
            .fullScreenCover(isPresented: $showSummary) {
                if let summary = summary {
                    CompletionSummaryView(summary: summary) {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.startWorkout(workout)
        }
        .task {
            // Timer for countdown updates
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                timerTick += 1
            }
        }
    }
    
    private var executionContent: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                // Active Exercise Card with integrated progress
                if let currentItem = viewModel.currentItem {
                    ActiveExerciseCardView(
                        item: currentItem,
                        currentSet: viewModel.session?.currentSet,
                        isOnSetBreak: viewModel.session?.isOnSetBreak ?? false,
                        remainingBreakTime: viewModel.session?.remainingBreakTime,
                        remainingRegularBreakTime: viewModel.session?.remainingRegularBreakTime,
                        progressText: viewModel.progress?.progressText ?? "",
                        elapsedTime: viewModel.elapsedTime,
                        percentComplete: viewModel.progress?.percentComplete ?? 0
                    ) {
                        showVideoPlayer = true
                    }
                    .id(timerTick) // Force update every second for countdown
                }
                
                // Complete/Next Button
                if !viewModel.isWorkoutComplete {
                    Button {
                        Task {
                            await viewModel.nextItem()
                            
                            if viewModel.isWorkoutComplete {
                                summary = await viewModel.completeWorkout()
                                showSummary = true
                            }
                        }
                    } label: {
                        HStack {
                            Text(buttonText)
                                .fontWeight(.semibold)
                            Image(systemName: buttonIcon)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gymAccent)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .disabled(viewModel.isPaused)
                }
                
                // Upcoming Items
                if !viewModel.upcomingItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Coming Up")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            ForEach(Array(viewModel.upcomingItems.enumerated()), id: \.offset) { index, item in
                                UpcomingItemRowView(
                                    item: item,
                                    position: (viewModel.session?.currentItemIndex ?? 0) + index + 2
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                }
            }
                .padding(.bottom, 20)
            }
            .ignoresSafeArea(edges: .top)
        }
        .overlay {
            if viewModel.isPaused {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("Workout Paused")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Tap Resume to continue")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
    }
    
    private var buttonText: String {
        guard let session = viewModel.session else { return "Next" }
        
        // Check if on regular break (between exercises)
        if case .break = session.currentItem {
            return "Skip Break"
        }
        
        // Check if on set break (between sets of same exercise)
        if session.isOnSetBreak {
            return "Skip Break"
        }
        
        // Check if doing a set of a multi-set exercise
        if let currentSet = session.currentSet,
           case .exercise(let item) = session.currentItem,
           let totalSets = item.sets,
           currentSet < totalSets {
            return "Complete Set"
        }
        
        return "Next"
    }
    
    private var buttonIcon: String {
        guard let session = viewModel.session else { return "arrow.right" }
        
        // Regular break or set break
        if case .break = session.currentItem {
            return "forward.fill"
        }
        
        if session.isOnSetBreak {
            return "forward.fill"
        }
        
        // Multi-set exercise
        if session.currentSet != nil {
            return "checkmark"
        }
        
        return "arrow.right"
    }
}

// MARK: - Preview

#Preview {
    let workout = Workout(title: "Test Workout")
    let ex1 = Exercise(title: "Push Up", muscleGroups: [.chest])
    let item1 = WorkoutItem(exercise: ex1, position: 0, configurationType: .repetitions,
                            sets: 3, repsPerSet: 12, restBetweenSetsSeconds: 60)
    workout.items.append(item1)
    
    return WorkoutExecutionView(workout: workout)
}

