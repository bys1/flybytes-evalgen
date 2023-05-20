module fbeg::demo::func::Syntax

extend lang::std::Layout;

lexical Ident = [a-zA-Z][a-zA-Z0-9]* !>> [a-zA-Z0-9];
lexical Natural = [0-9]+ !>> [0-9];

start syntax Prog = prog: Func*;

syntax Func = func: Ident name "(" {Ident ","}* ")" "=" Exp;

syntax Exp  = let:  "let" {Binding ","}* "in" Exp "end"
            | xcond: "if" Exp "then" Exp "else" Exp "end"
            | loop: "while" Exp "do" Exp "then" Exp "end"
            | bracket "(" Exp ")"
            | var: Ident
            | nat: Natural
            | call: Ident "(" {Exp ","}* ")"
            > non-assoc (
                  left      mul: Exp "*" Exp
                | non-assoc div: Exp "/" Exp
            )
            > left (
                  left add: Exp "+" Exp
                | left sub: Exp "-" Exp
            )
            > non-assoc (
                  non-assoc gt: Exp "\>" Exp
                | non-assoc lt: Exp "\<" Exp
                | non-assoc geq: Exp "\>=" Exp
                | non-assoc leq: Exp "\<=" Exp
            )
            > right assign: Ident ":=" Exp
            > right seq: Exp ";" Exp
            ;

syntax Binding = binding: Ident "=" Exp;