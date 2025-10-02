//
//  AppColors.swift
//  Gymtastic
//
//  Color system for the Gymnastic workout app
//  This file defines all colors used throughout the app with support for light and dark themes
//

import SwiftUI

// MARK: - App Colors

extension Color {
    
    // MARK: - Primary Brand Colors
    
    /// Primary accent color - Lime Green
    /// Used for: Primary buttons, highlights, active states, CTAs
    /// Light Mode: #C8F065 | Dark Mode: #C8F065
    static let gymAccent = Color(hex: "C8F065")
    
    /// Deprecated alias for gymAccent (maintained for backward compatibility)
    @available(*, deprecated, renamed: "gymAccent", message: "Use gymAccent instead")
    static let gymYellow = Color.gymAccent
    
    // MARK: - Background Colors
    
    /// Main app background color - adapts to theme
    /// Light Mode: #F7F6FB (Soft purple-gray) | Dark Mode: #1A1F25 (Deep charcoal)
    /// Used for: Main screen backgrounds, overall app background
    static var appBackground: Color {
        Color(light: Color(hex: "F7F6FB"), dark: Color(hex: "1A1F25"))
    }
    
    /// Light theme background color
    static let lightBackground = Color(hex: "F7F6FB")
    
    /// Dark theme background color
    static let darkBackground = Color(hex: "1A1F25")
    
    // MARK: - Surface/Card Colors
    
    /// Card and surface background color - adapts to theme
    /// Light Mode: #FFFFFF (White) | Dark Mode: #3A3F45 (Dark gray)
    /// Used for: Cards, panels, elevated surfaces, content containers
    static var cardBackground: Color {
        Color(light: .white, dark: Color(hex: "3A3F45"))
    }
    
    /// Light theme card color
    static let lightCard = Color.white
    
    /// Dark theme card color
    static let darkCard = Color(hex: "3A3F45")
    
    // MARK: - Text Colors
    
    /// Primary text color - adapts to theme
    /// Light Mode: Black | Dark Mode: White
    /// Used for: Headings, primary content, important labels
    static var textPrimary: Color {
        Color(light: .black, dark: .white)
    }
    
    /// Secondary text color - adapts to theme
    /// Light Mode: Gray (60% opacity) | Dark Mode: Gray (70% opacity)
    /// Used for: Descriptions, subtitles, secondary information
    static var textSecondary: Color {
        Color(light: Color.gray.opacity(0.6), dark: Color.gray.opacity(0.7))
    }
    
    /// Tertiary text color - adapts to theme
    /// Light Mode: Gray (40% opacity) | Dark Mode: Gray (50% opacity)
    /// Used for: Placeholders, disabled text, timestamps
    static var textTertiary: Color {
        Color(light: Color.gray.opacity(0.4), dark: Color.gray.opacity(0.5))
    }
    
    // MARK: - Semantic Colors
    
    /// Success/positive color
    /// Used for: Completion states, success messages, positive feedback
    static let success = Color.green
    
    /// Error/destructive color
    /// Used for: Delete buttons, error messages, warnings, destructive actions
    static let error = Color.red
    
    /// Info/break color - Blue
    /// Used for: Break periods, rest timers, informational elements
    static let info = Color.blue
    
    /// Warning color
    /// Used for: Warning messages, caution states
    static let warning = Color.orange
    
    // MARK: - Overlay Colors
    
    /// Semi-transparent black overlay
    /// Used for: Modal backgrounds, loading overlays, dimmed content
    static var overlayDark: Color {
        Color.black.opacity(0.3)
    }
    
    /// Semi-transparent white overlay
    /// Used for: Light overlays, subtle highlights
    static var overlayLight: Color {
        Color.white.opacity(0.3)
    }
    
    // MARK: - Border Colors
    
    /// Subtle border color - adapts to theme
    /// Light Mode: Gray (15% opacity) | Dark Mode: White (15% opacity)
    /// Used for: Card borders, dividers, subtle separators
    static var border: Color {
        Color(light: Color.gray.opacity(0.15), dark: Color.white.opacity(0.15))
    }
    
    /// Strong border color - adapts to theme
    /// Light Mode: Gray (30% opacity) | Dark Mode: White (30% opacity)
    /// Used for: Input fields, focused borders, prominent separators
    static var borderStrong: Color {
        Color(light: Color.gray.opacity(0.3), dark: Color.white.opacity(0.3))
    }
    
    // MARK: - Shadow Colors
    
    /// Standard shadow color
    /// Used for: Card shadows, elevated elements
    static var shadowStandard: Color {
        Color.black.opacity(0.08)
    }
    
    /// Strong shadow color
    /// Used for: Exercise cards, prominent shadows
    static var shadowStrong: Color {
        Color.black.opacity(0.15)
    }
    
    // MARK: - Tab Bar Colors (Custom Implementation)
    
    /// Tab bar background - inverted from main background
    /// Light Mode: #1A1F25 (Dark) | Dark Mode: #F7F6FB (Light)
    static var tabBarBackground: Color {
        Color(light: Color(hex: "1A1F25"), dark: Color(hex: "F7F6FB"))
    }
    
    /// Tab bar selected item background
    /// Light Mode: #3A3F45 (Dark gray) | Dark Mode: White
    static var tabBarSelectedBackground: Color {
        Color(light: Color(hex: "3A3F45"), dark: .white)
    }
    
    /// Tab bar selected text color
    /// Light Mode: White | Dark Mode: #1A1F25 (Dark)
    static var tabBarSelectedText: Color {
        Color(light: .white, dark: Color(hex: "1A1F25"))
    }
    
    /// Tab bar unselected text color
    /// Light Mode: #F7F6FB (Light) | Dark Mode: #3A3F45 (Dark gray)
    static var tabBarUnselectedText: Color {
        Color(light: Color(hex: "F7F6FB"), dark: Color(hex: "3A3F45"))
    }
    
    // MARK: - Component-Specific Colors
    
    /// Muscle group tag background
    /// Used for: Muscle group pills/badges
    static var muscleGroupTag: Color {
        Color.gymAccent.opacity(0.2)
    }
    
    /// Completion celebration gradient colors
    /// Used for: Workout completion screen backgrounds
    static var celebrationGradient: [Color] {
        [Color.gymAccent.opacity(0.3), Color.appBackground]
    }
    
    /// Exercise card gradient
    /// Used for: Active exercise cards during workout
    static var exerciseGradient: [Color] {
        [Color.gymAccent.opacity(0.1), Color.gymAccent.opacity(0.05)]
    }
    
    /// Break card background
    /// Used for: Break/rest period cards
    static var breakBackground: Color {
        Color.info.opacity(0.05)
    }
    
    /// Break card border
    /// Used for: Break/rest period card borders
    static var breakBorder: Color {
        Color.info.opacity(0.3)
    }
    
    /// Break timer background
    /// Used for: Break timer buttons and indicators
    static var breakTimer: Color {
        Color.info
    }
}

// MARK: - Color Initializers

extension Color {
    /// Initialize Color with separate light and dark mode colors
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - Color Preview

#Preview("App Colors - Light Mode") {
    ScrollView {
        VStack(alignment: .leading, spacing: 30) {
            // Brand Colors
            ColorSection(title: "Brand Colors") {
                ColorSwatch(name: "gymAccent", color: .gymAccent, hex: "#C8F065")
            }
            
            // Backgrounds
            ColorSection(title: "Backgrounds") {
                ColorSwatch(name: "appBackground", color: .lightBackground, hex: "#F7F6FB")
                ColorSwatch(name: "cardBackground", color: .lightCard, hex: "#FFFFFF")
            }
            
            // Text Colors
            ColorSection(title: "Text Colors") {
                ColorSwatch(name: "textPrimary", color: .black, hex: "Black")
                ColorSwatch(name: "textSecondary", color: Color.gray.opacity(0.6), hex: "Gray 60%")
                ColorSwatch(name: "textTertiary", color: Color.gray.opacity(0.4), hex: "Gray 40%")
            }
            
            // Semantic Colors
            ColorSection(title: "Semantic Colors") {
                ColorSwatch(name: "success", color: .success, hex: "Green")
                ColorSwatch(name: "error", color: .error, hex: "Red")
                ColorSwatch(name: "info", color: .info, hex: "Blue")
                ColorSwatch(name: "warning", color: .warning, hex: "Orange")
            }
            
            // Tab Bar Colors
            ColorSection(title: "Tab Bar (Inverted)") {
                ColorSwatch(name: "tabBarBackground", color: Color(hex: "1A1F25"), hex: "#1A1F25")
                ColorSwatch(name: "tabBarSelectedBg", color: Color(hex: "3A3F45"), hex: "#3A3F45")
                ColorSwatch(name: "tabBarSelectedText", color: .white, hex: "White")
                ColorSwatch(name: "tabBarUnselectedText", color: Color(hex: "F7F6FB"), hex: "#F7F6FB")
            }
        }
        .padding()
    }
    .background(Color.lightBackground)
    .preferredColorScheme(.light)
}

#Preview("App Colors - Dark Mode") {
    ScrollView {
        VStack(alignment: .leading, spacing: 30) {
            // Brand Colors
            ColorSection(title: "Brand Colors") {
                ColorSwatch(name: "gymAccent", color: .gymAccent, hex: "#C8F065")
            }
            
            // Backgrounds
            ColorSection(title: "Backgrounds") {
                ColorSwatch(name: "appBackground", color: .darkBackground, hex: "#1A1F25")
                ColorSwatch(name: "cardBackground", color: .darkCard, hex: "#3A3F45")
            }
            
            // Text Colors
            ColorSection(title: "Text Colors") {
                ColorSwatch(name: "textPrimary", color: .white, hex: "White")
                ColorSwatch(name: "textSecondary", color: Color.gray.opacity(0.7), hex: "Gray 70%")
                ColorSwatch(name: "textTertiary", color: Color.gray.opacity(0.5), hex: "Gray 50%")
            }
            
            // Semantic Colors
            ColorSection(title: "Semantic Colors") {
                ColorSwatch(name: "success", color: .success, hex: "Green")
                ColorSwatch(name: "error", color: .error, hex: "Red")
                ColorSwatch(name: "info", color: .info, hex: "Blue")
                ColorSwatch(name: "warning", color: .warning, hex: "Orange")
            }
            
            // Tab Bar Colors
            ColorSection(title: "Tab Bar (Inverted)") {
                ColorSwatch(name: "tabBarBackground", color: Color(hex: "F7F6FB"), hex: "#F7F6FB")
                ColorSwatch(name: "tabBarSelectedBg", color: .white, hex: "White")
                ColorSwatch(name: "tabBarSelectedText", color: Color(hex: "1A1F25"), hex: "#1A1F25")
                ColorSwatch(name: "tabBarUnselectedText", color: Color(hex: "3A3F45"), hex: "#3A3F45")
            }
        }
        .padding()
    }
    .background(Color.darkBackground)
    .preferredColorScheme(.dark)
}

// MARK: - Preview Helper Views

private struct ColorSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)
            
            VStack(spacing: 8) {
                content
            }
        }
    }
}

private struct ColorSwatch: View {
    let name: String
    let color: Color
    let hex: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Color circle
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            // Color info
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(.body, design: .monospaced))
                Text(hex)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
}

