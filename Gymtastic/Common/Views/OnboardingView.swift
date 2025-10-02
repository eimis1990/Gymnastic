//
//  OnboardingView.swift
//  Gymtastic
//
//  Created on 2025-10-02.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.lightBackground
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                WelcomePage(isPresented: $isPresented)
                    .tag(0)
                
                // Page 2: Features (optional - can add more pages)
                // FeaturesPage()
                //     .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

// MARK: - Welcome Page

struct WelcomePage: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Image Section
            VStack(spacing: 24) {
                // Hero Image
                Image(systemName: "figure.strengthtraining.traditional")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundColor(.gymAccent)
                    .padding(.horizontal, 40)
                
                // Progress indicator (decorative)
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.gymAccent)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            Spacer()
            
            // Text Section
            VStack(spacing: 16) {
                Text("Wherever You Are")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 4) {
                    Text("Health")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.gymAccent)
                    Text("Is Number One")
                        .font(.system(size: 32, weight: .bold))
                }
                
                Text("There is no instant way to a healthy life")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Get Started Button
            Button {
                withAnimation {
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    isPresented = false
                }
            } label: {
                Text("Get Started")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .cornerRadius(28)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(isPresented: .constant(true))
}

