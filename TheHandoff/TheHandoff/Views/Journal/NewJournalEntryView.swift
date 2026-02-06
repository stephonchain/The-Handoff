import SwiftUI
import SwiftData
import PhotosUI
import AVFoundation

struct NewJournalEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mode: JournalMode

    // Entry data
    @State private var entryDate: Date = Date()
    @State private var content: String = ""
    @State private var moodValue: Int = 3
    @State private var selectedTags: [String] = []
    @State private var highlights: [String] = []
    @State private var newHighlight: String = ""

    // Media
    @State private var selectedImages: [UIImage] = []
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isRecording = false
    @State private var recordedAudioURL: URL?
    @State private var audioDuration: Double = 0
    @State private var isPlayingAudio = false

    // Guided mode
    @State private var guidedChecklist: [GuidedItem] = []
    @State private var guidedNote: String = ""

    // UI state
    @State private var showingDatePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with date
                    headerSection

                    // Date selector
                    dateSection

                    // Media section (photos + audio)
                    mediaSection

                    // Content based on mode
                    switch mode {
                    case .quickDump:
                        quickDumpContent
                    case .guided:
                        guidedContent
                    case .pride:
                        prideContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveEntry()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(mode.color)
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if mode == .guided {
                    setupGuidedChecklist()
                }
                setupAudioSession()
            }
            .onDisappear {
                stopRecording()
                stopPlayingAudio()
            }
            .onChange(of: selectedPhotoItems) { _, newItems in
                loadSelectedPhotos(from: newItems)
            }
        }
    }

    private var canSave: Bool {
        switch mode {
        case .quickDump:
            return !content.isEmpty || !selectedImages.isEmpty || recordedAudioURL != nil
        case .guided:
            return guidedChecklist.contains { $0.isChecked } || !guidedNote.isEmpty || !selectedImages.isEmpty || recordedAudioURL != nil
        case .pride:
            return !highlights.isEmpty || !selectedImages.isEmpty || recordedAudioURL != nil
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(mode.color.opacity(0.15))
                    .frame(width: 72, height: 72)

                Image(systemName: mode.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(mode.color)
            }

            Text(mode.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(mode.emptySubtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }

    // MARK: - Date Section

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    showingDatePicker.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(mode.color)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Date de l'entrée")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(entryDate, format: .dateTime.weekday(.wide).day().month().year())
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    Spacer()

                    Image(systemName: showingDatePicker ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            if showingDatePicker {
                DatePicker(
                    "Date",
                    selection: $entryDate,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .tint(mode.color)
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Media Section

    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundStyle(mode.color)
                Text("Médias")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            // Selected images preview
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Button(action: {
                                    withAnimation {
                                        selectedImages.remove(at: index)
                                        if index < selectedPhotoItems.count {
                                            selectedPhotoItems.remove(at: index)
                                        }
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                        .background(Circle().fill(.black.opacity(0.5)))
                                }
                                .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
            }

            // Audio recording preview
            if recordedAudioURL != nil {
                HStack(spacing: 12) {
                    Button(action: toggleAudioPlayback) {
                        ZStack {
                            Circle()
                                .fill(mode.color.opacity(0.15))
                                .frame(width: 44, height: 44)

                            Image(systemName: isPlayingAudio ? "stop.fill" : "play.fill")
                                .foregroundStyle(mode.color)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Note vocale")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(formatDuration(audioDuration))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button(action: deleteRecording) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Action buttons
            HStack(spacing: 12) {
                // Photo picker
                PhotosPicker(
                    selection: $selectedPhotoItems,
                    maxSelectionCount: 5,
                    matching: .images
                ) {
                    HStack {
                        Image(systemName: "photo")
                        Text("Photos")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                // Audio recorder
                Button(action: toggleRecording) {
                    HStack {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic")
                            .foregroundStyle(isRecording ? .red : .primary)
                        Text(isRecording ? "Arrêter" : "Audio")
                            .font(.subheadline)
                            .foregroundStyle(isRecording ? .red : .primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isRecording ? Color.red.opacity(0.1) : Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isRecording ? Color.red : .clear, lineWidth: 2)
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Quick Dump Mode

    private var quickDumpContent: some View {
        VStack(spacing: 20) {
            // Text area
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "text.alignleft")
                        .foregroundStyle(mode.color)
                    Text("Écris ce qui te passe par la tête")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                TextEditor(text: $content)
                    .frame(minHeight: 200)
                    .scrollContentBackground(.hidden)
                    .padding(16)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            moodSelector
            tagSelector
        }
    }

    // MARK: - Guided Mode

    private var guidedContent: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "checklist")
                        .foregroundStyle(mode.color)
                    Text("Coche ce qui s'applique")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                VStack(spacing: 0) {
                    ForEach($guidedChecklist) { $item in
                        GuidedChecklistRow(item: $item, color: mode.color)

                        if item.id != guidedChecklist.last?.id {
                            Divider()
                                .padding(.leading, 52)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundStyle(mode.color)
                    Text("Ajouter une note (optionnel)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                TextField("Ce que tu veux ajouter...", text: $guidedNote, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(16)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            moodSelector
        }
    }

    private func setupGuidedChecklist() {
        guidedChecklist = [
            GuidedItem(icon: "heart.fill", text: "J'ai pris soin de moi aujourd'hui", category: .selfCare),
            GuidedItem(icon: "moon.zzz.fill", text: "J'ai bien dormi la nuit dernière", category: .sleep),
            GuidedItem(icon: "fork.knife", text: "J'ai mangé correctement", category: .nutrition),
            GuidedItem(icon: "figure.walk", text: "J'ai pris ma pause", category: .breaks),
            GuidedItem(icon: "person.2.fill", text: "J'ai eu un bon contact avec l'équipe", category: .team),
            GuidedItem(icon: "hand.raised.fill", text: "J'ai su poser mes limites", category: .boundaries),
            GuidedItem(icon: "brain.head.profile", text: "J'ai eu des pensées qui tournent en boucle", category: .rumination),
            GuidedItem(icon: "exclamationmark.triangle.fill", text: "J'ai vécu une situation difficile", category: .difficulty),
            GuidedItem(icon: "face.smiling.fill", text: "J'ai vécu un moment positif", category: .positive),
            GuidedItem(icon: "lightbulb.fill", text: "J'ai appris quelque chose", category: .learning)
        ]
    }

    // MARK: - Pride Mode

    private var prideContent: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(mode.color)
                    Text("Mes micro-victoires")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                VStack(spacing: 8) {
                    ForEach(highlights.indices, id: \.self) { index in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(mode.color.opacity(0.15))
                                    .frame(width: 36, height: 36)

                                Image(systemName: "trophy.fill")
                                    .font(.caption)
                                    .foregroundStyle(mode.color)
                            }

                            Text(highlights[index])
                                .font(.body)

                            Spacer()

                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    highlights.remove(at: index)
                                }
                                HapticManager.shared.impact(style: .light)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color(.tertiaryLabel))
                            }
                        }
                        .padding(12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                            .foregroundStyle(mode.color)

                        TextField("Ajouter une fierté...", text: $newHighlight)
                            .onSubmit { addHighlight() }

                        if !newHighlight.isEmpty {
                            Button(action: addHighlight) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(mode.color)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(mode.color.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.secondary)
                    Text("Suggestions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                FlowLayout(spacing: 8) {
                    ForEach(prideSuggestions, id: \.self) { suggestion in
                        Button(action: {
                            newHighlight = suggestion
                            addHighlight()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.caption2)
                                Text(suggestion)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundStyle(mode.color)
                    Text("Note (optionnel)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                TextEditor(text: $content)
                    .frame(minHeight: 80)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var prideSuggestions: [String] {
        [
            "J'ai aidé un patient difficile",
            "J'ai gardé mon calme",
            "J'ai pris ma pause",
            "J'ai bien communiqué",
            "J'ai appris quelque chose",
            "J'ai fait preuve de patience"
        ]
    }

    private func addHighlight() {
        guard !newHighlight.isEmpty else { return }
        withAnimation(.spring(response: 0.3)) {
            highlights.append(newHighlight)
        }
        newHighlight = ""
        HapticManager.shared.impact(style: .light)
    }

    // MARK: - Mood Selector

    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "face.smiling")
                    .foregroundStyle(mode.color)
                Text("Comment tu te sens ?")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            HStack(spacing: 0) {
                ForEach(1...5, id: \.self) { value in
                    Button(action: {
                        moodValue = value
                        HapticManager.shared.impact(style: .light)
                    }) {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(moodValue == value ? moodColor(value).opacity(0.15) : .clear)
                                    .frame(width: 48, height: 48)

                                Image(systemName: moodIcon(value))
                                    .font(.title2)
                                    .foregroundStyle(moodValue == value ? moodColor(value) : Color(.tertiaryLabel))
                            }

                            Text(moodLabel(value))
                                .font(.caption2)
                                .foregroundStyle(moodValue == value ? moodColor(value) : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func moodIcon(_ value: Int) -> String {
        switch value {
        case 1: return "cloud.rain.fill"
        case 2: return "cloud.fill"
        case 3: return "cloud.sun.fill"
        case 4: return "sun.max.fill"
        case 5: return "sparkles"
        default: return "circle"
        }
    }

    private func moodLabel(_ value: Int) -> String {
        switch value {
        case 1: return "Difficile"
        case 2: return "Bas"
        case 3: return "Neutre"
        case 4: return "Bien"
        case 5: return "Super"
        default: return ""
        }
    }

    private func moodColor(_ value: Int) -> Color {
        switch value {
        case 1: return Color(hex: "EF4444")
        case 2: return Color(hex: "F59E0B")
        case 3: return Color(hex: "6B7280")
        case 4: return Color(hex: "10B981")
        case 5: return Color(hex: "10B981")
        default: return Color(hex: "6B7280")
        }
    }

    private func moodEmoji(_ value: Int) -> String {
        switch value {
        case 1: return "😫"
        case 2: return "😔"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😊"
        default: return "😐"
        }
    }

    // MARK: - Tag Selector

    private var tagSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tag")
                    .foregroundStyle(mode.color)
                Text("Tags")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            FlowLayout(spacing: 8) {
                ForEach(availableTags, id: \.self) { tag in
                    Button(action: { toggleTag(tag) }) {
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedTags.contains(tag)
                                    ? mode.color.opacity(0.15)
                                    : Color(.systemBackground)
                            )
                            .foregroundStyle(
                                selectedTags.contains(tag)
                                    ? mode.color
                                    : .primary
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(selectedTags.contains(tag) ? mode.color : Color(.systemGray4), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var availableTags: [String] {
        ["Shift difficile", "Belle rencontre", "Apprentissage", "Équipe géniale",
         "Fatigue", "Fierté", "Questionnement", "Urgence", "Rétablissement"]
    }

    private func toggleTag(_ tag: String) {
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
        } else {
            selectedTags.append(tag)
        }
        HapticManager.shared.impact(style: .light)
    }

    // MARK: - Photo Handling

    private func loadSelectedPhotos(from items: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            await MainActor.run {
                selectedImages = images
            }
        }
    }

    // MARK: - Audio Recording

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        let audioFilename = FileManager.default.temporaryDirectory.appendingPathComponent("voice_note_\(UUID().uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            recordedAudioURL = audioFilename
            HapticManager.shared.impact(style: .medium)
        } catch {
            print("Could not start recording: \(error)")
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false

        if let url = recordedAudioURL {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                audioDuration = player.duration
            } catch {
                print("Could not get audio duration: \(error)")
            }
        }
    }

    private func deleteRecording() {
        stopPlayingAudio()
        if let url = recordedAudioURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordedAudioURL = nil
        audioDuration = 0
        HapticManager.shared.impact(style: .light)
    }

    private func toggleAudioPlayback() {
        if isPlayingAudio {
            stopPlayingAudio()
        } else {
            playAudio()
        }
    }

    private func playAudio() {
        guard let url = recordedAudioURL else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlayingAudio = true
        } catch {
            print("Could not play audio: \(error)")
        }
    }

    private func stopPlayingAudio() {
        audioPlayer?.stop()
        isPlayingAudio = false
    }

    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Save

    private func saveEntry() {
        let entryTitle: String
        let entryContent: String

        switch mode {
        case .quickDump:
            entryTitle = "Décharge rapide"
            entryContent = content
        case .guided:
            entryTitle = "Journal guidé"
            let checkedItems = guidedChecklist.filter { $0.isChecked }
            let checklistText = checkedItems.map { "✓ \($0.text)" }.joined(separator: "\n")
            if guidedNote.isEmpty {
                entryContent = checklistText
            } else {
                entryContent = checklistText + "\n\n---\n\n" + guidedNote
            }
        case .pride:
            entryTitle = "Mes fiertés"
            let highlightsText = highlights.map { "🏆 \($0)" }.joined(separator: "\n")
            entryContent = content.isEmpty ? highlightsText : "\(highlightsText)\n\n\(content)"
        }

        let entry = JournalEntry(title: entryTitle, content: entryContent, moodEmoji: moodEmoji(moodValue), date: entryDate)
        entry.tags = selectedTags
        entry.highlights = highlights

        // Save images
        if !selectedImages.isEmpty {
            entry.imageData = selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
        }

        // Save audio
        if let audioURL = recordedAudioURL,
           let audioData = try? Data(contentsOf: audioURL) {
            entry.audioData = audioData
            entry.audioDuration = audioDuration
        }

        modelContext.insert(entry)
        try? modelContext.save()
        HapticManager.shared.notification(type: .success)
    }
}

// MARK: - Guided Item

struct GuidedItem: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    let category: GuidedCategory
    var isChecked: Bool = false
}

enum GuidedCategory {
    case selfCare, sleep, nutrition, breaks, team, boundaries, rumination, difficulty, positive, learning
}

// MARK: - Guided Checklist Row

struct GuidedChecklistRow: View {
    @Binding var item: GuidedItem
    let color: Color

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                item.isChecked.toggle()
            }
            HapticManager.shared.impact(style: .light)
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(item.isChecked ? color : Color(.systemGray3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if item.isChecked {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color)
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }

                Image(systemName: item.icon)
                    .font(.body)
                    .foregroundStyle(item.isChecked ? color : Color(.tertiaryLabel))
                    .frame(width: 24)

                Text(item.text)
                    .font(.subheadline)
                    .foregroundStyle(item.isChecked ? .primary : .secondary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
