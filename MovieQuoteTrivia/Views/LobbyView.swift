import SwiftUI

struct LobbyView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Text("🎬 Game Lobby")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    if let room = viewModel.gameRoom {
                        // Room code display
                        VStack(spacing: 8) {
                            Text("Room Code")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))

                            Text(room.code)
                                .font(.system(size: 48, weight: .black, design: .monospaced))
                                .foregroundColor(.yellow)
                                .tracking(8)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                                        )
                                )
                                .shadow(color: .yellow.opacity(0.3), radius: 10)
                        }
                        .padding(.bottom, 10)
                    }
                }
                .padding(.top, 30)

                // Players list
                VStack(alignment: .leading, spacing: 15) {
                    Text("Players (\(viewModel.gameRoom?.players.count ?? 0)/6)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)

                    ScrollView {
                        VStack(spacing: 12) {
                            if let room = viewModel.gameRoom {
                                ForEach(Array(room.players.values.sorted(by: { $0.isHost && !$1.isHost })), id: \.id) { player in
                                    PlayerLobbyCard(player: player)
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                }
                .frame(maxHeight: .infinity)

                // Waiting message or start button
                if let player = viewModel.currentPlayer {
                    if player.isHost {
                        Button(action: {
                            viewModel.startGame()
                        }) {
                            Text("Start Game")
                                .font(.title2)
                                .fontWeight(.bold)
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
                        .disabled((viewModel.gameRoom?.players.count ?? 0) < 1)
                        .padding(.horizontal, 25)
                    } else {
                        HStack(spacing: 10) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))

                            Text("Waiting for host to start...")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                    }
                }

                // Leave button
                Button(action: {
                    viewModel.leaveRoom()
                }) {
                    Text("Leave Room")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.6))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 30)
            }
        }
    }
}

struct PlayerLobbyCard: View {
    let player: Player

    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            Text(player.avatarEmoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(0.6),
                                    Color.blue.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            // Name
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(player.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    if player.isHost {
                        Text("HOST")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.yellow.opacity(0.2))
                            )
                    }

                    if player.isAI {
                        Text("AI")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.cyan.opacity(0.2))
                            )
                    }
                }

                Text("Ready")
                    .font(.caption)
                    .foregroundColor(.green)
            }

            Spacer()

            // Ready indicator
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
