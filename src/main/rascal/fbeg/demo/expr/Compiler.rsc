module fbeg::demo::expr::Compiler

import lang::flybytes::Syntax;
import lang::flybytes::Compiler;

import fbeg::demo::expr::AST;

void compileProg(Prog p, str name) {
    compileClass(compile(p, name), |cwd:///<name>.class|);
}

Class compile(prog(list[Expr] exprs, Expr ret), str name) = class(
    object(name),
    methods = [main(
        "args",
        [compile(e) | e <- exprs] + [
            \do(invokeVirtual(
                object("java.io.PrintStream"),
                getStatic(object("java.lang.System"), object("java.io.PrintStream"), "out"),
                methodDesc(\void(), "println", [integer()]),
                [compile(ret)]
            )),
            \return()
        ]
    )]
);

Exp compile(nat(int n)) = iconst(n);

Exp compile(var(str name)) = load(name);

Exp compile(add(Expr lhs, Expr rhs)) = add(compile(lhs), compile(rhs));
Exp compile(sub(Expr lhs, Expr rhs)) = sub(compile(lhs), compile(rhs));
Exp compile(mul(Expr lhs, Expr rhs)) = mul(compile(lhs), compile(rhs));
Exp compile(div(Expr lhs, Expr rhs)) = div(compile(lhs), compile(rhs));

Stat compile(assign(str name, Expr val)) = decl(integer(), name, init = compile(val));