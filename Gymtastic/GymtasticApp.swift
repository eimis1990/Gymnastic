//
//  GymtasticApp.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI
import SwiftData

@main
struct GymtasticApp: App {
    let container: ModelContainer
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    init() {
        do {
            // Define the schema with all model types
            let schema = Schema([
                Exercise.self,
                Workout.self,
                WorkoutItem.self,
                Break.self
            ])
            
            // Configure SwiftData with CloudKit automatic sync
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
            
            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                
                if showOnboarding {
                    OnboardingView(isPresented: $showOnboarding)
                        .transition(.opacity)
                }
            }
        }
        .modelContainer(container)
    }
}

