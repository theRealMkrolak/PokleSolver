struct Card: CustomStringConvertible, Sendable {
    let number: Int

    init(number: Int) {
        self.number = number
    }

    var description: String {
        let cardNum = getNumber()
        let suits = ["♠", "♥", "♦", "♣"]
        let suit = suits[getSuit()]
        if cardNum == 13 {
            return "A\(suit)"
        } else if cardNum == 10 {
            return "J\(suit)"
        } else if cardNum == 11 {
            return "Q\(suit)"
        } else if cardNum == 12 {
            return "K\(suit)"
        } else {
            return String(cardNum + 1) + suit
        }
    }

    static func fromString(string: String) -> Card {
        let suits = ["♠", "♥", "♦", "♣"]
        let suitsChar = ["s", "h", "d", "c"]
        var suit: Int
        if let suitSym = suits.firstIndex(of: String(string.last!)) {
            suit = suitSym
        } else {
            guard let suitChar = suitsChar.firstIndex(of: String(string.last!)) else {
                return Card(number: -1)
            }
            suit = suitChar
        }

        let cardValue: Int
        let valueString = String(string.dropLast())

        switch valueString {
        case "A":
            cardValue = 0
        case "J":
            cardValue = 10
        case "Q":
            cardValue = 11
        case "K":
            cardValue = 12
        case "a":
            cardValue = 0
        case "j":
            cardValue = 10
        case "q":
            cardValue = 11
        case "k":
            cardValue = 12
        default:
            cardValue = Int(valueString)! - 1
        }

        return Card(number: cardValue + (suit * 13))
    }

    static func getPokleStateFromAnswerAndGuess(answer: Card, guess: Card) -> PokleState {
        if answer.number == guess.number {
            return .Green
        }

        if answer.getSuit() == guess.getSuit() {
            return .Yellow
        }

        if answer.getNumber() == guess.getNumber() {
            return .Yellow
        }

        return .Gray
    }

    func getNumber() -> Int {
        let temp = number % 13
        if temp == 0 {
            return 13
        }
        return temp
    }

    func getSuit() -> Int {
        return number / 13
    }

    static func compare(card1: Card, card2: Card) -> Bool {
        return card1.getNumber() == card2.getNumber()
    }
}
