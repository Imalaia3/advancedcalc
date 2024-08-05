## AdvancedCalc
**AdvancedCalc** is an arithmatic expression caclulator/interpreter written using the [Zig](https://ziglang.org/) programming language. It currently only supports basic mathematical operations and ordererd operations using parentheses. The algorithm is loosely based off of the [Shunting yard algorithm](https://en.wikipedia.org/wiki/Shunting_yard_algorithm), however it does not follow a specific implementation and some steps are approached differently. Please note that this is my first program written in Zig apart from the basic hello world.
## Execution + Compilation
To compile: `zig build-exe main.zig`

To run without generating an EXE: `zig run main.zig`

To use:
- Generate / Run program with the above commands.
- Type expression in the command line when prompted to.

## Capabilities

 - **Integer** Addition, Subtraction, Multiplication and Division
 - Raise to the power of an exponent using the  ^  symbol
 - Seperation of operations using parentheses
