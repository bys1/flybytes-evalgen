module fbeg::demo::func::Compiler

import fbeg::demo::func::AST;

import lang::flybytes::Syntax;
import lang::flybytes::Compiler;

import List;

int cnt = 0;

void compileProg(Prog p, str name) {
    compileClass(compile(p, name), |cwd:///<name>.class|);
}

Class compile(prog(list[Func] funcs), str name) = class(
    object(name),
    methods = [compile(f) | f <- funcs]
);

Method compile(func("main", _, Expr exp)) = main(
    "args",
    [
        \do(invokeVirtual(
            object("java.io.PrintStream"),
            getStatic(
                object("java.lang.System"),
                object("java.io.PrintStream"),
                "out"
            ),
            methodDesc(
                \void(),
                "println",
                [integer()]
            ),
            [compile(exp)]
        )),
        \return()
    ]
);

Method compile(func(str name, list[str] args, Expr exp)) = staticMethod(
    \private(),
    integer(),
    name,
    [var(integer(), arg) | arg <- args],
    [\return(compile(exp))]
);

Exp compile(let(list[Binding] bindings, Expr exp)) = sblock(
    [compile(binding) | binding <- bindings],
    compile(exp)
);

Exp compile(xcond(Expr condition, Expr then, Expr alt)) = cond(compile(condition), compile(then), compile(alt));

Exp compile(loop(Expr condition, Expr then, Expr result)) = sblock(
    [
        \while(
            compile(condition),
            [\do(compile(then))]
        )
    ],
    compile(result)
);

Exp compile(var(str name)) = load(name);
Exp compile(nat(int n)) = iconst(n);

Exp compile(call(str name, list[Expr] args)) = invokeStatic(
    methodDesc(
        integer(),
        name,
        [integer() | _ <- [0 .. size(args)]]
    ),
    [compile(arg) | arg <- args]
);

Exp compile(add(Expr lhs, Expr rhs)) = add(compile(lhs), compile(rhs));
Exp compile(sub(Expr lhs, Expr rhs)) = sub(compile(lhs), compile(rhs));
Exp compile(mul(Expr lhs, Expr rhs)) = mul(compile(lhs), compile(rhs));
Exp compile(div(Expr lhs, Expr rhs)) = div(compile(lhs), compile(rhs));
Exp compile( eq(Expr lhs, Expr rhs)) =  eq(compile(lhs), compile(rhs));
Exp compile(neq(Expr lhs, Expr rhs)) =  ne(compile(lhs), compile(rhs));
Exp compile( gt(Expr lhs, Expr rhs)) =  gt(compile(lhs), compile(rhs));
Exp compile( lt(Expr lhs, Expr rhs)) =  lt(compile(lhs), compile(rhs));
Exp compile(geq(Expr lhs, Expr rhs)) =  ge(compile(lhs), compile(rhs));
Exp compile(leq(Expr lhs, Expr rhs)) =  le(compile(lhs), compile(rhs));

Exp compile(assign(str name, Expr exp)) = sblock([store(name, compile(exp))], load(name));

Exp compile(seq(Expr lhs, Expr rhs)) = sblock([\do(compile(lhs))], compile(rhs));

Stat compile(binding(str ident, Expr exp)) = decl(integer(), ident, init = compile(exp));