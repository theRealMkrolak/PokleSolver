import Algorithms
import ArgumentParser
import Foundation

//Structure of input json
struct DailyInput: Decodable {
    let solution: String
    let hands: String
    let trophies: String
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
    print(
        "\nEnter rankings for each game state (format: 'G,S,B' where letters represent trophy material):"
    )
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

    return Trophies(
        trophies: (
            (rankings[0][0], rankings[0][1], rankings[0][2]),
            (rankings[1][0], rankings[1][1], rankings[1][2]),
            (rankings[2][0], rankings[2][1], rankings[2][2])
        ))
}

// Add this funcion to parse a Table
func parseTableFromCommandLine() -> Table {
    print("Enter a table (format: '6♠ 8♠ 9♥ 4♦ 7♠' for each hand):")
    if let input = readLine()?.split(separator: " ").map(String.init) {
        return Table(
            board: .river(
                Card.fromString(string: input[0]), Card.fromString(string: input[1]),
                Card.fromString(string: input[2]), Card.fromString(string: input[3]),
                Card.fromString(string: input[4])))
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

func parseHand(hand: String) -> (Card, Card) {
    let card1 = Card.fromString(string: hand.split(separator: " ")[0].description)
    let card2 = Card.fromString(string: hand.split(separator: " ")[1].description)
    return (card1, card2)
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
            hands.append(parseHand(hand: lines[i]))
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
                        return i - 3
                    }
                }
                rankings.append(parsedRanking)
            } else {
                print("Invalid ranking format on line \(i+1). Using default ranking.")
                rankings.append([0, 1, 2])
            }
        }

        let trophies = Trophies(
            trophies: (
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

func parseDailyInput(filePath: String, index: Int) -> (Table, [(Card, Card)], Trophies)? {
    do {
        let jsonData = try Data(contentsOf: URL(fileURLWithPath: filePath))
        let decoder = JSONDecoder()
        let dailyInputs = try decoder.decode([DailyInput].self, from: jsonData)
        guard index < dailyInputs.count else {
            print("Error: Index out of bounds")
            // Return some default values or throw an error
            return (
                Table(board: .preFlop), [], Trophies(trophies: ((0, 1, 2), (0, 1, 2), (0, 1, 2)))
            )
        }

        let jsonDict = dailyInputs[index]

        // Parse hands
        var handsArray: [(Card, Card)] = []
        let splitHands = jsonDict.hands.split(separator: " ")
        for i in 0..<3 {
            let hand = splitHands[i * 2] + " " + splitHands[i * 2 + 1]
            handsArray.append(parseHand(hand: String(hand)))
        }

        // Parse solution table
        let solutionCards = jsonDict.solution.split(separator: " ")
        let solutionTable = Table(
            board: .river(
                Card.fromString(string: solutionCards[0].description),
                Card.fromString(string: solutionCards[1].description),
                Card.fromString(string: solutionCards[2].description),
                Card.fromString(string: solutionCards[3].description),
                Card.fromString(string: solutionCards[4].description)
            ))

        // Parse trophies
        var trophiesArray: [Int] = []
        for trophy in jsonDict.trophies.split(separator: " ") {
            trophiesArray.append(3 - Int(trophy)!)
        }

        return (
            solutionTable, handsArray,
            Trophies(
                trophies: (
                    (trophiesArray[0], trophiesArray[1], trophiesArray[2]),
                    (trophiesArray[3], trophiesArray[4], trophiesArray[5]),
                    (trophiesArray[6], trophiesArray[7], trophiesArray[8])
                ))
        )
    } catch {
        return nil
    }
}

func getGameNumber() -> Int {
    let referenceDate = DateComponents(
        calendar: Calendar.current, timeZone: TimeZone.current, year: 2022, month: 7, day: 5
    ).date!

    let referenceTimeInterval = referenceDate.timeIntervalSince1970 * 1000
    let currentTimeInterval = Date().timeIntervalSince1970 * 1000

    let oneDayInMilliseconds: Double = 86_400_000

    let adjustedReferenceTimeInterval = referenceTimeInterval

    let daysDifference = Int(
        (currentTimeInterval - adjustedReferenceTimeInterval) / oneDayInMilliseconds)

    return daysDifference
}

struct Options: ParsableArguments {
    @Flag(help: "Enable verbose output")
    var verbose: Bool = false

    @Option(help: "The input file path")
    var inputFilePath: String?

    @Flag(help: "Save output to file")
    var outputFile: Bool = false
}

struct Daily: AsyncParsableCommand {

    @Option(help: "Pokle Number")
    var pokleNumber: Int = getGameNumber()

    @OptionGroup var options: Options

    mutating func run() async throws {
        // Implement daily command logic here
        var players: [(Card, Card)] = []
        var solution: Table
        var trophies: Trophies = Trophies(trophies: ((0, 1, 2), (0, 1, 2), (0, 1, 2)))
        var inputFilePath: String

        if let inputOption = options.inputFilePath {
            inputFilePath = inputOption
        } else {
            print("No input file provided")
            return
        }

        if let (solutionDaily, parsedPlayers, parsedTrophies) = parseDailyInput(
            filePath: inputFilePath, index: pokleNumber)
        {
            solution = solutionDaily
            players = parsedPlayers
            trophies = parsedTrophies
        } else {
            print("Failed to parse input file")
            return
        }

        let pokle = Pokle(
            player1: players[0], player2: players[1], player3: players[2], trophies: trophies,
            verbose: options.verbose)

        var won = false

        var output = ""

        var results: [PokleResult] = []

        for i in 0..<5 {
            let optimalTable = await pokle.getOptimalTable()
            let result: PokleResult =
                Table.getPokleResultFromAnswerAndGuess(answer: solution, guess: optimalTable)
                ?? PokleResult(result: (.Gray, .Gray, .Gray, .Gray, .Gray))
            pokle.elimateTables(guess: optimalTable, result: result)

            output +=
                "Guess \(i+1): \(optimalTable.board), Result: \(result), Possibilities Remaining: \(pokle.tables.count)\n"
            results.append(result)
            if result == PokleResult(result: (.Green, .Green, .Green, .Green, .Green)) {
                output += "Won in \(i+1) guesses 🎉"
                won = true
                break
            }

            if pokle.tables.count == 0 {
                output += "Invalid input! \n"
                break
            }
        }
        if !won {
            output += "I lost today! 🤖"
        }

        if options.verbose {
            print(output)
        }

        print("#Pokle #\(pokleNumber)")
        for i in 0..<results.count {
            print(results[i])
        }
        print("poklegame.com")
        return

    }
}

struct Solve: AsyncParsableCommand {
    @OptionGroup var options: Options

    mutating func run() async throws {
        var players: [(Card, Card)] = []
        var trophies: Trophies = Trophies(trophies: ((0, 1, 2), (0, 1, 2), (0, 1, 2)))

        if let inputFilePath = options.inputFilePath,
            let (parsedPlayers, parsedTrophies) = parseInputFile(filePath: inputFilePath)
        {
            players = parsedPlayers
            trophies = parsedTrophies

        } else {
            players = parseHandsFromCommandLine()
            trophies = parseRankingsFromCommandLine()

        }

        if options.verbose {
            // Display the input for confirmation
            for i in 0..<players.count {
                print("Player \(i+1): \(players[i].0) \(players[i].1)")
            }

            print("\nRankings:")
            print(trophies)
        }

        let pokle = Pokle(
            player1: players[0], player2: players[1], player3: players[2], trophies: trophies,
            verbose: options.verbose)

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
}

@main
struct PokleSolver: AsyncParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "A tool for solving the game of pokle",
        subcommands: [Solve.self, Daily.self],
        defaultSubcommand: Solve.self
    )

}
