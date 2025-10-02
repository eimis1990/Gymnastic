//
//  ExerciseDetailView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let exercise: Exercise
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showVideoPlayer = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Exercise Image
                if let imageData = exercise.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                            .frame(height: 250)
                        
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Muscle Groups
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target Muscles")
                        .font(.headline)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(exercise.muscleGroupsEnum, id: \.self) { group in
                            MuscleGroupTag(muscleGroup: group)
                        }
                    }
                }
                
                // Description
                if let description = exercise.exerciseDescription, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                // YouTube Video
                if let youtubeURL = exercise.youtubeURL, !youtubeURL.isEmpty {
                    Button {
                        showVideoPlayer = true
                    } label: {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            
                            Text("Watch Tutorial")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                }
                
                // Metadata
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details")
                        .font(.headline)
                    
                    MetadataRow(label: "Created", value: exercise.createdAt.formatted(date: .abbreviated, time: .omitted))
                    MetadataRow(label: "Last Modified", value: exercise.updatedAt.formatted(date: .abbreviated, time: .omitted))
                    
                    if exercise.isUsedInWorkouts {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Used in workouts")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(exercise.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            CreateExerciseView(exercise: exercise, modelContext: modelContext)
        }
        .sheet(isPresented: $showVideoPlayer) {
            if let urlString = exercise.youtubeURL,
               let url = URL(string: urlString) {
                YouTubePlayerView(url: url)
                    .ignoresSafeArea()
            }
        }
        .alert("Delete Exercise", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteExercise()
            }
        } message: {
            Text(exercise.isUsedInWorkouts
                 ? "This exercise is used in workouts. Are you sure you want to delete it?"
                 : "Are you sure you want to delete this exercise?")
        }
    }
    
    private func deleteExercise() {
        modelContext.delete(exercise)
        dismiss()
    }
}

// MARK: - Metadata Row

struct MetadataRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

// MARK: - Flow Layout (Simple)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ExerciseDetailView(
            exercise: Exercise(
                title: "Push Up",
                description: "A classic bodyweight exercise that targets the chest, triceps, and core muscles.",
                youtubeURL: "https://www.youtube.com/watch?v=dZgVxmf6jkA",
                muscleGroups: [.chest, .triceps, .core]
            )
        )
    }
    .modelContainer(for: [Exercise.self, Workout.self])
}

