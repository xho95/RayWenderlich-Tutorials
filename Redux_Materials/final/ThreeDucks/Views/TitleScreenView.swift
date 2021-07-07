/// Copyright (c) 2021 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct TitleScreenView: View {
  @EnvironmentObject var store: ThreeDucksStore

  var body: some View {
    VStack(alignment: .center, spacing: 32) {
      Spacer()

      Image("title")
        .resizable()
        .aspectRatio(contentMode: .fit)
      Button("New Game") {
        withAnimation {
          store.dispatch(.startGame)
        }
      }
      .font(.headline)
      .foregroundColor(.white)
      .padding()
      .background(Color.purple)
      .cornerRadius(40)

      if let score = store.state.previousBestScore {
        VStack(alignment: .center) {
          Text("Best Score")
            .font(.headline)

          Text("\(score.moves) moves, difficulty: \(score.difficulty.rawValue)")
            .font(.subheadline)
        }
        .foregroundColor(.purple)
      }

      Spacer()

      HStack(alignment: .center, spacing: 16) {
        ForEach(DifficultyLevel.allCases) { level in
          Button {
            store.dispatch(.setDifficulty(level))
          } label: {
            Label(
              level.rawValue,
              systemImage: store.state.gameDifficulty == level ?
                "rectangle.portrait.fill" :
                "rectangle.portrait")
          }
          .foregroundColor(level.color)
          .padding()
        }
      }
    }
  }
}

struct TitleScreenView_Previews: PreviewProvider {
  static var previews: some View {
    let previewStore: ThreeDucksStore = {
      let store = ThreeDucksStore.preview
      store.dispatch(.setPreviousBestScore(Score(difficulty: .normal, moves: 6)))
      return store
    }()

    TitleScreenView()
      .environmentObject(previewStore)
  }
}
