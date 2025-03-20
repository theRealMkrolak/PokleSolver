import Algorithms
import Foundation
import Progress

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        var chunks: [[Element]] = [[Element]](repeating: [Element](), count: size)
        var arr = self[0..<self.count]
        while !arr.isEmpty {
            for i in 0..<size {
                if let element = arr.last {
                    chunks[i].append(element)
                    arr = arr[0..<arr.count - 1]
                }
            }
        }
        return chunks
    }
}

struct ProgressBarTerminalPrinter: ProgressBarPrinter {
    var lastPrintedTime = 0.0

    init() {
        // the cursor is moved up before printing the progress bar.
        // have to move the cursor down one line initially.
        print("")
    }

    mutating func display(_ progressBar: ProgressBar) {
        let currentTime = getTimeOfDay()
        if currentTime - lastPrintedTime > 0.1 || progressBar.index == progressBar.count {
            print("\u{1B}[1A\u{1B}[K\(progressBar.value)")
            lastPrintedTime = currentTime
        }
    }
}

struct SendableProgressGroup<G: Sequence>: @unchecked Sendable {
    var progressGroup: ProgressGroup<G>

    init(progress: ProgressGroup<G>) {
        self.progressGroup = progress
    }

    public func getProgressGroup() -> ProgressGroup<G> {
        return self.progressGroup
    }
}

enum PokleState: CustomStringConvertible, Sendable {
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

struct PokleResult: CustomStringConvertible, Hashable {
    var result: (PokleState, PokleState, PokleState, PokleState, PokleState)

    var description: String {
        return "\(result.0)\(result.1)\(result.2)\(result.3)\(result.4)"
    }

    static func fromString(string: String) -> PokleResult {
        return PokleResult(
            result: (
                PokleState.fromString(string: String(string[string.startIndex])),
                PokleState.fromString(
                    string: String(string[string.index(string.startIndex, offsetBy: 1)])),
                PokleState.fromString(
                    string: String(string[string.index(string.startIndex, offsetBy: 2)])),
                PokleState.fromString(
                    string: String(string[string.index(string.startIndex, offsetBy: 3)])),
                PokleState.fromString(
                    string: String(string[string.index(string.startIndex, offsetBy: 4)]))
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

class Pokle: CustomStringConvertible {
    var player1: (Card, Card)
    var player2: (Card, Card)
    var player3: (Card, Card)
    var tables: [Table]
    var trophies: Trophies
    var history: [(Table, PokleResult)]
    var verbose: Bool

    init(
        player1: (Card, Card), player2: (Card, Card), player3: (Card, Card), trophies: Trophies,
        verbose: Bool = false
    ) {
        self.player1 = player1
        self.player2 = player2
        self.player3 = player3
        self.trophies = trophies
        self.tables = []
        self.history = []
        self.verbose = verbose
        self.findPossibleTables()
    }

    private func findPossibleTables() {
        let numbers = Array(0...51)
        let cardNumbers = [
            player1.0.number, player1.1.number, player2.0.number, player2.1.number,
            player3.0.number, player3.1.number,
        ]

        let permutations = Array(
            numbers.filter { !cardNumbers.contains($0) }.permutations(ofCount: 3))

        let playersWithTrophies: [[(Int, (Card, Card))]] = [
            [
                (trophies.trophies.0.0, player1), (trophies.trophies.0.1, player2),
                (trophies.trophies.0.2, player3),
            ],
            [
                (trophies.trophies.1.0, player1), (trophies.trophies.1.1, player2),
                (trophies.trophies.1.2, player3),
            ],
            [
                (trophies.trophies.2.0, player1), (trophies.trophies.2.1, player2),
                (trophies.trophies.2.2, player3),
            ],
        ]

        var seq: any Sequence<Int> = 0..<permutations.count
        if verbose {
            seq = Progress(
                0..<permutations.count,
                configuration: [
                    ProgressPercent(), ProgressBarLine(barLength: 70), ProgressTimeEstimates(),
                    ProgressStringWithUpdate { "Number Passing: \(self.tables.count)" },
                ])
        }

        for i in seq {
            if !(permutations[i][0] < permutations[i][1] && permutations[i][1] < permutations[i][2])
            {
                continue
            }

            let table1: Table = Table(
                board: GameState.flop(
                    Card(number: permutations[i][0]), Card(number: permutations[i][1]),
                    Card(number: permutations[i][2])))

            var zero_count = 0
            var sortedPlayers = playersWithTrophies[0].sorted {
                let result = table1.comparePlayers(player1: $0.1, player2: $1.1)
                if result == 0 {
                    zero_count += 1
                }
                return result == 1
            }

            if zero_count > 0
                || !(sortedPlayers[0].0 < sortedPlayers[1].0
                    && sortedPlayers[1].0 < sortedPlayers[2].0)
            {
                continue
            }

            let turns = numbers.filter { !cardNumbers.contains($0) }.filter {
                !permutations[i].contains($0)
            }

            for turn in turns {
                let table2 = Table(
                    board: GameState.turn(
                        Card(number: permutations[i][0]), Card(number: permutations[i][1]),
                        Card(number: permutations[i][2]), Card(number: turn)))

                zero_count = 0
                sortedPlayers = playersWithTrophies[1].sorted {
                    let result = table2.comparePlayers(player1: $0.1, player2: $1.1)
                    if result == 0 {
                        zero_count += 1
                    }
                    return result == 1
                }

                if zero_count > 0
                    || !(sortedPlayers[0].0 < sortedPlayers[1].0
                        && sortedPlayers[1].0 < sortedPlayers[2].0)
                {
                    continue
                }

                let rivers = numbers.filter { !cardNumbers.contains($0) }.filter {
                    !permutations[i].contains($0)
                }.filter { turn != $0 }

                for river in rivers {
                    let table3 = Table(
                        board: GameState.river(
                            Card(number: permutations[i][0]), Card(number: permutations[i][1]),
                            Card(number: permutations[i][2]), Card(number: turn),
                            Card(number: river)))

                    zero_count = 0
                    sortedPlayers = playersWithTrophies[2].sorted {
                        let result = table3.comparePlayers(player1: $0.1, player2: $1.1)
                        if result == 0 {
                            zero_count += 1
                        }
                        return result == 1
                    }

                    if zero_count > 0
                        || !(sortedPlayers[0].0 < sortedPlayers[1].0
                            && sortedPlayers[1].0 < sortedPlayers[2].0)
                    {
                        continue
                    }

                    let table4 = Table(board: table3.board, players: sortedPlayers.map { $1 })

                    addTable(table: table4)
                }
            }
        }

        if verbose {
            print("Possible Hands 🃏: \(tables.count)")
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
        let result: PokleResult =
            Table.getPokleResultFromAnswerAndGuess(answer: answer, guess: guess)
            ?? PokleResult(result: (.Gray, .Gray, .Gray, .Gray, .Gray))
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

        var flopTable: [[[[Table]]]] = Array(
            repeating: Array(repeating: Array(repeating: [], count: 52), count: 52), count: 52)
        var uniqueFlops: [Table] = []

        var optimalTable: Table = tables[0]
        var maxSum = 0

        var tableSequence: any Sequence<Table> = tables
        if verbose {
            print("Calculating optimal table...")
            tableSequence = Progress(tables)
        }

        for table in tableSequence {
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

        var possibleResultList: [PokleResult] = []

        tableSequence = tables
        print("Creating Possible Results List...")
        if verbose {
            tableSequence = Progress(tables)
        }

        for answer in tableSequence {
            for guess in tables {
                if let result = Table.getPokleResultFromAnswerAndGuess(answer: answer, guess: guess)
                {
                    possibleResultList.append(result)
                }
            }
        }

        let possibleResults = Set(possibleResultList)

        let threads = 5
        let verbose = self.verbose
        var elimatedTables: [Table: [PokleResult: Int]] = [:]
        do {
            elimatedTables = try await withThrowingTaskGroup(
                of: [Table: [PokleResult: Int]].self, returning: [Table: [PokleResult: Int]].self
            ) { group -> [Table: [PokleResult: Int]] in

                let uniqueFlopsList = uniqueFlopsLet.chunked(into: threads)
                for subUniqueFlops in uniqueFlopsList {
                    group.addTask {
                        var elimatedTables: [Table: [PokleResult: Int]] = [:]
                        for answerFlop in subUniqueFlops {
                            if case let .flop(answer_card1, answer_card2, answer_card3) = answerFlop
                                .board
                            {

                                let answerTables = flopTableLet[answer_card1.number][
                                    answer_card2.number][answer_card3.number]
                                var counts: [Int] = Array(repeating: 0, count: answerTables.count)

                                for result in possibleResults {
                                    let resultArray = [
                                        result.result.0, result.result.1, result.result.2,
                                        result.result.3, result.result.4,
                                    ]

                                    for guessFlop in uniqueFlopsLet {
                                        if case let .flop(
                                            guessed_card1, guessed_card2, guessed_card3) = guessFlop
                                            .board
                                        {
                                            let guessTables = flopTableLet[guessed_card1.number][
                                                guessed_card2.number][guessed_card3.number]

                                            if answerFlop.conform(guess: guessFlop, result: result)
                                            {
                                                for (index, answer) in answerTables.enumerated() {
                                                    if case let .river(
                                                        _, _, _, answer_card4, answer_card5) =
                                                        answer.board
                                                    {
                                                        for guess in guessTables {

                                                            if case let .river(
                                                                _, _, _, guessed_card4,
                                                                guessed_card5) = guess.board
                                                            {
                                                                if !answer.checkConformityRange(
                                                                    answers: [
                                                                        answer_card1, answer_card2,
                                                                        answer_card3, answer_card4,
                                                                        answer_card5,
                                                                    ],
                                                                    guesses: [
                                                                        guessed_card1,
                                                                        guessed_card2,
                                                                        guessed_card3,
                                                                        guessed_card4,
                                                                        guessed_card5,
                                                                    ], results: resultArray,
                                                                    start: 3, end: 5)
                                                                {
                                                                    counts[index] += 1
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                for (index, _) in answerTables.enumerated() {
                                                    counts[index] += guessTables.count
                                                }
                                            }
                                        }
                                    }
                                    for (index, count) in counts.enumerated() {
                                        var dictOfResults =
                                            elimatedTables[answerTables[index]] ?? [:]
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
                var printer = ProgressBarTerminalPrinter()
                var bar = ProgressBar(
                    count: threads,
                    configuration: [
                        ProgressPercent(), ProgressBarLine(barLength: 70),
                        ProgressTimeEstimates(),
                    ], printer: printer)
                for try await elimatedTables in group {
                    if verbose {
                        bar.next()
                        printer.display(bar)
                    }

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
            return Table(board: .preFlop)
        }

        //Find the table with the highest sum of elimated tables for each result

        for i in 0..<tables.count {
            let table = tables[i]

            var sum = 0
            for answer in tables {
                if let result = Table.getPokleResultFromAnswerAndGuess(answer: answer, guess: table)
                {
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
            [trophies.trophies.2.0, trophies.trophies.2.1, trophies.trophies.2.2],
        ]

        // Save tables using card descriptions
        var tablesData: [[String]] = []
        for table in tables {
            if case let .river(card1, card2, card3, card4, card5) = table.board {
                tablesData.append([
                    card1.description, card2.description, card3.description, card4.description,
                    card5.description,
                ])
            }
        }
        pokleData["tables"] = tablesData

        // Save history using card descriptions
        var historyData: [[[Any]]] = []
        for (table, result) in history {
            if case let .river(card1, card2, card3, card4, card5) = table.board {
                let tableData = [
                    card1.description, card2.description, card3.description, card4.description,
                    card5.description,
                ]
                let resultData = [
                    result.result.0 == .Green ? 2 : (result.result.0 == .Yellow ? 1 : 0),
                    result.result.1 == .Green ? 2 : (result.result.1 == .Yellow ? 1 : 0),
                    result.result.2 == .Green ? 2 : (result.result.2 == .Yellow ? 1 : 0),
                    result.result.3 == .Green ? 2 : (result.result.3 == .Yellow ? 1 : 0),
                    result.result.4 == .Green ? 2 : (result.result.4 == .Yellow ? 1 : 0),
                ]
                historyData.append([tableData, resultData])
            }
        }
        pokleData["history"] = historyData

        // Save to file
        let fileURL = URL(fileURLWithPath: "pokle_state.json")
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: pokleData, options: .prettyPrinted)
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
            guard let pokleData = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            else {
                print("Error: Invalid JSON format")
                return nil
            }

            // Load player hands
            guard let player1Data = pokleData["player1"] as? [String],
                let player2Data = pokleData["player2"] as? [String],
                let player3Data = pokleData["player3"] as? [String],
                player1Data.count == 2,
                player2Data.count == 2,
                player3Data.count == 2
            else {
                print("Error: Invalid player data")
                return nil
            }

            let player1 = (
                Card.fromString(string: player1Data[0]), Card.fromString(string: player1Data[1])
            )
            let player2 = (
                Card.fromString(string: player2Data[0]), Card.fromString(string: player2Data[1])
            )
            let player3 = (
                Card.fromString(string: player3Data[0]), Card.fromString(string: player3Data[1])
            )

            // Load trophies
            guard let trophiesData = pokleData["trophies"] as? [[Int]],
                trophiesData.count == 3,
                trophiesData[0].count == 3,
                trophiesData[1].count == 3,
                trophiesData[2].count == 3
            else {
                print("Error: Invalid trophies data")
                return nil
            }

            let trophiesObj = Trophies(
                trophies: (
                    (trophiesData[0][0], trophiesData[0][1], trophiesData[0][2]),
                    (trophiesData[1][0], trophiesData[1][1], trophiesData[1][2]),
                    (trophiesData[2][0], trophiesData[2][1], trophiesData[2][2])
                ))

            // Create Pokle instance
            let pokle = Pokle(
                player1: player1, player2: player2, player3: player3, trophies: trophiesObj)

            // Load tables
            if let tablesData = pokleData["tables"] as? [[String]] {
                pokle.tables = []  // Clear the default tables

                for tableData in tablesData {
                    if tableData.count == 5 {
                        let table = Table(
                            board: .river(
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
                        let resultData = entry[1] as? [Int], resultData.count == 5
                    {

                        let table = Table(
                            board: .river(
                                Card.fromString(string: tableData[0]),
                                Card.fromString(string: tableData[1]),
                                Card.fromString(string: tableData[2]),
                                Card.fromString(string: tableData[3]),
                                Card.fromString(string: tableData[4])
                            ))

                        let result = PokleResult(
                            result: (
                                resultData[0] == 2
                                    ? .Green : (resultData[0] == 1 ? .Yellow : .Gray),
                                resultData[1] == 2
                                    ? .Green : (resultData[1] == 1 ? .Yellow : .Gray),
                                resultData[2] == 2
                                    ? .Green : (resultData[2] == 1 ? .Yellow : .Gray),
                                resultData[3] == 2
                                    ? .Green : (resultData[3] == 1 ? .Yellow : .Gray),
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
        return
            "Player 1: \(player1) \n Player 2: \(player2) \n Player 3: \(player3) \n Trophies: \(trophies) \n Possiblities Remaining: \(tables.count)"
    }
}
