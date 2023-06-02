module fbeg::demo::expr::Syntax

extend lang::std::Layout;

lexical Ident = [a-zA-Z][a-zA-Z0-9]* !>> [a-zA-Z0-9];
lexical Natural = [0-9]+ !>> [0-9];

start syntax Prog = prog: (Expr ";")* "return" Expr;

syntax Expr = nat: Natural
            | var: Ident
            | bracket "(" Expr ")"
            > non-assoc (
                  mul: Expr "*" Expr
                | div: Expr "/" Expr
            )
            > left (
                  add: Expr "+" Expr
                | sub: Expr "-" Expr
            )
            > right assign: Ident "=" Expr
            ;