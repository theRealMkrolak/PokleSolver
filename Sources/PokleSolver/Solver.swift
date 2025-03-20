import Algorithms
import ArgumentParser
import Foundation
import PokleSolverLib

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
            print(pokle.description)
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
                print(optimalTable.description)
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
