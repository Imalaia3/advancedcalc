## AdvancedCalc
**AdvancedCalc** is an arithmatic expression caclulator/interpreter written using the Zig programming language. It currently only supports basic mathematical operations and ordererd operations using parentheses. The algorithm is loosely based off of the Shunting yard algorithm, however it does not follow a specific implementation and some steps are approached differently. Please note that this is my first program written in Zig apart from the basic hello world.
## Execution + Compilation
**Note: Sadly,  stdout and stdin do not work in Windows, so the expression is hardcoded in the main() function. Next commit should address this issue.**

To compile: `zig build-exe main,zig`
To run without generating an EXE `zig run main.zig`

## Capabilities

 - **Integer** Addition, Subtraction, Multiplication and Division
 - Seperation of operations using parentheses
