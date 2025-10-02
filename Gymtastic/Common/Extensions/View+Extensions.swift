//
//  View+Extensions.swift
//  Gymtastic
//
//  Created on 2025-10-01.
//

import SwiftUI

extension View {
    // MARK: - Loading Overlay
    
    /// Shows a loading overlay with activity indicator
    func loadingOverlay(isLoading: Bool) -> some View {
        overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
        }
    }
    
    // MARK: - Error Alert
    
    /// Shows an alert for error messages
    func errorAlert(error: Binding<String?>) -> some View {
        alert("Error", isPresented: Binding(
            get: { error.wrappedValue != nil },
            set: { if !$0 { error.wrappedValue = nil } }
        )) {
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: {
            if let errorMessage = error.wrappedValue {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Card Style
    
    /// Applies a card style with background and shadow
    func cardStyle(backgroundColor: Color = .lightCard) -> some View {
        self
            .background(backgroundColor)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    /// Applies a bordered card style
    func borderedCardStyle() -> some View {
        self
            .background(Color.lightCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
    }
    
    // MARK: - Exercise Card Shadow
    
    /// Applies shadow suitable for exercise cards
    func exerciseCardShadow() -> some View {
        shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Navigation Style
    
    /// Applies standard navigation bar styling
    func standardNavigationBar(title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Conditional Modifiers
    
    /// Conditionally applies a modifier
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    // MARK: - Accessibility
    
    /// Adds accessibility label and hint in one call
    func accessibility(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .if(hint != nil) {
                $0.accessibilityHint(hint!)
            }
    }
}

// MARK: - Int Extensions for Time Formatting

extension Int {
    /// Formats seconds into "Xm Ys" or "Xs" format
    var formattedDuration: String {
        let minutes = self / 60
        let seconds = self % 60
        
        if minutes > 0 {
            return seconds > 0 ? "\(minutes)m \(seconds)s" : "\(minutes)m"
        }
        return "\(seconds)s"
    }
    
    /// Formats seconds into "MM:SS" format
    var formattedTime: String {
        let minutes = self / 60
        let seconds = self % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Color Extensions
// Note: Main color definitions are now in AppColors.swift

extension Color {
    /// Initialize Color from hex string
    /// Supports 3, 6, and 8 character hex strings (RGB and ARGB)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview("Card Styles") {
    VStack(spacing: 20) {
        Text("Standard Card")
            .padding()
            .cardStyle()
        
        Text("Bordered Card")
            .padding()
            .borderedCardStyle()
        
        Text("Exercise Card")
            .padding()
            .cardStyle()
            .exerciseCardShadow()
    }
    .padding()
}

