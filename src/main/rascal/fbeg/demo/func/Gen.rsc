module fbeg::demo::func::Gen

import Type;

import lang::flybytes::Syntax;

import fbeg::Env;
import fbeg::EvalGen;
import fbeg::api::Iterator;
import fbeg::api::Types;
import fbeg::demo::func::AST;
import fbeg::demo::func::FuncEnv;

int(Prog) getEval() {
    return genEval(#(int(Prog)), actions, helperClasses = [getFuncEnvClass()], debug = true);
}

alias Res = tuple[int val, Env globalEnv];

Res(Prog) getEval2() {
    return genEval(#(Res(Prog)), actions, helperClasses = [getFuncEnvClass()], debug = true);
}

list[Stat] actions("prog", [Symbol funcs]) = [
    it_decl("it", getArg(funcs)),
    \while(
        it_hasNext(load("it")),
        [\do(recEval(it_next(load("it")), funcs))]
    ),
    \return(recEval(
        getField(
            object("EvalFuncEnv"),
            findObject(sconst("main"), object("EvalFuncEnv"), env = globalEnv()),
            getTreeType(),
            "exp"
        ),
        #Expr
    ))
];

list[Stat] actions("func", [Symbol name, Symbol args, Symbol exp]) = [
    putObjectField(
        fromRascalType(getArg(name), string()),
        newInstance(
            object("EvalFuncEnv"),
            constructorDesc([symbolToTypeClass(args), symbolToTypeClass(exp)]),
            [getArg(args), getArg(exp)]
        ),
        env = globalEnv(),
        field = "globalEnv"
    ),
    \return(iconst(0))
];

list[Stat] actions("let", [Symbol bindings, Symbol exp]) = [
    it_decl("it", getArg(bindings)),
    setRetEnv(),
    \while(
        it_hasNext(load("it")),
        [\do(recEval(it_next(load("it")), bindings, env = retEnv()))]
    ),
    decl(integer(), "ret", init = recEval(exp, env = retEnv())),
    \return(load("ret"))
];

list[Stat] actions("xcond", [Symbol condition, Symbol then, Symbol alt])
    = [\return(cond(recEval(condition), recEval(then, env = retEnv()), recEval(alt, env = retEnv())))];

list[Stat] actions("loop", [Symbol condition, Symbol then, Symbol result]) = [
    recDecl("condition", condition),
    recDecl("then", then),
    setRetEnv(),
    \while(
        recEval("condition", env = retEnv()),
        [\do(recEval("then", env = retEnv()))]
    ),
    \return(recEval(result, env = retEnv()))
];

list[Stat] actions("var", [Symbol name]) = [
    \return(
        findWrapped(
            getArg(name, string()),
            integer()
        ),
        load("env")
    )
];

list[Stat] actions("nat", [Symbol n]) = [\return(getArg(n, integer()), load("env"))];

list[Stat] actions("call", [Symbol name, Symbol args]) = [
    decl(object("EvalFuncEnv"), "func", init = findObject(
        fromRascalType(getArg(name), string()),
        object("EvalFuncEnv"),
        env = globalEnv()
    )),
    decl(envType(), "newEnv", init = newEnv()),
    it_decl("it", getArg(args)),
    decl(array(string()), "argNames", init = getField(object("EvalFuncEnv"), load("func"), array(string()), "args")),
    \for(
        [decl(integer(), "i", init = iconst(0))],
        lt(load("i"), alength(load("argNames"))),
        [store("i", add(load("i"), iconst(1)))],
        [
            putWrapped(
                aload(load("argNames"), load("i")),
                recEval(it_next(load("it")), args),
                integer(),
                envVar = "newEnv",
                replace = true
            )
        ]
    ),
    \return(
        recEval(
            getField(object("EvalFuncEnv"), load("func"), getTreeType(), "exp"),
            args,
            env = load("newEnv")
        ),
        load("env")
    )
];

list[Stat] actions("add", [Symbol lhs, Symbol rhs]) = [\return(add(recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("sub", [Symbol lhs, Symbol rhs]) = [\return(sub(recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("mul", [Symbol lhs, Symbol rhs]) = [\return(mul(recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("div", [Symbol lhs, Symbol rhs]) = [\return(div(recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("eq",  [Symbol lhs, Symbol rhs]) = [\return(Exp::eq (recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("neq", [Symbol lhs, Symbol rhs]) = [\return(ne (recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("gt",  [Symbol lhs, Symbol rhs]) = [\return(gt (recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("lt",  [Symbol lhs, Symbol rhs]) = [\return(lt (recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("geq", [Symbol lhs, Symbol rhs]) = [\return(ge (recEval(lhs), recEval(rhs, env = retEnv())))];
list[Stat] actions("leq", [Symbol lhs, Symbol rhs]) = [\return(le (recEval(lhs), recEval(rhs, env = retEnv())))];

list[Stat] actions("seq", [Symbol lhs, Symbol rhs]) = [\do(recEval(lhs)), \return(recEval(rhs, env = retEnv()))];

list[Stat] actions("assign", [Symbol name, Symbol exp]) = [
    decl(integer(), "exp", init = recEval(exp)),
    putWrappedField(
        getArg(name, string()),
        load("exp"),
        integer(),
        env = retEnv()
    ),
    \return(load("exp"))
];

list[Stat] actions("binding", [Symbol ident, Symbol exp]) = [
    putWrappedField(
        fromRascalType(getArg(ident), string()),
        recEval(exp),
        integer(),
        replace = true                                          // Always replace to allow shadowing
    ),
    \return(iconst(0))
];