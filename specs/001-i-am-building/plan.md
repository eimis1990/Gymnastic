# Implementation Plan: Custom Workout Builder

**Branch**: `001-i-am-building` | **Date**: 2025-10-01 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-i-am-building/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → ✅ COMPLETE: Feature spec loaded and analyzed
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → ✅ COMPLETE: Swift 5.9+, SwiftData, SwiftUI, native iOS detected
   → ✅ COMPLETE: All clarifications resolved in spec
3. Fill the Constitution Check section based on constitution
   → ✅ COMPLETE: Constitution requirements evaluated
4. Evaluate Constitution Check section
   → ✅ PASS: No violations, follows MVVM, Swift-first, native iOS
   → ✅ Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → ✅ COMPLETE: Technical decisions documented
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, .cursorrules
   → ✅ COMPLETE: All design artifacts generated
7. Re-evaluate Constitution Check section
   → ✅ PASS: Design aligns with constitution principles
   → ✅ Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach
   → ✅ COMPLETE: Task strategy documented
9. STOP - Ready for /tasks command
   → ✅ SUCCESS: Implementation plan complete
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)

## Summary
Build a native iOS workout management app that allows users to create custom exercises with detailed information (title, description, images, YouTube videos, muscle groups), then combine those exercises into personalized workouts with flexible configurations (rep-based or time-based), drag-and-drop reordering, and breaks between exercises. The app provides an execution mode with a clear active exercise view, progress tracking, and video access during workouts. All data is stored locally using SwiftData with a clean MVVM architecture following modern iOS development practices.

## Technical Context
**Language/Version**: Swift 5.9+ (latest stable)
**Primary Dependencies**: SwiftUI, SwiftData, SafariServices (SFSafariViewController)
**Storage**: SwiftData (local persistence with iCloud sync capability)
**Testing**: XCTest for unit tests, XCUITest for UI tests
**Target Platform**: iOS 17.0+ (to leverage latest SwiftData and SwiftUI features)
**Project Type**: Mobile (native iOS app)
**Performance Goals**: 60 fps UI, <1s app launch, smooth list scrolling with 100+ exercises
**Constraints**: Offline-first (all features work without internet), <50MB base app size, accessibility compliant (VoiceOver, Dynamic Type)
**Scale/Scope**: 3 main feature modules (Exercises, Workouts, Execution), ~15-20 screens/views, supports 1000+ exercises and 100+ workouts

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Core Principles Compliance
✅ **Swift-First & Modern iOS**
- Using Swift 5.9+ with modern concurrency (async/await for image loading, data operations)
- SwiftUI for all UI (no UIKit except SFSafariViewController for YouTube)
- Protocol-oriented design for repositories and services

✅ **Clean Architecture (MVVM)**
- Views: SwiftUI Views (no business logic)
- ViewModels: `@Observable` classes for state management and business logic
- Services: ExerciseService, WorkoutService, ImageStorageService
- Models: SwiftData @Model classes (Exercise, Workout, WorkoutItem, Break)
- Clear separation: ViewModels never import SwiftUI

✅ **iOS Design Guidelines**
- Native components: NavigationStack, List, TabView, Sheet, Alert
- SF Symbols for icons (dumbbell.fill, figure.run, timer, etc.)
- Dark mode support via SwiftUI automatic handling
- Dynamic Type support with .font(.body), .font(.title)
- VoiceOver labels on all interactive elements
- Responsive layouts with GeometryReader where needed

✅ **Test-Driven Development**
- Unit tests for all ViewModels (70%+ coverage target)
- UI tests for critical flows (create exercise, build workout, execute workout)
- Tests written before implementation (Red-Green-Refactor)

✅ **Performance & Battery Efficiency**
- `[weak self]` in closures to prevent retain cycles
- Lazy loading of images with thumbnail caching
- @Query in SwiftData for efficient data fetching
- No background tasks (app is offline-first, no networking)

### Code Quality Standards
✅ **Code Organization**: Feature-based grouping
```
Gymtastic/
├── Exercises/
├── Workouts/
├── Execution/
├── Models/
├── Services/
└── Common/
```

✅ **Dependency Management**: Swift Package Manager only (no external dependencies needed)

✅ **Security & Data Privacy**
- Camera and Photo Library permissions with NSPhotoLibraryUsageDescription
- Privacy manifest (PrivacyInfo.xcprivacy) for required reasons APIs
- No sensitive data (no authentication, just local workout data)

### Result
**STATUS**: ✅ PASS - No constitutional violations. Design follows all principles.

## Project Structure

### Documentation (this feature)
```
specs/001-i-am-building/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
│   ├── exercise-service.md
│   ├── workout-service.md
│   └── execution-service.md
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
Gymtastic/
├── GymtasticApp.swift                    # App entry point
├── Models/
│   ├── Exercise.swift                    # @Model SwiftData entity
│   ├── Workout.swift                     # @Model SwiftData entity
│   ├── WorkoutItem.swift                 # @Model SwiftData entity
│   ├── Break.swift                       # @Model SwiftData entity
│   └── MuscleGroup.swift                 # Enum for muscle groups
├── Exercises/
│   ├── Views/
│   │   ├── ExerciseListView.swift        # Main exercises screen
│   │   ├── ExerciseDetailView.swift      # View/edit exercise
│   │   ├── CreateExerciseView.swift      # Create new exercise
│   │   └── Components/
│   │       └── ExerciseCardView.swift
│   ├── ViewModels/
│   │   └── ExerciseViewModel.swift
│   └── Services/
│       ├── ExerciseService.swift         # Business logic
│       └── ImageStorageService.swift     # Image persistence
├── Workouts/
│   ├── Views/
│   │   ├── WorkoutListView.swift         # Workout library
│   │   ├── WorkoutBuilderView.swift      # Create/edit workout
│   │   ├── WorkoutTimelineView.swift     # Drag-drop timeline
│   │   └── Components/
│   │       ├── WorkoutCardView.swift
│   │       ├── WorkoutItemCardView.swift
│   │       └── BreakCardView.swift
│   ├── ViewModels/
│   │   └── WorkoutBuilderViewModel.swift
│   └── Services/
│       └── WorkoutService.swift          # Business logic
├── Execution/
│   ├── Views/
│   │   ├── WorkoutExecutionView.swift    # Active workout screen
│   │   ├── CompletionSummaryView.swift   # Workout complete
│   │   └── Components/
│   │       ├── ActiveExerciseCardView.swift
│   │       └── UpcomingItemRowView.swift
│   ├── ViewModels/
│   │   └── ExecutionViewModel.swift
│   └── Services/
│       └── ExecutionService.swift        # Workout progression logic
├── Common/
│   ├── Views/
│   │   ├── ImagePickerView.swift         # Camera/Library picker
│   │   └── YouTubePlayerView.swift       # SFSafariViewController wrapper
│   └── Extensions/
│       ├── View+Extensions.swift
│       └── Int+TimeFormatting.swift
├── Resources/
│   ├── Assets.xcassets
│   └── PrivacyInfo.xcprivacy
└── Info.plist

GymtasticTests/
├── ExerciseViewModelTests.swift
├── WorkoutBuilderViewModelTests.swift
├── ExecutionViewModelTests.swift
├── ExerciseServiceTests.swift
├── WorkoutServiceTests.swift
└── ExecutionServiceTests.swift

GymtasticUITests/
├── ExerciseFlowUITests.swift
├── WorkoutBuilderUITests.swift
└── WorkoutExecutionUITests.swift
```

**Structure Decision**: Mobile app structure with feature-based organization. Each feature module (Exercises, Workouts, Execution) contains its own Views, ViewModels, and Services following MVVM pattern. Models are shared in a central Models directory. Common reusable components are in Common directory. This structure aligns with the constitution's requirement for feature-based organization and clean architecture.

## Phase 0: Outline & Research
*Output: research.md*

### Research Tasks Executed
1. ✅ SwiftData best practices for iOS 17+
2. ✅ SwiftUI drag-and-drop implementation patterns
3. ✅ Image storage strategies for local persistence
4. ✅ SFSafariViewController integration for YouTube
5. ✅ XCTest async/await testing patterns
6. ✅ Accessibility implementation in SwiftUI

**Output**: All technical decisions documented in research.md

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

### Deliverables
1. ✅ **data-model.md**: SwiftData @Model entities with relationships, validation rules
2. ✅ **contracts/**: Service contracts for ExerciseService, WorkoutService, ExecutionService
3. ✅ **quickstart.md**: Step-by-step validation of primary user stories
4. ✅ **.cursorrules**: Project-specific context for AI coding assistants

### Design Decisions
- **Data Model**: SwiftData with 4 main @Model classes, cascading deletes for relationships
- **Service Layer**: Protocol-based services for testability (ExerciseServiceProtocol, etc.)
- **Image Storage**: Store images as Data in SwiftData with thumbnail generation
- **State Management**: @Observable ViewModels with @Environment for dependency injection
- **Navigation**: NavigationStack with value-based routing
- **Drag-Drop**: Using `.onDrag()` and `.onDrop()` with UTType.text transfer

**Output**: data-model.md, contracts/, quickstart.md, .cursorrules generated

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
1. Load `.specify/templates/tasks-template.md` as foundation
2. Generate tasks from Phase 1 design documents:
   - **Models** (4 tasks): Create SwiftData @Model classes
   - **Services** (3 tasks): Implement service protocols with business logic
   - **ViewModels** (3 tasks): Create observable ViewModels
   - **Views** (15-20 tasks): Implement SwiftUI views per feature
   - **Tests** (10-15 tasks): Unit tests for ViewModels and Services
   - **UI Tests** (3-5 tasks): Critical user flow tests
   - **Integration** (2-3 tasks): Service integration with SwiftData

**Ordering Strategy** (TDD Approach):
1. **Foundation** [P]: Models → Services protocols → ImageStorageService
2. **Exercise Module**:
   - ExerciseService tests → ExerciseService implementation
   - ExerciseViewModel tests → ExerciseViewModel implementation
   - Exercise views (parallel where possible)
3. **Workout Module**:
   - WorkoutService tests → WorkoutService implementation
   - WorkoutBuilderViewModel tests → WorkoutBuilderViewModel implementation
   - Workout views including drag-drop timeline
4. **Execution Module**:
   - ExecutionService tests → ExecutionService implementation
   - ExecutionViewModel tests → ExecutionViewModel implementation
   - Execution views with active card and progression
5. **Integration & Polish**:
   - UI tests for critical flows
   - Accessibility audit
   - Performance testing

**Task Markers**:
- [P] = Parallelizable (independent files/modules)
- [TEST] = Test task (must come before implementation)
- [UI] = UI implementation task
- [INT] = Integration task

**Estimated Output**: 35-45 numbered, ordered tasks in tasks.md following Red-Green-Refactor cycle

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)
**Phase 4**: Implementation (execute tasks.md following constitutional principles)
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)

## Complexity Tracking
*Fill ONLY if Constitution Check has violations that must be justified*

No violations detected. Design fully complies with constitution.

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [x] Phase 0: Research complete (/plan command) ✅
- [x] Phase 1: Design complete (/plan command) ✅
- [x] Phase 2: Task planning approach described (/plan command) ✅
- [ ] Phase 3: Tasks generated (/tasks command) - READY
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [x] Initial Constitution Check: PASS
- [x] Post-Design Constitution Check: PASS
- [x] All NEEDS CLARIFICATION resolved
- [x] No complexity deviations

---
*Based on Constitution v1.0.0 - See `.specify/memory/constitution.md`*
