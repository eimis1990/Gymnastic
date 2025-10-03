# Changelog

## 2025-10-03 - Home Screen & Navigation Enhancement

### Added
- **Home Screen**: New dashboard-style landing screen with multiple sections
  - **Profile Header**: Greeting message ("Good Morning", "Hi Alexa") with profile avatar placeholder and notification bell with red dot indicator
  - **Search Bar**: Quick search input with magnifying glass icon and filter button
  - **Quick Actions**: Horizontal scrollable row with 5 category buttons (Strength, Cardio, Yoga, Weight, Sports)
  - **Promotional Card**: Eye-catching gradient card with "25% Off your first session!" message and "Get Started" CTA button
  - **Favorite Workouts Section**: Displays up to 3 recently updated workouts in horizontal scrollable cards
    - Each card shows workout thumbnail, title, exercise count, and duration
    - Empty state message when no workouts exist ("No favorite workouts yet")
    - "See all" link for navigation to full workout list
  - Tapping favorite workout cards opens full workout detail sheet
  
- **Profile Tab**: Placeholder tab for future profile features
  - Simple empty state with person icon
  - "Profile" title and "Coming Soon" message
  - Properly themed colors and styling

- **4-Tab Navigation**: Expanded from 2 tabs to 4 tabs
  - Home (house.fill icon) - new default tab
  - Exercises (dumbbell.fill icon)
  - Workouts (list.bullet.rectangle.fill icon)
  - Profile (person.fill icon) - new placeholder tab

### Changed
- **Tab Bar Design**: Complete redesign to icon-only approach
  - Removed text labels from all tabs
  - Icons increased from 20pt to 24pt for better visibility
  - Active tab indicated by darker icon color (`.textPrimary`)
  - Inactive tabs use light gray (`.textSecondary`)
  - Small accent-colored dot (5pt) appears below active tab icon
  - Removed background color difference between tabs
  - Cleaner, more modern appearance
  - Bottom padding reduced to 0 for edge-to-edge design

- **Tab Bar Spacing**: Adjusted positioning
  - Reduced bottom padding from 20pt to 0pt
  - Tab bar sits closer to bottom edge of screen

### Technical Details
- `HomeTabView` component with sections: header, search, quick actions, promo card, favorites
- `QuickActionButton` component for category buttons
- `FavoriteWorkoutCard` component for workout preview cards
- `ProfileTabView` component with empty state
- Tab bar updated to VStack layout with dot indicator Circle view
- Home screen uses SwiftData @Query to fetch workouts for favorites
- All components use semantic color system (`.appBackground`, `.cardBackground`, `.textPrimary`, `.gymAccent`)

### Documentation
- Updated `spec.md` with 13 new functional requirements (FR-053 through FR-065)
- Updated `tasks.md` with 3 new tasks (T082-T084) for Home and Profile implementation
- Updated requirement count from 52 to 65 functional requirements
- Updated task count from 81 to 84 tasks
- Updated completed task count from 72 to 75 tasks
- Added "Home screen and navigation enhancements" to execution status

### Files Modified
- `Gymtastic/ContentView.swift` - Added HomeTabView, ProfileTabView, updated tab bar design, expanded to 4 tabs
- `specs/001-i-am-building/spec.md` - Added FR-053 through FR-065, updated execution status
- `specs/001-i-am-building/tasks.md` - Added T082-T084, updated counts and date

---

## 2025-10-02 - Theme Refinements & YouTube Player Improvements

### Changed
- **Theme Colors App-Wide**: Comprehensive color system overhaul for consistency
  - Fixed `ActiveExerciseCardView` info card to use `Color.appBackground` instead of semi-transparent overlay
  - Removed glass effect (`.ultraThinMaterial`) for cleaner, flatter design
  - Updated all text colors to use semantic colors (`.textPrimary`, `.textSecondary`, `.textTertiary`)
  - Removed spacing between info card and progress line for unified appearance
  
- **Tab Bar Styling**: Enhanced custom tab bar implementation
  - Selected tab now uses `Color.appBackground` for proper contrast against `cardBackground` container
  - Tab bar container uses `cardBackground` with subtle shadow
  - Unselected tabs use `.textSecondary` for better visual hierarchy
  - Removed inverted color scheme complexity
  
- **Workout Builder Cards**: Cleaner design without drag handles
  - Removed drag handle icons from `WorkoutItemCardView` and `BreakCardView`
  - Cards remain fully draggable (entire card is the drag target)
  - Updated to use theme-aware colors (`cardBackground`, `textPrimary`, `textSecondary`)
  - Added proper shadows using `Color.shadowStandard`
  - Fixed color consistency across light and dark modes
  
- **Background Colors in Sheets**: Fixed transparent background issues
  - `WorkoutExecutionView`: Added `Color.appBackground` to prevent transparency
  - `CompletionSummaryView`: Updated gradient and text colors to use theme colors
  - `OnboardingView`: Changed from hardcoded colors to `Color.appBackground`
  - All stat cards now use `Color.cardBackground`
  
- **Card Style Helpers**: Updated extension methods
  - `cardStyle()` now defaults to `Color.cardBackground` instead of static `.lightCard`
  - `borderedCardStyle()` uses `Color.cardBackground` and theme-aware shadows
  - Updated `ExerciseCardView` placeholder colors to use `.border` and `.textTertiary`
  
- **YouTube Video Button**: Improved UX and positioning
  - Repositioned to bottom-right corner of exercise image as overlay
  - Reduced size: compact design with play icon + "Video" text
  - Smaller font sizes (12pt icon, 14pt text) with minimal padding (12x8)
  - Maintained red background (#FF0000) for YouTube brand consistency
  
- **YouTube Player**: Major upgrade from Safari view to embedded player
  - Replaced `SFSafariViewController` with `WKWebView` for native embedding
  - Created `YouTubeBottomSheet` component with fixed height (320px)
  - Shows only video player without YouTube page chrome
  - Supports multiple URL formats (youtube.com/watch, youtu.be, embed)
  - 16:9 responsive iframe with proper aspect ratio
  - Bottom sheet presentation with handle bar and close button
  - Parameters: `playsinline=1`, `autoplay=0`, `rel=0`, `modestbranding=1`

### Fixed
- Color inconsistencies across light and dark themes
- Transparent backgrounds in sheet presentations
- Text visibility issues with wrong color combinations
- Card styling inconsistencies between different views

### Technical Details
- All views now use semantic color system from `AppColors.swift`
- Consistent use of `.textPrimary`, `.textSecondary`, `.textTertiary`
- All cards use `.cardBackground` for proper theme adaptation
- WKWebView configuration: disabled scrolling, black background
- Video ID extraction supports multiple YouTube URL patterns

### Documentation
- Updated `tasks.md` with completed tasks T066-T072
- Added new theme refinement section to Phase 3.10
- Updated task count from 65 to 81 tasks
- Marked 72 tasks as completed

### Files Modified
- `Gymtastic/Execution/Views/Components/ActiveExerciseCardView.swift` - Theme colors and video button positioning
- `Gymtastic/ContentView.swift` - Tab bar styling and colors
- `Gymtastic/Workouts/Views/Components/WorkoutItemCardView.swift` - Removed drag handles, theme colors
- `Gymtastic/Workouts/Views/Components/BreakCardView.swift` - Removed drag handles, theme colors
- `Gymtastic/Workouts/Views/WorkoutBuilderView.swift` - Updated button colors
- `Gymtastic/Workouts/Views/WorkoutTimelineView.swift` - Updated button colors
- `Gymtastic/Execution/Views/WorkoutExecutionView.swift` - Background colors, YouTube bottom sheet
- `Gymtastic/Execution/Views/CompletionSummaryView.swift` - Theme colors throughout
- `Gymtastic/Common/Views/OnboardingView.swift` - Background and text colors
- `Gymtastic/Common/Views/YouTubePlayerView.swift` - WKWebView implementation, bottom sheet
- `Gymtastic/Common/Extensions/View+Extensions.swift` - Card style helpers
- `Gymtastic/Exercises/Views/Components/ExerciseCardView.swift` - Theme colors
- `specs/001-i-am-building/tasks.md` - Documentation updates

---

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
