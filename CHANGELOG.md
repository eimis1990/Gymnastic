# Changelog

## 2025-10-02 - Custom Tab Bar with Theme Support

### Changed
- **Custom Tab Bar**: Built from scratch using SwiftUI for precise color control
  - **Light Theme**: Dark tab bar (#1A1F25) with selected pill (#3A3F45), white text on selected, #F7F6FB on unselected
  - **Dark Theme**: Light tab bar (#F7F6FB) with selected pill (white), dark text (#1A1F25) on selected, #3A3F45 on unselected
  - Rounded pill container with proper corner radius
  - Selected tab shows icon + text, unselected shows only icon
  - Smooth transitions between tabs
  - Automatically adapts to system theme changes

### Technical Details
- Replaced native `TabView` with custom SwiftUI tab bar implementation
- Created `CustomTabBar` component with theme-aware color computed properties
- Created `TabBarButton` component for reusable tab items
- Uses `@Environment(\.colorScheme)` for automatic theme detection
- Direct hex color usage ensures exact color matching
- VStack layout with custom tab bar at bottom

---

## 2025-10-02 - UI Polish & Tab Bar Redesign

### Changed
- **Tab Bar Appearance**: Completely redesigned bottom navigation
  - Matches design reference for better visual hierarchy
  
- **Exercise List Layout**: Converted from List to ScrollView with cards
  - Removed double backgrounds (list cell + card)
  - Removed duplicate chevron arrows (NavigationLink provides its own)
  - Larger card images (80x80) for better visibility
  - Increased padding for more spacious feel
  - Cards now appear as standalone elements, not list rows
  
- **Workout List Layout**: Same improvements as exercises
  - Clean card-only design without list backgrounds
  - Better spacing between cards
  - Context menu for delete functionality
  
- **ExerciseCardView**: Enhanced design
  - Made `showChevron` parameter optional (default: true)
  - Larger thumbnail images (80x80 instead of 60x60)
  - Better icon size for placeholders
  - Updated muscle group tag colors to use `gymAccent`
  - Improved padding and spacing

### Technical Details
- Replaced `List` with `ScrollView` + `LazyVStack` for better control
- Used `PlainButtonStyle()` to prevent default button styling
- Added `contextMenu` for delete actions (long-press to delete)
- Custom `UITabBarAppearance` configuration for precise color control

---

## 2025-10-02 - UI Refinements & Onboarding Flow

### Added
- **Onboarding Screen**: Welcome/get started screen displayed on first app launch
  - Hero image with fitness icon
  - Motivational message: "Wherever You Are Health Is Number One"
  - "Get Started" button to begin using the app
  - Completion status saved to UserDefaults to prevent re-showing
  
- **New Color Scheme**: Refreshed visual design with modern colors
  - Accent color changed from yellow (#FED90F) to lime green (#C8F065)
  - Light theme: Background #F7F6FB with white cards
  - Dark theme: Background #1A1F25 with cards #3A3F45
  - All buttons and interactive elements use new accent color

### Changed
- **View+Extensions.swift**: Updated color system
  - Added `gymAccent` as new primary color
  - Kept `gymYellow` as deprecated alias for backwards compatibility
  - Added theme-specific colors: `lightBackground`, `lightCard`, `darkBackground`, `darkCard`
  - Updated card shadows for softer, more modern appearance
  
- **GymtasticApp.swift**: Added onboarding logic
  - Check for "hasCompletedOnboarding" UserDefaults flag
  - Display OnboardingView with fade transition when flag is false
  - OnboardingView dismisses when user taps "Get Started"
  
- **ContentView.swift**: Updated to use new color scheme
  - Background uses `lightBackground` color
  - TabView tint uses `gymAccent` color
  - All buttons updated to use new accent color
  - List backgrounds set to transparent with custom background color
  
- **WorkoutExecutionView.swift**: Updated execution screen colors
  - Background changed to `lightBackground`
  - Progress bar uses `gymAccent` color
  - Action buttons use `gymAccent` with black text for better contrast
  
- **CompletionSummaryView.swift**: Updated summary screen
  - Background gradient uses `gymAccent` and `lightBackground`
  - Success icon uses `gymAccent` color
  - "Done" button uses `gymAccent` with black text
  - Stat cards use `lightCard` background

### Documentation
- Updated `spec.md` with 6 new functional requirements (FR-047 through FR-052)
- Updated `tasks.md` with 3 new tasks (T056-T058) for UI refinements
- Updated requirement count from 46 to 52
- Added UI/Design section to functional requirements
- Documented onboarding flow and color scheme in execution status

### Files Created
- `Gymtastic/Common/Views/OnboardingView.swift` - Welcome screen with get started flow

### Files Modified
- `Gymtastic/Common/Extensions/View+Extensions.swift` - Color system updates
- `Gymtastic/GymtasticApp.swift` - Onboarding integration
- `Gymtastic/ContentView.swift` - Color scheme updates
- `Gymtastic/Execution/Views/WorkoutExecutionView.swift` - Color updates
- `Gymtastic/Execution/Views/CompletionSummaryView.swift` - Color updates
- `specs/001-i-am-building/spec.md` - Added UI requirements
- `specs/001-i-am-building/tasks.md` - Added UI refinement tasks

---

## 2025-10-02 - Regular Break Timer Implementation

### Fixed
- **Regular Break Countdown**: Regular breaks (between exercises) now automatically start countdown timers
  - Timer starts immediately when break begins
  - Shows large countdown display with remaining seconds
  - Button changes to "Skip Break" during regular breaks
  - Consistent countdown experience for both set breaks and regular breaks

### Changed
- **ExecutionSession Model**: Added regular break tracking
  - `regularBreakStartTime: Date?` - tracks when regular break started
  - `remainingRegularBreakTime: Int?` - computed property for countdown
  
- **ExecutionService Logic**: Auto-start break timers
  - Sets `regularBreakStartTime` when moving to a break item
  - Initializes timer in `startWorkout` if first item is a break
  - Resets timer when moving to next item

- **Button Text Logic**: Enhanced contextual button text
  - "Skip Break" for regular breaks (between exercises)
  - "Skip Break" for set breaks (between sets)
  - "Complete Set" for exercises with multiple sets
  - "Next" for single-set exercises or moving to next exercise

- **ActiveExerciseCardView**: Shows countdown for regular breaks
  - Displays remaining time in large 60pt font
  - Consistent styling with set break countdown
  - Shows "seconds remaining" label

### Documentation
- Updated `spec.md` with new functional requirements (FR-044 through FR-046)
- Updated `execution-service.md` contract with regular break tracking
- Added new acceptance scenarios for regular break timers
- Updated requirement count from 38 to 46

---

## 2025-10-02 - Set Tracking & Break Timer Implementation

### Fixed
- **Background Color Issue**: Added proper background color (`Color(.systemBackground)`) to `WorkoutExecutionView` so the fullScreenCover displays correctly without being transparent

### Added
- **Individual Set Tracking**: Exercises with multiple sets now track progress through each set individually
  - Display shows "Set 1 of 3" format to indicate current progress
  - Each set must be completed separately using the "Complete Set" button
  
- **Break Timer Between Sets**: Automatic countdown timer between sets
  - After completing a set (except the last one), users see a countdown timer showing remaining rest time
  - Timer displays in large, easy-to-read format with seconds remaining
  - Shows which set is coming next (e.g., "Get ready for Set 2")
  - Users can skip breaks by tapping "Skip Break" button
  
- **Dynamic Button Text**: Button text changes contextually
  - "Complete Set" when performing a set of a multi-set exercise
  - "Skip Break" when on a rest period between sets
  - "Next" when moving to next exercise or single-set exercise

### Changed
- **ExecutionSession Model**: Added set tracking fields
  - `currentSet: Int?` - tracks which set user is on (1-based)
  - `isOnSetBreak: Bool` - indicates if currently resting between sets
  - `setBreakStartTime: Date?` - when the break started
  - `setBreakDuration: Int?` - duration of current break
  - `remainingBreakTime: Int?` - computed property showing seconds remaining

- **ExecutionService Logic**: Enhanced progression logic
  - Initializes `currentSet` to 1 when starting multi-set exercises
  - Starts break timer after completing a set (if not last set)
  - Moves to next set after break completion
  - Resets set tracking when moving to next exercise

- **ActiveExerciseCardView**: Enhanced display
  - Shows current set number for multi-set exercises
  - Displays countdown timer during set breaks
  - Shows "Get ready for Set X" message during breaks
  - Updated configuration display to show individual reps per set instead of total

### Technical Details
- Added 1-second timer task in `WorkoutExecutionView` to update countdown display
- Break timer calculates remaining time based on elapsed time since break start
- Automatic UI refresh every second using `.id(timerTick)` modifier

### Documentation
- Updated `spec.md` with new functional requirements (FR-039 through FR-043)
- Updated `execution-service.md` contract with set tracking behavioral requirements
- Added new acceptance scenarios for set tracking and break timers
