import PokleSolverLib
import Testing

@Suite("HandTest")
class HandTest {

    @Test("Test Hand Ace 3 of a kind")
    func testHand1() {
        let ace1 = Card.fromString(string:"As")
        let ace2 = Card.fromString(string:"Ah")
        let ace3 = Card.fromString(string:"Ac")

        let six1 = Card.fromString(string:"6s")
        let six2 = Card.fromString(string:"6h")
        let six3 = Card.fromString(string:"6c")

        let two = Card.fromString(string:"2s")
        let three = Card.fromString(string:"3s")
        let four = Card.fromString(string:"4s")

        let hand1 = Hand(hand: (ace1, ace2), board: GameState.river(two, three, four, ace3, six3))
        let hand2 = Hand(hand: (six1, six2), board: GameState.river(two, three, four, ace3, six3))

        #expect(hand1.handType == HandType.threeOfAKind)
        #expect(hand2.handType == HandType.threeOfAKind)
        #expect(Hand.compareHands(hand1:hand1, hand2:hand2) == -1)
    }

    @Test("Test Hand Ace full house")
    func testHand2() {
        let ace1 = Card.fromString(string:"As")
        let ace2 = Card.fromString(string:"Ah")
        let ace3 = Card.fromString(string:"Ac")

        let six1 = Card.fromString(string:"6s")
        let six2 = Card.fromString(string:"6h")
        let six3 = Card.fromString(string:"6c")

        let two = Card.fromString(string:"2s")
        let three = Card.fromString(string:"3s")
        let four1 = Card.fromString(string:"4s")
        let four2 = Card.fromString(string:"4c")

        let hand1 = Hand(hand: (ace1, four1), board: GameState.river(two, four2, ace2, ace3, six3))
        let hand2 = Hand(hand: (six1, six2), board: GameState.river(two, four2, ace2, ace3, six3))

        #expect(Hand.compareHands(hand1:hand1, hand2:hand2) == -1)
    }
}
