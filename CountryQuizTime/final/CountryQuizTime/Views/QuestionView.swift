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

struct QuestionView: View {
  var question: Question
  @EnvironmentObject var quiz: Quiz
  @State private var showResult = false
  @State private var selection = ""
  @State private var message = ""

  var body: some View {
    VStack(alignment: .leading) {
      titleView
      optionsView
    }
    .alert("Result", isPresented: $showResult) {
      nextButton
    } message: {
      messageView
    }
  }

  private var titleView: some View {
    Text(question.title)
      .font(.title2.bold())
      .fixedSize(horizontal: false, vertical: true)
  }

  private var optionsView: some View {
    ForEach(question.options, id: \.self) { option in
      optionButton(option)
    }
  }

private func optionButton(_ option: String) -> some View {
  Button(option) {
    let isCorrect = quiz.checkQuestion(question: question, choice: option)
    message = isCorrect ?
    String(localized: "correctly", comment: "Correct message") :
    String(localized: "incorrectly", comment: "Incorrect message")
    showResult.toggle()
  }
  .buttonStyle(QuizButtonStyle())
}

  private var nextButton: some View {
    Button("Next", role: .cancel) {
      quiz.nextQuestion()
      selection = ""
    }
  }

  private var messageView: some View {
    Text("You answered \(message)", comment: "Question result message")
  }
}

struct QuestionView_Previews: PreviewProvider {
  static var previews: some View {
    QuestionView(question: Question.mockQuestion)
      .environmentObject(Quiz())
      .environment(\.locale, .init(identifier: "en"))
    QuestionView(question: Question.mockQuestion)
      .environmentObject(Quiz())
      .environment(\.locale, .init(identifier: "es"))
  }
}
