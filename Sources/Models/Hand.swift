import Algorithms
import Foundation

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

class Hand: CustomStringConvertible {
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
