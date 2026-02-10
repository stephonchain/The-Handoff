# ShiftMood - Localization Guide

---

## Overview

ShiftMood is designed with **English as the primary language** with full **French localization** included in v0.1.

The app automatically detects the user's device language and displays the appropriate strings.

---

## Implementation

### Xcode Setup

1. **Add Localizations:**
   - Project Settings > Info > Localizations
   - Add: English (Development Language)
   - Add: French

2. **Localizable.strings Files:**
   ```
   Resources/
   ├── en.lproj/
   │   └── Localizable.strings
   └── fr.lproj/
       └── Localizable.strings
   ```

3. **Usage in SwiftUI:**
   ```swift
   Text("welcome_title") // Automatically localized
   Text(LocalizedStringKey("affirmation_text"))
   ```

---

## English Strings (en.lproj/Localizable.strings)

### Onboarding

```
// Welcome Screen
"welcome_title" = "Welcome to ShiftMood";
"welcome_subtitle" = "Track your emotional wellbeing shift after shift";
"welcome_feature_1" = "Track your mood before and after each shift";
"welcome_feature_2" = "Write in your personal journal";
"welcome_feature_3" = "Count down to your time off";
"welcome_button" = "Get Started";

// Name Input
"name_input_title" = "What's your first name?";
"name_input_placeholder" = "First name";
"name_input_caption" = "We'll use your first name to personalize your experience.";
"name_input_button" = "Continue";

// Time Off Setup
"timeoff_setup_title" = "Do you have time off coming up?";
"timeoff_setup_subtitle" = "Set up your first countdown to stay motivated!";
"timeoff_setup_start" = "Start date";
"timeoff_setup_end" = "End date";
"timeoff_setup_button" = "Add my time off";
"timeoff_setup_skip" = "Skip";
```

### Home Screen

```
"home_greeting" = "Hello, %@";
"home_affirmation_title" = "Daily Affirmation";
"home_timeoff_countdown" = "Only %d days until your time off!";
"home_timeoff_countdown_plural" = "Only %d days until your time off!";
"home_timeoff_countdown_singular" = "Only 1 day until your time off!";
"home_quick_actions" = "Quick Actions";
"home_checkin_button" = "Check in";
"home_journal_button" = "New journal";
```

### Check-In/Out

```
// Check-In
"checkin_title" = "How are you feeling before your shift?";
"checkin_energy" = "Energy level";
"checkin_stress" = "Anticipated stress";
"checkin_motivation" = "Motivation";
"checkin_button" = "Let's go! 🚀";

// Energy labels
"energy_1" = "Exhausted";
"energy_2" = "Low";
"energy_3" = "Moderate";
"energy_4" = "Good";
"energy_5" = "Excellent";

// Stress labels
"stress_1" = "Very low";
"stress_2" = "Low";
"stress_3" = "Moderate";
"stress_4" = "High";
"stress_5" = "Very high";

// Motivation labels
"motivation_1" = "None";
"motivation_2" = "Low";
"motivation_3" = "Moderate";
"motivation_4" = "High";
"motivation_5" = "Very high";

// Check-Out
"checkout_title" = "How was your shift?";
"checkout_fatigue" = "Fatigue";
"checkout_emotional_load" = "Emotional load";
"checkout_satisfaction" = "Satisfaction";
"checkout_badges_title" = "How are you feeling?";
"checkout_button_save" = "Done";
"checkout_button_journal" = "Write in my journal";

// Fatigue labels
"fatigue_1" = "Fresh";
"fatigue_2" = "A bit tired";
"fatigue_3" = "Tired";
"fatigue_4" = "Very tired";
"fatigue_5" = "Exhausted";

// Emotional load labels
"emotional_load_1" = "Very light";
"emotional_load_2" = "Light";
"emotional_load_3" = "Moderate";
"emotional_load_4" = "Heavy";
"emotional_load_5" = "Very heavy";

// Satisfaction labels
"satisfaction_1" = "Poor";
"satisfaction_2" = "Below average";
"satisfaction_3" = "Average";
"satisfaction_4" = "Good";
"satisfaction_5" = "Excellent";
```

### Mood Badges

```
"badge_happy" = "Happy";
"badge_sad" = "Sad";
"badge_calm" = "Calm";
"badge_anxious" = "Anxious";
"badge_proud" = "Proud";
"badge_tired" = "Tired";
"badge_frustrated" = "Frustrated";
"badge_grateful" = "Grateful";
```

### Journal

```
"journal_title" = "Journal";
"journal_new_title" = "New Entry";
"journal_edit_title" = "Edit Entry";
"journal_search_placeholder" = "Search entries...";
"journal_empty_title" = "No entries yet";
"journal_empty_subtitle" = "Start writing your journal";
"journal_empty_button" = "Create my first entry";

"journal_field_title" = "Title";
"journal_field_title_placeholder" = "Entry title";
"journal_field_mood" = "Mood";
"journal_field_tags" = "Tags";
"journal_field_content_placeholder" = "Write here...";
"journal_field_highlights" = "Highlights (optional)";
"journal_highlight_placeholder" = "Something I'm proud of";

"journal_button_cancel" = "Cancel";
"journal_button_save" = "Save";
"journal_button_delete" = "Delete";

"journal_delete_alert_title" = "Delete entry?";
"journal_delete_alert_message" = "This action cannot be undone.";
"journal_delete_alert_confirm" = "Delete";
"journal_delete_alert_cancel" = "Cancel";
```

### Suggested Tags

```
"tag_difficult_shift" = "Difficult shift";
"tag_great_encounter" = "Great encounter";
"tag_learning" = "Learning";
"tag_great_team" = "Great team";
"tag_fatigue" = "Fatigue";
"tag_pride" = "Pride";
"tag_questioning" = "Questioning";
"tag_emergency" = "Emergency";
"tag_death" = "Death";
"tag_recovery" = "Recovery";
"tag_family" = "Family";
```

### Settings

```
"settings_title" = "Settings";
"settings_profile" = "Profile";
"settings_profile_name" = "First name";
"settings_timeoff" = "Time Off";
"settings_timeoff_subtitle" = "%d periods planned";
"settings_about" = "About";
"settings_version" = "Version";
"settings_support" = "Support";
```

### Time Off Management

```
"timeoff_title" = "My Time Off";
"timeoff_upcoming" = "Upcoming";
"timeoff_past" = "Past";
"timeoff_add_title" = "Add Time Off";
"timeoff_edit_title" = "Edit Time Off";
"timeoff_type" = "Type";
"timeoff_type_vacation" = "Vacation";
"timeoff_type_rtt" = "Comp Time";
"timeoff_type_training" = "Training";
"timeoff_custom_name" = "Custom name (optional)";
"timeoff_days_count" = "%d days";
"timeoff_button_save" = "Save";
```

### Stats (Placeholder)

```
"stats_title" = "Statistics";
"stats_coming_soon_title" = "Coming Soon";
"stats_coming_soon_subtitle" = "Your emotional statistics and trends will appear here in the next version.";
```

### Affirmation Categories

```
"category_resilience" = "Resilience";
"category_competence" = "Competence";
"category_compassion" = "Compassion";
"category_balance" = "Balance";
```

### General

```
"button_close" = "Close";
"button_done" = "Done";
"button_add" = "Add";
"button_edit" = "Edit";
"button_delete" = "Delete";
"button_cancel" = "Cancel";
"button_save" = "Save";
"button_continue" = "Continue";
"button_skip" = "Skip";

"common_today" = "Today";
"common_yesterday" = "Yesterday";
"common_days_ago" = "%d days ago";
"common_just_now" = "Just now";
```

---

## French Strings (fr.lproj/Localizable.strings)

### Onboarding

```
// Welcome Screen
"welcome_title" = "Bienvenue sur ShiftMood";
"welcome_subtitle" = "Suivez votre bien-être émotionnel shift après shift";
"welcome_feature_1" = "Suivez votre humeur avant et après chaque shift";
"welcome_feature_2" = "Écrivez dans votre journal personnel";
"welcome_feature_3" = "Comptez jusqu'à vos congés";
"welcome_button" = "Commencer";

// Name Input
"name_input_title" = "Comment vous appelez-vous ?";
"name_input_placeholder" = "Prénom";
"name_input_caption" = "Nous utiliserons votre prénom pour personnaliser votre expérience.";
"name_input_button" = "Continuer";

// Time Off Setup
"timeoff_setup_title" = "Avez-vous des congés prévus ?";
"timeoff_setup_subtitle" = "Configurez votre premier countdown pour rester motivé(e) !";
"timeoff_setup_start" = "Date de début";
"timeoff_setup_end" = "Date de fin";
"timeoff_setup_button" = "Ajouter mes congés";
"timeoff_setup_skip" = "Passer";
```

### Home Screen

```
"home_greeting" = "Bonjour, %@";
"home_affirmation_title" = "Affirmation du jour";
"home_timeoff_countdown" = "Plus que %d jours avant tes congés !";
"home_timeoff_countdown_plural" = "Plus que %d jours avant tes congés !";
"home_timeoff_countdown_singular" = "Plus qu'1 jour avant tes congés !";
"home_quick_actions" = "Actions rapides";
"home_checkin_button" = "Check-in";
"home_journal_button" = "Nouveau journal";
```

### Check-In/Out

```
// Check-In
"checkin_title" = "Comment te sens-tu avant ton shift ?";
"checkin_energy" = "Niveau d'énergie";
"checkin_stress" = "Stress anticipé";
"checkin_motivation" = "Motivation";
"checkin_button" = "C'est parti ! 🚀";

// Energy labels
"energy_1" = "Épuisé(e)";
"energy_2" = "Faible";
"energy_3" = "Moyen";
"energy_4" = "Bon";
"energy_5" = "Excellent";

// Stress labels
"stress_1" = "Très faible";
"stress_2" = "Faible";
"stress_3" = "Moyen";
"stress_4" = "Élevé";
"stress_5" = "Très élevé";

// Motivation labels
"motivation_1" = "Aucune";
"motivation_2" = "Faible";
"motivation_3" = "Moyenne";
"motivation_4" = "Forte";
"motivation_5" = "Très forte";

// Check-Out
"checkout_title" = "Comment s'est passé ton shift ?";
"checkout_fatigue" = "Fatigue";
"checkout_emotional_load" = "Charge émotionnelle";
"checkout_satisfaction" = "Satisfaction";
"checkout_badges_title" = "Comment te sens-tu ?";
"checkout_button_save" = "Terminer";
"checkout_button_journal" = "Écrire dans mon journal";

// Fatigue labels
"fatigue_1" = "En forme";
"fatigue_2" = "Un peu fatigué(e)";
"fatigue_3" = "Fatigué(e)";
"fatigue_4" = "Très fatigué(e)";
"fatigue_5" = "Épuisé(e)";

// Emotional load labels
"emotional_load_1" = "Très légère";
"emotional_load_2" = "Légère";
"emotional_load_3" = "Moyenne";
"emotional_load_4" = "Lourde";
"emotional_load_5" = "Très lourde";

// Satisfaction labels
"satisfaction_1" = "Mauvaise";
"satisfaction_2" = "Sous la moyenne";
"satisfaction_3" = "Moyenne";
"satisfaction_4" = "Bonne";
"satisfaction_5" = "Excellente";
```

### Mood Badges

```
"badge_happy" = "Content(e)";
"badge_sad" = "Triste";
"badge_calm" = "Calme";
"badge_anxious" = "Anxieux(se)";
"badge_proud" = "Fier(ère)";
"badge_tired" = "Fatigué(e)";
"badge_frustrated" = "Frustré(e)";
"badge_grateful" = "Reconnaissant(e)";
```

### Journal

```
"journal_title" = "Journal";
"journal_new_title" = "Nouvelle entrée";
"journal_edit_title" = "Modifier l'entrée";
"journal_search_placeholder" = "Rechercher...";
"journal_empty_title" = "Pas encore d'entrées";
"journal_empty_subtitle" = "Commencez à écrire votre journal";
"journal_empty_button" = "Créer ma première entrée";

"journal_field_title" = "Titre";
"journal_field_title_placeholder" = "Titre de votre entrée";
"journal_field_mood" = "Humeur";
"journal_field_tags" = "Tags";
"journal_field_content_placeholder" = "Écrivez ici...";
"journal_field_highlights" = "Highlights (optionnel)";
"journal_highlight_placeholder" = "Une chose dont je suis fier(e)";

"journal_button_cancel" = "Annuler";
"journal_button_save" = "Enregistrer";
"journal_button_delete" = "Supprimer";

"journal_delete_alert_title" = "Supprimer l'entrée ?";
"journal_delete_alert_message" = "Cette action est irréversible.";
"journal_delete_alert_confirm" = "Supprimer";
"journal_delete_alert_cancel" = "Annuler";
```

### Suggested Tags

```
"tag_difficult_shift" = "Shift difficile";
"tag_great_encounter" = "Belle rencontre";
"tag_learning" = "Apprentissage";
"tag_great_team" = "Équipe géniale";
"tag_fatigue" = "Fatigue";
"tag_pride" = "Fierté";
"tag_questioning" = "Questionnement";
"tag_emergency" = "Urgence";
"tag_death" = "Décès";
"tag_recovery" = "Rétablissement";
"tag_family" = "Famille";
```

### Settings

```
"settings_title" = "Réglages";
"settings_profile" = "Profil";
"settings_profile_name" = "Prénom";
"settings_timeoff" = "Congés";
"settings_timeoff_subtitle" = "%d périodes planifiées";
"settings_about" = "À propos";
"settings_version" = "Version";
"settings_support" = "Support";
```

### Time Off Management

```
"timeoff_title" = "Mes congés";
"timeoff_upcoming" = "À venir";
"timeoff_past" = "Passés";
"timeoff_add_title" = "Ajouter des congés";
"timeoff_edit_title" = "Modifier les congés";
"timeoff_type" = "Type";
"timeoff_type_vacation" = "Congés";
"timeoff_type_rtt" = "RTT";
"timeoff_type_training" = "Formation";
"timeoff_custom_name" = "Nom personnalisé (optionnel)";
"timeoff_days_count" = "%d jours";
"timeoff_button_save" = "Enregistrer";
```

### Stats (Placeholder)

```
"stats_title" = "Statistiques";
"stats_coming_soon_title" = "Bientôt disponible";
"stats_coming_soon_subtitle" = "Vos statistiques émotionnelles et tendances apparaîtront ici dans la prochaine version.";
```

### Affirmation Categories

```
"category_resilience" = "Résilience";
"category_competence" = "Compétence";
"category_compassion" = "Compassion";
"category_balance" = "Équilibre";
```

### General

```
"button_close" = "Fermer";
"button_done" = "Terminé";
"button_add" = "Ajouter";
"button_edit" = "Modifier";
"button_delete" = "Supprimer";
"button_cancel" = "Annuler";
"button_save" = "Enregistrer";
"button_continue" = "Continuer";
"button_skip" = "Passer";

"common_today" = "Aujourd'hui";
"common_yesterday" = "Hier";
"common_days_ago" = "Il y a %d jours";
"common_just_now" = "À l'instant";
```

---

## Affirmations Library

### English Affirmations (50)

**Resilience (10)**
1. "I make a difference, even in small gestures"
2. "My limits protect my ability to care"
3. "Each difficult shift makes me stronger"
4. "I deserve rest as much as my patients"
5. "My fatigue is legitimate, not a weakness"
6. "I can't control everything, and that's okay"
7. "Asking for help is a sign of wisdom"
8. "I'm human, not a machine"
9. "My emotions are valid, even at work"
10. "I choose to preserve myself to last"

**Competence (10)**
1. "My experience is valuable"
2. "I know what I'm doing, I was trained for this"
3. "Every technical gesture I perform matters"
4. "I learn from every situation"
5. "My vigilance saves lives"
6. "I'm capable of handling the unexpected"
7. "My knowledge strengthens every day"
8. "I trust my clinical judgment"
9. "My professionalism makes a difference"
10. "I'm proud of my profession"

**Compassion (15)**
1. "My empathy is my strength, not my weakness"
2. "Listening to a patient is care in itself"
3. "A smile can change someone's day"
4. "I see the person behind the condition"
5. "My presence brings comfort"
6. "Every patient deserves my kindness"
7. "I'm the human connection in a technical system"
8. "My humanity is my best tool"
9. "Care begins with a look"
10. "I create safety through my presence"
11. "My attention is a gift I offer"
12. "Being there matters"
13. "My compassion doesn't run out, it grows"
14. "Every gentle gesture is an act of resistance"
15. "I care with both my hands and my heart"

**Balance (15)**
1. "My days off are sacred"
2. "I'm more than my job"
3. "Taking care of myself allows me to care for others"
4. "Saying no protects my energy"
5. "My personal wellbeing isn't selfish"
6. "I deserve a life outside the hospital"
7. "My hobbies recharge me to care better"
8. "Work-life balance is a right, not a luxury"
9. "I don't bring work home (in my head)"
10. "My loved ones need me whole, not exhausted"
11. "Disconnecting is necessary to reconnect"
12. "My identity extends beyond my scrubs"
13. "I cultivate my personal life with as much care"
14. "My time off is vital, not optional"
15. "I choose to live, not just survive"

### French Affirmations (50)

**Résilience (10)**
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

**Compétence (10)**
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

**Équilibre (15)**
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

## Implementation in Swift

### Loading Localized Affirmations

```swift
struct LocalizedAffirmation {
    let textKey: String // e.g., "affirmation_resilience_1"
    let category: AffirmationCategory
}

struct AffirmationsLibrary {
    static let allAffirmations: [LocalizedAffirmation] = [
        // Resilience
        LocalizedAffirmation(textKey: "affirmation_resilience_1", category: .resilience),
        LocalizedAffirmation(textKey: "affirmation_resilience_2", category: .resilience),
        // ... etc for all 50
    ]
    
    static func getAffirmationForDay(_ date: Date = Date()) -> LocalizedAffirmation {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % allAffirmations.count
        return allAffirmations[index]
    }
    
    static func localizedText(for affirmation: LocalizedAffirmation) -> String {
        return NSLocalizedString(affirmation.textKey, comment: "")
    }
}
```

### Add to Localizable.strings

**English (en.lproj/Localizable.strings):**
```
"affirmation_resilience_1" = "I make a difference, even in small gestures";
"affirmation_resilience_2" = "My limits protect my ability to care";
// ... all 50
```

**French (fr.lproj/Localizable.strings):**
```
"affirmation_resilience_1" = "Je fais une différence, même dans les petits gestes";
"affirmation_resilience_2" = "Mes limites protègent ma capacité à soigner";
// ... all 50
```

---

## Testing Localization

### In Xcode

1. **Change Simulator Language:**
   - Settings > General > Language & Region
   - Add French
   - Restart app

2. **Scheme Language Override:**
   - Edit Scheme > Run
   - Options > App Language
   - Select French or English

3. **Preview Multiple Languages:**
```swift
#Preview("English") {
    HomeView()
        .environment(\.locale, Locale(identifier: "en"))
}

#Preview("French") {
    HomeView()
        .environment(\.locale, Locale(identifier: "fr"))
}
```

---

## Future Languages (v0.2+)

**Priority Order:**
1. Spanish (Spain & Latin America)
2. German (Germany, Austria, Switzerland)
3. Portuguese (Brazil & Portugal)
4. Italian
5. Dutch
6. Japanese

**Localization Strategy:**
- Professional translation service (not Google Translate)
- Native nurse speakers for affirmations
- Cultural adaptation (not just word-for-word)
- Beta testing with native speakers

---

**Last Updated:** January 29, 2026
