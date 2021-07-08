/// Copyright (c) 2021 Razeware LLC
/// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. Notwithstanding the foregoing, you may not use, copy, modify, merge, publish, distribute, sublicense, create a derivative work, and/or sell copies of the Software in any work that is designed, intended, or marketed for pedagogical or instructional purposes related to programming, coding, application development, or information technology.  Permission for such use, copying, modification, merger, publication, distribution, sublicensing, creation of derivative works, or sale is expressly withheld. This project and source code may use libraries or frameworks that are released under various Open-Source licenses. Use of those libraries and frameworks are governed by their own individual licenses.
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

typealias Reducer<State, Action> = (State, Action) -> State

let threeDucksReducer: Reducer<ThreeDucksState, ThreeDucksAction> = { state, action in
    var mutatingState = state
    
    switch action {
    case .startGame:
        mutatingState.gameState = .started
        
        mutatingState.cards = [
            Card(animal: .bat),
            Card(animal: .bat),
            Card(animal: .ducks),
            Card(animal: .ducks),
            Card(animal: .bear),
            Card(animal: .bear),
            Card(animal: .pelican),
            Card(animal: .pelican),
            Card(animal: .horse),
            Card(animal: .horse),
            Card(animal: .elephant),
            Card(animal: .elephant)
        ].shuffled()
        
        mutatingState.selectedCards = []
        mutatingState.moves = 0

    case .endGame:
        mutatingState.gameState = .title
        
    case .flipCard(let id):
        guard mutatingState.selectedCards.count < 2 else { break }
        
        guard !mutatingState.selectedCards.contains(where: { $0.id == id }) else { break }
        
        var cards = mutatingState.cards
        
        guard let selectedIndex = cards.firstIndex(where: { $0.id == id }) else { break }
        
        let selectedCard = cards[selectedIndex]
        let flippedCard = Card(id: selectedCard.id, animal: selectedCard.animal, isFlipped: true)
        
        cards[selectedIndex] = flippedCard
        
        mutatingState.selectedCards.append(selectedCard)
        mutatingState.cards = cards
        
        mutatingState.moves += 1
        
    case .unFlipSelectedCards:
        let selectedIDs = mutatingState.selectedCards.map { $0.id }
        
        let cards: [Card] = mutatingState.cards.map { card in
            guard selectedIDs.contains(card.id) else { return card }
            
            return Card(id: card.id, animal: card.animal, isFlipped: false)
        }
        
        mutatingState.selectedCards = []
        mutatingState.cards = cards
        
    case .clearSelectedCards:
        mutatingState.selectedCards = []
    }
    
    return mutatingState
}
