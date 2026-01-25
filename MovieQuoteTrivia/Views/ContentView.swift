import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            switch viewModel.gamePhase {
            case .menu:
                MainMenuView(viewModel: viewModel)
                    .transition(.opacity)

            case .lobby:
                LobbyView(viewModel: viewModel)
                    .transition(.slide)

            case .playing, .roundEnd:
                GameView(viewModel: viewModel)
                    .transition(.opacity)

            case .gameOver:
                VictoryView(viewModel: viewModel)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.gamePhase)
    }
}

#Preview {
    ContentView()
}
