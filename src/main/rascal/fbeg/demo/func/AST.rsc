module fbeg::demo::func::AST

import ParseTree;

import fbeg::demo::func::Syntax;

data Prog(loc src = |unknown:///|)
    = prog(list[Func] funcs)
    ;

data Func(loc src = |unknown:///|)
    = func(str name, list[str] args, Expr exp)
    ;

data Expr(loc src = |unknown:///|)
    = let(list[Binding] bindings, Expr exp)
    | xcond(Expr condition, Expr then, Expr alt)
    | loop(Expr condition, Expr then, Expr result)
    | var(str name)
    | avar(str name, Expr index)
    | nat(int n)
    | call(str name, list[Expr] args)
    | add(Expr lhs, Expr rhs)
    | sub(Expr lhs, Expr rhs)
    | mul(Expr lhs, Expr rhs)
    | div(Expr lhs, Expr rhs)
    |  eq(Expr lhs, Expr rhs)
    | neq(Expr lhs, Expr rhs)
    | gt (Expr lhs, Expr rhs)
    | lt (Expr lhs, Expr rhs)
    | geq(Expr lhs, Expr rhs)
    | leq(Expr lhs, Expr rhs)
    | assign(str name, Expr exp)
    | aassign(str name, Expr index, Expr exp)
    | seq(Expr lhs, Expr rhs)
    ;

data Binding(loc src = |unknown:///|)
    = binding(str ident, Expr exp)
    | array(str ident, Expr size)
    ;

/**
 *  Parses the program at the given location to an AST.
 */
Prog parseProg(loc l) = implode(#Prog, parse(#start[Prog], l));