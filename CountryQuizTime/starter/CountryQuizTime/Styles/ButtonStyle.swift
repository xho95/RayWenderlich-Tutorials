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

enum ButtonConstants {
  static let cornerRadius: CGFloat = 4.0
  static let lineWidth: CGFloat = 1.0
  static let clipShape = RoundedRectangle(cornerRadius: ButtonConstants.cornerRadius)
}

struct QuizButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    HStack {
      Spacer()
      configuration.label
        .font(.body.bold())
      Spacer()
    }
    .padding()
    .foregroundColor(.white)
    .background(configuration.isPressed ? Color.blue.opacity(0.4) : Color.blue)
    .overlay(
      RoundedRectangle(cornerRadius: ButtonConstants.cornerRadius)
        .stroke(Color.blue, lineWidth: ButtonConstants.lineWidth)
    )
    .clipShape(ButtonConstants.clipShape)
  }
}

struct ActionButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.caption.bold())
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(configuration.isPressed ? Color.red.opacity(0.4) : Color.red)
      .foregroundColor(.white)
      .overlay(
        RoundedRectangle(cornerRadius: ButtonConstants.cornerRadius)
          .stroke(Color.red, lineWidth: ButtonConstants.lineWidth)
      )
      .clipShape(ButtonConstants.clipShape)
  }
}
