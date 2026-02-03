# ShiftMood - Design System

---

## Color Palette

### Primary Colors

```swift
// Primary (Warm Orange/Yellow)
Color(hex: "F59E0B") // Main brand color
Color(hex: "FBBF24") // Lighter variant
Color(hex: "D97706") // Darker variant

// Secondary (Purple for night shifts)
Color(hex: "8B5CF6") // Main purple
Color(hex: "A78BFA") // Lighter purple
Color(hex: "7C3AED") // Darker purple

// Success (Green for rest/vacation)
Color(hex: "10B981") // Main green
Color(hex: "34D399") // Lighter green
Color(hex: "059669") // Darker green

// Danger (Red for stress/urgent)
Color(hex: "EF4444") // Main red
Color(hex: "F87171") // Lighter red
Color(hex: "DC2626") // Darker red
```

### Neutral Colors

```swift
// Light Mode
Color(hex: "F3F4F6") // Background light
Color(hex: "E5E7EB") // Border light
Color(hex: "9CA3AF") // Text secondary
Color(hex: "6B7280") // Text tertiary
Color(hex: "374151") // Text secondary dark
Color(hex: "1F2937") // Text primary

// Dark Mode (system adaptive)
.primary // Adaptive primary text
.secondary // Adaptive secondary text
Color(.systemGray6) // Adaptive background
Color(.systemGray5) // Adaptive card background
```

### Mood Colors

```swift
// Emotions
let happyColor = Color(hex: "FBBF24") // Yellow
let sadColor = Color(hex: "6B7280") // Gray
let calmColor = Color(hex: "10B981") // Green
let anxiousColor = Color(hex: "F59E0B") // Orange
let proudColor = Color(hex: "8B5CF6") // Purple
let tiredColor = Color(hex: "94A3B8") // Slate
let frustratedColor = Color(hex: "EF4444") // Red
let gratefulColor = Color(hex: "F472B6") // Pink
```

### Usage Guidelines

**Primary Color (#F59E0B):**
- Main CTAs (buttons, links)
- Active states
- Key interactive elements
- Affirmation cards accent

**Secondary Color (#8B5CF6):**
- Night shift indicators
- Competence category
- Alternative CTAs

**Success Color (#10B981):**
- Vacation/rest indicators
- Positive feedback
- Confirmation states
- Calm mood badge

**Danger Color (#EF4444):**
- Destructive actions (delete)
- High stress indicators
- Error states

---

## Typography

### Font System

Using **SF Pro** (System Font) for iOS

### Type Scale

```swift
// Headers
.largeTitle // 34pt, bold
.title // 28pt, bold
.title2 // 22pt, bold
.title3 // 20pt, semibold
.headline // 17pt, semibold

// Body
.body // 17pt, regular
.callout // 16pt, regular
.subheadline // 15pt, regular
.footnote // 13pt, regular
.caption // 12pt, regular
.caption2 // 11pt, regular
```

### Font Weights

```swift
.ultraLight // 100
.thin // 200
.light // 300
.regular // 400 (default)
.medium // 500
.semibold // 600
.bold // 700
.heavy // 800
.black // 900
```

### Usage Examples

```swift
// Screen titles
Text("ShiftMood")
    .font(.largeTitle)
    .fontWeight(.bold)

// Section headers
Text("Affirmation du jour")
    .font(.title3)
    .fontWeight(.semibold)

// Body text
Text("Je fais une différence...")
    .font(.body)
    .fontWeight(.medium)

// Metadata
Text("Il y a 2 heures")
    .font(.caption)
    .foregroundStyle(.secondary)
```

---

## Spacing System

### Scale (8pt base)

```swift
enum Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 48
}
```

### Usage Guidelines

**Component internal spacing:**
- Padding inside buttons: 12pt vertical, 20pt horizontal
- Card padding: 16pt all sides
- List item padding: 12pt vertical, 16pt horizontal

**Layout spacing:**
- Between sections: 24pt
- Between related elements: 12pt
- Between unrelated elements: 32pt
- Screen edge margins: 16pt

**Vertical rhythm:**
- Title to subtitle: 8pt
- Subtitle to content: 16pt
- Between cards: 12pt

---

## Corner Radius

```swift
enum CornerRadius {
    static let xs: CGFloat = 4 // Tiny elements
    static let sm: CGFloat = 8 // Tags, badges
    static let md: CGFloat = 12 // Cards, inputs
    static let lg: CGFloat = 16 // Modals, sheets
    static let xl: CGFloat = 20 // Large containers
    static let full: CGFloat = 999 // Circular/pill
}
```

### Usage

```swift
// Cards
RoundedRectangle(cornerRadius: 12)

// Buttons
Capsule() // or RoundedRectangle(cornerRadius: 999)

// Tags
Capsule()

// Sheets/Modals
RoundedRectangle(cornerRadius: 20)
```

---

## Shadows

### Shadow System

```swift
enum Shadow {
    // Light shadow (cards, buttons)
    static func light() -> some View {
        Color.black.opacity(0.05)
            .blur(radius: 4)
            .offset(y: 2)
    }
    
    // Medium shadow (elevated cards)
    static func medium() -> some View {
        Color.black.opacity(0.1)
            .blur(radius: 8)
            .offset(y: 4)
    }
    
    // Heavy shadow (modals)
    static func heavy() -> some View {
        Color.black.opacity(0.15)
            .blur(radius: 16)
            .offset(y: 8)
    }
}
```

### SwiftUI Implementation

```swift
// Method 1: Using .shadow modifier
.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

// Method 2: Custom shadow view
struct CardShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardShadow() -> some View {
        modifier(CardShadow())
    }
}
```

---

## Icons

### System Icons (SF Symbols)

**Navigation:**
- house.fill (Home)
- book.fill (Journal)
- chart.bar.fill (Stats)
- gearshape.fill (Settings)

**Actions:**
- plus (Add new)
- pencil (Edit)
- trash (Delete)
- xmark (Close)
- checkmark (Confirm)

**Mood/Emotion:**
- bolt.fill (Energy)
- brain.head.profile (Stress)
- target (Motivation)
- bed.double.fill (Fatigue)
- heart.fill (Emotional load)
- face.smiling (Satisfaction)

**Shift Types:**
- sun.max.fill (Day shift)
- moon.stars.fill (Night shift)
- bed.double.fill (Rest)

**Categories:**
- shield.fill (Resilience)
- star.fill (Competence)
- heart.fill (Compassion)
- scale.3d (Balance)

**Vacation:**
- calendar (Dates)
- airplane (Travel)
- beach.umbrella (Vacation)

### Icon Sizes

```swift
// Sizes
.font(.caption) // 12pt
.font(.footnote) // 13pt
.font(.body) // 17pt
.font(.title3) // 20pt
.font(.title2) // 22pt
.font(.title) // 28pt
.font(.largeTitle) // 34pt

// Custom sizes
Image(systemName: "heart.fill")
    .font(.system(size: 24))
```

---

## Buttons

### Primary Button

```swift
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "F59E0B"),
                            Color(hex: "FBBF24")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: Color(hex: "F59E0B").opacity(0.3), radius: 8, y: 4)
        }
    }
}
```

### Secondary Button

```swift
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(Color(hex: "F59E0B"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "F59E0B").opacity(0.1))
                .clipShape(Capsule())
        }
    }
}
```

### Destructive Button

```swift
struct DestructiveButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(role: .destructive, action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "EF4444"))
                .clipShape(Capsule())
        }
    }
}
```

---

## Cards

### Standard Card

```swift
struct StandardCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}
```

### Highlighted Card (Affirmation)

```swift
struct HighlightedCard<Content: View>: View {
    let content: Content
    let color: Color
    
    init(color: Color = Color(hex: "F59E0B"), @ViewBuilder content: () -> Content) {
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [color, color.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: color.opacity(0.3), radius: 12, y: 6)
    }
}
```

---

## Input Fields

### Text Field

```swift
struct StyledTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}
```

### Text Editor

```swift
struct StyledTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            
            TextEditor(text: $text)
                .padding(8)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
```

---

## List Styles

### Custom List Row

```swift
struct CustomListRow<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        HStack {
            content
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }
}
```

---

## Animations

### Spring Animation

```swift
// Default spring
.animation(.spring(), value: someValue)

// Custom spring
.animation(
    .spring(response: 0.3, dampingFraction: 0.7),
    value: someValue
)
```

### Timing Curves

```swift
// Ease in-out (default)
.animation(.easeInOut, value: someValue)

// Ease in
.animation(.easeIn(duration: 0.2), value: someValue)

// Ease out
.animation(.easeOut(duration: 0.2), value: someValue)

// Linear
.animation(.linear(duration: 0.3), value: someValue)
```

### Transition Effects

```swift
// Opacity
.transition(.opacity)

// Scale
.transition(.scale)

// Slide
.transition(.slide)

// Combined
.transition(.scale.combined(with: .opacity))

// Asymmetric
.transition(
    .asymmetric(
        insertion: .scale.combined(with: .opacity),
        removal: .opacity
    )
)
```

---

## Haptic Feedback

```swift
// HapticManager.swift already defined in architecture
// Usage examples:

// Light impact (selections, toggles)
HapticManager.shared.impact(style: .light)

// Medium impact (button presses)
HapticManager.shared.impact(style: .medium)

// Heavy impact (important actions)
HapticManager.shared.impact(style: .heavy)

// Success notification
HapticManager.shared.notification(type: .success)

// Warning notification
HapticManager.shared.notification(type: .warning)

// Error notification
HapticManager.shared.notification(type: .error)

// Selection (scrolling through options)
HapticManager.shared.selection()
```

---

## Dark Mode Support

### Adaptive Colors

```swift
// Use system adaptive colors
Color.primary // Adaptive text
Color.secondary // Adaptive secondary text
Color(.systemBackground) // Adaptive background
Color(.systemGray6) // Adaptive surface

// Custom adaptive colors
Color("CustomColor") // Define in Assets with light/dark variants
```

### Dark Mode Testing

```swift
// Preview in both modes
#Preview {
    HomeView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    HomeView()
        .preferredColorScheme(.dark)
}
```

---

## Accessibility

### Dynamic Type

All text automatically scales with system settings when using:
```swift
.font(.body) // Scales with Dynamic Type
```

### VoiceOver Labels

```swift
Image(systemName: "plus")
    .accessibilityLabel("Ajouter une nouvelle entrée")

Button(action: {}) {
    Image(systemName: "heart.fill")
}
.accessibilityLabel("Aimer cette affirmation")
.accessibilityHint("Double-tapez pour marquer comme aimée")
```

### Minimum Touch Targets

Ensure all interactive elements are at least **44x44 points**:
```swift
Button(action: {}) {
    Text("Tap")
}
.frame(minWidth: 44, minHeight: 44)
```

---

## App Icon Guidelines

### Sizes Required

- 1024x1024 (App Store)
- 180x180 (iPhone @3x)
- 120x120 (iPhone @2x)
- 167x167 (iPad Pro @2x)
- 152x152 (iPad @2x)

### Design Elements

**Icon Concept:**
- Heart icon (compassion) + journal book
- Primary color: #F59E0B
- Clean, minimal design
- No text in icon
- Single focal point

**Style:**
- Flat design with subtle gradients
- Rounded corners (iOS automatically applies)
- High contrast for visibility
- Works at small sizes

---

## Launch Screen

### Design

```
┌─────────────────────────┐
│                         │
│                         │
│                         │
│       [App Icon]        │
│                         │
│      ShiftMood          │
│                         │
│                         │
│                         │
└─────────────────────────┘
```

**Elements:**
- App icon (120x120pt)
- App name below (title font)
- White/adaptive background
- Fade-in animation (0.3s)

---

## Component Library Summary

### Reusable Components

1. **MoodSlider** - 5-level mood selector
2. **EmojiMoodSelector** - Multi-select emoji grid
3. **TagChipView** - Tag badges
4. **AffirmationCard** - Daily affirmation display
5. **VacationCountdownCard** - Countdown widget
6. **JournalEntryRow** - List item for entries
7. **PrimaryButton** - Main CTA button
8. **SecondaryButton** - Secondary actions
9. **StandardCard** - Generic card container
10. **EmptyStateView** - Empty state messages

---

## Design Principles

### 1. Simplicity
- Minimal UI, maximum clarity
- One primary action per screen
- Progressive disclosure

### 2. Warmth
- Use warm colors (orange, yellow)
- Friendly tone in copy
- Rounded corners throughout

### 3. Professionalism
- Clean typography
- Consistent spacing
- Subtle animations

### 4. Empathy
- Validating language
- Non-judgmental mood tracking
- Focus on self-care

### 5. Accessibility
- High contrast
- Large touch targets
- VoiceOver support
- Dynamic Type support

---

## Resources

### Design Tools
- SF Symbols app (icons)
- Xcode Previews (live testing)
- Figma (optional design mocks)

### Inspiration
- Apple Human Interface Guidelines
- iOS Health app
- Calm app aesthetics
- Day One journal app

---

**Last Updated:** January 29, 2026
