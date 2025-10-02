//
//  CompletionSummaryView.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI

struct CompletionSummaryView: View {
    let summary: WorkoutSummary
    let onDismiss: () -> Void
    
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.gymAccent.opacity(0.3), Color.appBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Success Icon
                    ZStack {
                        Circle()
                            .fill(Color.gymAccent.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: summary.wasCompleted ? "checkmark.circle.fill" : "flag.checkered.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.gymAccent)
                    }
                    .scaleEffect(showConfetti ? 1.0 : 0.5)
                    .opacity(showConfetti ? 1.0 : 0.0)
                    
                    // Title
                    VStack(spacing: 8) {
                        Text(summary.wasCompleted ? "Workout Complete!" : "Workout Stopped")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        
                        Text(summary.workoutTitle)
                            .font(.title3)
                            .foregroundColor(.textSecondary)
                    }
                    .multilineTextAlignment(.center)
                    
                    // Stats Cards
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            StatCard(
                                icon: "clock.fill",
                                value: summary.formattedDuration,
                                label: "Total Time",
                                color: .blue
                            )
                            
                            StatCard(
                                icon: "dumbbell.fill",
                                value: "\(summary.completedExercises)/\(summary.totalExercises)",
                                label: "Exercises",
                                color: .green
                            )
                        }
                        
                        if summary.wasCompleted {
                            HStack(spacing: 16) {
                                StatCard(
                                    icon: "flame.fill",
                                    value: "100%",
                                    label: "Completion",
                                    color: .orange
                                )
                                
                                StatCard(
                                    icon: "star.fill",
                                    value: "Great!",
                                    label: "Performance",
                                    color: .yellow
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Motivational Message
                    Text(motivationalMessage)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    // Done Button
                    Button(action: onDismiss) {
                        Text("Done")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gymAccent)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showConfetti = true
            }
        }
    }
    
    private var motivationalMessage: String {
        if summary.wasCompleted {
            return "🎉 Amazing work! You crushed it!"
        } else {
            return "💪 Every workout counts! Keep it up!"
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.shadowStandard, radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    CompletionSummaryView(
        summary: WorkoutSummary(
            workoutTitle: "Chest & Core Day",
            startTime: Date().addingTimeInterval(-1200),
            endTime: Date(),
            totalDuration: 1200,
            completedExercises: 5,
            totalExercises: 5,
            wasCompleted: true
        ),
        onDismiss: {}
    )
}

