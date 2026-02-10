# ShiftMood - Screens Specifications (English)

---

## Screen-by-Screen Detailed Specs

**Primary Language:** English
**Localization:** French (see LOCALIZATION.md for all translations)

---

## 1. ONBOARDING FLOW

### 1.1 Welcome Screen

**Purpose:** First impression, explain app value proposition

**Layout:**
```
┌─────────────────────────────┐
│                             │
│      [App Icon/Logo]        │
│                             │
│       ShiftMood             │
│    Nurse Journal            │
│                             │
│   🩺 Track your emotional   │
│   wellbeing shift by shift  │
│                             │
│   📖 Write in your          │
│   personal journal          │
│                             │
│   🎉 Count down to          │
│   your time off             │
│                             │
│   [Get Started]             │
│                             │
└─────────────────────────────┘
```

**Elements:**
- App icon (120x120pt)
- Title: "ShiftMood" (largeTitle, bold)
- Subtitle: "Nurse Journal" (title3, regular)
- 3 feature bullets with icons
- Primary button: "Get Started" (full width, rounded)

**Colors:**
- Background: White
- Primary text: #1F2937
- Button: #F59E0B gradient

**Interaction:**
- Tap "Get Started" → NameInputView

---

### 1.2 Name Input Screen

**Purpose:** Collect user's first name for personalization

**Layout:**
```
┌─────────────────────────────┐
│  [< Back]                   │
│                             │
│   What's your               │
│   first name?               │
│                             │
│   ┌─────────────────────┐   │
│   │ First name         │   │
│   └─────────────────────┘   │
│                             │
│   We'll use your first name │
│   to personalize your       │
│   experience.               │
│                             │
│                             │
│   [Continue]                │
│                             │
└─────────────────────────────┘
```

**Elements:**
- Back button (top left)
- Title: "What's your first name?" (title, bold)
- TextField: placeholder "First name"
- Caption: explanation text (caption, secondary)
- Primary button: "Continue" (enabled only if name entered)

**Validation:**
- Minimum 2 characters
- Trim whitespace
- No special characters

**Interaction:**
- Type name, tap Continue → TimeOffSetupView
- Saves UserProfile to SwiftData

---

### 1.3 Time Off Setup Screen

**Purpose:** Optional setup of first time off countdown

**Layout:**
```
┌─────────────────────────────┐
│  [< Back]        [Skip]     │
│                             │
│   Do you have time off      │
│   coming up?                │
│                             │
│   Set up your first         │
│   countdown to stay         │
│   motivated!                │
│                             │
│   Start date                │
│   [Date Picker]             │
│                             │
│   End date                  │
│   [Date Picker]             │
│                             │
│   [Add my time off]         │
│                             │
└─────────────────────────────┘
```

**Elements:**
- Back button (top left)
- Skip button (top right)
- Title + subtitle
- 2 Date pickers (start/end)
- Primary button: "Add my time off"

**Validation:**
- End date must be after start date
- Both dates must be in future

**Interaction:**
- Tap "Skip" → HomeView (no time off saved)
- Tap "Add" → Saves vacation, → HomeView
- Sets onboardingCompleted = true

---

## 2. HOME VIEW (Main Dashboard)

### 2.1 Home Screen

**Purpose:** Daily hub with affirmation, countdown, and quick actions

**Layout:**
```
┌─────────────────────────────┐
│  Hello, Steve 👋            │
│  Thursday, January 29       │
│                             │
│  ┌───────────────────────┐  │
│  │ 💪                    │  │
│  │ "I make a difference, │  │
│  │ even in small         │  │
│  │ gestures"             │  │
│  │                       │  │
│  │ Resilience      ♥️    │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ 🎉 Only               │  │
│  │                       │  │
│  │     12 days           │  │
│  │                       │  │
│  │ until your time off!  │  │
│  └───────────────────────┘  │
│                             │
│  Quick Actions              │
│  ┌─────────┐  ┌──────────┐ │
│  │ Check   │  │ New      │ │
│  │ in      │  │ journal  │ │
│  └─────────┘  └──────────┘ │
│                             │
└─────────────────────────────┘
[Tab Bar: Home | Journal | Stats | Settings]
```

**Sections:**

1. **Header**
   - Greeting: "Hello, [Name] 👋"
   - Date: "Thursday, January 29"

2. **Affirmation Card**
   - Icon (matching category)
   - Affirmation text (body, medium weight)
   - Category badge (bottom left)
   - Like button (bottom right, heart icon)
   - Card style: white background, shadow, rounded corners

3. **Time Off Countdown Card**
   - Emoji 🎉
   - Large number: days until time off
   - Subtext: "until your time off!"
   - Tap to manage time off
   - Card style: gradient background (#F59E0B to #FBBF24)

4. **Quick Actions**
   - 2 buttons side by side
   - "Check in" (if no check-in today)
   - "New journal"
   - Icons: bolt.fill, square.and.pencil

**Interactions:**
- Tap affirmation heart → toggles like
- Tap countdown card → SettingsView (Time Off section)
- Tap Check in → CheckInView sheet
- Tap New journal → NewJournalView sheet

---

## 3. MOOD CHECK-IN/OUT

### 3.1 Check-In View (Pre-Shift)

**Purpose:** Track emotional state before starting shift

**Layout:**
```
┌─────────────────────────────┐
│  How are you feeling        │
│  before your shift?         │
│                [X]          │
│                             │
│  ┌───────────────────────┐  │
│  │ ⚡ Energy level       │  │
│  │ ○ ○ ○ ○ ○            │  │
│  │ 1  2  3  4  5         │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ 😰 Anticipated stress │  │
│  │ ○ ○ ○ ○ ○            │  │
│  │ 1  2  3  4  5         │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ 🎯 Motivation         │  │
│  │ ○ ○ ○ ○ ○            │  │
│  │ 1  2  3  4  5         │  │
│  └───────────────────────┘  │
│                             │
│  [Let's go! 🚀]             │
│                             │
└─────────────────────────────┘
```

**Elements:**
- Title: "How are you feeling before your shift?"
- Close button (top right)
- 3 MoodSlider components:
  1. Energy (bolt icon, orange color)
  2. Stress (anxious emoji, red color)
  3. Motivation (target icon, purple color)
- Primary button: "Let's go! 🚀"

**MoodSlider Labels:**
- Energy: Exhausted, Low, Moderate, Good, Excellent
- Stress: Very low, Low, Moderate, High, Very high
- Motivation: None, Low, Moderate, High, Very high

**Validation:**
- All 3 sliders must have value > 0

**Interaction:**
- Tap circle → sets value, fills color
- Tap "Let's go!" → saves preMood to Shift, dismisses sheet
- Creates new Shift if none exists for today

---

### 3.2 Check-Out View (Post-Shift)

**Purpose:** Track emotional state after shift + journal prompt

**Layout:**
```
┌─────────────────────────────┐
│  How was your shift?        │
│                [X]          │
│                             │
│  ┌───────────────────────┐  │
│  │ 😴 Fatigue            │  │
│  │ ○ ○ ○ ○ ○            │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ 💭 Emotional load     │  │
│  │ ○ ○ ○ ○ ○            │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ 😊 Satisfaction       │  │
│  │ ○ ○ ○ ○ ○            │  │
│  └───────────────────────┘  │
│                             │
│  How are you feeling?       │
│  [😊] [😔] [😌] [😰]       │
│  [💪] [😴] [😤] [🙏]       │
│                             │
│  [Done]                     │
│  [Write in my journal]      │
│                             │
└─────────────────────────────┘
```

**Elements:**
- Title: "How was your shift?"
- 3 MoodSliders (fatigue, emotional load, satisfaction)
- Emoji badge selector (8 options, multi-select)
- 2 buttons:
  - Secondary: "Done" (just saves)
  - Primary: "Write in my journal" (saves + opens journal)

**MoodSlider Labels:**
- Fatigue: Fresh, A bit tired, Tired, Very tired, Exhausted
- Emotional load: Very light, Light, Moderate, Heavy, Very heavy
- Satisfaction: Poor, Below average, Average, Good, Excellent

**Interactions:**
- Tap emoji badge → toggles selection
- Tap "Done" → saves postMood, dismisses
- Tap "Write in my journal" → saves postMood, opens NewJournalView

---

## 4. JOURNAL

### 4.1 Journal List View

**Purpose:** Browse all journal entries

**Layout:**
```
┌─────────────────────────────┐
│ [Tab: Home | Journal | ...] │
│                             │
│  Journal              [+]   │
│                             │
│  [Search bar]               │
│                             │
│  Today                      │
│  ┌───────────────────────┐  │
│  │ 😴 Night shift        │  │
│  │ So many patients      │  │
│  │ tonight...            │  │
│  │ 11:45 PM · Night      │  │
│  └───────────────────────┘  │
│                             │
│  Yesterday                  │
│  ┌───────────────────────┐  │
│  │ 😊 Great day          │  │
│  │ Touching encounter    │  │
│  │ 6:30 PM · Day         │  │
│  └───────────────────────┘  │
│                             │
│  [Empty State if no entries]│
│                             │
└─────────────────────────────┘
```

**Elements:**
- Navigation title: "Journal"
- Add button (top right, +)
- Search bar (sticky below title)
- Grouped by date sections
- JournalEntryRow components

**JournalEntryRow Details:**
- Mood emoji (left, large)
- Title (body, bold)
- Preview (2 lines, truncated)
- Metadata: time · tags (comma separated)
- Swipe actions: Delete (red)

**Empty State:**
- Icon: book.closed
- Title: "No entries yet"
- Subtitle: "Start writing your journal"
- Button: "Create my first entry"

**Interactions:**
- Tap + button → NewJournalView sheet
- Tap entry row → JournalDetailView
- Swipe left → delete action
- Search → filters by title/content

---

### 4.2 New Journal View

**Purpose:** Create new journal entry

**Layout:**
```
┌─────────────────────────────┐
│  [Cancel]     New Entry     │
│                      [Save] │
│                             │
│  Title                      │
│  ┌─────────────────────┐    │
│  │ Night shift         │    │
│  └─────────────────────┘    │
│                             │
│  Mood                       │
│  [😊] [😔] [😌] [😰] [💪] │
│                             │
│  Tags                       │
│  [Difficult shift] [Fatigue]│
│  [+ Add]                    │
│                             │
│  ┌─────────────────────┐    │
│  │ Write here...       │    │
│  │                     │    │
│  │                     │    │
│  │                     │    │
│  └─────────────────────┘    │
│                             │
│  Highlights (optional)      │
│  • Successful stabilization │
│  • Great team               │
│  • Need rest                │
│                             │
└─────────────────────────────┘
```

**Elements:**
1. **Navigation Bar**
   - Cancel button (left): "Cancel"
   - Title: "New Entry"
   - Save button (right): "Save" (disabled if title empty)

2. **Title Field**
   - Label: "Title"
   - TextField, placeholder: "Entry title"
   - Max length: 100 characters

3. **Mood Selector**
   - Label: "Mood"
   - 5 emoji buttons (single select)
   - Default: 😊

4. **Tags Section**
   - Label: "Tags"
   - FlowLayout with TagChipView
   - Suggested tags + custom input
   - Max 10 tags

5. **Content Editor**
   - TextEditor (multiline)
   - Placeholder: "Write here..."
   - Max length: 5000 characters
   - Auto-grows with content

6. **Highlights Section** (optional)
   - Label: "Highlights (optional)"
   - 3 TextField rows
   - Bullet point prefix
   - Placeholder: "Something I'm proud of"

**Suggested Tags:**
- Difficult shift, Great encounter, Learning
- Great team, Fatigue, Pride
- Questioning, Emergency, Death
- Recovery, Family

**Validation:**
- Title required (min 1 char)
- Content optional
- At least 1 emoji selected

**Interactions:**
- Tap Cancel → confirmation alert if content exists
- Tap Save → saves entry, dismisses sheet
- Keyboard toolbar: Done button

---

### 4.3 Journal Detail View

**Purpose:** Read full journal entry

**Layout:**
```
┌─────────────────────────────┐
│  [< Journal]          [···] │
│                             │
│  😴 Difficult night shift   │
│                             │
│  Thursday, Jan 29 · 11:45PM │
│  [Night] [Fatigue] [Pride]  │
│                             │
│  ───────────────────────    │
│                             │
│  So many patients tonight,  │
│  little sleep. But I        │
│  managed to stabilize       │
│  Mr. Johnson, that's a win. │
│                             │
│  Learned a new technique    │
│  with Sophie, she's really  │
│  patient.                   │
│                             │
│  Highlights                 │
│  • Successfully stabilized  │
│    a critical patient       │
│  • Great collaboration      │
│    with the team            │
│  • Need to better manage    │
│    my recovery              │
│                             │
└─────────────────────────────┘
```

**Elements:**
- Navigation: back button, overflow menu (···)
- Mood emoji (large, left aligned)
- Title (title2, bold)
- Metadata: date, time, tags
- Divider
- Content (scrollable, body text)
- Highlights section (if exists)

**Overflow Menu (···):**
- Edit (pencil icon)
- Delete (trash icon, red)

**Interactions:**
- Tap back → returns to list
- Tap Edit → opens JournalEditView sheet
- Tap Delete → confirmation alert → deletes entry

---

## 5. SETTINGS

### 5.1 Settings View

**Purpose:** Manage profile, time off, and app info

**Layout:**
```
┌─────────────────────────────┐
│  Settings                   │
│                             │
│  Profile                    │
│  ┌───────────────────────┐  │
│  │ First name            │  │
│  │ Steve            [>]  │  │
│  └───────────────────────┘  │
│                             │
│  Time Off                   │
│  ┌───────────────────────┐  │
│  │ My time off       [>] │  │
│  │ 2 periods planned     │  │
│  └───────────────────────┘  │
│                             │
│  About                      │
│  ┌───────────────────────┐  │
│  │ Version               │  │
│  │ 0.1 (1)               │  │
│  ├───────────────────────┤  │
│  │ Support               │  │
│  │ steve@steverover.com  │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Sections:**

1. **Profile**
   - Row: "First name" → tap opens name edit alert

2. **Time Off**
   - Row: "My time off" → TimeOffManagementView
   - Subtitle: count of time off periods

3. **About**
   - Static row: Version number
   - Row: Support email (tap to compose email)

**Interactions:**
- Tap First name → Alert with TextField to edit
- Tap My time off → push TimeOffManagementView
- Tap Support → opens Mail compose with pre-filled email

---

### 5.2 Time Off Management View

**Purpose:** Add/edit/delete time off periods

**Layout:**
```
┌─────────────────────────────┐
│  [< Settings]  My Time Off  │
│                       [+]   │
│                             │
│  Upcoming                   │
│  ┌───────────────────────┐  │
│  │ Summer Break          │  │
│  │ Jul 15 - Jul 31       │  │
│  │ 16 days               │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ Holiday Break         │  │
│  │ Dec 23 - Dec 26       │  │
│  │ 3 days                │  │
│  └───────────────────────┘  │
│                             │
│  Past                       │
│  ┌───────────────────────┐  │
│  │ Winter Break          │  │
│  │ Jan 10 - Jan 20       │  │
│  └───────────────────────┘  │
│                             │
└─────────────────────────────┘
```

**Elements:**
- Navigation: back button, add button (+)
- Grouped lists: "Upcoming" and "Past"
- TimeOffRow components
- Swipe to delete

**TimeOffRow:**
- Title (custom name or default)
- Date range
- Days count
- Tap to edit

**Add/Edit Sheet:**
- Date pickers (start/end)
- Type picker (Vacation, Comp Time, Training)
- Save button

**Interactions:**
- Tap + → opens add sheet
- Tap row → opens edit sheet
- Swipe left → delete action

---

## 6. STATS VIEW (Placeholder)

### 6.1 Stats Placeholder

**Purpose:** Coming soon message for v0.2

**Layout:**
```
┌─────────────────────────────┐
│  Statistics                 │
│                             │
│                             │
│        📊                   │
│                             │
│   Coming Soon               │
│                             │
│   Your emotional statistics │
│   and trends will appear    │
│   here in the next version. │
│                             │
│                             │
└─────────────────────────────┘
```

**Elements:**
- Icon: chart.bar.fill
- Title: "Coming Soon"
- Description text
- No interaction

---

## NAVIGATION STRUCTURE

```
App Launch
├── If onboardingCompleted == false
│   └── OnboardingView
│       ├── WelcomeView
│       ├── NameInputView
│       └── TimeOffSetupView
│           └── → Sets onboardingCompleted = true
│
└── If onboardingCompleted == true
    └── TabView (ContentView)
        ├── HomeView (Tab 1)
        │   ├── Present CheckInView (sheet)
        │   ├── Present CheckOutView (sheet)
        │   └── Present NewJournalView (sheet)
        │
        ├── JournalListView (Tab 2)
        │   ├── Present NewJournalView (sheet)
        │   └── Push JournalDetailView
        │       └── Present JournalEditView (sheet)
        │
        ├── StatsPlaceholderView (Tab 3)
        │
        └── SettingsView (Tab 4)
            └── Push TimeOffManagementView
                └── Present TimeOffEditView (sheet)
```

---

## SHEET PRESENTATIONS

All sheets use `.medium` presentation detent with drag indicator

**Sheets:**
1. CheckInView
2. CheckOutView
3. NewJournalView
4. JournalEditView
5. TimeOffEditView

**Alerts:**
1. Name edit (Settings)
2. Delete confirmation (Journal)
3. Cancel confirmation (New Journal with content)

---

## ANIMATIONS

### Mood Slider Selection
```swift
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedValue)
```

### Card Appearance
```swift
.transition(.scale.combined(with: .opacity))
```

### Countdown Number Change
```swift
.contentTransition(.numericText(countsDown: true))
.animation(.easeInOut, value: daysCount)
```

---

## ACCESSIBILITY

### VoiceOver Labels
- All interactive elements have accessibility labels
- Mood sliders announce value changes
- Buttons announce their actions

### Dynamic Type
- All text scales with system font size
- Minimum touch targets: 44x44pt

### Color Contrast
- All text meets WCAG AA standards
- Interactive elements have sufficient contrast

---

## DARK MODE

All screens support system dark mode with:
- Adaptive colors using `.primary`, `.secondary`
- Custom colors with dark variants
- Proper contrast in both modes

---

## LOCALIZATION NOTES

All text strings shown in these mockups should be implemented using `NSLocalizedString` or SwiftUI `Text(LocalizedStringKey:)` for automatic French translation.

See `LOCALIZATION.md` for complete translation keys and implementation details.

---

**Last Updated:** January 29, 2026
**Language:** English (Primary), French (Full Localization)
