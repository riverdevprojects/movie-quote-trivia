import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.1, green: 0.05, blue: 0.3),
                    Color(red: 0.15, green: 0.1, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Only show game content if we have a question
            if viewModel.currentQuestion != nil {
                VStack(spacing: 20) {
                    // Player cards at top (keep stable order)
                    PlayerCardsView(viewModel: viewModel)
                        .padding(.horizontal)

                    // Round indicator
                    if let room = viewModel.gameRoom {
                        Text("Round \(room.currentRound)/\(room.totalRounds)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }

                    // Timer bar
                    TimerBarView(progress: viewModel.timeRemaining / 10.0)
                        .padding(.horizontal, 25)

                    // Quote display area (always shown)
                    QuoteDisplayView(displayedText: viewModel.displayedText)
                        .frame(maxHeight: .infinity)
                        .padding(.horizontal, 25)

                    // Answer buttons (2x2 grid)
                    AnswerGridView(
                        viewModel: viewModel,
                        answers: viewModel.shuffledAnswers,
                        correctAnswer: viewModel.currentQuestion?.correctAnswer ?? "",
                        selectedAnswer: viewModel.selectedAnswer,
                        showCorrectAnswer: viewModel.showCorrectAnswer,
                        revealedAnswers: viewModel.revealedAnswers,
                        revealedPlayers: viewModel.revealedPlayers,
                        hasAnswered: viewModel.hasAnswered,
                        onAnswerSelected: { answer in
                            viewModel.submitAnswer(answer)
                        }
                    )
                    .padding(.horizontal, 25)
                    .padding(.bottom, 30)
                }
            } else {
                // Loading state while question loads
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                    
                    Text("Loading question...")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
}

struct PlayerCardsView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                if let room = viewModel.gameRoom {
                    // Maintain stable order - use ID sorting to prevent shuffling
                    let stablePlayers = room.players.values.sorted { $0.id < $1.id }

                    ForEach(stablePlayers, id: \.id) { player in
                        PlayerScoreCard(
                            player: player,
                            isCurrentPlayer: player.id == viewModel.currentPlayer?.id,
                            answerTime: viewModel.getAnswerTimeForPlayer(player),
                            showScores: viewModel.showScoreUpdates,
                            viewModel: viewModel
                        )
                    }
                }
            }
            .padding(.vertical, 10)
        }
    }
}

struct PlayerScoreCard: View {
    let player: Player
    let isCurrentPlayer: Bool
    let answerTime: String?
    let showScores: Bool
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 6) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: isCurrentPlayer ?
                                [Color.yellow.opacity(0.6), Color.orange.opacity(0.6)] :
                                [Color.purple.opacity(0.4), Color.blue.opacity(0.4)]
                            ),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Text(player.avatarEmoji)
                    .font(.title2)

                // Answered indicator - use validated check to prevent stale data display
                if viewModel.shouldShowAnsweredIndicator(for: player) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 15, height: 15)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 18, y: -18)
                }
            }

            // Answer time (appears when answered) - use validated indicator check
            if let time = answerTime, viewModel.shouldShowAnsweredIndicator(for: player) {
                Text(time)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.cyan)
                    .transition(.scale.combined(with: .opacity))
            } else if viewModel.shouldShowAnsweredIndicator(for: player) {
                // Spacer to maintain layout when answered but time not yet available
                Text(" ")
                    .font(.system(size: 10, weight: .bold))
            }

            // Name
            Text(player.name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(maxWidth: 70)

            // Score (use getDisplayScore to show old score until reveal)
            Text("\(viewModel.getDisplayScore(for: player))")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(showScores ? .yellow : .yellow.opacity(0.6))
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showScores)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: viewModel.getDisplayScore(for: player))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(isCurrentPlayer ? 0.15 : 0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCurrentPlayer ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 2)
                )
        )
    }
}

struct TimerBarView: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 20)

                // Progress - with NaN protection
                let safeProgress = progress.isNaN || progress.isInfinite ? 0 : max(0, min(1, progress))
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: safeProgress > 0.5 ?
                                [Color.green, Color.blue] :
                                safeProgress > 0.25 ?
                                [Color.yellow, Color.orange] :
                                [Color.orange, Color.red]
                            ),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(safeProgress), height: 20)
                    .animation(.linear(duration: 0.1), value: safeProgress)
            }
        }
        .frame(height: 20)
    }
}

struct QuoteDisplayView: View {
    let displayedText: String

    var body: some View {
        ScrollView {
            Text(displayedText.isEmpty ? " " : displayedText)
                .font(.system(size: 28, weight: .medium, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct AnswerGridView: View {
    @ObservedObject var viewModel: GameViewModel
    let answers: [String]
    let correctAnswer: String
    let selectedAnswer: String?
    let showCorrectAnswer: Bool
    let revealedAnswers: Set<String>
    let revealedPlayers: [String: [String]]
    let hasAnswered: Bool
    let onAnswerSelected: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 15),
            GridItem(.flexible(), spacing: 15)
        ], spacing: 15) {
            ForEach(answers, id: \.self) { answer in
                AnswerButton(
                    answer: answer,
                    correctAnswer: correctAnswer,
                    selectedAnswer: selectedAnswer,
                    showCorrectAnswer: showCorrectAnswer,
                    isRevealed: revealedAnswers.contains(answer),
                    isDisabled: hasAnswered,
                    answersLocked: viewModel.answersLocked,
                    playersWhoSelected: getPlayersWhoSelected(answer: answer),
                    action: { onAnswerSelected(answer) }
                )
            }
        }
    }

    private func getPlayersWhoSelected(answer: String) -> [Player] {
        guard let room = viewModel.gameRoom,
              let playerIDs = revealedPlayers[answer] else {
            return []
        }
        
        // Return players in the exact order they were revealed (by playerID)
        return playerIDs.compactMap { playerID in
            room.players[playerID]
        }
    }
}

struct AnswerButton: View {
    let answer: String
    let correctAnswer: String
    let selectedAnswer: String?
    let showCorrectAnswer: Bool
    let isRevealed: Bool
    let isDisabled: Bool
    let answersLocked: Bool
    let playersWhoSelected: [Player]
    let action: () -> Void

    @State private var isPressed = false

    private var isCorrect: Bool {
        answer == correctAnswer
    }

    private var isSelected: Bool {
        answer == selectedAnswer
    }

    var backgroundColor: Color {
        // Only show colors after answer is revealed
        if showCorrectAnswer && isRevealed {
            if isCorrect {
                return .green.opacity(0.4)
            } else if isSelected {
                return .red.opacity(0.4)
            }
        } else if isSelected && !showCorrectAnswer {
            return .blue.opacity(0.3)
        }
        return .white.opacity(0.15)
    }

    var borderColor: Color {
        if showCorrectAnswer && isRevealed {
            if isCorrect {
                return .green
            } else if isSelected {
                return .red
            }
        } else if isSelected {
            return .blue
        }
        return .white.opacity(0.3)
    }

    var body: some View {
        Button(action: {
            // CANNOT click if locked or disabled
            if !isDisabled && !answersLocked {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                }
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 8) {
                // Answer text
                Text(answer)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 8)
                    .padding(.top, 12)

                // Player avatars (revealed one by one, stable order)
                if !playersWhoSelected.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(playersWhoSelected.enumerated()), id: \.element.id) { index, player in
                            Text(player.avatarEmoji)
                                .font(.system(size: 16))
                                .transition(.scale.combined(with: .opacity))
                                .id("\(answer)-\(player.id)") // Unique ID to prevent shuffling
                        }
                    }
                    .padding(.bottom, 8)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(backgroundColor)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(borderColor, lineWidth: 2)
            )
            .shadow(color: borderColor.opacity(0.3), radius: isSelected ? 8 : 4)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            // Dim the button when locked
            .opacity(answersLocked && !isSelected ? 0.5 : 1.0)
        }
        .disabled(isDisabled || answersLocked) // Disable when locked
        .animation(.easeInOut(duration: 0.4), value: backgroundColor)
        .animation(.easeInOut(duration: 0.4), value: borderColor)
        .animation(.easeInOut(duration: 0.2), value: answersLocked)
    }
}
