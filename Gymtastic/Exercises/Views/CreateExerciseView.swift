//
//  CreateExerciseView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI
import SwiftData

struct CreateExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: ExerciseViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var youtubeURL = ""
    @State private var selectedMuscleGroups: Set<MuscleGroup> = []
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var imageSourceType: ImagePickerView.SourceType = .photoLibrary
    @State private var showImageSourceSelection = false
    
    let exercise: Exercise? // For editing
    
    init(exercise: Exercise? = nil, modelContext: ModelContext) {
        self.exercise = exercise
        let service = ExerciseService(modelContext: modelContext)
        _viewModel = State(initialValue: ExerciseViewModel(service: service))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Title Section
                Section("Exercise Name") {
                    TextField("e.g., Push Up", text: $title)
                        .autocapitalization(.words)
                }
                
                // Description Section
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                
                // Image Section
                Section("Image") {
                    if let image = selectedImage {
                        HStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                                .clipped()
                            
                            Spacer()
                            
                            Button("Change") {
                                showImageSourceSelection = true
                            }
                            .buttonStyle(.bordered)
                        }
                    } else {
                        Button(action: { showImageSourceSelection = true }) {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                Text("Add Image")
                            }
                        }
                    }
                }
                
                // YouTube URL Section
                Section("Video Tutorial") {
                    TextField("YouTube URL", text: $youtubeURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .textContentType(.URL)
                }
                
                // Muscle Groups Section
                Section("Muscle Groups") {
                    ForEach(MuscleGroup.allCases) { muscleGroup in
                        Button {
                            toggleMuscleGroup(muscleGroup)
                        } label: {
                            HStack {
                                Image(systemName: muscleGroup.sfSymbolName)
                                    .foregroundColor(selectedMuscleGroups.contains(muscleGroup) ? .gymYellow : .secondary)
                                
                                Text(muscleGroup.rawValue)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedMuscleGroups.contains(muscleGroup) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.gymYellow)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(exercise == nil ? "New Exercise" : "Edit Exercise")
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
                            await saveExercise()
                        }
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .loadingOverlay(isLoading: viewModel.isLoading)
            .errorAlert(error: $viewModel.errorMessage)
            .confirmationDialog("Select Image Source", isPresented: $showImageSourceSelection) {
                Button("Camera") {
                    imageSourceType = .camera
                    showImagePicker = true
                }
                Button("Photo Library") {
                    imageSourceType = .photoLibrary
                    showImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(selectedImage: $selectedImage, sourceType: imageSourceType)
            }
        }
        .onAppear {
            loadExistingExercise()
        }
    }
    
    // MARK: - Helpers
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedMuscleGroups.isEmpty
    }
    
    private func toggleMuscleGroup(_ group: MuscleGroup) {
        if selectedMuscleGroups.contains(group) {
            selectedMuscleGroups.remove(group)
        } else {
            selectedMuscleGroups.insert(group)
        }
    }
    
    private func loadExistingExercise() {
        guard let exercise = exercise else { return }
        
        title = exercise.title
        description = exercise.exerciseDescription ?? ""
        youtubeURL = exercise.youtubeURL ?? ""
        selectedMuscleGroups = Set(exercise.muscleGroupsEnum)
        
        if let imageData = exercise.imageData {
            selectedImage = UIImage(data: imageData)
        }
    }
    
    private func saveExercise() async {
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        let urlString = youtubeURL.isEmpty ? nil : youtubeURL
        let descriptionText = description.isEmpty ? nil : description
        
        if let existingExercise = exercise {
            await viewModel.updateExercise(
                existingExercise,
                title: title,
                description: descriptionText,
                imageData: imageData,
                youtubeURL: urlString,
                muscleGroups: Array(selectedMuscleGroups)
            )
        } else {
            await viewModel.createExercise(
                title: title,
                description: descriptionText,
                imageData: imageData,
                youtubeURL: urlString,
                muscleGroups: Array(selectedMuscleGroups)
            )
        }
        
        if viewModel.errorMessage == nil {
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    CreateExerciseView(modelContext: ModelContext(
        try! ModelContainer(for: Exercise.self, Workout.self, WorkoutItem.self, Break.self)
    ))
}

