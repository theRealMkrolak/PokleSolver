enum GameState: Sendable {
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

struct Table: CustomStringConvertible, Hashable, Sendable {
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

    static func getPokleResultFromAnswerAndGuess(answer: Table, guess: Table) -> PokleResult? {
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
                answer: possible_card2, guess: guessed_card1) == .Yellow
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

    private static func compareHighCard(hand1_sorted_by_face: [Card], hand2_sorted_by_face: [Card])
        -> Int
    {
        let hand1_sorted_by_face = hand1_sorted_by_face.filter { card1 in
            !hand2_sorted_by_face.contains(where: { card2 in card1.getNumber() == card2.getNumber()
            })
        }
        let hand2_sorted_by_face = hand2_sorted_by_face.filter { card1 in
            !hand1_sorted_by_face.contains(where: { card2 in card1.getNumber() == card2.getNumber()
            })
        }

        if hand1_sorted_by_face.count == 0 {
            return 0
        }

        if hand2_sorted_by_face.count == 0 {
            return 0
        }

        return hand1_sorted_by_face[hand1_sorted_by_face.count - 1].getNumber()
            < hand2_sorted_by_face[hand2_sorted_by_face.count - 1].getNumber() ? 1 : -1
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
            return compareHighCard(
                hand1_sorted_by_face: hand1_sorted_by_face,
                hand2_sorted_by_face: hand2_sorted_by_face)
        }

        if hand1.getHandType() == .onePair {
            var hand1_max_pair = 0
            var hand2_max_pair = 0
            for i in 0..<hand1_sorted_by_face.count {
                if i + 1 < hand1_sorted_by_face.count
                    && hand1_sorted_by_face[i].getNumber()
                        == hand1_sorted_by_face[i + 1].getNumber()
                {
                    hand1_max_pair = hand1_sorted_by_face[i].getNumber()
                }
                if i + 1 < hand2_sorted_by_face.count
                    && hand2_sorted_by_face[i].getNumber()
                        == hand2_sorted_by_face[i + 1].getNumber()
                {
                    hand2_max_pair = hand2_sorted_by_face[i].getNumber()
                }
            }

            if hand1_max_pair == hand2_max_pair {
                return compareHighCard(
                    hand1_sorted_by_face: hand1_sorted_by_face,
                    hand2_sorted_by_face: hand2_sorted_by_face)
            }

            return hand1_max_pair < hand2_max_pair ? 1 : -1
        }

        if hand1.getHandType() == .twoPair {

            let hand1_sorted_pairs = hand1_sorted_by_face.filter { card in
                hand1.pairs.contains(where: { $0.number == card.number })
            }
            let hand2_sorted_pairs = hand2_sorted_by_face.filter { card in
                hand2.pairs.contains(where: { $0.number == card.number })
            }

            let hand1_max_pair = hand1_sorted_pairs.max { $0.getNumber() < $1.getNumber() }!
                .getNumber()
            let hand2_max_pair = hand2_sorted_pairs.max { $0.getNumber() < $1.getNumber() }!
                .getNumber()

            let hand1_second_pair = hand1_sorted_pairs.filter { $0.getNumber() != hand1_max_pair }
                .max { $0.getNumber() < $1.getNumber() }!.getNumber()
            let hand2_second_pair = hand2_sorted_pairs.filter { $0.getNumber() != hand2_max_pair }
                .max { $0.getNumber() < $1.getNumber() }!.getNumber()

            if hand1_max_pair == hand2_max_pair {
                if hand1_second_pair == hand2_second_pair {
                    return compareHighCard(
                        hand1_sorted_by_face: hand1_sorted_by_face,
                        hand2_sorted_by_face: hand2_sorted_by_face)
                }
                return hand1_second_pair < hand2_second_pair ? 1 : -1
            }

            return hand1_max_pair < hand2_max_pair ? 1 : -1
        }

        if hand1.getHandType() == .threeOfAKind {
            let hand1_sorted_three_of_a_kind = hand1_sorted_by_face.filter { card in
                hand1.three_of_a_kinds.contains(where: { $0.number == card.number })
            }
            let hand2_sorted_three_of_a_kind = hand2_sorted_by_face.filter { card in
                hand2.three_of_a_kinds.contains(where: { $0.number == card.number })
            }

            let hand1_max_three_of_a_kind = hand1_sorted_three_of_a_kind.max {
                $0.getNumber() < $1.getNumber()
            }!.getNumber()
            let hand2_max_three_of_a_kind = hand2_sorted_three_of_a_kind.max {
                $0.getNumber() < $1.getNumber()
            }!.getNumber()

            if hand1_max_three_of_a_kind == hand2_max_three_of_a_kind {
                return compareHighCard(
                    hand1_sorted_by_face: hand1_sorted_by_face,
                    hand2_sorted_by_face: hand2_sorted_by_face)
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
            let hand1_flush_high = hand1.flushes!.getNumber()
            let hand2_flush_high = hand2.flushes!.getNumber()
            if hand1_flush_high == hand2_flush_high {
                // No kickers with flush
                return 0
            }

            return hand1_flush_high < hand2_flush_high ? 1 : -1
        }

        if hand1.getHandType() == .fullHouse {
            // First compare the three of a kinds
            let hand1_three_of_a_kind_value = hand1.three_of_a_kinds.max {
                $0.getNumber() < $1.getNumber()
            }!.getNumber()
            let hand2_three_of_a_kind_value = hand2.three_of_a_kinds.max {
                $0.getNumber() < $1.getNumber()
            }!.getNumber()

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
            let hand1_sorted_four_of_a_kind = hand1_sorted_by_face.filter { card in
                hand1.four_of_a_kinds.contains(where: { $0.number == card.number })
            }
            let hand2_sorted_four_of_a_kind = hand2_sorted_by_face.filter { card in
                hand2.four_of_a_kinds.contains(where: { $0.number == card.number })
            }

            let hand1_max_four_of_a_kind = hand1_sorted_four_of_a_kind.max {
                $0.getNumber() < $1.getNumber()
            }!.getNumber()
            let hand2_max_four_of_a_kind = hand2_sorted_four_of_a_kind.max {
                $0.getNumber() < $1.getNumber()
            }!.getNumber()

            if hand1_max_four_of_a_kind == hand2_max_four_of_a_kind {
                return compareHighCard(
                    hand1_sorted_by_face: hand1_sorted_by_face,
                    hand2_sorted_by_face: hand2_sorted_by_face)
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

    func hash(into hasher: inout Hasher) {
        hasher.combine(toUniqueInt())
    }

    static func == (lhs: Table, rhs: Table) -> Bool {
        return lhs.toUniqueInt() == rhs.toUniqueInt()
    }
}
