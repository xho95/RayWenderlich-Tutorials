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

struct CardView: View {
  var card: Card

  var body: some View {
    ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(card.isFlipped && card.animal == .ducks ? Color.purple : Color.black)

      if card.isFlipped {
        CardFrontContentView(animal: card.animal)
          .padding()
      } else {
        CardBackContentView()
          .padding()
      }
    }
    .rotation3DEffect(
      card.isFlipped ?
        Angle(degrees: 180):
        Angle(degrees: 0), axis: (x: 0, y: 10, z: 0))
  }
}

struct CardView_Previews: PreviewProvider {
  static var previews: some View {
    CardView(card: Card(animal: .owl, isFlipped: false))
    CardView(card: Card(animal: .owl, isFlipped: true))
    CardView(card: Card(animal: .ducks, isFlipped: true))
  }
}
