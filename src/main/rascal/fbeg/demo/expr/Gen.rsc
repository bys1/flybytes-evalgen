module fbeg::demo::expr::Gen

import lang::flybytes::Syntax;

import fbeg::EvalGen;
import fbeg::Env;
import fbeg::api::Iterator;
import fbeg::demo::expr::AST;

import Type;

int(Prog) getEval() {
    return genEval(#(int(Prog)), actions, debug = true);
}

list[Stat] actions("nat", [Symbol n]) = [\return(getArg(n, integer()), load("env"))];

list[Stat] actions("add", [Symbol lhs, Symbol rhs]) = [\return(add(recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("sub", [Symbol lhs, Symbol rhs]) = [\return(sub(recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("mul", [Symbol lhs, Symbol rhs]) = [\return(mul(recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("div", [Symbol lhs, Symbol rhs]) = [\return(div(recEval(lhs), recEval(rhs, env = retEnv())))];

list[Stat] actions("var", [Symbol name]) = [\return(findObject(getArg(name, string()), integer()), load("env"))];

list[Stat] actions("assign", [Symbol name, Symbol val]) = [
    decl(integer(), "val", init = recEval(val)),
    putObject(
        getArg(name, string()),
        load("val"),
        integer(),
        env = retEnv()
    ),
    \return(load("val"), load("env"))
];

list[Stat] actions("prog", [Symbol exprs, Symbol ret]) = [
    it_decl("it", getArg(exprs)),
    \while(
        it_hasNext(load("it")),
        [
            \do(recEval(it_next(load("it")), exprs)),
            recEnv()
        ]
    ),
    \return(recEval(ret))
];