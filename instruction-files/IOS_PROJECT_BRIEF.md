# ShiftMood - iOS Native App
## Nurse Emotional Wellness Journal

---

## Vision

ShiftMood is a native iOS journaling app specifically designed for nurses and healthcare workers to track their emotional wellbeing before and after shifts, maintain a reflective practice, and monitor their mental health over time.

**Target User:** International nurses and healthcare workers (RN, LPN, CNA, EN) who work rotating shifts and need emotional support tools.

**Primary Markets:** United States, United Kingdom, Canada, Australia
**Secondary Markets:** France, Belgium, Switzerland, Germany

**Core Problem Solved:** Nurses experience high emotional labor and burnout. Current journaling apps are generic and don't understand the shift-work context, countdown to time off, or nursing-specific stressors.

**Languages:** English (primary), French (full localization included)

---

## MVP Scope (v0.1 - TestFlight)

### ✅ INCLUDED Features

1. **Emotional Check-in/Check-out**
   - Pre-shift mood tracking (3 sliders: energy, stress, motivation)
   - Post-shift mood tracking (3 sliders: fatigue, emotional load, satisfaction)
   - Quick emoji badges for common feelings

2. **Shift Journal**
   - Text-based journal entries
   - Title + content + tags
   - Optional: "Highlights" section (3 bullet points)
   - Link to specific shift

3. **Daily Affirmations**
   - 50 pre-written nursing-specific affirmations
   - Daily rotation based on date
   - Categories: resilience, competence, compassion, balance
   - Can mark as "liked" for future reference

4. **Vacation Countdown**
   - Add upcoming vacation dates
   - Widget-style countdown on home screen
   - "X shifts until vacation" calculation

5. **Basic Settings**
   - User first name
   - Manage time off dates
   - About/version info

### ❌ NOT in v0.1

- Planning/schedule import (v0.2)
- Statistics/charts (v0.2)
- Voice recording (v0.3)
- Cloud sync (v0.2 with CloudKit)
- In-app purchases (v0.2)
- Multiple users/accounts (local only)
- Export data (v0.2)

---

## Technical Requirements

### Platform
- **iOS 17.0+** minimum (to use latest SwiftData APIs)
- **iPhone only** (iPad support in v0.3)
- **Portrait orientation** only

### Data Storage
- **SwiftData** for local persistence
- All data stored on-device
- No backend/server required for v0.1
- Future: CloudKit sync optional in v0.2

### Architecture
- **SwiftUI** for all interfaces
- **Swift 5.9+**
- **MVVM pattern** with ViewModels
- **Swift Concurrency** (async/await)
- **No third-party dependencies** in v0.1

### Performance Targets
- App launch: <1 second
- Screen transitions: smooth 60fps
- Database queries: <50ms
- Zero network calls (100% offline)

---

## User Flows

### First Launch (Onboarding)
```
1. Welcome screen
   "Welcome to ShiftMood 👋"
   Explanation: "Track your emotional wellbeing shift after shift"

2. Name input
   "What's your first name?"
   TextField for first name

3. First time off setup (optional)
   "Do you have time off coming up?"
   Date picker: start + end date
   Skip button available

4. → Home screen
```

### Daily Usage Flow (Shift Day)
```
Morning (before shift):
1. Open app
2. See daily affirmation on home
3. Tap "Check in before my shift"
4. Rate 3 sliders: energy, stress, motivation
5. Tap "Let's go!"
6. → Back to home

Evening (after shift):
1. Notification: "How was your shift?"
2. Open app
3. Tap "Check out after my shift"
4. Rate 3 sliders: fatigue, emotional load, satisfaction
5. Quick emoji badge selection
6. Option: "Write in my journal?"
7. If yes → Journal entry screen
8. Save
```

### Journal Entry Flow
```
1. Tap "Nouveau journal" from anywhere
2. Auto-suggested title based on recent mood
3. Select mood emoji
4. Add tags (suggestions + custom)
5. Write in text editor
6. Optional: Add 3 highlights
7. Tap "Enregistrer"
8. → Back to journal list
```

### Time Off Countdown Flow
```
1. Home screen shows: "Only 12 days until your time off! 🎉"
2. Tap countdown card
3. → Settings > Time Off
4. List of upcoming time off periods
5. Add new: date picker start/end
6. Delete: swipe to delete
7. Calculation: working days between now and time off start
```

---

## Screen Structure

### Navigation
- **TabView** with 4 tabs:
  1. 🏠 Home (main dashboard)
  2. 📖 Journal (list of entries)
  3. 📊 Stats (placeholder for v0.2)
  4. ⚙️ Settings

### Screen Hierarchy
```
App
├── OnboardingView (first launch only)
│   ├── WelcomeView
│   ├── NameInputView
│   └── VacationSetupView
│
├── TabView
│   ├── HomeView
│   │   ├── AffirmationCard
│   │   ├── VacationCountdownCard
│   │   ├── NextShiftCard (future)
│   │   └── QuickActions
│   │       ├── CheckInButton
│   │       └── NewJournalButton
│   │
│   ├── JournalListView
│   │   ├── JournalEntryRow (list item)
│   │   └── → JournalDetailView
│   │       └── JournalEditView (sheet)
│   │
│   ├── StatsView (placeholder)
│   │   └── "Coming soon" message
│   │
│   └── SettingsView
│       ├── Profile section (name)
│       ├── Vacations section
│       │   └── VacationManagementView
│       └── About section
│
├── CheckInView (sheet)
│   ├── 3 sliders
│   └── Save button
│
├── CheckOutView (sheet)
│   ├── 3 sliders
│   ├── Emoji badges
│   └── Save + option to journal
│
└── NewJournalView (sheet)
    ├── Title field
    ├── Mood selector
    ├── Tag selector
    ├── Text editor
    ├── Highlights section
    └── Save button
```

---

## Data Models

### Core Entities (SwiftData)

1. **UserProfile**
   - firstName: String
   - createdAt: Date
   - onboardingCompleted: Bool

2. **Shift**
   - id: UUID
   - date: Date
   - type: ShiftType (enum: jour, nuit, repos)
   - preMood: Mood? (embedded)
   - postMood: Mood? (embedded)
   - duration: TimeInterval?

3. **Mood**
   - timestamp: Date
   - energy: Int (1-5)
   - stress: Int (1-5)
   - motivation: Int (1-5)
   - emotionalLoad: Int? (post-shift only)
   - fatigue: Int? (post-shift only)
   - satisfaction: Int? (post-shift only)
   - badges: [String] (emoji codes)

4. **JournalEntry**
   - id: UUID
   - shiftId: UUID?
   - title: String
   - content: String
   - moodEmoji: String
   - tags: [String]
   - highlights: [String] (max 3)
   - createdAt: Date
   - modifiedAt: Date

5. **Vacation**
   - id: UUID
   - startDate: Date
   - endDate: Date
   - type: VacationType (congés, RTT, formation)
   - status: VacationStatus (planifié, validé)

6. **DailyAffirmation**
   - id: UUID
   - text: String
   - category: AffirmationCategory
   - shownDate: Date
   - liked: Bool

---

## Design System

### Color Palette

```swift
Primary: #F59E0B (warm orange/yellow)
Secondary: #8B5CF6 (purple for night shifts)
Success: #10B981 (green for rest/vacation)
Danger: #EF4444 (red for urgent/stress)
Neutral Light: #F3F4F6
Neutral Dark: #1F2937

Mood Colors:
Happy: #FBBF24
Sad: #6B7280
Calm: #10B981
Anxious: #F59E0B
Proud: #8B5CF6
Tired: #94A3B8
```

### Typography
- **System font** (San Francisco)
- Title: .largeTitle, bold
- Headers: .title2, semibold
- Body: .body, regular
- Caption: .caption, regular

### Spacing
- Extra small: 4pt
- Small: 8pt
- Medium: 16pt
- Large: 24pt
- Extra large: 32pt

### Corner Radius
- Small: 8pt (buttons, tags)
- Medium: 12pt (cards)
- Large: 20pt (modals)

### Shadows
```swift
Light: .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
Medium: .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
```

---

## Key Components (Reusable)

### MoodSlider
```
- Custom slider with emoji markers
- Range: 1-5
- Labels: descriptive text for each value
- Haptic feedback on value change
- Color changes based on value
```

### AffirmationCard
```
- Card with daily affirmation text
- Category badge (top right)
- Heart icon to "like"
- Subtle gradient background
- Shadow for depth
```

### VacationCountdownCard
```
- Large number display (days/shifts remaining)
- Progress bar
- Vacation dates below
- Tap to manage vacations
- Animated number changes
```

### JournalEntryRow
```
- Title + preview (2 lines)
- Mood emoji badge
- Date/time
- Tags (first 2 visible)
- Swipe actions: delete
```

### EmojiMoodSelector
```
- Horizontal scrollable row
- 6 emoji options
- Single or multi-select
- Haptic feedback on selection
```

### TagChipView
```
- Rounded pill shape
- Dismissible (X button)
- Suggested tags vs custom
- Color-coded by category
```

---

## Affirmations (50 Nursing-Specific)

**Resilience (10)**
1. "Je fais une différence, même dans les petits gestes"
2. "Mes limites protègent ma capacité à soigner"
3. "Chaque shift difficile me rend plus forte"
4. "Je mérite de me reposer autant que mes patients"
5. "Ma fatigue est légitime, pas une faiblesse"
6. "Je ne peux pas tout contrôler, et c'est ok"
7. "Demander de l'aide est un signe de sagesse"
8. "Je suis humaine, je ne suis pas une machine"
9. "Mes émotions sont valides, même au travail"
10. "Je choisis de me préserver pour durer"

**Competence (10)**
1. "Mon expérience est précieuse"
2. "Je sais ce que je fais, j'ai été formée pour ça"
3. "Chaque geste technique que je pose compte"
4. "J'apprends de chaque situation"
5. "Ma vigilance sauve des vies"
6. "Je suis capable de gérer l'imprévu"
7. "Mes connaissances se renforcent chaque jour"
8. "Je fais confiance à mon jugement clinique"
9. "Mon professionnalisme fait la différence"
10. "Je suis fière de mon métier"

**Compassion (15)**
1. "Mon empathie est ma force, pas ma faiblesse"
2. "Écouter un patient est un soin en soi"
3. "Un sourire peut changer une journée"
4. "Je vois la personne derrière la pathologie"
5. "Ma présence apaise"
6. "Chaque patient mérite ma bienveillance"
7. "Je suis le lien humain dans un système technique"
8. "Mon humanité est mon meilleur outil"
9. "Prendre soin commence par un regard"
10. "Je crée de la sécurité par ma présence"
11. "Mon attention est un cadeau que j'offre"
12. "Je suis là, et ça compte"
13. "Ma compassion ne s'épuise pas, elle se nourrit"
14. "Chaque geste doux est un acte de résistance"
15. "Je soigne avec mes mains et mon cœur"

**Balance (15)**
1. "Mes jours de repos sont sacrés"
2. "Je ne suis pas que mon métier"
3. "Prendre soin de moi me permet de soigner les autres"
4. "Dire non protège mon énergie"
5. "Mon bien-être personnel n'est pas égoïste"
6. "Je mérite une vie en dehors de l'hôpital"
7. "Mes loisirs me ressourcent pour mieux soigner"
8. "L'équilibre vie pro/perso est un droit, pas un luxe"
9. "Je ne ramène pas le travail à la maison (dans ma tête)"
10. "Mes proches ont besoin de moi entière, pas épuisée"
11. "Déconnecter est nécessaire pour reconnecter"
12. "Mon identité dépasse ma blouse"
13. "Je cultive ma vie personnelle avec autant de soin"
14. "Mes vacances sont vitales, pas optionnelles"
15. "Je choisis de vivre, pas seulement de survivre"

---

## Success Metrics (Post-Launch)

### Usage
- Daily active users (target: 60% of downloads)
- Entries per week per user (target: 3+)
- Affirmation view rate (target: 80%)

### Retention
- Day 7 retention: 50%
- Day 30 retention: 30%
- Average session length: 3-5 minutes

### Feedback
- App Store rating: 4.5+ stars
- Qualitative feedback from TestFlight nurses
- Feature requests prioritization

---

## Future Roadmap (Post-v0.1)

### v0.2 (2-3 weeks after TestFlight)
- CloudKit sync
- Stats/charts (mood trends)
- Planning import (PDF/manual)
- In-app purchase ($1.99/month or $4.99 one-time)
- Export journal to PDF

### v0.3 (2 months)
- Voice recording for journal entries
- Widgets (countdown, affirmation)
- iPad support
- Dark mode refinements

### v0.4 (3-4 months)
- Pattern analysis (burnout detection)
- Notifications (check-in reminders)
- Team shifts (group feature for hospital units)
- Integration with Health app (sleep, steps)

---

## App Store Listing (Draft)

**Name:** ShiftMood - Nurse Journal

**Subtitle:** Emotional wellness for nurses

**Description:**
ShiftMood is the emotional wellness app designed specifically for nurses and healthcare workers.

Track your mood before and after each shift, write in your personal journal, and count down the days until your well-deserved time off.

Features:
• Emotional check-in before/after each shift
• Personal and private journal entries
• Daily positive affirmations
• Countdown to your time off
• 100% private (data stored on your device)
• Works offline

ShiftMood helps you take care of yourself so you can take care of others.

**Keywords:**
nurse, nursing, journal, wellness, mental health, shift work, RN, LPN, CNA, healthcare, burnout, self-care

**Category:** Health & Fitness (Primary), Lifestyle (Secondary)

**Age Rating:** 4+ (no objectionable content)

---

## Localization

**Supported Languages (v0.1):**
- English (US) - Primary
- French (France) - Full localization

**Future Languages (v0.2+):**
- Spanish
- German
- Portuguese
- Italian

---

## TestFlight Distribution Plan

### Phase 1 (Week 1)
- 10 beta testers (personal contacts)
- Focus: critical bugs, usability issues
- Daily feedback collection

### Phase 2 (Week 2-3)
- 30 beta testers (Facebook groups)
- Focus: feature validation, missing features
- Weekly feedback surveys

### Phase 3 (Week 4)
- App Store submission
- Public launch

---

## Development Timeline

**Day 1 (6h):**
- Xcode project setup
- SwiftData models + schema
- Navigation structure (TabView)
- Home screen layout (no functionality)

**Day 2 (8h):**
- Check-in/out flows (sliders + save)
- Journal CRUD (create, list, detail)
- Affirmations rotation logic
- Vacation countdown calculation

**Day 3 (4h):**
- UI polish (colors, spacing, fonts)
- App icon + launch screen
- TestFlight build configuration
- Upload to App Store Connect

**Total: 18 hours over 3 days**

---

## Questions for Developer

1. **User Name:** Hardcoded or onboarding input? → Onboarding input
2. **Affirmations:** Fetch from API or hardcoded? → Hardcoded 50 strings
3. **Shift tracking:** Manual or automatic? → Manual (future: auto via patterns)
4. **Tags:** Predefined list or fully custom? → Both (suggestions + custom)
5. **Vacation calculation:** By calendar days or work shifts? → Work shifts (exclude weekends)

---

## Contact

**Developer:** Steve Rover
**Target Users:** International nurses and healthcare workers
**Languages:** English (primary), French (full localization)
**Support:** [steve@steverover.com](mailto:steve@steverover.com)

---

**Last Updated:** January 29, 2026
**Version:** 0.1 (TestFlight)
