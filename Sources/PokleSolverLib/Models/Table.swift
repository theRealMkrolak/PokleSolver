public enum GameState: Sendable {
    case preFlop
    case flop(Card, Card, Card)
    case turn(Card, Card, Card, Card)
    case river(Card, Card, Card, Card, Card)

    static func compare(_ board1: GameState, _ board2: GameState) -> Bool {
        switch (board1, board2) {
        case (.preFlop, .preFlop):
            return true
        case (
            .flop(let hand1card1, let hand1card2, let hand1card3),
            .flop(let hand2card1, let hand2card2, let hand2card3)
        ):
            return Card.compare(card1: hand1card1, card2: hand2card1)
                && Card.compare(card1: hand1card2, card2: hand2card2)
                && Card.compare(card1: hand1card3, card2: hand2card3)
        case (
            .turn(let hand1card1, let hand1card2, let hand1card3, let hand1card4),
            .turn(let hand2card1, let hand2card2, let hand2card3, let hand2card4)
        ):
            return Card.compare(card1: hand1card1, card2: hand2card1)
                && Card.compare(card1: hand1card2, card2: hand2card2)
                && Card.compare(card1: hand1card3, card2: hand2card3)
                && Card.compare(card1: hand1card4, card2: hand2card4)
        case (
            .river(let hand1card1, let hand1card2, let hand1card3, let hand1card4, let hand1card5),
            .river(let hand2card1, let hand2card2, let hand2card3, let hand2card4, let hand2card5)
        ):
            return Card.compare(card1: hand1card1, card2: hand2card1)
                && Card.compare(card1: hand1card2, card2: hand2card2)
                && Card.compare(card1: hand1card3, card2: hand2card3)
                && Card.compare(card1: hand1card4, card2: hand2card4)
                && Card.compare(card1: hand1card5, card2: hand2card5)
        default:
            return false
        }
    }

    var description: String {
        var description = ""
        switch self {
        case .preFlop:
            description = "Pre-flop"
        case .flop(let card1, let card2, let card3):
            description = "Flop: \(card1) \(card2) \(card3)"
        case .turn(let card1, let card2, let card3, let card4):
            description = "Turn: \(card1) \(card2) \(card3) \(card4)"
        case .river(let card1, let card2, let card3, let card4, let card5):
            description = "River: \(card1) \(card2) \(card3) \(card4) \(card5)"
        }
        return description
    }
}

public struct Table: CustomStringConvertible, Hashable, Sendable {
    public let board: GameState
    public let players: [(Card, Card)]

    public init(board: GameState, players: [(Card, Card)] = []) {
        self.board = board
        self.players = players
    }

    func comparePlayers(player1: (Card, Card), player2: (Card, Card)) -> Int {
        let hand1 = Hand(hand: player1, board: board)
        let hand2 = Hand(hand: player2, board: board)
        return Hand.compareHands(hand1: hand1, hand2: hand2)
    }

    func checkConformityRange(
        answers: [Card], guesses: [Card], results: [PokleState], start: Int, end: Int
    ) -> Bool {
        for i in start..<min(answers.count, end) {
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
                        || answers[2].number == guesses[i].number
                    {
                        return false
                    }
                } else {
                    if (guesses[i].getNumber() != answers[i].getNumber()
                        && guesses[i].getSuit() != answers[i].getSuit())
                        || guesses[i].number == answers[i].number
                    {
                        return false
                    }
                }
            } else if results[i] == .Green {
                if i < 3 {
                    if answers[0].number != guesses[i].number
                        && answers[1].number != guesses[i].number
                        && answers[2].number != guesses[i].number
                    {
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
                        || answers[2].getSuit() == guesses[i].getSuit()
                    {
                        return false
                    }
                } else {
                    if guesses[i].getNumber() == answers[i].getNumber()
                        || guesses[i].getSuit() == answers[i].getSuit()
                    {
                        return false
                    }
                }
            }
        }
        return true
    }

    private func checkConformity(answers: [Card], guesses: [Card], results: [PokleState]) -> Bool {
        return checkConformityRange(
            answers: answers, guesses: guesses, results: results, start: 0, end: answers.count)
    }

    func conform(guess: Table, result: PokleResult) -> Bool {
        switch (self.board, guess.board) {
        case (
            .river(
                let answer_card1, let answer_card2, let answer_card3, let answer_card4,
                let answer_card5),
            .river(
                let guessed_card1, let guessed_card2, let guessed_card3, let guessed_card4,
                let guessed_card5)
        ):
            let guesses = [
                guessed_card1, guessed_card2, guessed_card3, guessed_card4, guessed_card5,
            ]
            let answers = [answer_card1, answer_card2, answer_card3, answer_card4, answer_card5]
            let results = [
                result.result.0, result.result.1, result.result.2, result.result.3, result.result.4,
            ]

            return checkConformity(answers: answers, guesses: guesses, results: results)

        case (
            .turn(let answer_card1, let answer_card2, let answer_card3, let answer_card4),
            .turn(let guessed_card1, let guessed_card2, let guessed_card3, let guessed_card4)
        ):
            let guesses = [guessed_card1, guessed_card2, guessed_card3, guessed_card4]
            let answers = [answer_card1, answer_card2, answer_card3, answer_card4]
            let results = [result.result.0, result.result.1, result.result.2, result.result.3]

            return checkConformity(answers: answers, guesses: guesses, results: results)

        case (
            .flop(let answer_card1, let answer_card2, let answer_card3),
            .flop(let guessed_card1, let guessed_card2, let guessed_card3)
        ):
            let guesses = [guessed_card1, guessed_card2, guessed_card3]
            let answers = [answer_card1, answer_card2, answer_card3]
            let results = [result.result.0, result.result.1, result.result.2]

            return checkConformity(answers: answers, guesses: guesses, results: results)

        default:
            return false
        }
    }

    public static func getPokleResultFromAnswerAndGuess(answer: Table, guess: Table) -> PokleResult?
    {
        switch (answer.board, guess.board) {
        case (
            .river(
                let possible_card1, let possible_card2, let possible_card3, let possible_card4,
                let possible_card5),
            .river(
                let guessed_card1, let guessed_card2, let guessed_card3, let guessed_card4,
                let guessed_card5)
        ):

            var spot1: PokleState = .Gray
            if Card.getPokleStateFromAnswerAndGuess(answer: possible_card1, guess: guessed_card1)
                == .Green
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card2, guess: guessed_card1) == .Green
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card3, guess: guessed_card1) == .Green
            {
                spot1 = .Green
            } else if Card.getPokleStateFromAnswerAndGuess(
                answer: possible_card1, guess: guessed_card1) == .Yellow
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card2, guess: guessed_card1) == .Yellow
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card3, guess: guessed_card1) == .Yellow
            {
                spot1 = .Yellow
            }

            var spot2: PokleState = .Gray
            if Card.getPokleStateFromAnswerAndGuess(answer: possible_card1, guess: guessed_card2)
                == .Green
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card2, guess: guessed_card2) == .Green
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card3, guess: guessed_card2) == .Green
            {
                spot2 = .Green
            } else if Card.getPokleStateFromAnswerAndGuess(
                answer: possible_card2, guess: guessed_card2) == .Yellow
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card1, guess: guessed_card2) == .Yellow
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card3, guess: guessed_card2) == .Yellow
            {
                spot2 = .Yellow
            }

            var spot3: PokleState = .Gray
            if Card.getPokleStateFromAnswerAndGuess(answer: possible_card1, guess: guessed_card3)
                == .Green
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card2, guess: guessed_card3) == .Green
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card3, guess: guessed_card3) == .Green
            {
                spot3 = .Green
            } else if Card.getPokleStateFromAnswerAndGuess(
                answer: possible_card1, guess: guessed_card3) == .Yellow
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card2, guess: guessed_card3) == .Yellow
                || Card.getPokleStateFromAnswerAndGuess(
                    answer: possible_card3, guess: guessed_card3) == .Yellow
            {
                spot3 = .Yellow
            }

            let results = PokleResult(
                result: (
                    spot1,
                    spot2,
                    spot3,
                    Card.getPokleStateFromAnswerAndGuess(
                        answer: possible_card4, guess: guessed_card4),
                    Card.getPokleStateFromAnswerAndGuess(
                        answer: possible_card5, guess: guessed_card5)
                ))
            return results
        default:
            return nil
        }
    }

    public var description: String {
        var description = board.description
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

    public func hash(into hasher: inout Hasher) {
        hasher.combine(toUniqueInt())
    }

    public static func == (lhs: Table, rhs: Table) -> Bool {
        return lhs.toUniqueInt() == rhs.toUniqueInt()
    }
}
