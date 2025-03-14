class Trophies: CustomStringConvertible {
    var trophies: ((Int, Int, Int), (Int, Int, Int), (Int, Int, Int))

    init(trophies: ((Int, Int, Int), (Int, Int, Int), (Int, Int, Int))) {
        self.trophies = trophies
    }

    private func intToString(nat: Int) -> String {
        if nat == 0 {
            return "B"
        } else if nat == 1 {
            return "S"
        } else {
            return "G"
        }
    }

    var description: String {
        let firstRow =
            "\(intToString(nat: trophies.0.0)),\(intToString(nat: trophies.0.1)),\(intToString(nat: trophies.0.2))"
        let secondRow =
            "\(intToString(nat: trophies.1.0)),\(intToString(nat: trophies.1.1)),\(intToString(nat: trophies.1.2))"
        let thirdRow =
            "\(intToString(nat: trophies.2.0)),\(intToString(nat: trophies.2.1)),\(intToString(nat: trophies.2.2))"
        return "\n\(firstRow)\n\(secondRow)\n\(thirdRow)"
    }
}
