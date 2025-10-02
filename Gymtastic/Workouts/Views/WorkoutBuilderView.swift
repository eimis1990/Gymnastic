//
//  WorkoutBuilderView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI
import SwiftData

struct WorkoutBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]
    
    @State private var viewModel: WorkoutBuilderViewModel
    @State private var workoutTitle = ""
    @State private var showExerciseSelection = false
    @State private var showBreakConfiguration = false
    @State private var showExerciseConfiguration = false
    @State private var selectedExerciseForConfiguration: Exercise?
    
    let workout: Workout?
    
    init(workout: Workout? = nil, modelContext: ModelContext) {
        self.workout = workout
        let service = WorkoutService(modelContext: modelContext)
        _viewModel = State(initialValue: WorkoutBuilderViewModel(service: service))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header Section
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Workout Name", text: $workoutTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .textFieldStyle(.plain)
                    
                    if let currentWorkout = viewModel.currentWorkout {
                        HStack {
                            Label("\(currentWorkout.items.count) exercises", systemImage: "dumbbell.fill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Label(currentWorkout.estimatedDurationFormatted, systemImage: "clock")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Timeline View
                if let currentWorkout = viewModel.currentWorkout {
                    WorkoutTimelineView(
                        workout: currentWorkout,
                        onReorder: { from, to in
                            Task {
                                await viewModel.reorderWorkoutItems(from: from, to: to)
                            }
                        },
                        onDelete: { index in
                            Task {
                                await viewModel.removeWorkoutItem(at: index)
                            }
                        },
                        onAddExercise: {
                            showExerciseSelection = true
                        },
                        onAddBreak: {
                            showBreakConfiguration = true
                        }
                    )
                } else {
                    loadingView
                }
            }
            .navigationTitle(workout == nil ? "New Workout" : "Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveWorkout()
                        }
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showExerciseSelection) {
                ExerciseSelectionSheet(exercises: exercises) { exercise in
                    selectedExerciseForConfiguration = exercise
                    showExerciseSelection = false
                    showExerciseConfiguration = true
                }
            }
            .sheet(isPresented: $showExerciseConfiguration) {
                if let exercise = selectedExerciseForConfiguration {
                    ExerciseConfigurationSheet(exercise: exercise) { config in
                        Task {
                            await viewModel.addExercise(exercise, configuration: config)
                        }
                        showExerciseConfiguration = false
                        selectedExerciseForConfiguration = nil
                    }
                }
            }
            .sheet(isPresented: $showBreakConfiguration) {
                BreakConfigurationSheet { duration in
                    Task {
                        await viewModel.addBreak(durationSeconds: duration)
                    }
                    showBreakConfiguration = false
                }
            }
            .loadingOverlay(isLoading: viewModel.isLoading)
            .errorAlert(error: $viewModel.errorMessage)
        }
        .task {
            if let existingWorkout = workout {
                workoutTitle = existingWorkout.title
                await viewModel.loadWorkout(existingWorkout)
            } else {
                await viewModel.createNewWorkout(title: "New Workout")
            }
        }
    }
    
    private var isValid: Bool {
        !workoutTitle.trimmingCharacters(in: .whitespaces).isEmpty &&
        viewModel.currentWorkout?.items.isEmpty == false
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func saveWorkout() async {
        guard let currentWorkout = viewModel.currentWorkout else { return }
        await viewModel.updateWorkoutTitle(workoutTitle)
        
        if viewModel.errorMessage == nil {
            dismiss()
        }
    }
}

// MARK: - Exercise Selection Sheet

struct ExerciseSelectionSheet: View {
    let exercises: [Exercise]
    let onSelect: (Exercise) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { exercise in
            exercise.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filteredExercises.isEmpty {
                    ContentUnavailableView(
                        "No Exercises",
                        systemImage: "dumbbell.fill",
                        description: Text("Create exercises first before adding them to workouts")
                    )
                } else {
                    ForEach(filteredExercises) { exercise in
                        Button {
                            onSelect(exercise)
                        } label: {
                            HStack(spacing: 12) {
                                if let thumbnailData = exercise.thumbnailData,
                                   let uiImage = UIImage(data: thumbnailData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(8)
                                        .clipped()
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.title)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(exercise.muscleGroupsEnum.map(\.rawValue).joined(separator: ", "))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.gymYellow)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Exercise Configuration Sheet

struct ExerciseConfigurationSheet: View {
    let exercise: Exercise
    let onSave: (ExerciseConfiguration) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var configurationType: ConfigurationType = .repetitions
    @State private var sets = 3
    @State private var repsPerSet = 10
    @State private var restBetweenSets = 60
    @State private var durationSeconds = 45
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise") {
                    HStack {
                        if let thumbnailData = exercise.thumbnailData,
                           let uiImage = UIImage(data: thumbnailData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                                .clipped()
                        }
                        
                        Text(exercise.title)
                            .font(.headline)
                    }
                }
                
                Section("Configuration Type") {
                    Picker("Type", selection: $configurationType) {
                        Text("Repetitions").tag(ConfigurationType.repetitions)
                        Text("Time").tag(ConfigurationType.time)
                    }
                    .pickerStyle(.segmented)
                }
                
                if configurationType == .repetitions {
                    Section("Repetitions") {
                        Stepper("Sets: \(sets)", value: $sets, in: 1...10)
                        Stepper("Reps per set: \(repsPerSet)", value: $repsPerSet, in: 1...100)
                        Stepper("Rest between sets: \(restBetweenSets)s", value: $restBetweenSets, in: 0...300, step: 15)
                    }
                } else {
                    Section("Duration") {
                        Stepper("Duration: \(durationSeconds)s", value: $durationSeconds, in: 5...600, step: 5)
                        
                        HStack {
                            Spacer()
                            Text(formatDuration(durationSeconds))
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Configure Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let config = ExerciseConfiguration(
                            type: configurationType,
                            sets: sets,
                            repsPerSet: repsPerSet,
                            restBetweenSets: restBetweenSets,
                            durationSeconds: durationSeconds
                        )
                        onSave(config)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        }
        return "\(remainingSeconds)s"
    }
}

// MARK: - Break Configuration Sheet

struct BreakConfigurationSheet: View {
    let onSave: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var durationSeconds = 120
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Break Duration") {
                    Stepper("Duration: \(durationSeconds)s", value: $durationSeconds, in: 15...600, step: 15)
                    
                    HStack {
                        Spacer()
                        VStack {
                            Text(formatDuration(durationSeconds))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Text("Break Time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                }
                
                Section("Quick Presets") {
                    HStack {
                        ForEach([30, 60, 90, 120], id: \.self) { preset in
                            Button("\(preset)s") {
                                durationSeconds = preset
                            }
                            .buttonStyle(.bordered)
                            .tint(durationSeconds == preset ? .blue : .gray)
                        }
                    }
                }
            }
            .navigationTitle("Add Break")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(durationSeconds)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        }
        return "\(remainingSeconds)s"
    }
}

// MARK: - Preview

#Preview {
    WorkoutBuilderView(modelContext: ModelContext(
        try! ModelContainer(for: Exercise.self, Workout.self, WorkoutItem.self, Break.self)
    ))
}

