import Foundation

public class Deck {
    var cards: [Card]

    init(numCards: Int) {
        cards = [Card]()
        for i in 0..<numCards {
            cards.append(Card(number: i))
        }
    }

    init(cards: [Card]) {
        self.cards = cards
    }

    static func standardDeck() -> Deck {
        return Deck(numCards: 52)
    }

    func shuffle() {
        var newDeck = [Card]()
        while cards.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(cards.count)))
            newDeck.append(cards[randomIndex])
            cards.remove(at: randomIndex)
        }
        cards = newDeck
    }

    func drawRandom(num: Int = 1) -> [Card] {
        var drawnCards = [Card]()
        for _ in 0..<num {
            let randomIndex = Int(arc4random_uniform(UInt32(cards.count)))
            drawnCards.append(cards[randomIndex])
            cards.remove(at: randomIndex)
        }
        for i in drawnCards {
            cards.append(i)
        }
        return drawnCards
    }

    func addCard(card: Card) {
        cards.append(card)
    }

}
