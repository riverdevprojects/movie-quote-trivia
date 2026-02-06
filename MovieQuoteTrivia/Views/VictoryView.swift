import SwiftUI

struct VictoryView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.2, green: 0.1, blue: 0.3),
                    Color(red: 0.15, green: 0.05, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Trophy and title
                VStack(spacing: 15) {
                    Text("🏆")
                        .font(.system(size: 80))
                        .shadow(color: .yellow.opacity(0.5), radius: 20)

                    Text("Game Over!")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Final Rankings")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 20)

                // Rankings list
                ScrollView {
                    VStack(spacing: 15) {
                        let rankedPlayers = viewModel.getSortedPlayers()

                        ForEach(Array(rankedPlayers.enumerated()), id: \.element.id) { index, player in
                            RankingCard(
                                player: player,
                                rank: index + 1,
                                isCurrentPlayer: player.id == viewModel.currentPlayer?.id
                            )
                        }
                    }
                    .padding(.horizontal, 25)
                }
                .frame(maxHeight: 400)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    // Play Again - returns to lobby (available for everyone)
                    Button(action: {
                        viewModel.returnToLobby()
                    }) {
                        Text("Play Again")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: .green.opacity(0.5), radius: 10)
                    }
                    .padding(.horizontal, 25)

                    // Leave/Close - host closes room, non-host leaves
                    Button(action: {
                        viewModel.leaveRoom()
                    }) {
                        Text(viewModel.currentPlayer?.isHost == true ? "Close Room" : "Leave Room")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 25)
                }
                .padding(.bottom, 30)
            }
        }
    }
}

struct RankingCard: View {
    let player: Player
    let rank: Int
    let isCurrentPlayer: Bool

    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .white.opacity(0.6)
        }
    }

    var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }

    var body: some View {
        HStack(spacing: 20) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 50, height: 50)

                if rank <= 3 {
                    Text(rankEmoji)
                        .font(.title2)
                } else {
                    Text("\(rank)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(rankColor)
                }
            }

            // Avatar
            Text(player.avatarEmoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: rank == 1 ?
                                    [Color.yellow.opacity(0.6), Color.orange.opacity(0.6)] :
                                    [Color.purple.opacity(0.4), Color.blue.opacity(0.4)]
                                ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            // Player info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(player.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    if isCurrentPlayer {
                        Text("YOU")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.blue)
                            )
                    }

                    if player.isAI {
                        Text("AI")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.cyan.opacity(0.6))
                            )
                    }
                }

                Text("\(player.score) points")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    isCurrentPlayer ?
                        Color.blue.opacity(0.2) :
                        Color.white.opacity(0.08)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            rank == 1 ? Color.yellow.opacity(0.5) :
                            isCurrentPlayer ? Color.blue.opacity(0.5) :
                            Color.white.opacity(0.1),
                            lineWidth: rank == 1 ? 3 : 1
                        )
                )
        )
        .shadow(
            color: rank == 1 ? Color.yellow.opacity(0.3) : Color.clear,
            radius: 15
        )
        .scaleEffect(rank == 1 ? 1.05 : 1.0)
    }
}
