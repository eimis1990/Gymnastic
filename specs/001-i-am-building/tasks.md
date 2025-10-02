# Tasks: Custom Workout Builder

**Feature**: 001-i-am-building  
**Input**: Design documents from `/specs/001-i-am-building/`  
**Prerequisites**: plan.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → ✅ FOUND: Swift 5.9+, SwiftUI, SwiftData, iOS 17+
   → ✅ Structure: Feature-based (Exercises/, Workouts/, Execution/)
2. Load optional design documents:
   → ✅ data-model.md: 5 entities (Exercise, Workout, WorkoutItem, Break, MuscleGroup)
   → ✅ contracts/: 3 services (ExerciseService, WorkoutService, ExecutionService)
   → ✅ research.md: 10 technical decisions documented
3. Generate tasks by category:
   → Setup: Xcode project, SwiftData, test targets
   → Tests: 32 service test scenarios + ViewModel tests
   → Core: Models, Services, ViewModels, Views
   → Integration: Navigation, ImageStorage, YouTube
   → Polish: UI tests, accessibility, performance
4. Apply task rules:
   → [P] = Independent files (models, separate services, tests)
   → Sequential = Shared dependencies (ViewModels → Views)
   → TDD = Tests before implementation
5. Number tasks sequentially (T001-T055)
6. Generate dependency graph ✅
7. Create parallel execution examples ✅
8. Validate task completeness ✅
9. Return: SUCCESS (55 tasks ready for execution)
```

---

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[TEST]**: Test task (must come before implementation, must fail initially)
- **[UI]**: UI implementation task
- **[INT]**: Integration task

---

## Phase 3.1: Setup & Infrastructure (T001-T008)

### Project Initialization
- [x] **T001** Create Xcode project "Gymtastic" with iOS 17.0 deployment target, bundle ID `com.gymtastic.app`, organization name "Gymtastic" ✅

- [x] **T002** Configure project structure: Create groups `Models/`, `Exercises/`, `Workouts/`, `Execution/`, `Common/`, `Resources/` in Xcode project navigator ✅

- [x] **T003** Add test targets: Create `GymtasticTests` (unit tests) and `GymtasticUITests` (UI tests) targets with proper bundle IDs ✅

### SwiftData Configuration
- [x] **T004** Configure SwiftData ModelContainer in `Gymtastic/GymtasticApp.swift` with schema for all @Model types and CloudKit automatic configuration ✅

- [x] **T005** Add Info.plist entries: `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` with clear permission descriptions ✅

- [x] **T006** Create PrivacyInfo.xcprivacy manifest file in `Resources/` with no tracking domains and no required reasons APIs ✅

### Development Tools
- [x] **T007** [P] Create `.swiftlint.yml` configuration file at project root with constitution-compliant rules (no force unwrap warnings, 300 line limit for files) ✅

- [x] **T008** [P] Create `.gitignore` for Xcode project: exclude `*.xcuserstate`, `DerivedData/`, `.DS_Store`, `*.swp` ✅

### UI Refinements
- [x] **T056** [P] [UI] Update color scheme: Change accent color to lime green (#C8F065), add light theme colors (background: #F7F6FB, card: white), add dark theme colors (background: #1A1F25, card: #3A3F45), update all views to use new colors ✅

- [x] **T057** [P] [UI] Create `Common/Views/OnboardingView.swift`: Build welcome/get started screen with hero image, motivational text "Wherever You Are Health Is Number One", and "Get Started" button that saves completion flag to UserDefaults ✅

- [x] **T058** [UI] Add onboarding flow to `GymtasticApp.swift`: Check UserDefaults flag "hasCompletedOnboarding", display OnboardingView as overlay when flag is false, transition with animation when completed ✅

---

## Phase 3.2: Data Models (T009-T013)
**All models are parallelizable - different files, no dependencies**

- [x] **T009** [P] Create `Models/MuscleGroup.swift`: Define enum with 11 cases (Chest, Back, Shoulders, Biceps, Triceps, Legs, Core, Glutes, Forearms, Calves, Full Body), CaseIterable, Identifiable, with `sfSymbolName` computed property ✅

- [x] **T010** [P] Create `Models/Exercise.swift`: SwiftData @Model class with properties (id, title, exerciseDescription, youtubeURL, imageData, thumbnailData, muscleGroups as [String], createdAt, updatedAt), @Relationship with WorkoutItem (deleteRule: .nullify), computed properties (muscleGroupsEnum, isUsedInWorkouts) ✅

- [x] **T011** [P] Create `Models/WorkoutItem.swift`: SwiftData @Model class with properties (id, exercise, workout, configurationType enum, position, sets, repsPerSet, restBetweenSetsSeconds, durationSeconds), computed properties (estimatedDuration, configurationSummary), ConfigurationType enum (repetitions, time) ✅

- [x] **T012** [P] Create `Models/Break.swift`: SwiftData @Model class with properties (id, workout, durationSeconds, position), computed property (formattedDuration) ✅

- [x] **T013** [P] Create `Models/Workout.swift`: SwiftData @Model class with properties (id, title, createdAt, updatedAt), @Relationship with items and breaks (deleteRule: .cascade), computed properties (totalExercises, estimatedDuration, orderedSequence), WorkoutSequenceItem enum ✅

---

## Phase 3.3: Service Tests (T014-T025)
**⚠️ CRITICAL: These tests MUST be written and MUST FAIL before ANY service implementation**

### ExerciseService Tests (10 test scenarios)
- [x] **T014** [P] [TEST] Create `GymtasticTests/ExerciseServiceTests.swift`: Test file with setup using in-memory SwiftData ModelConfiguration, test TC-E01 (create exercise with valid data), TC-E02 (create with image), TC-E03 (update exercise) ✅

- [x] **T015** [P] [TEST] Add tests to `GymtasticTests/ExerciseServiceTests.swift`: TC-E04 (delete unused exercise), TC-E05 (search exercises), TC-E06 (empty title error), TC-E07 (invalid YouTube URL error) ✅

- [x] **T016** [P] [TEST] Add tests to `GymtasticTests/ExerciseServiceTests.swift`: TC-E08 (no muscle groups error), TC-E09 (oversized image error), TC-E10 (delete exercise used in workouts warning) ✅

### WorkoutService Tests (11 test scenarios)
- [x] **T017** [P] [TEST] Create `GymtasticTests/WorkoutServiceTests.swift`: Test file with setup, test TC-W01 (create empty workout), TC-W02 (add rep-based exercise), TC-W03 (add time-based exercise), TC-W04 (add break) ✅

- [x] **T018** [P] [TEST] Add tests to `GymtasticTests/WorkoutServiceTests.swift`: TC-W05 (reorder exercises), TC-W06 (remove exercise), TC-W07 (calculate duration), TC-W08 (empty title error) ✅

- [x] **T019** [P] [TEST] Add tests to `GymtasticTests/WorkoutServiceTests.swift`: TC-W09 (invalid sets error), TC-W10 (validate empty workout error), TC-W11 (invalid break duration error) ✅

### ExecutionService Tests (11 test scenarios)
- [x] **T020** [P] [TEST] Create `GymtasticTests/ExecutionServiceTests.swift`: Test file with setup, ExecutionSession struct, WorkoutProgress struct, WorkoutSummary struct definitions, test TC-X01 (start workout), TC-X02 (advance to next item), TC-X03 (complete workout) ✅

- [x] **T021** [P] [TEST] Add tests to `GymtasticTests/ExecutionServiceTests.swift`: TC-X04 (get progress), TC-X05 (get upcoming items), TC-X06 (pause and resume), TC-X07 (stop workout early) ✅

- [x] **T022** [P] [TEST] Add tests to `GymtasticTests/ExecutionServiceTests.swift`: TC-X08 (workout with breaks), TC-X09 (start empty workout error), TC-X10 (advance beyond last item error) ✅

### ImageStorage Tests
- [x] **T023** [P] [TEST] Create `GymtasticTests/ImageStorageServiceTests.swift`: Test thumbnail generation (200x200, <50KB target), image validation (<2MB), compression quality, async operations ✅

### ViewModel Tests (Create test files - implementations come later)
- [x] **T024** [P] [TEST] Create `GymtasticTests/ExerciseViewModelTests.swift`: Test file stub with @Observable mock, test createExercise, updateExercise, deleteExercise, loadExercises, searchExercises methods ✅

- [x] **T025** [P] [TEST] Create `GymtasticTests/WorkoutBuilderViewModelTests.swift`: Test file stub for createWorkout, addExercise, addBreak, reorderItems, removeItem, validateWorkout methods ✅

**🔴 CHECKPOINT: Run tests with ⌘U - ALL TESTS MUST FAIL before proceeding to T026**

---

## Phase 3.4: Service Implementations (T026-T032)

### Protocols & Errors
- [x] **T026** [P] Create `Exercises/Services/ExerciseServiceProtocol.swift`: Protocol definition with all methods from exercise-service.md contract, ExerciseServiceError enum with all error cases and localizedDescription ✅

- [x] **T027** [P] Create `Workouts/Services/WorkoutServiceProtocol.swift`: Protocol definition with all methods from workout-service.md contract, WorkoutServiceError enum with all error cases ✅

- [x] **T028** [P] Create `Execution/Services/ExecutionServiceProtocol.swift`: Protocol definition with all methods from execution-service.md contract, ExecutionServiceError enum, ExecutionSession/WorkoutProgress/WorkoutSummary structs ✅

### Service Implementations
- [x] **T029** Create `Exercises/Services/ExerciseService.swift`: Implement ExerciseServiceProtocol with ModelContext, all CRUD operations, validation methods, YouTube URL validation (regex pattern), implement all business rules from contract ✅

- [x] **T030** Create `Common/Services/ImageStorageService.swift`: Implement thumbnail generation using UIGraphicsImageRenderer, image validation (<2MB), compression to JPEG with quality 0.8 for full image and 0.7 for thumbnail, async operations ✅

- [x] **T031** Create `Workouts/Services/WorkoutService.swift`: Implement WorkoutServiceProtocol with ModelContext, workout CRUD, exercise/break management, position management logic (sequential numbering), reorder algorithm, validation methods ✅

- [x] **T032** Create `Execution/Services/ExecutionService.swift`: Implement ExecutionServiceProtocol, session management (in-memory, not persisted), progression logic (advance index, track completed), pause/resume with timestamp handling, completion detection, progress calculation ✅

**🟢 CHECKPOINT: Run tests with ⌘U - Service tests (T014-T023) should now PASS**

---

## Phase 3.5: ViewModels (T033-T038)

- [x] **T033** Create `Exercises/ViewModels/ExerciseViewModel.swift`: @Observable class with ExerciseService dependency, @Published properties (exercises, isLoading, errorMessage), methods (createExercise, updateExercise, deleteExercise, loadExercises, searchExercises), proper error handling ✅

- [x] **T034** [TEST] Implement tests in `GymtasticTests/ExerciseViewModelTests.swift`: Complete all ViewModel test scenarios using mock ExerciseService, verify state changes, error handling, async operations ✅

- [x] **T035** Create `Workouts/ViewModels/WorkoutBuilderViewModel.swift`: @Observable class with WorkoutService dependency, properties (currentWorkout, exercises, selectedExercise, isLoading, errorMessage), methods (createWorkout, addExercise, addBreak, reorderItems, removeItem, saveWorkout, validateWorkout) ✅

- [x] **T036** [TEST] Implement tests in `GymtasticTests/WorkoutBuilderViewModelTests.swift`: Complete all ViewModel test scenarios, verify workout building flow, reordering logic, validation ✅

- [x] **T037** Create `Execution/ViewModels/ExecutionViewModel.swift`: @Observable class with ExecutionService, properties (session, currentItem, upcomingItems, progress, status), methods (startWorkout, nextItem, pauseWorkout, resumeWorkout, stopWorkout, completeWorkout), timer management ✅

- [x] **T038** [P] [TEST] Create `GymtasticTests/ExecutionViewModelTests.swift`: Test execution flow, progression, pause/resume, completion, progress calculations ✅

**🟢 CHECKPOINT: Run tests with ⌘U - ViewModel tests (T034, T036, T038) should PASS**

---

## Phase 3.6: Common Components (T039-T041)

- [x] **T039** [P] Create `Common/Views/ImagePickerView.swift`: SwiftUI wrapper for PHPickerViewController with UIViewControllerRepresentable, supports camera and photo library, returns UIImage, handles permissions gracefully ✅

- [x] **T040** [P] Create `Common/Views/YouTubePlayerView.swift`: SwiftUI wrapper for SFSafariViewController with UIViewControllerRepresentable, opens YouTube URL, presents as sheet ✅

- [x] **T041** [P] Create `Common/Extensions/View+Extensions.swift`: Extension with custom modifiers (loading overlay, error alert), common styling helpers (card style, shadow style) ✅

---

## Phase 3.7: Exercise Module Views (T042-T045)

- [x] **T042** [UI] Create `Exercises/Views/Components/ExerciseCardView.swift`: SwiftUI view showing exercise thumbnail (AsyncImage from thumbnailData), title, muscle groups (HStack with tags), SF Symbol icons, card styling with shadow ✅

- [x] **T043** [UI] Create `Exercises/Views/ExerciseListView.swift`: List of exercises using @Query, pull-to-refresh, search bar, navigation to detail view, "+" button for create, empty state view, swipe-to-delete with confirmation ✅ (Integrated in ContentView)

- [x] **T044** [UI] Create `Exercises/Views/CreateExerciseView.swift`: Form with TextField (title), TextEditor (description), ImagePickerView (image selection), TextField (YouTube URL), multi-select muscle groups (List with checkmarks), Save button, validation error display, NavigationStack ✅

- [x] **T045** [UI] Create `Exercises/Views/ExerciseDetailView.swift`: Display exercise details, full image (AsyncImage), muscle groups, description, YouTube "See Video" button (presents YouTubePlayerView as sheet), Edit button (navigates to CreateExerciseView in edit mode), Delete button with confirmation ✅

---

## Phase 3.8: Workout Module Views (T046-T049)

- [x] **T046** [UI] Create `Workouts/Views/Components/WorkoutItemCardView.swift`: SwiftUI view for exercise in timeline, shows exercise title, image thumbnail, configuration summary ("3 sets × 10 reps" or "45s"), drag handle icon, compact design ✅

- [x] **T047** [UI] Create `Workouts/Views/Components/BreakCardView.swift`: SwiftUI view for break in timeline, shows "Break" label with timer icon, formatted duration ("2m 0s"), different styling from exercise cards (lighter background) ✅

- [x] **T048** [UI] Create `Workouts/Views/WorkoutListView.swift`: List of workouts using @Query, shows workout title, exercise count, estimated duration, "+" button to create, navigation to WorkoutBuilderView, swipe-to-delete, empty state ✅ (Integrated in ContentView)

- [x] **T049** [UI] Create `Workouts/Views/WorkoutTimelineView.swift`: Vertical list with drag-and-drop using .onDrag() and .onDrop(), shows WorkoutItemCardView and BreakCardView, reorder functionality, "Add Exercise" and "Add Break" buttons positioned between items, visual feedback during drag (scale, opacity), haptic feedback on drop ✅

- [x] **T050** [UI] Create `Workouts/Views/WorkoutBuilderView.swift`: Main workout creation view, TextField for workout title, WorkoutTimelineView for items, sheet for exercise selection (ExerciseListView), sheet for exercise configuration (sets/reps/rest or duration with toggle), estimated duration display at top, Save button, handles add/remove/reorder operations via WorkoutBuilderViewModel ✅

---

## Phase 3.9: Execution Module Views (T051-T053)

- [x] **T051** [UI] Create `Execution/Views/Components/ActiveExerciseCardView.swift`: Large prominent card at top, shows exercise image (full size), title (large font), configuration ("3 sets × 10 reps"), "See Video" button, "Next" button at bottom, progress bar, card styling with elevation ✅

- [x] **T052** [UI] Create `Execution/Views/Components/UpcomingItemRowView.swift`: Compact row for upcoming exercises/breaks, shows title only (no full details), small icon (dumbbell for exercise, timer for break), position number, subtle separator ✅

- [x] **T053** [UI] Create `Execution/Views/WorkoutExecutionView.swift`: VStack with ActiveExerciseCardView at top (current item), progress indicator ("Exercise 3 of 8"), ScrollView with List of UpcomingItemRowView items (next 3-5), pause button (top-trailing), stop button with confirmation alert, handles nextItem, pause/resume via ExecutionViewModel ✅

- [x] **T054** [UI] Create `Execution/Views/CompletionSummaryView.swift`: Success screen, shows "Workout Complete!" title, workout name, total duration formatted, exercises completed count, completion animation (checkmark), "Done" button returns to workout list ✅

---

## Phase 3.10: App Integration & Polish (T055-T065)

### Navigation & Main App
- [x] **T055** [INT] Create `Gymtastic/ContentView.swift`: TabView with 2 tabs (Exercises, Workouts), SF Symbol icons (dumbbell.fill, list.bullet.rectangle), NavigationStack for each tab, proper tab labels with .accessibilityLabel() ✅

- [ ] **T056** [INT] Update `Gymtastic/GymtasticApp.swift`: Inject services into environment using @Environment, provide ExerciseService, WorkoutService, ExecutionService instances, ensure ModelContainer is accessible

### Navigation Routes
- [ ] **T057** [INT] Create navigation handling: Define Route enum (exerciseDetail, createExercise, workoutBuilder, execution), implement .navigationDestination(for: Route.self) in ContentView, handle deep linking

### Accessibility
- [ ] **T058** [P] Add accessibility labels: Add .accessibilityLabel() to all buttons, images, icons in all views, add .accessibilityHint() for non-obvious actions, add .accessibilityValue() for progress indicators, ensure minimum 44pt touch targets

- [ ] **T059** [P] Test with VoiceOver: Enable VoiceOver, test create exercise flow, test workout builder flow, test execution flow, verify all elements announced correctly

- [ ] **T060** [P] Test Dynamic Type: Enable largest text size in iOS settings, verify all screens layout correctly, verify no text truncation, verify readable font scaling

### UI Tests (Critical Flows)
- [ ] **T061** [P] [TEST] Create `GymtasticUITests/ExerciseFlowUITests.swift`: UI test for creating exercise (tap +, fill form, save), viewing exercise detail, editing exercise, deleting exercise, searching exercises, use accessibility identifiers

- [ ] **T062** [P] [TEST] Create `GymtasticUITests/WorkoutBuilderUITests.swift`: UI test for creating workout, adding exercises, adding breaks, reordering via drag-drop (use .press(forDuration:thenDragTo:)), removing items, saving workout

- [ ] **T063** [P] [TEST] Create `GymtasticUITests/WorkoutExecutionUITests.swift`: UI test for starting workout, advancing through exercises, viewing video (verify SFSafariViewController appears), pausing/resuming, completing workout, viewing summary

### Performance & Validation
- [ ] **T064** [INT] Performance optimization: Add lazy loading to exercise list thumbnails, implement image caching strategy, add loading indicators for async operations, profile with Instruments (Allocations, Time Profiler), verify 60fps scrolling, verify <1s app launch

- [ ] **T065** [P] Manual validation using `quickstart.md`: Execute all 3 user stories step-by-step, validate all acceptance criteria, test all edge cases and error handling, verify accessibility compliance, verify Dark Mode support, document any issues found

---

## Dependencies Graph

```
Setup (T001-T008)
    ↓
Models (T009-T013) [All parallel]
    ↓
Service Tests (T014-T025) [Parallel within categories]
    ↓
Service Implementations (T026-T032) [Sequential: T026-T028 parallel, then T029-T032 sequential]
    ↓
ViewModel Tests (T033-T038) [Interleaved: Create VM → Test VM]
    ↓
Common Components (T039-T041) [All parallel]
    ↓
Views - Exercises (T042-T045) [Sequential: Components first, then views]
    ↓
Views - Workouts (T046-T050) [Sequential: Components first, then views]
    ↓
Views - Execution (T051-T054) [Sequential: Components first, then views]
    ↓
Integration (T055-T057) [Sequential]
    ↓
Polish (T058-T065) [T058-T060 parallel, T061-T063 parallel, T064-T065 sequential]
```

---

## Parallel Execution Examples

### Batch 1: Models (After T008)
```bash
# Run these 5 tasks simultaneously - all independent files
T009: MuscleGroup.swift enum
T010: Exercise.swift @Model
T011: WorkoutItem.swift @Model
T012: Break.swift @Model
T013: Workout.swift @Model
```

### Batch 2: Service Tests (After T013)
```bash
# Run these test files in parallel
T014: ExerciseServiceTests.swift (TC-E01, E02, E03)
T017: WorkoutServiceTests.swift (TC-W01-W04)
T020: ExecutionServiceTests.swift (TC-X01-X03)
T023: ImageStorageServiceTests.swift
T024: ExerciseViewModelTests.swift (stubs)
T025: WorkoutBuilderViewModelTests.swift (stubs)
```

### Batch 3: Service Protocols (After T025)
```bash
# Run these 3 protocol files in parallel
T026: ExerciseServiceProtocol.swift
T027: WorkoutServiceProtocol.swift
T028: ExecutionServiceProtocol.swift
```

### Batch 4: Common Components (After T038)
```bash
# Run these 3 common files in parallel
T039: ImagePickerView.swift
T040: YouTubePlayerView.swift
T041: View+Extensions.swift
```

### Batch 5: Accessibility (After T057)
```bash
# Run these accessibility tasks in parallel
T058: Add accessibility labels to all views
T059: VoiceOver testing
T060: Dynamic Type testing
```

### Batch 6: UI Tests (After T060)
```bash
# Run these UI test files in parallel
T061: ExerciseFlowUITests.swift
T062: WorkoutBuilderUITests.swift
T063: WorkoutExecutionUITests.swift
```

---

## Task Execution Commands

Each task can be executed using the Task agent. Example commands:

```swift
// T009: Create MuscleGroup enum
"Create Models/MuscleGroup.swift with Swift enum containing 11 muscle group cases (Chest, Back, Shoulders, Biceps, Triceps, Legs, Core, Glutes, Forearms, Calves, Full Body). Conform to String, Codable, CaseIterable, Identifiable protocols. Add sfSymbolName computed property returning appropriate SF Symbol for each case."

// T029: Implement ExerciseService
"Implement Exercises/Services/ExerciseService.swift conforming to ExerciseServiceProtocol. Use SwiftData ModelContext for persistence. Implement all CRUD operations (create, update, delete, fetch). Add validation for title (1-100 chars), YouTube URL (regex pattern), muscle groups (min 1), image size (<2MB). Implement search by title (case-insensitive). Handle all error cases with ExerciseServiceError. Follow async/await patterns."

// T043: Create ExerciseListView
"Create Exercises/Views/ExerciseListView.swift with SwiftUI List showing exercises using @Query. Include search bar, pull-to-refresh, navigation to detail view, '+' button for create, empty state view ('No exercises yet'), swipe-to-delete with confirmation alert. Use ExerciseCardView for list items. Add .accessibilityLabel() to all interactive elements."
```

---

## Validation Checklist
*GATE: Checked before marking tasks complete*

- [x] All 3 contracts have corresponding test tasks (T014-T022)
- [x] All 5 entities have model creation tasks (T009-T013)
- [x] All tests come before implementation (Phase 3.3 before 3.4)
- [x] Parallel tasks are truly independent (different files)
- [x] Each task specifies exact file path
- [x] No [P] task modifies same file as another [P] task
- [x] TDD enforced: Tests (T014-T025) → Services (T029-T032) → ViewModels (T033-T038)
- [x] All quickstart scenarios covered (T065 manual validation)
- [x] Accessibility requirements addressed (T058-T060)
- [x] Critical UI flows have tests (T061-T063)
- [x] Performance targets validated (T064)

---

## Notes

### TDD Enforcement
- **🔴 Red**: T014-T025 write tests that MUST FAIL
- **🟢 Green**: T029-T032 implement services to make tests pass
- **🔵 Refactor**: T064 optimize after tests pass

### Commit Strategy
- Commit after each task completion
- Use descriptive messages: `"[T009] Create MuscleGroup enum with 11 cases"`
- Tag after phase completion: `phase-3.4-services-complete`

### Parallel Execution
- Tasks marked [P] can run simultaneously
- Use multiple terminal windows or automation
- Example: Open 5 Chat sessions for T009-T013

### Testing Commands
```bash
# Run all tests
⌘U in Xcode

# Run specific test class
# Right-click test class → Run

# View code coverage
# Product → Test → Show Code Coverage
# Target: 70%+ for Services and ViewModels

# Run UI tests on simulator
# Select iPhone 15 Pro simulator → ⌘U
```

### Common Patterns
```swift
// SwiftData @Model
@Model
final class EntityName {
    @Attribute(.unique) var id: UUID
    var property: String
    @Relationship(deleteRule: .cascade) var related: [RelatedEntity]
}

// @Observable ViewModel
@Observable
final class FeatureViewModel {
    private let service: ServiceProtocol
    var items: [Item] = []
    var isLoading = false
    var errorMessage: String?
    
    func loadItems() async { ... }
}

// SwiftUI View
struct FeatureView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: FeatureViewModel
    
    var body: some View {
        NavigationStack { ... }
    }
}
```

---

## Success Criteria

Upon completion of all 65 tasks:
- ✅ All 38 functional requirements from spec.md implemented
- ✅ Test coverage ≥ 70% for Services and ViewModels
- ✅ All 32 service test scenarios passing
- ✅ All 3 UI test flows passing
- ✅ Zero compiler warnings
- ✅ SwiftLint clean
- ✅ Accessibility compliant (VoiceOver, Dynamic Type)
- ✅ Performance targets met (<1s launch, 60fps scrolling)
- ✅ All quickstart scenarios validated
- ✅ Constitution compliance verified

---

**Generated**: 2025-10-01  
**Total Tasks**: 65  
**Estimated Duration**: 15-20 development days (single developer)  
**Parallelization**: Up to 6 tasks simultaneously in optimal batches

---

**🚀 Tasks ready for execution! Start with T001 and follow the dependency graph.**

