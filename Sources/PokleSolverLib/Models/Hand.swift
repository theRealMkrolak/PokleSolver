import Algorithms
import Foundation

public enum HandType {
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

public class Hand: CustomStringConvertible {
    let hand: (Card, Card)
    let board: GameState

    public var handType: HandType? = nil
    var pairs: [Card] = []
    var three_of_a_kinds: [Card] = []
    var four_of_a_kinds: [Card] = []
    var straights: Card? = nil
    var flushes: Card? = nil

    public init(hand: (Card, Card), board: GameState) {
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
        let sorted_by_face_unique = Array(Set(sorted_by_face.map { $0.getNumber() })).sorted {
            $0 < $1
        }
        let sorted_by_face_ace = sorted_by_face_unique.map { $0 % 13 }.sorted { $0 < $1 }

        // Handle straight flush with ace low
        for i in 0..<combined.count {
            if i + 4 < sorted_by_number.count
                && sorted_by_number[i].number + 1 == sorted_by_number[i + 1].number
                && sorted_by_number[i].number + 2 == sorted_by_number[i + 2].number
                && sorted_by_number[i].number + 3 == sorted_by_number[i + 3].number
                && sorted_by_number[i].number + 4 == sorted_by_number[i + 4].number
                && sorted_by_number[i].getSuit() == sorted_by_number[i + 4].getSuit()
            {
                self.straights = sorted_by_number[i + 4]
                return .straightFlush
            }
        }

        // Handle straight flush with ace high
        for i in 0..<combined.count {
            if sorted_by_number[i].getNumber() == 13 {
                for j in i + 1..<combined.count {
                    if j + 3 < combined.count
                        && sorted_by_number[j].number == sorted_by_number[i].number + 9
                        && sorted_by_number[j + 1].number == sorted_by_number[i].number + 10
                        && sorted_by_number[j + 2].number == sorted_by_number[i].number + 11
                        && sorted_by_number[j + 3].number == sorted_by_number[i].number + 12
                    {
                        self.straights = sorted_by_number[i]
                        return .straightFlush
                    }
                }
            }
        }

        for i in 0..<combined.count {
            if i + 3 < combined.count
                && sorted_by_face[i].getNumber() == sorted_by_face[i + 3].getNumber()
            {
                self.four_of_a_kinds.append(sorted_by_face[i])
                return .fourOfAKind
            }
        }

        var three_of_a_kind = false
        var one_pair_count = 0
        for i in 0..<combined.count {
            if i + 2 < combined.count
                && sorted_by_face[i].getNumber() == sorted_by_face[i + 2].getNumber()
            {
                self.three_of_a_kinds.append(sorted_by_face[i])
                three_of_a_kind = true
            }

            if (i + 1 < combined.count
                && sorted_by_face[i].getNumber() == sorted_by_face[i + 1].getNumber())
                && (i + 2 >= combined.count
                    || sorted_by_face[i].getNumber() != sorted_by_face[i + 2].getNumber())
            {
                one_pair_count += 1
                self.pairs.append(sorted_by_face[i])
            }
        }

        if three_of_a_kind && one_pair_count > 1 {
            return .fullHouse
        }

        var flush = [0, 0, 0, 0]
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

        // Handle straight with ace high
        for i in 0..<sorted_by_face_unique.count {
            if i + 4 < sorted_by_face_unique.count
                && sorted_by_face_unique[i] + 1 == sorted_by_face_unique[i + 1]
                && sorted_by_face_unique[i] + 2 == sorted_by_face_unique[i + 2]
                && sorted_by_face_unique[i] + 3 == sorted_by_face_unique[i + 3]
                && sorted_by_face_unique[i] + 4 == sorted_by_face_unique[i + 4]

            {
                self.straights = sorted_by_number.first {
                    $0.getNumber() == sorted_by_face_unique[i + 4]
                }
                return .straight
            }
        }

        // Handle straight with ace low
        for i in 0..<sorted_by_face_ace.count {
            if i + 4 < sorted_by_face_ace.count
                && sorted_by_face_ace[i] + 1 == sorted_by_face_ace[i + 1]
                && sorted_by_face_ace[i] + 2 == sorted_by_face_ace[i + 2]
                && sorted_by_face_ace[i] + 3 == sorted_by_face_ace[i + 3]
                && sorted_by_face_ace[i] + 4 == sorted_by_face_ace[i + 4]

            {
                self.straights = sorted_by_face.first {
                    $0.getNumber() == sorted_by_face_ace[i + 4]
                }
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

    public static func compareHands(hand1: Hand, hand2: Hand) -> Int {
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

    public var description: String {
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
