import SwiftUI

struct MainMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var playerName: String = ""
    @State private var showJoinRoom: Bool = false
    @State private var roomCode: String = ""
    @State private var selectedDifficulty: Question.Difficulty = .medium
    @FocusState private var isNameFieldFocused: Bool
    
    private let userNameKey = "SavedPlayerName"

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4),
                    Color(red: 0.3, green: 0.1, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 40)

                    // Title
                    VStack(spacing: 10) {
                        Text("🎬")
                            .font(.system(size: 80))

                        Text("Movie Quote")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("TRIVIA")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: .orange, radius: 10)
                    }
                    .padding(.bottom, 20)

                    // Player name input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Name")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.leading, 5)

                        TextField("Enter your name", text: $playerName)
                            .textFieldStyle(CustomTextFieldStyle())
                            .autocapitalization(.words)
                            .focused($isNameFieldFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                isNameFieldFocused = false
                                savePlayerName()
                            }
                            .onChange(of: playerName) { _ in
                                savePlayerName()
                            }
                    }
                    .padding(.horizontal, 40)

                    // Difficulty selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Difficulty")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.leading, 5)
                        
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            Text("Easy").tag(Question.Difficulty.easy)
                            Text("Medium").tag(Question.Difficulty.medium)
                            Text("Hard").tag(Question.Difficulty.hard)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)

                    // Buttons
                    VStack(spacing: 15) {
                        MenuButton(
                            title: "Single Player",
                            icon: "person.fill",
                            color: .blue
                        ) {
                            isNameFieldFocused = false
                            createSinglePlayerGame()
                        }
                        .disabled(playerName.isEmpty)

                        MenuButton(
                            title: "Create Room",
                            icon: "plus.circle.fill",
                            color: .green
                        ) {
                            isNameFieldFocused = false
                            createMultiplayerRoom()
                        }
                        .disabled(playerName.isEmpty)

                        MenuButton(
                            title: "Join Room",
                            icon: "arrow.right.circle.fill",
                            color: .purple
                        ) {
                            isNameFieldFocused = false
                            showJoinRoom = true
                        }
                        .disabled(playerName.isEmpty)
                    }
                    .padding(.horizontal, 40)

                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding()
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }

                    Spacer().frame(height: 40)
                }
            }
            .onTapGesture {
                isNameFieldFocused = false
            }
            .onAppear {
                loadPlayerName()
            }
        }
        .sheet(isPresented: $showJoinRoom) {
            JoinRoomSheet(
                roomCode: $roomCode,
                onJoin: {
                    viewModel.joinRoom(code: roomCode, playerName: playerName)
                    showJoinRoom = false
                }
            )
        }
    }
    
    private func loadPlayerName() {
        if let savedName = UserDefaults.standard.string(forKey: userNameKey), !savedName.isEmpty {
            playerName = savedName
        }
    }
    
    private func savePlayerName() {
        UserDefaults.standard.set(playerName, forKey: userNameKey)
    }

    private func createSinglePlayerGame() {
        viewModel.createRoom(playerName: playerName, isSinglePlayer: true, difficulty: selectedDifficulty)
    }

    private func createMultiplayerRoom() {
        viewModel.createRoom(playerName: playerName, isSinglePlayer: false, difficulty: selectedDifficulty)
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)

                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.7)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .foregroundColor(.white)
            .font(.title3)
    }
}

struct JoinRoomSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var roomCode: String
    let onJoin: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.15, green: 0.1, blue: 0.35)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Text("Enter Room Code")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    TextField("6-LETTER CODE", text: $roomCode)
                        .textFieldStyle(CustomTextFieldStyle())
                        .autocapitalization(.allCharacters)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .onChange(of: roomCode) { newValue in
                            roomCode = String(newValue.prefix(6).uppercased())
                        }
                        .padding(.horizontal, 30)

                    Button(action: {
                        onJoin()
                    }) {
                        Text("Join Game")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                    }
                    .disabled(roomCode.count != 6)
                    .padding(.horizontal, 30)
                }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            }.foregroundColor(.white))
        }
    }
}
