module fbeg::demo::expr::AST

import fbeg::demo::expr::Syntax;

import ParseTree;

data Prog = prog(list[Expr] exprs, Expr ret);

data Expr = nat(int n)
          | var(str name)
          | add(Expr lhs, Expr rhs)
          | sub(Expr lhs, Expr rhs)
          | mul(Expr lhs, Expr rhs)
          | div(Expr lhs, Expr rhs)
          | assign(str name, Expr val)
          ;

Prog parseProg(loc l) = implode(#Prog, parse(#start[Prog], l));