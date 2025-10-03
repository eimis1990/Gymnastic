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
                        HomeTabView()
                    case 1:
                        ExercisesTabView()
                    case 2:
                        WorkoutsTabView()
                    case 3:
                        ProfileTabView()
                    default:
                        HomeTabView()
                    }
                }
            }
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .background(Color.appBackground)
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 8) {
            // Home Tab
            TabBarButton(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            // Exercises Tab
            TabBarButton(
                icon: "dumbbell.fill",
                title: "Exercises",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            // Workouts Tab
            TabBarButton(
                icon: "list.bullet.rectangle.fill",
                title: "Workouts",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            // Profile Tab
            TabBarButton(
                icon: "person.fill",
                title: "Profile",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(Color.cardBackground)
        .cornerRadius(40)
        .shadow(color: Color.shadowStandard, radius: 8, x: 0, y: -2)
        .padding(.horizontal, 20)
        .padding(.bottom, 0)
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
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .textPrimary : .textSecondary)
                
                // Dot indicator
                Circle()
                    .fill(isSelected ? Color.gymAccent : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Home Tab

struct HomeTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.updatedAt, order: .reverse) private var workouts: [Workout]
    @State private var searchText = ""
    @State private var selectedWorkout: Workout?
    
    var favoriteWorkouts: [Workout] {
        // For now, just return first 3 workouts. Later we can add a favorite flag
        Array(workouts.prefix(3))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Profile Image and Greeting
                    HStack(spacing: 16) {
                        // Profile Image
                        Circle()
                            .fill(Color.gymAccent.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gymAccent)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good Morning")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            Text("Hi Alexa")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                        }
                        
                        Spacer()
                        
                        // Notification Bell
                        Button {
                            // TODO: Show notifications
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.title2)
                                    .foregroundColor(.textPrimary)
                                
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 2, y: -2)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textSecondary)
                        
                        TextField("Search", text: $searchText)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Button {
                            // TODO: Open filters
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Quick Actions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            QuickActionButton(icon: "dumbbell.fill", title: "Strength", selectedTab: 1)
                            QuickActionButton(icon: "figure.run", title: "Cardio", selectedTab: 2)
                            QuickActionButton(icon: "figure.mind.and.body", title: "Yoga", selectedTab: 2)
                            QuickActionButton(icon: "figure.strengthtraining.traditional", title: "Weight", selectedTab: 1)
                            QuickActionButton(icon: "sportscourt.fill", title: "Sports", selectedTab: 2)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Promotional Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("25%")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.textPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.appBackground)
                                    .cornerRadius(12)
                                
                                Text("Off your first session!")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Button {
                                    // TODO: Get started action
                                } label: {
                                    Text("Get Started")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.black.opacity(0.3))
                                        .cornerRadius(20)
                                }
                                .padding(.top, 4)
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(
                            LinearGradient(
                                colors: [Color.gymAccent.opacity(0.8), Color.gymAccent.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.shadowStandard, radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    
                    // Favorite Workouts Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Favorite Workouts")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            Button {
                                // TODO: Navigate to all workouts
                            } label: {
                                Text("See all")
                                    .font(.subheadline)
                                    .foregroundColor(.gymAccent)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if favoriteWorkouts.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.textSecondary)
                                
                                Text("No favorite workouts yet")
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                                
                                Text("Start creating workouts to see them here")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(favoriteWorkouts) { workout in
                                        Button {
                                            selectedWorkout = workout
                                        } label: {
                                            FavoriteWorkoutCard(workout: workout)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color.appBackground)
            .navigationBarHidden(true)
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout, modelContext: modelContext)
            }
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let selectedTab: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color.cardBackground)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.textPrimary)
                )
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Favorite Workout Card

struct FavoriteWorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Mock image placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gymAccent.opacity(0.3))
                .frame(width: 180, height: 120)
                .overlay(
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gymAccent)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Label("\(workout.items.count)", systemImage: "dumbbell.fill")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                    
                    Label(workout.estimatedDurationFormatted, systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .frame(width: 180)
    }
}

// MARK: - Profile Tab

struct ProfileTabView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.gymAccent)
                
                Text("Profile")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .padding(.top, 16)
                
                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
            .navigationTitle("Profile")
        }
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
            VStack(spacing: 0) {
                // Main Content
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
                    }
                    .padding(.vertical)
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
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
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


