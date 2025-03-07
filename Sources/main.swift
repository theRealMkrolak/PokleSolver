#!/usr/bin/env swift

import Foundation
import Algorithms
import Progress

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

enum GameState : Sendable {
    case preFlop 
    case flop (Card, Card, Card)
    case turn (Card, Card, Card, Card)
    case river (Card, Card, Card, Card, Card)

    static func compare(_ board1: GameState, _ board2: GameState) -> Bool {
        switch (board1, board2) {
            case (.preFlop, .preFlop):
                return true
            case (.flop(let hand1card1, let hand1card2, let hand1card3), .flop(let hand2card1, let hand2card2, let hand2card3)):
                return Card.compare(card1: hand1card1, card2: hand2card1) 
                    && Card.compare(card1: hand1card2, card2: hand2card2) 
                    && Card.compare(card1: hand1card3, card2: hand2card3)
            case (.turn(let hand1card1, let hand1card2, let hand1card3, let hand1card4), .turn(let hand2card1, let hand2card2, let hand2card3, let hand2card4)):
                return Card.compare(card1: hand1card1, card2: hand2card1) 
                    && Card.compare(card1: hand1card2, card2: hand2card2) 
                    && Card.compare(card1: hand1card3, card2: hand2card3) 
                    && Card.compare(card1: hand1card4, card2: hand2card4)
            case (.river(let hand1card1, let hand1card2, let hand1card3, let hand1card4, let hand1card5), .river(let hand2card1, let hand2card2, let hand2card3, let hand2card4, let hand2card5)):
                return Card.compare(card1: hand1card1, card2: hand2card1) 
                    && Card.compare(card1: hand1card2, card2: hand2card2) 
                    && Card.compare(card1: hand1card3, card2: hand2card3) 
                    && Card.compare(card1: hand1card4, card2: hand2card4) 
                    && Card.compare(card1: hand1card5, card2: hand2card5)
            default:
                return false
        }
    }
}

enum HandType {
    case highCard 
    case onePair 
    case twoPair      
    case threeOfAKind   
    case straight 
    case flush 
    case fullHouse 
    case fourOfAKind 
    case straightFlush 

    static func compare(_ hand1: HandType, _ hand2: HandType) -> Int {
        if hand1 == hand2 {
            return 0
        }
        switch (hand1, hand2) {
            case (.straightFlush, _):
                return -1
            case (_, .straightFlush):
                return 1
            case (.fourOfAKind, _):
                return -1
            case (_, .fourOfAKind):
                return 1
            case (.fullHouse, _):
                return -1
            case (_, .fullHouse):
                return 1
            case (.flush, _):
                return -1
            case (_, .flush):
                return 1
            case (.straight, _):
                return -1
            case (_, .straight):
                return 1
            case (.threeOfAKind, _):
                return -1
            case (_, .threeOfAKind):
                return 1
            case (.twoPair, _):
                return -1
            case (_, .twoPair):
                return 1
            case (.onePair, _):
                return -1
            case (_, .onePair):
                return 1
            case (.highCard, _):
                return -1
            case (_, .highCard):
                return 1
            default:
                return 0
        }
    }
}

enum PokleState : CustomStringConvertible , Sendable {
    case Yellow
    case Gray
    case Green

    var description: String {
        switch self {
            case .Yellow:
                return "🟨"
            case .Gray:
                return "⬜"
            case .Green:
                return "🟩"
        }
    }

    static func fromString(string: String) -> PokleState {
        switch string {
            case "🟨":
                return .Yellow
            case "⬜":
                return .Gray
            case "🟩":
                return .Green
            case "G":
                return .Green
            case "Y":
                return .Yellow
            case "B":
                return .Gray
            default:
                return .Gray
        }
    }
}

struct PokleResult : CustomStringConvertible, Hashable {
    var result: (PokleState, PokleState, PokleState, PokleState, PokleState)

    var description: String {
        return "(\(result.0)\(result.1)\(result.2)\(result.3)\(result.4))"
    }

    static func fromString(string: String) -> PokleResult {
        return PokleResult(result: (
            PokleState.fromString(string: String(string[string.startIndex])),
            PokleState.fromString(string: String(string[string.index(string.startIndex, offsetBy: 1)])),
            PokleState.fromString(string: String(string[string.index(string.startIndex, offsetBy: 2)])),
            PokleState.fromString(string: String(string[string.index(string.startIndex, offsetBy: 3)])),
            PokleState.fromString(string: String(string[string.index(string.startIndex, offsetBy: 4)]))
        ))
    }

    func toInt() -> Int {
        let firstDigit = result.0 == .Green ? 0 : result.0 == .Yellow ? 1 : 2
        let secondDigit = result.1 == .Green ? 0 : result.1 == .Yellow ? 1 : 2
        let thirdDigit = result.2 == .Green ? 0 : result.2 == .Yellow ? 1 : 2
        let fourthDigit = result.3 == .Green ? 0 : result.3 == .Yellow ? 1 : 2
        let fifthDigit = result.4 == .Green ? 0 : result.4 == .Yellow ? 1 : 2

        var result = firstDigit 
        result = result * 3 + secondDigit
        result = result * 3 + thirdDigit
        result = result * 3 + fourthDigit
        result = result * 3 + fifthDigit
        return result
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(toInt())
    }

    static func == (lhs: PokleResult, rhs: PokleResult) -> Bool {
        return lhs.toInt() == rhs.toInt()
    }
}

struct Card : CustomStringConvertible, Sendable {
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
            cardValue = Int(valueString)!-1
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

class Deck {
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

class Hand : CustomStringConvertible {
    let hand: (Card, Card)
    let board: GameState


    var handType: HandType? = nil
    var pairs: [Card] = []
    var three_of_a_kinds: [Card] = []
    var four_of_a_kinds: [Card] = []
    var straights: Card? = nil
    var flushes: Card? = nil

    init(hand: (Card, Card), board: GameState) {
        self.hand = hand
        self.board = board
        self.handType = getHandType()
    }

    func getHandType() -> HandType {
        // Convert tuples to arrays and combine them
        if handType != nil {
            return handType!
        }

        let handArray = [hand.0, hand.1]
        var boardArray: [Card] = []
        switch board {
            case .preFlop:
                boardArray = []
            case .flop(let card1, let card2, let card3):
                boardArray = [card1, card2, card3]
            case .turn(let card1, let card2, let card3, let card4):
                boardArray = [card1, card2, card3, card4]
            case .river(let card1, let card2, let card3, let card4, let card5):
                boardArray = [card1, card2, card3, card4, card5]
        }
        

        let combined = handArray + boardArray

        let sorted_by_number = combined.sorted { $0.number < $1.number }
        let sorted_by_face = combined.sorted { $0.getNumber() < $1.getNumber() }

        
        for i in 0..<combined.count {
            if i+4 < sorted_by_number.count
                && sorted_by_number[i].number + 1 == sorted_by_number[i+1].number
                && sorted_by_number[i].number + 2 == sorted_by_number[i+2].number
                && sorted_by_number[i].number + 3 == sorted_by_number[i+3].number
                && sorted_by_number[i].number + 4 == sorted_by_number[i+4].number
                && sorted_by_number[i].getSuit() == sorted_by_number[i+4].getSuit()
            {
                self.straights = sorted_by_number[i+4]
                return .straightFlush
            }
        }

        for i in 0..<combined.count {
            if i+3 < combined.count && sorted_by_face[i].getNumber() == sorted_by_face[i+3].getNumber() {
                self.four_of_a_kinds.append(sorted_by_face[i])
                return .fourOfAKind
            }
        }


        var three_of_a_kind = false
        var one_pair_count = 0
        for i in 0..<combined.count {
            if i+2 < combined.count && sorted_by_face[i].getNumber() == sorted_by_face[i+2].getNumber() {
                self.three_of_a_kinds.append(sorted_by_face[i])
                three_of_a_kind = true
            }
            
            if (i+1 < combined.count && sorted_by_face[i].getNumber() == sorted_by_face[i+1].getNumber())
            && (i+2 >= combined.count || sorted_by_face[i].getNumber() != sorted_by_face[i+2].getNumber()) {
                one_pair_count += 1
                self.pairs.append(sorted_by_face[i])
            }
        }

        if three_of_a_kind && one_pair_count > 1 {
            return .fullHouse
        }

        var flush = [0,0,0,0]
        for i in 0..<combined.count {
            flush[combined[i].getSuit()] += 1
        }

        for i in 0..<flush.count {
            if flush[i] >= 5 {
                for j in 0..<combined.count {
                    if combined[j].getSuit() == i {
                        if self.flushes == nil {
                            self.flushes = combined[j]
                        } else if combined[j].getNumber() > self.flushes!.getNumber() {
                            self.flushes = combined[j]
                        }
                    }
                }
                return .flush
            }
        }

        for i in 0..<sorted_by_face.count {
            if i+4 < sorted_by_face.count
                && sorted_by_face[i].getNumber() + 1 == sorted_by_face[i+1].getNumber()
                && sorted_by_face[i].getNumber() + 2 == sorted_by_face[i+2].getNumber()
                && sorted_by_face[i].getNumber() + 3 == sorted_by_face[i+3].getNumber()
                && sorted_by_face[i].getNumber() + 4 == sorted_by_face[i+4].getNumber()
            {
                self.straights = sorted_by_face[i+4]
                return .straight
            }
        }

        if three_of_a_kind {
            return .threeOfAKind
        }

        if one_pair_count >= 2 {
            return .twoPair
        }

        if one_pair_count == 1 {
            return .onePair
        }

        return .highCard

    }

    var description: String {
        var description = ""
        switch board {
            case .preFlop:
                description = "Pre-flop"
            case .flop(let card1, let card2, let card3):
                description = "Flop: \(card1) \(card2) \(card3)"
            case .turn(let card1, let card2, let card3, let card4):
                description = "Turn: \(card1) \(card2) \(card3) \(card4)"
            case .river(let card1, let card2, let card3, let card4, let card5):
                description = "River: \(card1) \(card2) \(card3) \(card4) \(card5)"
        }

        return "\(hand.0) \(hand.1) | \(description)"
    }
}


struct Table : CustomStringConvertible , Hashable , Sendable {
    let board: GameState
    let players: [(Card, Card)]


    init(board: GameState, players: [(Card, Card)] = []) {
        self.board = board
        self.players = players
    }

    func comparePlayers(player1: (Card, Card), player2: (Card, Card)) -> Int {
        let hand1 = Hand(hand: player1, board: board)
        let hand2 = Hand(hand: player2, board: board)
        return Table.compareHands(hand1: hand1, hand2: hand2)
    }

    func checkConformityRange(answers: [Card], guesses: [Card], results: [PokleState], start: Int, end: Int) -> Bool {
        for i in start..<min(answers.count,end){
            if results[i] == .Yellow {
                if i < 3 {
                    if (answers[0].getNumber() != guesses[i].getNumber() 
                    && answers[0].getSuit() != guesses[i].getSuit()
                    && answers[1].getNumber() != guesses[i].getNumber()
                    && answers[1].getSuit() != guesses[i].getSuit()
                    && answers[2].getNumber() != guesses[i].getNumber()
                    && answers[2].getSuit() != guesses[i].getSuit())
                    || answers[0].number == guesses[i].number
                    || answers[1].number == guesses[i].number
                    || answers[2].number == guesses[i].number {
                        return false
                    }
                } else {
                    if (guesses[i].getNumber() != answers[i].getNumber() 
                    && guesses[i].getSuit() != answers[i].getSuit())
                    || guesses[i].number == answers[i].number {
                        return false
                    }
                }
            } else if results[i] == .Green {
                if i < 3 {
                    if answers[0].number != guesses[i].number 
                    && answers[1].number != guesses[i].number 
                    && answers[2].number != guesses[i].number {
                        return false
                    }
                } else {
                    if guesses[i].number != answers[i].number {
                        return false
                    }
                }
            } else if results[i] == .Gray {
                if i < 3 {
                    if answers[0].getNumber() == guesses[i].getNumber() 
                    || answers[0].getSuit() == guesses[i].getSuit() 
                    || answers[1].getNumber() == guesses[i].getNumber() 
                    || answers[1].getSuit() == guesses[i].getSuit() 
                    || answers[2].getNumber() == guesses[i].getNumber() 
                    || answers[2].getSuit() == guesses[i].getSuit() {
                        return false
                    }
                } else {
                    if guesses[i].getNumber() == answers[i].getNumber() 
                    || guesses[i].getSuit() == answers[i].getSuit() {
                        return false
                    }
                }
            }
        }
        return true
    }


    private func checkConformity(answers: [Card], guesses: [Card], results: [PokleState]) -> Bool {
        return checkConformityRange(answers: answers, guesses: guesses, results: results, start: 0, end: answers.count)
    }

    func conform(guess: Table, result: PokleResult) -> Bool {
        switch (self.board, guess.board) {
            case (.river(let answer_card1, let answer_card2, let answer_card3, let answer_card4, let answer_card5),
                  .river(let guessed_card1, let guessed_card2, let guessed_card3, let guessed_card4, let guessed_card5)):
                let guesses = [guessed_card1, guessed_card2, guessed_card3, guessed_card4, guessed_card5]
                let answers = [answer_card1, answer_card2, answer_card3, answer_card4, answer_card5]
                let results = [result.result.0, result.result.1, result.result.2, result.result.3, result.result.4]

                
                return checkConformity(answers: answers, guesses: guesses, results: results)
            
            case (.turn(let answer_card1, let answer_card2, let answer_card3, let answer_card4),
                  .turn(let guessed_card1, let guessed_card2, let guessed_card3, let guessed_card4)):
                let guesses = [guessed_card1, guessed_card2, guessed_card3, guessed_card4]
                let answers = [answer_card1, answer_card2, answer_card3, answer_card4]
                let results = [result.result.0, result.result.1, result.result.2, result.result.3]
            
                return checkConformity(answers: answers, guesses: guesses, results: results)

            case (.flop(let answer_card1, let answer_card2, let answer_card3),
                  .flop(let guessed_card1, let guessed_card2, let guessed_card3)):
                let guesses = [guessed_card1, guessed_card2, guessed_card3]
                let answers = [answer_card1, answer_card2, answer_card3]
                let results = [result.result.0, result.result.1, result.result.2]

                return checkConformity(answers: answers, guesses: guesses, results: results)

            default:
                return false
        }
    }


    static func getPokleResultFromAnswerAndGuess(answer: Table, guess: Table) -> PokleResult? {
        switch (answer.board, guess.board) {
            case (.river(let possible_card1, let possible_card2, let possible_card3, let possible_card4, let possible_card5),
                    .river(let guessed_card1, let guessed_card2, let guessed_card3, let guessed_card4, let guessed_card5)):
                let results = PokleResult(result: (
                    Card.getPokleStateFromAnswerAndGuess(answer: possible_card1, guess: guessed_card1),
                    Card.getPokleStateFromAnswerAndGuess(answer: possible_card2, guess: guessed_card2),
                    Card.getPokleStateFromAnswerAndGuess(answer: possible_card3, guess: guessed_card3),
                    Card.getPokleStateFromAnswerAndGuess(answer: possible_card4, guess: guessed_card4),
                    Card.getPokleStateFromAnswerAndGuess(answer: possible_card5, guess: guessed_card5)
                ))
                return results
            default:
                return nil
        }
    }

    private static func compareHighCard(hand1_sorted_by_face: [Card], hand2_sorted_by_face: [Card]) -> Int {
        let hand1_sorted_by_face = hand1_sorted_by_face.filter { card1 in 
            !hand2_sorted_by_face.contains(where: { card2 in card1.getNumber() == card2.getNumber() })
        }
        let hand2_sorted_by_face = hand2_sorted_by_face.filter { card1 in 
            !hand1_sorted_by_face.contains(where: { card2 in card1.getNumber() == card2.getNumber() })
        }

        if hand1_sorted_by_face.count == 0 {
            return 0
        }
        
        if hand2_sorted_by_face.count == 0 {
            return 0
        }

        return hand1_sorted_by_face[hand1_sorted_by_face.count - 1].getNumber() < hand2_sorted_by_face[hand2_sorted_by_face.count - 1].getNumber() ? 1 : -1
    }


    static func compareHands(hand1: Hand, hand2: Hand) -> Int {
        if hand1.getHandType() != hand2.getHandType() {
            return HandType.compare(hand1.getHandType(), hand2.getHandType())
        }

        var hand1_cards: [Card] = []
        var hand2_cards: [Card] = []
        switch hand1.board {
            case .preFlop:
                hand1_cards = [hand1.hand.0, hand1.hand.1]
            case .flop(let card1, let card2, let card3):
                hand1_cards = [hand1.hand.0, hand1.hand.1, card1, card2, card3]
            case .turn(let card1, let card2, let card3, let card4):
                hand1_cards = [hand1.hand.0, hand1.hand.1, card1, card2, card3, card4]
            case .river(let card1, let card2, let card3, let card4, let card5):
                hand1_cards = [hand1.hand.0, hand1.hand.1, card1, card2, card3, card4, card5]
        }
        switch hand2.board {
            case .preFlop:
                hand2_cards = [hand2.hand.0, hand2.hand.1]
            case .flop(let card1, let card2, let card3):
                hand2_cards = [hand2.hand.0, hand2.hand.1, card1, card2, card3]
            case .turn(let card1, let card2, let card3, let card4):
                hand2_cards = [hand2.hand.0, hand2.hand.1, card1, card2, card3, card4]
            case .river(let card1, let card2, let card3, let card4, let card5):
                hand2_cards = [hand2.hand.0, hand2.hand.1, card1, card2, card3, card4, card5]
        }

        let hand1_sorted_by_face = hand1_cards.sorted { $0.getNumber() < $1.getNumber() }
        let hand2_sorted_by_face = hand2_cards.sorted { $0.getNumber() < $1.getNumber() }

        if hand1.getHandType() == .highCard {
            return compareHighCard(hand1_sorted_by_face: hand1_sorted_by_face, hand2_sorted_by_face: hand2_sorted_by_face)
        }

        if hand1.getHandType() == .onePair {
            var hand1_max_pair = 0
            var hand2_max_pair = 0
            for i in 0..<hand1_sorted_by_face.count {
                if i+1 < hand1_sorted_by_face.count && hand1_sorted_by_face[i].getNumber() == hand1_sorted_by_face[i+1].getNumber() {
                    hand1_max_pair = hand1_sorted_by_face[i].getNumber()
                }
                if i+1 < hand2_sorted_by_face.count && hand2_sorted_by_face[i].getNumber() == hand2_sorted_by_face[i+1].getNumber() {
                    hand2_max_pair = hand2_sorted_by_face[i].getNumber()
                }
            }


            if hand1_max_pair == hand2_max_pair {
                return compareHighCard(hand1_sorted_by_face: hand1_sorted_by_face, hand2_sorted_by_face: hand2_sorted_by_face)
            }

            return hand1_max_pair < hand2_max_pair ? 1 : -1
        }

        if hand1.getHandType() == .twoPair {
            
            let hand1_sorted_pairs = hand1_sorted_by_face.filter { card in hand1.pairs.contains(where: { $0.number == card.number }) }
            let hand2_sorted_pairs = hand2_sorted_by_face.filter { card in hand2.pairs.contains(where: { $0.number == card.number }) }

            let hand1_max_pair = hand1_sorted_pairs.max { $0.getNumber() < $1.getNumber() }!.getNumber()
            let hand2_max_pair = hand2_sorted_pairs.max { $0.getNumber() < $1.getNumber() }!.getNumber()

            let hand1_second_pair = hand1_sorted_pairs.filter { $0.getNumber() != hand1_max_pair }.max { $0.getNumber() < $1.getNumber() }!.getNumber()
            let hand2_second_pair = hand2_sorted_pairs.filter { $0.getNumber() != hand2_max_pair }.max { $0.getNumber() < $1.getNumber() }!.getNumber()

            if hand1_max_pair == hand2_max_pair {
                if hand1_second_pair == hand2_second_pair {
                    return compareHighCard(hand1_sorted_by_face: hand1_sorted_by_face, hand2_sorted_by_face: hand2_sorted_by_face)
                }
                return hand1_second_pair < hand2_second_pair ? 1 : -1
            }

            return hand1_max_pair < hand2_max_pair ? 1 : -1
        }

        if hand1.getHandType() == .threeOfAKind {
            let hand1_sorted_three_of_a_kind = hand1_sorted_by_face.filter { card in hand1.three_of_a_kinds.contains(where: { $0.number == card.number }) }
            let hand2_sorted_three_of_a_kind = hand2_sorted_by_face.filter { card in hand2.three_of_a_kinds.contains(where: { $0.number == card.number }) }

            let hand1_max_three_of_a_kind = hand1_sorted_three_of_a_kind.max { $0.getNumber() < $1.getNumber() }!.getNumber()
            let hand2_max_three_of_a_kind = hand2_sorted_three_of_a_kind.max { $0.getNumber() < $1.getNumber() }!.getNumber()

            if hand1_max_three_of_a_kind == hand2_max_three_of_a_kind {
                return compareHighCard(hand1_sorted_by_face: hand1_sorted_by_face, hand2_sorted_by_face: hand2_sorted_by_face)
            }

            return hand1_max_three_of_a_kind < hand2_max_three_of_a_kind ? 1 : -1
        }
        
        if hand1.getHandType() == .straight {
            let hand1_straight_high = hand1.straights!.getNumber()
            let hand2_straight_high = hand2.straights!.getNumber()

            if hand1_straight_high == hand2_straight_high {
                // No kickers with straight
               return 0
            }

            return hand1_straight_high < hand2_straight_high ? 1 : -1
            
        }

        if hand1.getHandType() == .flush {
            let hand1_flush_high =  hand1.flushes!.getNumber()
            let hand2_flush_high = hand2.flushes!.getNumber()

            if hand1_flush_high == hand2_flush_high {
                // No kickers with flush
                return 0
            }

            return hand1_flush_high < hand2_flush_high ? 1 : -1
        }   

        if hand1.getHandType() == .fullHouse {
            // First compare the three of a kinds
            let hand1_three_of_a_kind_value = hand1.three_of_a_kinds.max { $0.getNumber() < $1.getNumber() }!.getNumber()
            let hand2_three_of_a_kind_value = hand2.three_of_a_kinds.max { $0.getNumber() < $1.getNumber() }!.getNumber()
            
            if hand1_three_of_a_kind_value != hand2_three_of_a_kind_value {
                // Higher three of a kind wins
                return hand1_three_of_a_kind_value < hand2_three_of_a_kind_value ? 1 : -1
            }
            
            // If three of a kinds are equal, compare the pairs
            // Find all pairs that aren't part of the three of a kind
            let hand1_pairs = hand1.pairs.filter { $0.getNumber() != hand1_three_of_a_kind_value }
                                      .max { $0.getNumber() < $1.getNumber() }
            let hand2_pairs = hand2.pairs.filter { $0.getNumber() != hand2_three_of_a_kind_value }
                                      .max { $0.getNumber() < $1.getNumber() }
            
            if let hand1_pair = hand1_pairs, let hand2_pair = hand2_pairs {
                if hand1_pair.getNumber() != hand2_pair.getNumber() {
                    // Higher pair wins
                    return hand1_pair.getNumber() < hand2_pair.getNumber() ? 1 : -1
                }
            }
            
            // If everything is equal
            return 0
        }

        if hand1.getHandType() == .fourOfAKind {
            let hand1_sorted_four_of_a_kind = hand1_sorted_by_face.filter { card in hand1.four_of_a_kinds.contains(where: { $0.number == card.number }) }
            let hand2_sorted_four_of_a_kind = hand2_sorted_by_face.filter { card in hand2.four_of_a_kinds.contains(where: { $0.number == card.number }) }

            let hand1_max_four_of_a_kind = hand1_sorted_four_of_a_kind.max { $0.getNumber() < $1.getNumber() }!.getNumber()
            let hand2_max_four_of_a_kind = hand2_sorted_four_of_a_kind.max { $0.getNumber() < $1.getNumber() }!.getNumber()

            if hand1_max_four_of_a_kind == hand2_max_four_of_a_kind {
                return compareHighCard(hand1_sorted_by_face: hand1_sorted_by_face, hand2_sorted_by_face: hand2_sorted_by_face)
            }

            return hand1_max_four_of_a_kind < hand2_max_four_of_a_kind ? 1 : -1
        }


        if hand1.getHandType() == .straightFlush {
            let hand1_straight_flush_high = hand1.straights!.getNumber()
            let hand2_straight_flush_high = hand2.straights!.getNumber()

            if hand1_straight_flush_high == hand2_straight_flush_high {
                return 0
            }

            return hand1_straight_flush_high < hand2_straight_flush_high ? 1 : -1
        }

        return 0
    }

    var description: String {
        var description = ""
        switch board {
            case .preFlop:
                description = "Pre-flop"
            case .flop(let card1, let card2, let card3):
                description = "Flop: \(card1) \(card2) \(card3)"
            case .turn(let card1, let card2, let card3, let card4):
                description = "Turn: \(card1) \(card2) \(card3) \(card4)"
            case .river(let card1, let card2, let card3, let card4, let card5):
                description = "River: \(card1) \(card2) \(card3) \(card4) \(card5)" 
        }
        description += "\n \(players)"
        return description
    }

    func shortDescription() -> String {
        switch board {
            case .preFlop:
                return " "
            case .flop(let card1, let card2, let card3):
                return "\(card1.number)\(card2.number)\(card3.number)"
            case .turn(let card1, let card2, let card3, let card4):
                return "\(card1.number)\(card2.number)\(card3.number)\(card4.number)"
            case .river(let card1, let card2, let card3, let card4, let card5):
                return "\(card1.number)\(card2.number)\(card3.number)\(card4.number)\(card5.number)"
        }

    }

    func toUniqueInt() -> Int {
        var cardNumbers: [Int] = []
        switch board {
            case .preFlop:
                cardNumbers = [0]
            case .flop(let card1, let card2, let card3):
                cardNumbers = [card1.number, card2.number, card3.number]
            case .turn(let card1, let card2, let card3, let card4):
                cardNumbers = [card1.number, card2.number, card3.number, card4.number]
            case .river(let card1, let card2, let card3, let card4, let card5):
                cardNumbers = [card1.number, card2.number, card3.number, card4.number, card5.number]
        }

        var num = 0

        for cardNumber in cardNumbers {
            num = num * 52 + cardNumber
        }

        return num
    }


    func hash(into hasher: inout Hasher) {
        hasher.combine(toUniqueInt())
    }

    static func == (lhs: Table, rhs: Table) -> Bool {
        return lhs.toUniqueInt() == rhs.toUniqueInt()
    }
}

class Trophies : CustomStringConvertible {
    var trophies: ((Int, Int, Int), (Int, Int, Int), (Int, Int, Int))

    init(trophies: ((Int, Int, Int), (Int, Int, Int), (Int, Int, Int))) {
        self.trophies = trophies
    }

    var description: String {
        return "\(trophies.0) \n \(trophies.1) \n \(trophies.2)"
    }
}

class Pokle : CustomStringConvertible {
    var player1: (Card, Card)
    var player2: (Card, Card)
    var player3: (Card, Card)
    var tables: [Table]
    var trophies: Trophies
    var history: [(Table, PokleResult)]

    init(player1: (Card, Card), player2: (Card, Card), player3: (Card, Card), trophies: Trophies) {
        self.player1 = player1
        self.player2 = player2
        self.player3 = player3
        self.trophies = trophies
        self.tables = []
        self.history = []
        self.findPossibleTables()
    }

    private func findPossibleTables() {
        let numbers = Array(0...51)
        let cardNumbers = [player1.0.number, player1.1.number, player2.0.number, player2.1.number, player3.0.number, player3.1.number
        ]

        let permutations = Array(numbers.filter { !cardNumbers.contains($0) }.permutations(ofCount: 3))

        let playersWithTrophies: [[(Int,(Card, Card))]] = [[(trophies.trophies.0.0,player1), (trophies.trophies.0.1,player2), (trophies.trophies.0.2,player3)],
                                                           [(trophies.trophies.1.0,player1), (trophies.trophies.1.1,player2), (trophies.trophies.1.2,player3)],
                                                           [(trophies.trophies.2.0,player1), (trophies.trophies.2.1,player2), (trophies.trophies.2.2,player3)]]

        for i in Progress(0..<permutations.count, configuration: [ProgressPercent(), ProgressBarLine(barLength: 70), ProgressTimeEstimates(), ProgressStringWithUpdate{ "Number Passing: \(self.tables.count)"}]){
           if !(permutations[i][0] < permutations[i][1] && permutations[i][1] < permutations[i][2]){
                continue
           }
           
           let table1 : Table = Table(board: GameState.flop(Card(number: permutations[i][0]), Card(number: permutations[i][1]), Card(number: permutations[i][2])))
    
            var zero_count = 0
            var sortedPlayers = playersWithTrophies[0].sorted { 
                let result = table1.comparePlayers(player1: $0.1, player2: $1.1)
                if result == 0 {
                    zero_count += 1
                }
                return result == 1
            }

            if zero_count > 0 || !(sortedPlayers[0].0 < sortedPlayers[1].0 && sortedPlayers[1].0 < sortedPlayers[2].0) {
                continue
            }

            let turns = numbers.filter { !cardNumbers.contains($0) }.filter { !permutations[i].contains($0) }

            for turn in turns {
                let table2 = Table(board: GameState.turn(Card(number: permutations[i][0]), Card(number: permutations[i][1]), Card(number: permutations[i][2]), Card(number: turn)))

                zero_count = 0
                sortedPlayers = playersWithTrophies[1].sorted { 
                    let result = table2.comparePlayers(player1: $0.1, player2: $1.1)
                    if result == 0 {
                        zero_count += 1
                    }
                    return result == 1
                }

                if zero_count > 0 || !(sortedPlayers[0].0 < sortedPlayers[1].0 && sortedPlayers[1].0 < sortedPlayers[2].0) {
                    continue
                }

                let rivers = numbers.filter { !cardNumbers.contains($0) }.filter { !permutations[i].contains($0) }.filter { turn != $0 }
                
                for river in rivers{
                    let table3 = Table(board: GameState.river(Card(number: permutations[i][0]), Card(number: permutations[i][1]), Card(number: permutations[i][2]), Card(number: turn), Card(number: river)))

                    zero_count = 0
                    sortedPlayers = playersWithTrophies[2].sorted { 
                        let result = table3.comparePlayers(player1: $0.1, player2: $1.1)
                            if result == 0 {
                            zero_count += 1
                        }
                        return result == 1
                    }


                    if zero_count > 0 || !(sortedPlayers[0].0 < sortedPlayers[1].0 && sortedPlayers[1].0 < sortedPlayers[2].0) {
                        continue
                    }


                    let table4 = Table(board: table3.board, players: sortedPlayers.map { $1 })

                    addTable(table: table4)
                }
            }
        }
    }

    func elimateTables(guess: Table, result: PokleResult) {
        history.append((guess, result))
        var newTables: [Table] = []

        for table: Table in tables {
            if table.conform(guess: guess, result: result) {
                newTables.append(table)
            }
        }

        tables = newTables
    }


    func getElimatedTables(answer: Table, guess: Table) -> Int {
        let result : PokleResult = Table.getPokleResultFromAnswerAndGuess(answer: answer, guess: guess) ?? PokleResult(result: (.Gray, .Gray, .Gray, .Gray, .Gray))
        var count = 0

        for table in tables {
            if answer.conform(guess: table, result: result) {
                count += 1
            }
        }

        return count
    }

    func getAverageElimatedTables(guess: Table) -> Double {
        var total = 0

        for table in tables {
            total += getElimatedTables(answer: table, guess: guess)
        }

        return Double(total) / Double(tables.count)
    }

    func getOptimalTable() async -> Table {
        //Computer sum of elimated tables for each result and answer
        

        var flopTable : [[[[Table]]]] = Array(repeating: Array(repeating: Array(repeating: [], count: 52), count: 52), count: 52)
        var uniqueFlops : [Table] = []

        var optimalTable: Table = tables[0]
        var maxSum = 0

        print("Starting to calculate flop table")

        for table in tables {
            if case let .river(card1, card2, card3, _, _) = table.board {
                if flopTable[card1.number][card2.number][card3.number].count == 0 {
                    let tempTable = Table(board: .flop(card1, card2, card3))
                    uniqueFlops.append(tempTable)
                }
                flopTable[card1.number][card2.number][card3.number].append(table)
            }
        }

        let flopTableLet = flopTable
        let uniqueFlopsLet = uniqueFlops

        print("Finished calculating flop table")
        print("Unique Flops: \(uniqueFlops.count)")

        var possibleResultList: [PokleResult] = []

        for answer in Progress(tables) {
            for guess in tables {
                if let result = Table.getPokleResultFromAnswerAndGuess(answer: answer, guess: guess) {            
                    possibleResultList.append(result)
                }
            }
        }

        let possibleResults = Set(possibleResultList)

        print("Starting to calculate elimation table")
        print("Possible Results: \(possibleResults.count)")

        
        let threads = 5
        var elimatedTables: [Table: [PokleResult: Int]] = [:]
        do {
            elimatedTables = try await withThrowingTaskGroup(of: [Table: [PokleResult: Int]].self, returning: [Table: [PokleResult: Int]].self) { group -> [Table: [PokleResult: Int]] in
                let uniqueFlopsList = uniqueFlopsLet.chunked(into: threads)
                for subUniqueFlops in uniqueFlopsList {
                    group.addTask {
                        var elimatedTables: [Table: [PokleResult: Int]] = [:]
                        for answerFlop in subUniqueFlops{
                            if case let .flop(answer_card1, answer_card2, answer_card3) = answerFlop.board {

                            let answerTables = flopTableLet[answer_card1.number][answer_card2.number][answer_card3.number]
                            var counts: [Int] = Array(repeating: 0, count: answerTables.count)

                            for result in possibleResults {      
                                let resultArray = [result.result.0, result.result.1, result.result.2, result.result.3, result.result.4]
                                
                                for guessFlop in uniqueFlopsLet {
                                    if case let .flop(guessed_card1, guessed_card2, guessed_card3) = guessFlop.board {
                                        let guessTables = flopTableLet[guessed_card1.number][guessed_card2.number][guessed_card3.number]
                                        
                                        if answerFlop.conform(guess: guessFlop, result: result) {
                                            for (index, answer) in answerTables.enumerated() {
                                                if case let .river(_, _, _, answer_card4, answer_card5) = answer.board {
                                                    for guess in guessTables {

                                                        if case let .river(_, _, _, guessed_card4, guessed_card5) = guess.board {
                                                            if !answer.checkConformityRange(answers: [answer_card1, answer_card2, answer_card3, answer_card4, answer_card5], guesses: [guessed_card1, guessed_card2, guessed_card3, guessed_card4, guessed_card5], results: resultArray, start: 3, end: 5) {
                                                                counts[index] += 1
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }else{
                                            for (index, _) in answerTables.enumerated() {
                                                counts[index] += guessTables.count
                                            }
                                        }
                                    }
                                }
                                for (index, count) in counts.enumerated() {
                                    var dictOfResults = elimatedTables[answerTables[index]] ?? [:]
                                    dictOfResults[result] = count
                                    elimatedTables[answerTables[index]] = dictOfResults
                                    counts[index] = 0
                                    }                   
                                }
                            }
                        }
                        return elimatedTables
                    }
                }

                var returnElimatedTables: [Table: [PokleResult: Int]] = [:]

                    for try await elimatedTables in group {
                        for (table, results) in elimatedTables {
                            var dictOfResults = elimatedTables[table] ?? [:]
                            for (result, count) in results {
                                dictOfResults[result] = count
                            }
                            returnElimatedTables[table] = dictOfResults
                        }
                    }
                return returnElimatedTables
            }
        } catch {
            print("Error: \(error)")
            return Table(board: .preFlop)
        }


        print("Finished calculating elimation table")

        //Find the table with the highest sum of elimated tables for each result

        for i in Progress(0..<tables.count, configuration: [ProgressPercent(), ProgressBarLine(barLength: 70), ProgressTimeEstimates(), ProgressStringWithUpdate{ "Best Hand: \(optimalTable.board) \(maxSum)"}]){
            let table = tables[i]

            var sum = 0
            for answer in tables{
                if let result = Table.getPokleResultFromAnswerAndGuess(answer: answer, guess: table) {
                    sum += (elimatedTables[answer] ?? [result: 0])[result] ?? 0
                }
            }

            if sum > maxSum {
                maxSum = sum
                optimalTable = table
            }
        }

        return optimalTable
    }


    func addTable(table: Table) {
        tables.append(table)
    }

    func saveTablesToFile() {
        // Create a dictionary representation of the Pokle state
        var pokleData: [String: Any] = [:]
        
        // Save player hands using card descriptions
        pokleData["player1"] = [player1.0.description, player1.1.description]
        pokleData["player2"] = [player2.0.description, player2.1.description]
        pokleData["player3"] = [player3.0.description, player3.1.description]
        
        // Save trophies
        pokleData["trophies"] = [
            [trophies.trophies.0.0, trophies.trophies.0.1, trophies.trophies.0.2],
            [trophies.trophies.1.0, trophies.trophies.1.1, trophies.trophies.1.2],
            [trophies.trophies.2.0, trophies.trophies.2.1, trophies.trophies.2.2]
        ]
        
        // Save tables using card descriptions
        var tablesData: [[String]] = []
        for table in tables {
            if case let .river(card1, card2, card3, card4, card5) = table.board {
                tablesData.append([card1.description, card2.description, card3.description, card4.description, card5.description])
            }
        }
        pokleData["tables"] = tablesData
        
        // Save history using card descriptions
        var historyData: [[[Any]]] = []
        for (table, result) in history {
            if case let .river(card1, card2, card3, card4, card5) = table.board {
                let tableData = [card1.description, card2.description, card3.description, card4.description, card5.description]
                let resultData = [
                    result.result.0 == .Green ? 2 : (result.result.0 == .Yellow ? 1 : 0),
                    result.result.1 == .Green ? 2 : (result.result.1 == .Yellow ? 1 : 0),
                    result.result.2 == .Green ? 2 : (result.result.2 == .Yellow ? 1 : 0),
                    result.result.3 == .Green ? 2 : (result.result.3 == .Yellow ? 1 : 0),
                    result.result.4 == .Green ? 2 : (result.result.4 == .Yellow ? 1 : 0)
                ]
                historyData.append([tableData, resultData])
            }
        }
        pokleData["history"] = historyData
        
        // Save to file
        let fileURL = URL(fileURLWithPath: "pokle_state.json")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: pokleData, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
            print("Successfully saved Pokle state to pokle_state.json")
        } catch {
            print("Error saving Pokle state: \(error)")
        }
    }



    static func createFromFile(filePath: String = "pokle_state.json") -> Pokle? {
        let fileURL = URL(fileURLWithPath: filePath)
        
        do {
            let jsonData = try Data(contentsOf: fileURL)
            guard let pokleData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                print("Error: Invalid JSON format")
                return nil
            }
            
            // Load player hands
            guard let player1Data = pokleData["player1"] as? [String],
                  let player2Data = pokleData["player2"] as? [String],
                  let player3Data = pokleData["player3"] as? [String],
                  player1Data.count == 2,
                  player2Data.count == 2,
                  player3Data.count == 2 else {
                print("Error: Invalid player data")
                return nil
            }
            
            let player1 = (Card.fromString(string: player1Data[0]), Card.fromString(string: player1Data[1]))
            let player2 = (Card.fromString(string: player2Data[0]), Card.fromString(string: player2Data[1]))
            let player3 = (Card.fromString(string: player3Data[0]), Card.fromString(string: player3Data[1]))
            
            // Load trophies
            guard let trophiesData = pokleData["trophies"] as? [[Int]],
                  trophiesData.count == 3,
                  trophiesData[0].count == 3,
                  trophiesData[1].count == 3,
                  trophiesData[2].count == 3 else {
                print("Error: Invalid trophies data")
                return nil
            }
            
            let trophiesObj = Trophies(trophies: (
                (trophiesData[0][0], trophiesData[0][1], trophiesData[0][2]),
                (trophiesData[1][0], trophiesData[1][1], trophiesData[1][2]),
                (trophiesData[2][0], trophiesData[2][1], trophiesData[2][2])))
            
            // Create Pokle instance
            let pokle = Pokle(player1: player1, player2: player2, player3: player3, trophies: trophiesObj)
            
            // Load tables
            if let tablesData = pokleData["tables"] as? [[String]] {
                pokle.tables = []  // Clear the default tables
                
                for tableData in tablesData {
                    if tableData.count == 5 {
                        let table = Table(board: .river(
                            Card.fromString(string: tableData[0]),
                            Card.fromString(string: tableData[1]),
                            Card.fromString(string: tableData[2]),
                            Card.fromString(string: tableData[3]),
                            Card.fromString(string: tableData[4])
                        ))
                        pokle.tables.append(table)
                    }
                }
            }
            
            // Load history
            if let historyData = pokleData["history"] as? [[[Any]]] {
                for entry in historyData {
                    if entry.count == 2, 
                       let tableData = entry[0] as? [String], tableData.count == 5,
                       let resultData = entry[1] as? [Int], resultData.count == 5 {
                        
                        let table = Table(board: .river(
                            Card.fromString(string: tableData[0]),
                            Card.fromString(string: tableData[1]),
                            Card.fromString(string: tableData[2]),
                            Card.fromString(string: tableData[3]),
                            Card.fromString(string: tableData[4])
                        ))
                        
                        let result = PokleResult(result: (
                            resultData[0] == 2 ? .Green : (resultData[0] == 1 ? .Yellow : .Gray),
                            resultData[1] == 2 ? .Green : (resultData[1] == 1 ? .Yellow : .Gray),
                            resultData[2] == 2 ? .Green : (resultData[2] == 1 ? .Yellow : .Gray),
                            resultData[3] == 2 ? .Green : (resultData[3] == 1 ? .Yellow : .Gray),
                            resultData[4] == 2 ? .Green : (resultData[4] == 1 ? .Yellow : .Gray)
                        ))
                        
                        pokle.history.append((table, result))
                    }
                }
            }
            
            print("Successfully loaded Pokle state from \(filePath)")
            return pokle
            
        } catch {
            print("Error loading Pokle state: \(error)")
            return nil
        }
    }

    var description: String {
        return "Player 1: \(player1) \n Player 2: \(player2) \n Player 3: \(player3) \n Trophies: \(trophies) \n Possiblities Remaining: \(tables.count)"
    }
}




// Add this function to parse command line arguments for hands
func parseHandsFromCommandLine() -> [(Card, Card)] {
    print("Enter three poker hands (format: 'A♠ K♥ 2♦ 6♣' for each hand):")
    var hands: [(Card, Card)] = []
    
    for i in 1...3 {
        print("Hand \(i): ", terminator: "")
        if let input = readLine()?.split(separator: " ").map(String.init) {
            if input.count == 2 {
                let card1 = Card.fromString(string: input[0])
                let card2 = Card.fromString(string: input[1])
                hands.append((card1, card2))
            } else {
                print("Invalid input format. Using default hand.")
                hands.append((Card.fromString(string: "A♠"), Card.fromString(string: "K♥")))
            }
        } else {
            print("Error reading input. Using default hand.")
            hands.append((Card.fromString(string: "A♠"), Card.fromString(string: "K♥")))
        }
    }
    
    return hands
}

// Add this function to parse rankings for each game state
func parseRankingsFromCommandLine() -> Trophies {
    print("\nEnter rankings for each game state (format: 'G,S,B' where letters represent trophy material):")
    var rankings: [[Int]] = []
    
    let stateNames = ["Flop", "Turn", "River"]
    
    for i in 0..<3 {
        print("\(stateNames[i]) rankings: ", terminator: "")
        if let input = readLine() {
            let parsedRanking = input.split(separator: ",")
                                    .map {
                                        if $0 == "G" {
                                            return 2
                                        } else if $0 == "S" {
                                            return 1
                                        } else if $0 == "B" {
                                            return 0
                                        } else {
                                            return i
                                        }
                                    }
            
            if parsedRanking.count == 3 {
                rankings.append(parsedRanking)
            } else {
                print("Invalid input format. Using default ranking.")
                rankings.append([0, 1, 2])
            }
        } else {
            print("Error reading input. Using default ranking.")
            rankings.append([0, 1, 2])
        }
    }
    
    return Trophies(trophies: ((rankings[0][0], rankings[0][1], rankings[0][2]),
                               (rankings[1][0], rankings[1][1], rankings[1][2]), 
                               (rankings[2][0], rankings[2][1], rankings[2][2])))
}

// Add this funcion to parse a Table
func parseTableFromCommandLine() -> Table {
    print("Enter a table (format: '6♠ 8♠ 9♥ 4♦ 7♠' for each hand):")
    if let input = readLine()?.split(separator: " ").map(String.init) {
        return Table(board: .river(Card.fromString(string: input[0]), Card.fromString(string: input[1]), Card.fromString(string: input[2]), Card.fromString(string: input[3]), Card.fromString(string: input[4])))
    }
    return Table(board: .preFlop)
}

// Add this function to parse a PokleResult from the command line
func parsePokleResultFromCommandLine() -> PokleResult {
    print("Enter a PokleResult Emoji or Y/G/B (example: 🟨🟨🟩🟩⬜ or YYGGB)")
    if let input = readLine() {
        return PokleResult.fromString(string: input)
    }
    return PokleResult(result: (.Gray, .Gray, .Gray, .Gray, .Gray))
}

// Add this function to parse command line arguments for input file
func parseInputFile(filePath: String) -> ([(Card, Card)], Trophies)? {
    do {
        let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = fileContents.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        guard lines.count >= 6 else {
            print("Error: Input file must contain at least 6 lines")
            return nil
        }
        
        // Parse hands
        var hands: [(Card, Card)] = []
        for i in 0..<3 {
            let handInput = lines[i].split(separator: " ").map(String.init)
            if handInput.count == 2 {
                let card1 = Card.fromString(string: handInput[0])
                let card2 = Card.fromString(string: handInput[1])
                hands.append((card1, card2))
            } else {
                print("Invalid hand format on line \(i+1). Using default hand.")
                hands.append((Card.fromString(string: "A♠"), Card.fromString(string: "K♥")))
            }
        }
        
        // Parse rankings
        var rankings: [[Int]] = []
        for i in 3..<6 {
            let rankingInput = lines[i].split(separator: ",").map(String.init)
            if rankingInput.count == 3 {
                let parsedRanking = rankingInput.map {
                    if $0 == "G" {
                        return 2
                    } else if $0 == "S" {
                        return 1
                    } else if $0 == "B" {
                        return 0
                    } else {
                        return i-3
                    }
                }
                rankings.append(parsedRanking)
            } else {
                print("Invalid ranking format on line \(i+1). Using default ranking.")
                rankings.append([0, 1, 2])
            }
        }
        
        let trophies = Trophies(trophies: (
            (rankings[0][0], rankings[0][1], rankings[0][2]),
            (rankings[1][0], rankings[1][1], rankings[1][2]),
            (rankings[2][0], rankings[2][1], rankings[2][2])
        ))
        
        return (hands, trophies)
    } catch {
        print("Error reading input file: \(error)")
        return nil
    }
}

print("Welcome to the Pokle Solver")

// Create and run the async task
let task = Task {
    // Check for input file flag
    var players: [(Card, Card)] = []
    var trophies: Trophies = Trophies(trophies: ((0, 1, 2), (0, 1, 2), (0, 1, 2)))
    var useInputFile = false

    let args = CommandLine.arguments
    if args.count > 1 && args[1] == "--input" && args.count > 2 {
        if let (parsedPlayers, parsedTrophies) = parseInputFile(filePath: args[2]) {
            players = parsedPlayers
            trophies = parsedTrophies
            useInputFile = true
            
            // Display the input for confirmation
            print("\nLoaded from file \(args[2]):")
            for i in 0..<players.count {
                print("Player \(i+1): \(players[i].0) \(players[i].1)")
            }
            
            print("\nRankings:")
            let stateNames = ["Flop", "Turn", "River"]
            print("\(stateNames[0]): \(trophies.trophies.0.0) \(trophies.trophies.0.1) \(trophies.trophies.0.2)")
            print("\(stateNames[1]): \(trophies.trophies.1.0) \(trophies.trophies.1.1) \(trophies.trophies.1.2)")
            print("\(stateNames[2]): \(trophies.trophies.2.0) \(trophies.trophies.2.1) \(trophies.trophies.2.2)")
        }
    }

    // If not using input file, get inputs from command line
    if !useInputFile {
        players = parseHandsFromCommandLine()
        trophies = parseRankingsFromCommandLine()
        
        // Display the input for confirmation
        print("\nYou entered:")
        for i in 0..<players.count {
            print("Player \(i+1): \(players[i].0) \(players[i].1)")
        }
        
        print("\nRankings:")
        let stateNames = ["Flop", "Turn", "River"]
        print("\(stateNames[0]): \(trophies.trophies.0.0) \(trophies.trophies.0.1) \(trophies.trophies.0.2)")
        print("\(stateNames[1]): \(trophies.trophies.1.0) \(trophies.trophies.1.1) \(trophies.trophies.1.2)")
        print("\(stateNames[2]): \(trophies.trophies.2.0) \(trophies.trophies.2.1) \(trophies.trophies.2.2)")
    }

    let pokle = Pokle(player1: players[0], player2: players[1], player3: players[2], trophies: trophies) 

    pokle.saveTablesToFile()

    // Parse a table from the command line
    for i in 0..<5 {
        let optimalTable = await pokle.getOptimalTable()
        print("Guess \(i+1), Optimal Table is \(optimalTable)")
        print("Give me your result from pokle")
        let result = parsePokleResultFromCommandLine()
        print("Entered Result: \(result)")
        if result == PokleResult(result: (.Green, .Green, .Green, .Green, .Green)) {
            print("You win!")
            break
        }
        let table = Table(board: optimalTable.board)
        pokle.elimateTables(guess: table, result: result)
        print("Possibilities Remaining: \(pokle.tables.count)")
        if pokle.tables.count == 0 {
            print("We lose! or invalid input!")
            break
        }
    }
}

// Wait for the task to complete
RunLoop.main.run(until: Date(timeIntervalSinceNow: 3600)) // Run for up to 1 hour










