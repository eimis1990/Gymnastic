//
//  WorkoutTimelineView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI
import UniformTypeIdentifiers

struct WorkoutTimelineView: View {
    let workout: Workout
    let onReorder: (Int, Int) -> Void
    let onDelete: (Int) -> Void
    let onAddExercise: () -> Void
    let onAddBreak: () -> Void
    
    @State private var draggedItem: WorkoutSequenceItem?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if workout.orderedSequence.isEmpty {
                    emptyState
                } else {
                    ForEach(Array(workout.orderedSequence.enumerated()), id: \.offset) { index, item in
                        TimelineItemView(
                            item: item,
                            onDelete: { onDelete(index) }
                        )
                        .onDrag {
                            self.draggedItem = item
                            return NSItemProvider(object: "\(index)" as NSString)
                        }
                        .onDrop(of: [.text], delegate: DropViewDelegate(
                            destinationItem: item,
                            items: workout.orderedSequence,
                            draggedItem: $draggedItem,
                            onMove: { from, to in
                                if from != to {
                                    onReorder(from, to)
                                }
                            }
                        ))
                    }
                }
                
                // Add buttons
                HStack(spacing: 16) {
                    Button(action: onAddExercise) {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gymYellow.opacity(0.2))
                            .foregroundColor(.gymYellow)
                            .cornerRadius(12)
                    }
                    
                    Button(action: onAddBreak) {
                        Label("Add Break", systemImage: "timer")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No exercises added yet")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Tap 'Add Exercise' to start building your workout")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Timeline Item View

struct TimelineItemView: View {
    let item: WorkoutSequenceItem
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main content
            switch item {
            case .exercise(let workoutItem):
                WorkoutItemCardView(item: workoutItem)
            case .break(let breakItem):
                BreakCardView(breakItem: breakItem)
            }
            
            // Delete button
            Button(action: { showDeleteAlert = true }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                    .background(Circle().fill(Color.white))
            }
            .offset(x: 8, y: -8)
        }
        .alert("Delete Item", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("Are you sure you want to delete this item?")
        }
    }
}

// MARK: - Drop Delegate

struct DropViewDelegate: DropDelegate {
    let destinationItem: WorkoutSequenceItem
    let items: [WorkoutSequenceItem]
    @Binding var draggedItem: WorkoutSequenceItem?
    let onMove: (Int, Int) -> Void
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem else { return }
        guard draggedItem.id != destinationItem.id else { return }
        
        if let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id }),
           let toIndex = items.firstIndex(where: { $0.id == destinationItem.id }) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onMove(fromIndex, toIndex)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        self.draggedItem = nil
        return true
    }
}

// MARK: - Preview

#Preview {
    let workout = Workout(title: "Test Workout")
    let ex1 = Exercise(title: "Push Up", muscleGroups: [.chest])
    let item1 = WorkoutItem(exercise: ex1, position: 0, configurationType: .repetitions,
                            sets: 3, repsPerSet: 12, restBetweenSetsSeconds: 60)
    let breakItem = Break(durationSeconds: 120, position: 1)
    workout.items.append(item1)
    workout.breaks.append(breakItem)
    
    return WorkoutTimelineView(
        workout: workout,
        onReorder: { _, _ in },
        onDelete: { _ in },
        onAddExercise: {},
        onAddBreak: {}
    )
}

