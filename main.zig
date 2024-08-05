///////////////////////////////////////////////////////
// An expression evaluator that is loosely based off //
// of the Shunting Yard Algorithm                    //
///////////////////////////////////////////////////////

const std = @import("std");
const debug = std.debug;
///const stdin = std.io.getStdIn().reader();
//var stdout = std.io.getStdOut().writer();



const TokenType = enum {
    num,
    add,
    mul,
    sub,
    div,
    pow,
    EOF
};

const Token = struct {
    group: TokenType,
    value: i32,
    depth: u32
};

const CalcError = error {
    InvalidCharError,
    ImportanceUnavailable,
    UnoperableTokenType,
    NegativeDepthValue,
    DepthNoReturnToZero
};

//FIXME: instead of arraylist we can return []Token and deinit in tokenize() instead of in main()
pub fn tokenize(alloc: std.mem.Allocator ,in:[] const u8) !std.ArrayList(Token) {
    var token_array = std.ArrayList(Token).init(alloc);
    var current_depth: u32 = 0;


    var i: usize = 0;
    while (i < in.len) : (i+=1){

        if (in[i] == '(') {
            current_depth += 1;
            continue;
        }
        if (in[i] == ')') {
            if (current_depth == 0) {
                return CalcError.NegativeDepthValue;
            }

            current_depth -= 1;
            continue;
        }
        
        //FIXME: this if else-switch can be condensed into a switch using (0,1,2,3,4,5,6,7,8,9=>)
        if (std.ascii.isDigit(in[i])) {
            const start = i;
            while (i < in.len and std.ascii.isDigit(in[i])) { i+=1; }
            i-=1;

            try token_array.append(Token{
                .group = TokenType.num,
                .value = try std.fmt.parseInt(i32,in[start..(i+1)],10),
                .depth = current_depth
            });
        } else {
            const tok_type: TokenType = switch (in[i]) {
                '+'  => TokenType.add,
                '-'  => TokenType.sub,
                '*'  => TokenType.mul,
                '/'  => TokenType.div,
                '^'  => TokenType.pow,
                else => return CalcError.InvalidCharError
            };
            try token_array.append(Token{
                .group = tok_type,
                .value = 0,
                .depth = current_depth
            });
        }

    }

    if (current_depth > 0) { return CalcError.DepthNoReturnToZero; }

    return token_array;
}

pub fn getTokImportance(t: Token) !u32 {
    const base_importance: u32 = switch (t.group) {
      TokenType.add, TokenType.sub => 1,
      TokenType.div, TokenType.mul => 2,
      TokenType.pow => 3,
      TokenType.EOF => 0, // 0 so everything is more important
      TokenType.num => return CalcError.ImportanceUnavailable 
    };
    return base_importance + (10*t.depth);
}

pub fn doOperation(a: i32, op: TokenType, b: i32) !i32 {
    return switch (op) {
        TokenType.add => a + b,
        TokenType.sub => a - b,
        TokenType.mul => a * b,
        TokenType.pow => std.math.pow(i32, a, b),
        TokenType.div => @divFloor(a, b),
        TokenType.num, TokenType.EOF => return CalcError.UnoperableTokenType
    };
}

pub fn calculate(allloc: std.mem.Allocator, tokens: std.ArrayList(Token)) !i32 {   
    
    var ops = std.ArrayList(Token).init(allloc);
    defer ops.deinit();
    var nums = std.ArrayList(i32).init(allloc);
    defer nums.deinit();
    
    for (tokens.items) |tok| {
        if (tok.group == TokenType.num) {
            try nums.append(tok.value);
            continue;
        }

        while (ops.items.len > 0) {
            if (try getTokImportance(ops.getLast()) >= try getTokImportance(tok)) {
                const otherTok = ops.pop();
                const b = nums.pop();
                const a = nums.pop();
                try nums.append(try doOperation(a,otherTok.group,b));
            }
            else { break; }
        }
        try ops.append(tok);


        debug.print("Stacks after iteration:\nNums: [", .{});
        for (nums.items) |n| { debug.print("{d},", .{n}); }
        debug.print("]\nOps: [", .{});
        for (ops.items) |n| { debug.print("{s},", .{@tagName(n.group)}); }
        debug.print("]\n", .{});
    }

    return nums.getLast();
}


pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    // EXPRESSION DEFINED HERE
    try stdout.print("Enter expression: ", .{});

    const expression_raw = try stdin.readUntilDelimiterAlloc(std.heap.page_allocator,
        '\n',
        8192,
    );
    const expression = std.mem.trim(u8, expression_raw, "\r");
    defer std.heap.page_allocator.free(expression_raw);
    
    
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    
    try stdout.print("Parsing...\n", .{});
    var tokens = try tokenize(arena_allocator.allocator(),expression);
    defer tokens.deinit();
    try tokens.append(Token{
        .group = TokenType.EOF,
        .value = 0,
        .depth = 0
    });


    debug.print("Listing all parsed tokens:\n", .{});
    for (tokens.items) |tok| {
        debug.print("Token: type = {s}, value = {d}, \tdepth = {d}\n", .{
            @tagName(tok.group),
            tok.value,
            tok.depth
        });
    }

    try stdout.print("Performing calculation...\n", .{});
    const result = try calculate(arena_allocator.allocator(),tokens);
    try stdout.print("Expression has been evaluated successfully!\n", .{});
    try stdout.print("{s} = {d}\n", .{expression,result});

}
