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

import Foundation
import Combine

typealias ThreeDucksStore = Store<ThreeDucksState, ThreeDucksAction>

class Store<State, Action>: ObservableObject {
  @Published private(set) var state: State
  private let reducer: Reducer<State, Action>
  private let middlewares: [Middleware<State, Action>]
  private let queue = DispatchQueue(label: "com.raywenderlich.ThreeDucks.store", qos: .userInitiated)
  private var subscriptions: Set<AnyCancellable> = []

  init(
    initial: State,
    reducer: @escaping Reducer<State, Action>,
    middlewares: [Middleware<State, Action>] = []
  ) {
    self.state = initial
    self.reducer = reducer
    self.middlewares = middlewares
  }

  // The dispatch function dispatches an action to the serial queue.
  func dispatch(_ action: Action) {
    queue.sync {
      self.dispatch(self.state, action)
    }
  }

  // The internal work for dispatching actions
  private func dispatch(_ currentState: State, _ action: Action) {
    // generate a new state using the reducer
    let newState = reducer(currentState, action)

    // pass the new state and action to all the middlewares
    // if they publish an action dispatch pass it to the dispatch function
    middlewares.forEach { middleware in
      let publisher = middleware(newState, action)
      publisher
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: dispatch)
        .store(in: &subscriptions)
    }

    // Finally set the state to the new state
    state = newState
  }
}

extension ThreeDucksStore {
  static var preview: ThreeDucksStore {
    ThreeDucksStore(
      initial: ThreeDucksState(),
      reducer: threeDucksReducer,
      middlewares: [
        gameLogic,
        bestScoreMiddleware(using: ScorePersistence()),
        audioPlayerMiddleware(using: QuackPlayer())
      ])
  }
}
