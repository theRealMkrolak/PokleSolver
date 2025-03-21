# PokleSolver

A command-line tool for solving the game of Pokle (poklegame.com).

## Overview

PokleSolver is a Swift-based tool that helps solve Pokle puzzles. It can either solve the daily Pokle challenge or help you interactively solve a custom Pokle puzzle.

## Features

- Solve the daily Pokle puzzle
- Solve custom Pokle puzzles
- Calculate optimal guesses based on remaining possibilities
- Track the number of remaining possibilities after each guess
- Generate output for sharing your results

## Installation

Clone the repository and build the project using Swift Package Manager:

```bash
git clone https://github.com/yourusername/PokleSolver.git
cd PokleSolver
swift build -c release
```

## Usage

### Solving the Daily Pokle

```bash
.build/release/PokleSolver daily --pokle-number <number> --input-file-path <path>
```

Options:

- `--pokle-number`: Specify the Pokle number (defaults to current day's number)
- `--input-file-path`: Path to the input file containing Pokle data (example: daily.json which contains the daily Pokle data)
- `--verbose`: Enable detailed output
- `--output-file`: Save results to a file

### Interactive Solving

```bash
.build/release/PokleSolver
```

Options:

- `--input-file-path`: Path to the input file containing player hands and trophies
- `--verbose`: Enable detailed output
- `--output-file`: Save results to a file

If no input file is provided, you'll be prompted to enter player hands and rankings via the command line.

## Input File Format

The input file should contain the player hands and trophy information in a specific format. See the sample input files in the repository for examples.

## Output

The tool provides optimal guesses and tracks the number of remaining possibilities after each guess. In verbose mode, it displays detailed information about the solving process.

When solving the daily puzzle, it also generates shareable output for posting your results.

## Dependencies

- ArgumentParser
- Foundation
- Algorithms

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

This is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

PokleSolver is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
