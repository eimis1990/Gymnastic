//
//  ContentView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                Group {
                    switch selectedTab {
                    case 0:
                        ExercisesTabView()
                    case 1:
                        WorkoutsTabView()
                    default:
                        ExercisesTabView()
                    }
                }
            }
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 8) {
            // Exercises Tab
            TabBarButton(
                icon: "dumbbell.fill",
                title: "Exercises",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            // Workouts Tab
            TabBarButton(
                icon: "list.bullet.rectangle.fill",
                title: "Workouts",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color.cardBackground)
        .cornerRadius(40)
        .shadow(color: Color.shadowStandard, radius: 8, x: 0, y: -2)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                
                if isSelected {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                }
            }
            .foregroundColor(isSelected ? .textPrimary : .textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                isSelected ? Color.appBackground : Color.clear
            )
            .cornerRadius(25)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Exercises Tab

struct ExercisesTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.createdAt, order: .reverse) private var exercises: [Exercise]
    @State private var showCreateExercise = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredExercises) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                            ExerciseCardView(exercise: exercise, showChevron: false)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteExercise(exercise)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color.appBackground)
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Exercises")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateExercise = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gymAccent)
                    }
                }
            }
            .sheet(isPresented: $showCreateExercise) {
                CreateExerciseView(modelContext: modelContext)
            }
            .overlay {
                if exercises.isEmpty {
                    EmptyStateView(
                        icon: "dumbbell.fill",
                        title: "No Exercises Yet",
                        message: "Tap + to create your first exercise"
                    )
                }
            }
        }
    }
    
    private var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func deleteExercises(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(exercises[index])
        }
    }
    
    private func deleteExercise(_ exercise: Exercise) {
        modelContext.delete(exercise)
    }
}

// MARK: - Workouts Tab

struct WorkoutsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.updatedAt, order: .reverse) private var workouts: [Workout]
    @State private var showCreateWorkout = false
    @State private var selectedWorkout: Workout?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(workouts) { workout in
                        Button {
                            selectedWorkout = workout
                        } label: {
                            WorkoutCardView(workout: workout)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteWorkout(workout)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color.appBackground)
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateWorkout = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gymAccent)
                    }
                }
            }
            .sheet(isPresented: $showCreateWorkout) {
                WorkoutBuilderView(modelContext: modelContext)
            }
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout, modelContext: modelContext)
            }
            .overlay {
                if workouts.isEmpty {
                    EmptyStateView(
                        icon: "list.bullet.rectangle.fill",
                        title: "No Workouts Yet",
                        message: "Tap + to create your first workout"
                    )
                }
            }
        }
    }
    
    private func deleteWorkouts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(workouts[index])
        }
    }
    
    private func deleteWorkout(_ workout: Workout) {
        modelContext.delete(workout)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Workout Card View

struct WorkoutCardView: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            HStack {
                Label("\(workout.items.count) exercises", systemImage: "dumbbell.fill")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Label(workout.estimatedDurationFormatted, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.shadowStandard, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Workout Detail View

struct WorkoutDetailView: View {
    let workout: Workout
    let modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false
    @State private var showExecutionView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats
                    HStack(spacing: 20) {
                        StatItem(icon: "dumbbell.fill", value: "\(workout.items.count)", label: "Exercises")
                        StatItem(icon: "timer", value: "\(workout.breaks.count)", label: "Breaks")
                        StatItem(icon: "clock", value: workout.estimatedDurationFormatted, label: "Duration")
                    }
                    .padding()
                    
                    // Timeline Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Workout Timeline")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(workout.orderedSequence, id: \.id) { item in
                            switch item {
                            case .exercise(let workoutItem):
                                WorkoutItemCardView(item: workoutItem)
                                    .padding(.horizontal)
                            case .break(let breakItem):
                                BreakCardView(breakItem: breakItem)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Start Button
                    Button {
                        showExecutionView = true
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Workout")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gymAccent)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                .padding(.vertical)
            }
            .navigationTitle(workout.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                WorkoutBuilderView(workout: workout, modelContext: modelContext)
            }
            .fullScreenCover(isPresented: $showExecutionView) {
                WorkoutExecutionView(workout: workout)
            }
        }
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.gymAccent)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutItem.self, Break.self])
}


