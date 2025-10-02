# Gymnastic App - Color System

This document describes the complete color system used in the Gymnastic workout app, with support for both light and dark themes.

## 📋 Color Reference File

All colors are defined in: **`Gymtastic/Common/AppColors.swift`**

## 🎨 Color Palette Overview

### Brand Colors

| Color Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| `gymAccent` | `#C8F065` Lime Green | `#C8F065` Lime Green | Primary buttons, highlights, active states, CTAs |

### Background Colors

| Color Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| `appBackground` | `#F7F6FB` Soft purple-gray | `#1A1F25` Deep charcoal | Main screen backgrounds |
| `cardBackground` | `#FFFFFF` White | `#3A3F45` Dark gray | Cards, panels, elevated surfaces |

### Text Colors

| Color Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| `textPrimary` | Black | White | Headings, primary content |
| `textSecondary` | Gray 60% | Gray 70% | Descriptions, subtitles |
| `textTertiary` | Gray 40% | Gray 50% | Placeholders, disabled text |

### Semantic Colors

| Color Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| `success` | Green | Green | Completion states, success messages |
| `error` | Red | Red | Delete buttons, error messages, destructive actions |
| `info` | Blue | Blue | Break periods, rest timers, informational elements |
| `warning` | Orange | Orange | Warning messages, caution states |

### Tab Bar Colors (Inverted Design)

The tab bar uses an inverted color scheme for visual distinction:

| Color Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| `tabBarBackground` | `#1A1F25` Dark | `#F7F6FB` Light | Tab bar container background |
| `tabBarSelectedBackground` | `#3A3F45` Dark gray | White | Selected tab background |
| `tabBarSelectedText` | White | `#1A1F25` Dark | Selected tab text/icon |
| `tabBarUnselectedText` | `#F7F6FB` Light | `#3A3F45` Dark gray | Unselected tab text/icon |

### Overlay Colors

| Color Name | Value | Usage |
|------------|-------|-------|
| `overlayDark` | Black 30% | Modal backgrounds, loading overlays |
| `overlayLight` | White 30% | Light overlays, subtle highlights |

### Border Colors

| Color Name | Light Mode | Dark Mode | Usage |
|------------|------------|-----------|-------|
| `border` | Gray 15% | White 15% | Card borders, dividers, subtle separators |
| `borderStrong` | Gray 30% | White 30% | Input fields, focused borders |

### Shadow Colors

| Color Name | Value | Usage |
|------------|-------|-------|
| `shadowStandard` | Black 8% | Card shadows, elevated elements |
| `shadowStrong` | Black 15% | Exercise cards, prominent shadows |

### Component-Specific Colors

| Color Name | Value | Usage |
|------------|-------|-------|
| `muscleGroupTag` | gymAccent 20% | Muscle group pills/badges |
| `celebrationGradient` | [gymAccent 30%, appBackground] | Workout completion screen backgrounds |
| `exerciseGradient` | [gymAccent 10%, gymAccent 5%] | Active exercise cards during workout |
| `breakBackground` | info 5% | Break/rest period cards |
| `breakBorder` | info 30% | Break/rest period card borders |
| `breakTimer` | info | Break timer buttons and indicators |

## 🔧 Usage Examples

### Accessing Colors in SwiftUI

```swift
// Brand color
Text("Hello")
    .foregroundColor(.gymAccent)

// Adaptive background (automatically changes with theme)
VStack {
    // Content
}
.background(Color.appBackground)

// Card styling
RoundedRectangle(cornerRadius: 12)
    .fill(Color.cardBackground)
    .shadow(color: .shadowStandard, radius: 8, x: 0, y: 2)

// Text hierarchy
Text("Title")
    .foregroundColor(.textPrimary)
Text("Subtitle")
    .foregroundColor(.textSecondary)
Text("Caption")
    .foregroundColor(.textTertiary)

// Semantic colors
Button("Delete") { }
    .foregroundColor(.error)

Button("Save") { }
    .background(Color.gymAccent)
```

### Creating Custom Hex Colors

```swift
// Create a custom color from hex
let customColor = Color(hex: "FF5733")

// Create adaptive color with different values for light/dark mode
let adaptiveColor = Color(
    light: Color(hex: "F7F6FB"),
    dark: Color(hex: "1A1F25")
)
```

## 🎭 Theme Support

All colors marked as "adaptive" automatically respond to the system's light/dark mode setting. The app uses:

- **Light Theme**: Clean, modern appearance with soft purple-gray backgrounds
- **Dark Theme**: Reduced eye strain with deep charcoal backgrounds
- **Tab Bar**: Inverted color scheme for visual distinction from main content

## 📱 Visual Preview

To see all colors in both light and dark modes, you can:

1. Open `Gymtastic/Common/AppColors.swift` in Xcode
2. Use the **#Preview** at the bottom of the file
3. Toggle between light and dark mode in the preview canvas

The preview shows:
- All brand colors
- Background colors
- Text color hierarchy
- Semantic colors
- Tab bar colors
- Component-specific colors

## 🔄 Migration Notes

### Deprecated Colors

- `gymYellow` → Use `gymAccent` instead (both point to the same lime green color)

### Legacy Support

The following static colors are maintained for backward compatibility:
- `lightBackground` → `#F7F6FB`
- `lightCard` → `#FFFFFF`
- `darkBackground` → `#1A1F25`
- `darkCard` → `#3A3F45`

However, prefer using the adaptive versions (`appBackground`, `cardBackground`) for new code.

## 📝 Design Principles

1. **Accessibility**: All color combinations meet WCAG contrast requirements
2. **Consistency**: Use semantic names instead of direct colors
3. **Adaptability**: Prefer adaptive colors that respond to system theme
4. **Simplicity**: Use the predefined colors instead of creating custom ones
5. **Documentation**: Every color includes usage notes and hex values

## 🚀 Future Enhancements

Potential future additions to the color system:
- Gradient presets for various UI elements
- Animation/transition colors
- Chart/data visualization colors
- Accessibility high-contrast variants
- Custom theme support

---

**Last Updated**: October 2, 2025

