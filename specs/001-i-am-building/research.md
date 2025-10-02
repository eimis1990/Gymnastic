# Technical Research: Custom Workout Builder

**Feature**: 001-i-am-building  
**Date**: 2025-10-01  
**Status**: Complete

## Overview
This document captures technical research decisions for building a native iOS workout management app using Swift 5.9+, SwiftUI, and SwiftData.

---

## 1. Data Persistence Strategy

### Decision: SwiftData with Local Storage
**Chosen**: SwiftData framework for local persistence with optional iCloud sync

**Rationale**:
- Native iOS 17+ framework, no third-party dependencies
- Type-safe Swift macros (`@Model`) eliminate boilerplate
- Automatic CloudKit integration for future iCloud sync
- Efficient querying with `@Query` property wrapper
- Built-in change tracking and undo support
- Strong relationship management with cascading deletes

**Alternatives Considered**:
- **Core Data**: More mature but verbose, SwiftData is the modern successor
- **Realm**: Powerful but adds external dependency, constitution prefers SPM-first
- **UserDefaults/Files**: Too manual, no relationship support, poor performance at scale

**Implementation Details**:
- Use `@Model` macro on Exercise, Workout, WorkoutItem, Break entities
- `ModelContainer` initialized in `@main` App struct
- `@Query` in views for reactive UI updates
- Cascade delete rules for workout-exercise relationships
- Store images as `Data` type in SwiftData (with size limits)

**References**:
- [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- WWDC23: Meet SwiftData
- Best practice: Keep models in separate files for clarity

---

## 2. Image Storage Strategy

### Decision: Store Image Data in SwiftData with Thumbnail Optimization
**Chosen**: Store images as `Data` in SwiftData with generated thumbnails

**Rationale**:
- Keeps all exercise data in single source of truth
- No file management complexity
- Automatic backup with iCloud sync
- Thumbnail generation reduces memory for list views
- SwiftData handles data efficiently with binary attributes

**Alternatives Considered**:
- **File System Storage**: More complex, requires manual cleanup, no automatic sync
- **External Database**: Unnecessary complexity for local-only app
- **Photo Library Reference**: User might delete photos, losing exercise images

**Implementation Details**:
```swift
@Model
class Exercise {
    var imageData: Data?
    var thumbnailData: Data?
    
    // Generate thumbnail on image set
    func setImage(_ uiImage: UIImage) {
        imageData = uiImage.jpegData(compressionQuality: 0.8)
        thumbnailData = uiImage.thumbnail(size: CGSize(width: 200, height: 200))
                                .jpegData(compressionQuality: 0.7)
    }
}
```

**Size Constraints**:
- Full image: Max 2MB (compress if needed)
- Thumbnail: Target 50KB for list performance
- Warning if user selects image > 5MB

---

## 3. UI Framework & Architecture

### Decision: SwiftUI with MVVM Pattern
**Chosen**: Pure SwiftUI with `@Observable` ViewModels

**Rationale**:
- Constitution mandates SwiftUI-first for new features
- `@Observable` macro (iOS 17+) eliminates `@Published` boilerplate
- Declarative UI reduces bugs vs imperative UIKit
- Built-in Dark Mode, Dynamic Type support
- Native accessibility with minimal code

**Alternatives Considered**:
- **UIKit**: More control but verbose, not constitution-compliant
- **SwiftUI + Combine**: `@Observable` is simpler and more modern
- **MVI/Redux**: Overkill for local-only app, adds complexity

**Architecture Pattern**:
```
View (SwiftUI)
  ↓ user actions
ViewModel (@Observable)
  ↓ business logic
Service (Protocol)
  ↓ data operations
SwiftData ModelContext
```

**Implementation Details**:
- ViewModels are `@Observable` classes (not structs)
- ViewModels injected via `@Environment` for testability
- Services are protocols for easy mocking
- Views are pure: no business logic, only UI binding
- ViewModels never import SwiftUI (testability)

---

## 4. Drag-and-Drop Implementation

### Decision: Native SwiftUI Drag-and-Drop with UTType
**Chosen**: `.onDrag()` and `.onDrop()` modifiers with data transfer

**Rationale**:
- Native SwiftUI support, no external libraries
- Works across iOS (no UIKit required)
- Accessible by default (VoiceOver announcements)
- Smooth animations built-in

**Implementation Approach**:
```swift
struct WorkoutTimelineView: View {
    @State private var items: [WorkoutItem]
    
    var body: some View {
        ForEach(items) { item in
            WorkoutItemCard(item: item)
                .onDrag {
                    NSItemProvider(object: item.id.uuidString as NSString)
                }
                .onDrop(of: [.text], delegate: DropDelegate(...))
        }
    }
}
```

**Key Considerations**:
- Use `id` for tracking items during reorder
- Update order in SwiftData after drop completes
- Haptic feedback on successful drop
- Visual feedback (scale, opacity) during drag

**References**:
- [Human Interface Guidelines: Drag and Drop](https://developer.apple.com/design/human-interface-guidelines/drag-and-drop)
- SwiftUI onDrag/onDrop documentation

---

## 5. YouTube Video Integration

### Decision: SFSafariViewController for In-App YouTube Playback
**Chosen**: `SFSafariViewController` wrapped in SwiftUI

**Rationale**:
- Native iOS component, no YouTube SDK needed
- Full YouTube functionality (comments, related videos, etc.)
- User remains in app context
- Respects user's YouTube settings (signed in, etc.)
- Falls back to YouTube app if user prefers

**Alternatives Considered**:
- **WKWebView**: Requires custom player, violates YouTube TOS
- **YouTube iOS SDK**: External dependency, constitution prefers native
- **Open in Safari/YouTube app**: Takes user out of app context

**Implementation**:
```swift
import SafariServices

struct YouTubePlayerView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
```

**Usage**:
- Show as `.sheet()` from "See Video" button
- Validate YouTube URL format before storing
- Handle invalid URLs gracefully (show error alert)

---

## 6. Testing Strategy

### Decision: XCTest with Async/Await for Modern Swift
**Chosen**: XCTest with async test methods, no external test frameworks

**Rationale**:
- Native iOS testing, zero dependencies
- Async/await support in Xcode 13+
- Fast, integrated with Xcode Test Navigator
- Constitution mandates 70% coverage for business logic

**Test Organization**:
```
GymtasticTests/
├── Unit/
│   ├── ViewModels/
│   │   ├── ExerciseViewModelTests.swift
│   │   ├── WorkoutBuilderViewModelTests.swift
│   │   └── ExecutionViewModelTests.swift
│   └── Services/
│       ├── ExerciseServiceTests.swift
│       ├── WorkoutServiceTests.swift
│       └── ImageStorageServiceTests.swift
└── UI/
    ├── ExerciseFlowUITests.swift
    ├── WorkoutBuilderUITests.swift
    └── ExecutionFlowUITests.swift
```

**Key Techniques**:
- **Mock Services**: Protocol-based services enable easy mocking
- **In-Memory SwiftData**: Use `ModelConfiguration(isStoredInMemoryOnly: true)` for tests
- **Async Testing**: Use `async throws` functions with `await` for async operations
- **UI Testing**: XCUITest for critical user flows with accessibility identifiers

**Example**:
```swift
final class ExerciseViewModelTests: XCTestCase {
    var sut: ExerciseViewModel!
    var mockService: MockExerciseService!
    
    override func setUp() async throws {
        mockService = MockExerciseService()
        sut = ExerciseViewModel(service: mockService)
    }
    
    func testCreateExercise_WithValidData_CreatesExercise() async throws {
        // Given
        let title = "Push Up"
        
        // When
        await sut.createExercise(title: title)
        
        // Then
        XCTAssertEqual(mockService.createCallCount, 1)
        XCTAssertEqual(sut.exercises.count, 1)
    }
}
```

---

## 7. Accessibility Implementation

### Decision: Built-in SwiftUI Accessibility with Manual Enhancements
**Chosen**: SwiftUI automatic accessibility + manual labels where needed

**Rationale**:
- SwiftUI provides accessibility for free (VoiceOver, Dynamic Type)
- Constitution mandates accessibility compliance (NON-NEGOTIABLE)
- Manual labels improve context for screen readers
- Dynamic Type support is automatic with SwiftUI fonts

**Implementation Checklist**:
- ✅ Use `.accessibilityLabel()` on all custom controls
- ✅ Use `.accessibilityHint()` for non-obvious actions
- ✅ Use `.accessibilityValue()` for dynamic values (timer, progress)
- ✅ Use semantic fonts (`.font(.title)`, `.font(.body)`)
- ✅ Test with VoiceOver enabled
- ✅ Test with largest Dynamic Type size
- ✅ Ensure minimum 44pt touch targets
- ✅ Use `.accessibilityAddTraits()` for custom elements

**Example**:
```swift
Button(action: startWorkout) {
    Label("Start", systemImage: "play.fill")
}
.accessibilityLabel("Start workout")
.accessibilityHint("Begins the workout execution with active exercise view")
```

---

## 8. Performance Optimization

### Decision: Lazy Loading with Thumbnail Caching
**Chosen**: Thumbnails for lists, full images loaded on-demand

**Rationale**:
- Constitution requires 60fps scrolling
- Large images in lists cause stuttering
- Thumbnail generation keeps memory low
- SwiftUI `List` already lazy loads views

**Implementation Strategy**:
- **Lists**: Show thumbnails (200x200, ~50KB)
- **Detail Views**: Load full image async with loading indicator
- **Memory**: Release full images when view disappears
- **Cache**: SwiftData automatically caches query results

**Key Techniques**:
```swift
// In list view - use thumbnail
Image(uiImage: UIImage(data: exercise.thumbnailData ?? Data()))
    .resizable()
    .scaledToFill()

// In detail view - load full image async
AsyncImage(data: exercise.imageData)
```

**Performance Targets** (from constitution):
- ✅ App launch: < 1 second
- ✅ List scrolling: 60fps with 100+ items
- ✅ View transitions: Smooth animations
- ✅ Image loading: < 200ms for thumbnails

---

## 9. Navigation Architecture

### Decision: NavigationStack with Value-Based Routing
**Chosen**: iOS 16+ `NavigationStack` with `navigationDestination(for:)`

**Rationale**:
- Modern SwiftUI navigation (replaces NavigationView)
- Type-safe routing with enums
- Deep linking support
- State restoration built-in

**Implementation**:
```swift
enum Route: Hashable {
    case exerciseDetail(Exercise)
    case createExercise
    case workoutBuilder(Workout?)
    case execution(Workout)
}

struct ContentView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            TabView {
                ExerciseListView()
                WorkoutListView()
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .exerciseDetail(let exercise):
                    ExerciseDetailView(exercise: exercise)
                case .createExercise:
                    CreateExerciseView()
                case .workoutBuilder(let workout):
                    WorkoutBuilderView(workout: workout)
                case .execution(let workout):
                    WorkoutExecutionView(workout: workout)
                }
            }
        }
    }
}
```

---

## 10. Privacy & Permissions

### Decision: Minimal Permissions with Clear Purpose Strings
**Chosen**: Only Camera and Photo Library permissions

**Required Info.plist Keys**:
```xml
<key>NSCameraUsageDescription</key>
<string>Take photos of exercises for your workout library</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Select exercise photos from your library</string>
```

**Privacy Manifest** (PrivacyInfo.xcprivacy):
- No tracking domains
- No required reasons APIs used
- No data collection

**Best Practices**:
- Request permissions just-in-time (when user taps add image)
- Explain why permission is needed before requesting
- Gracefully handle permission denial (show alert, offer retry)

---

## Summary of Key Technologies

| Aspect | Technology | Version/Requirement |
|--------|-----------|-------------------|
| Language | Swift | 5.9+ |
| UI Framework | SwiftUI | iOS 17+ |
| Data Persistence | SwiftData | iOS 17+ |
| Testing | XCTest | Built-in |
| Minimum iOS | iOS 17.0 | Latest features |
| Architecture | MVVM | @Observable ViewModels |
| Image Picker | PhotosUI | PHPickerViewController |
| YouTube | SafariServices | SFSafariViewController |
| Accessibility | SwiftUI Built-in | + Manual labels |

---

## Risk Mitigation

### Identified Risks & Mitigations:

1. **Risk**: Large image files causing performance issues
   - **Mitigation**: Thumbnail generation, size limits, compression

2. **Risk**: Complex drag-drop state management
   - **Mitigation**: Native SwiftUI modifiers, simple reorder logic

3. **Risk**: SwiftData relationship bugs (new framework)
   - **Mitigation**: Comprehensive unit tests, cascade delete rules

4. **Risk**: Accessibility not properly implemented
   - **Mitigation**: Manual testing with VoiceOver, accessibility audit checklist

5. **Risk**: Memory leaks in ViewModels
   - **Mitigation**: `[weak self]` in closures, Instruments profiling

---

**Research Complete**: All technical decisions documented and justified. Ready for Phase 1 (Design & Contracts).

