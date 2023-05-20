module Proto

import Env;

import lang::flybytes::Syntax;
import lang::flybytes::api::System;
import lang::flybytes::api::String;
import lang::flybytes::api::Object;

import lang::flybytes::Compiler;

data Prog       = prog(list[Func] funcs)
                ;

data Func       = func(str name, list[str] args, Expr exp)
                ;

data Expr(loc src = |unknown:///|)
                = let(list[Binding] bindings, Expr exp)
                | xcond(Expr condition, Expr then, Expr alt)
                | loop(Expr condition, Expr then, Expr result)
                | var(str name)
                | nat(int n)
                | call(str name, list[Expr] args)
                | add(Expr lhs, Expr rhs)
                | sub(Expr lhs, Expr rhs)
                | mul(Expr lhs, Expr rhs)
                | div(Expr lhs, Expr rhs)
                | gt (Expr lhs, Expr rhs)
                | lt (Expr lhs, Expr rhs)
                | geq(Expr lhs, Expr rhs)
                | leq(Expr lhs, Expr rhs)
                | assign(str name, Expr exp)
                | seq(Expr lhs, Expr rhs)
                ;

data Binding    = binding(str ident, Expr exp)
                ;

@javaClass{Proto}
java int hashCode(str string);

@reflect
@javaClass{Proto}
java int(Expr) genEval(type[Expr] t);

@reflect
@javaClass{Proto}
java void(Func) genEvalFunc(type[Func] t);

@reflect
@javaClass{Proto}
java int(Prog) genEvalProg(type[Prog] t);

void compileAll() {
    compileBinding();
    compileExp();
    compileFuncEnv();
    compileFunc();
    compileProg();
}

int FUNC;   // ladder
int LET;    // ladder

void compileExp() {
    resetAll();
    FUNC = addLadder();
    LET = addLadder();
    str vl = "io.usethesource.vallang.";
    Class cl = class(
        object("PEval"),
        modifiers = {\public(), \final()},
        interfaces = [object("java.util.function.BiFunction")],
        fields = [
            field(
                object("<vl>IValueFactory"),
                "vf",
                modifiers = {\private(), \final()}
            ),
            field(
                object("Env"),
                "__FBEG_env",
                modifiers = {\private(), \final()}
            ),
            field(
                object("PEvalBinding"),
                "__FBEG_eval_binding",
                modifiers = {\private(), \final()}
            )
        ],
        methods = [
            constructor(
                \public(),
                [
                    var(object("<vl>IValueFactory"), "vf"),
                    var(object("PEvalBinding"), "binding")
                ],
                [
                    invokeSuper([], []),
                    putField(object("<vl>IValueFactory"), "vf", load("vf")),
                    putField(object("Env"), "__FBEG_env", invokeStatic(
                        object("Env"),
                        methodDesc(
                            object("Env"),
                            "getInstance",
                            []
                        ),
                        []
                    )),
                    putField(object("PEvalBinding"), "__FBEG_eval_binding", load("binding")),
                    \return()
                ]
            ),
            method(
                \public(),
                object("java.lang.Object"),
                "apply",
                [
                    var(object("java.lang.Object"), "args"),
                    var(object("java.lang.Object"), "map")
                ],
                [
                \try([
                    \return(
                        \invokeInterface(                                           // IInteger this.vf.integer(int)
                            object("<vl>IValueFactory"),
                            getField(object("<vl>IValueFactory"), "vf"),
                            methodDesc(
                                object("<vl>IInteger"),
                                "integer",
                                [integer()]
                            ),
                            [
                                invokeSpecial(                                      // int this.eval(IConstructor)
                                    this(),
                                    methodDesc(
                                        integer(),
                                        "eval",
                                        [object("<vl>IConstructor")]
                                    ),
                                    [
                                        checkcast(                                  // (IConstructor) ((IValue[]) args)[0]
                                            aload(
                                                checkcast(
                                                    load("args"),
                                                    array(object("<vl>IValue"))
                                                ),
                                                \const(integer(), 0)
                                            ),
                                            object("<vl>IConstructor")
                                        )
                                    ]
                                )
                            ]
                        )
                    )
                ],
                [
                    \catch(
                        object("EvalException"),
                        "e",
                        [
                            \do(invokeVirtual(
                                object("EvalException"),
                                load("e"),
                                methodDesc(
                                    \void(),
                                    "printNodeStackTrace",
                                    []
                                ),
                                []
                            )),
                            \throw(
                                invokeVirtual(
                                    object("EvalException"),
                                    load("e"),
                                    methodDesc(
                                        object("java.lang.Throwable"),
                                        "getCause",
                                        []
                                    ),
                                    []
                                )
                            )
                        ]
                    )
                ])
                ]
            ),
            method(
                \protected(),
                integer(),
                "eval",
                [
                    var(object("<vl>IConstructor"), "arg")
                ],
                [   // ===== START OF EVALUATION =====
                \try([
                    \decl(string(), "name", init = \invokeInterface(
                        object("<vl>IConstructor"),
                        load("arg"),
                        methodDesc(string(), "getName", []),
                        []
                    )),
                    \decl(integer(), "key", init = \const(integer(), -1)),
                    \switch(
                        invokeVirtual(
                            string(),
                            load("name"),
                            methodDesc(integer(), "hashCode", []),
                            []
                        ),
                        [
                            \case(hashCode("let") ,   [\store("key", \const(integer(),  0)), \break()]),
                            \case(hashCode("xcond"),  [\store("key", \const(integer(),  1)), \break()]),
                            \case(hashCode("loop"),   [\store("key", \const(integer(),  2)), \break()]),
                            \case(hashCode("var"),    [\store("key", \const(integer(),  3)), \break()]),
                            \case(hashCode("nat"),    [\store("key", \const(integer(),  4)), \break()]),
                            \case(hashCode("call"),   [\store("key", \const(integer(),  5)), \break()]),
                            \case(hashCode("add"),    [\store("key", \const(integer(),  6)), \break()]),
                            \case(hashCode("sub"),    [\store("key", \const(integer(),  7)), \break()]),
                            \case(hashCode("mul"),    [\store("key", \const(integer(),  8)), \break()]),
                            \case(hashCode("div"),    [\store("key", \const(integer(),  9)), \break()]),
                            \case(hashCode("gt"),     [\store("key", \const(integer(), 10)), \break()]),
                            \case(hashCode("lt"),     [\store("key", \const(integer(), 11)), \break()]),
                            \case(hashCode("geq"),    [\store("key", \const(integer(), 12)), \break()]),
                            \case(hashCode("leq"),    [\store("key", \const(integer(), 13)), \break()]),
                            \case(hashCode("assign"), [\store("key", \const(integer(), 14)), \break()]),
                            \case(hashCode("seq"),    [\store("key", \const(integer(), 15)), \break()])
                        ],
                        option = lookup()
                    ),
                    \switch(
                        load("key"),
                        [
                            getCase(0, "let", [
                                \do(addLevel({LET})),
                                \decl(object("java.lang.Iterable"), "bindings", init = getArg(0, "java.lang.Iterable")),
                                \decl(object("java.util.Iterator"), "it", init = invokeInterface(
                                    object("java.lang.Iterable"),
                                    load("bindings"),
                                    methodDesc(
                                        object("java.util.Iterator"),
                                        "iterator",
                                        []
                                    ),
                                    []
                                )),
                                \while(
                                    invokeInterface(
                                        object("java.util.Iterator"),
                                        load("it"),
                                        methodDesc(
                                            boolean(),
                                            "hasNext",
                                            []
                                        ),
                                        []
                                    ),
                                    [
                                        \decl(object("<vl>IConstructor"), "binding", init = checkcast(
                                            invokeInterface(
                                                object("java.util.Iterator"),
                                                load("it"),
                                                methodDesc(
                                                    object(),
                                                    "next",
                                                    []
                                                ),
                                                []
                                            ),
                                            object("<vl>IConstructor")
                                        )),
                                        \do(invokeVirtual(
                                            object("PEvalBinding"),
                                            getField(object("PEvalBinding"), "__FBEG_eval_binding"),
                                            methodDesc(
                                                \void(),
                                                "eval",
                                                [object("<vl>IConstructor")]
                                            ),
                                            [load("binding")]
                                        ))
                                    ]
                                ),
                                \decl(integer(), "ret", init = recEval(1)),
                                \do(removeLevel()),
                                \return(load("ret"))
                            ]),
                            getCase(1, "xcond", [
                                \return(cond(recEval(0), recEval(1), recEval(2)))
                            ]),
                            getCase(2, "loop", [
                                \decl(object("<vl>IConstructor"), "condition", init = getArg(0, "<vl>IConstructor")),
                                \decl(object("<vl>IConstructor"), "then",      init = getArg(1, "<vl>IConstructor")),
                                \while(
                                    \invokeSpecial(
                                        this(),
                                        methodDesc(
                                            integer(),
                                            "eval",
                                            [object("<vl>IConstructor")]
                                        ),
                                        [load("condition")]
                                    ),
                                    [\do(\invokeSpecial(
                                        this(),
                                        methodDesc(
                                            integer(),
                                            "eval",
                                            [object("<vl>IConstructor")]
                                        ),
                                        [load("then")]
                                    ))]
                                ),
                                \return(recEval(2))
                            ]),
                            getCase(3, "var", [
                                \decl(string(), "name", init = \invokeInterface(
                                    object("<vl>IString"),
                                    getArg(0, "<vl>IString"),
                                    methodDesc(string(), "getValue", []),
                                    []
                                )),
                                \decl(object("java.lang.Integer"), "val", init = findObject(object("java.lang.Integer"), load("name"), FUNC)),
                                \return(invokeVirtual(
                                    object("java.lang.Integer"),
                                    load("val"),
                                    methodDesc(
                                        integer(),
                                        "intValue",
                                        []
                                    ),
                                    []
                                ))
                            ]),
                            getCase(4, "nat", [
                                \decl(integer(), "n", init = \invokeInterface(
                                    object("<vl>IInteger"),
                                    getArg(0, "<vl>IInteger"),
                                    methodDesc(integer(), "intValue", []),
                                    []
                                )),
                                \return(load("n"))
                            ]),
                            getCase(5, "call", [
                                \decl(string(), "name", init = \invokeInterface(
                                    object("<vl>IString"),
                                    getArg(0, "<vl>IString"),
                                    methodDesc(string(), "getValue", []),
                                    []
                                )),
                                \decl(object("<vl>ICollection"), "args", init = getArg(1, "<vl>ICollection")),
                                \return(invokeVirtual(
                                    object("FuncEnv"),
                                    findObjectLocal(object("FuncEnv"), load("name"), iconst(0)),
                                    methodDesc(
                                        integer(),
                                        "eval",
                                        [object("<vl>ICollection")]
                                    ),
                                    [load("args")]
                                ))
                            ]),
                            getCase(6, "add", [
                                \decl(integer(), "lhs", init = recEval(0)),
                                \decl(integer(), "rhs", init = recEval(1)),
                                \return(add(load("lhs"), load("rhs")))
                            ]),
                            getCase(7, "sub", [
                                \decl(integer(), "lhs", init = recEval(0)),
                                \decl(integer(), "rhs", init = recEval(1)),
                                \return(sub(load("lhs"), load("rhs")))
                            ]),
                            getCase(8, "mul", [
                                \decl(integer(), "lhs", init = recEval(0)),
                                \decl(integer(), "rhs", init = recEval(1)),
                                \return(mul(load("lhs"), load("rhs")))
                            ]),
                            getCase(9, "div", [
                                \decl(integer(), "lhs", init = recEval(0)),
                                \decl(integer(), "rhs", init = recEval(1)),
                                \return(div(load("lhs"), load("rhs")))
                            ]),
                            getCase(10, "gt", [
                                \decl(integer(), "lhs", init = recEval(0)),
                                \decl(integer(), "rhs", init = recEval(1)),
                                \return(gt(load("lhs"), load("rhs")))
                            ]),
                            getCase(11, "lt", [
                                \decl(integer(), "lhs", init = recEval(0)),
                                \decl(integer(), "rhs", init = recEval(1)),
                                \return(lt(load("lhs"), load("rhs")))
                            ]),
                            getCase(12, "geq", [
                                \decl(integer(), "lhs", init = recEval(0)),
                                \decl(integer(), "rhs", init = recEval(1)),
                                \return(ge(load("lhs"), load("rhs")))
                            ]),
                            getCase(13, "leq", [
                                \decl(integer(), "lhs", init = recEval(0)),
                                \decl(integer(), "rhs", init = recEval(1)),
                                \return(le(load("lhs"), load("rhs")))
                            ]),
                            getCase(14, "assign", [
                                \decl(string(), "name", init = \invokeInterface(
                                    object("<vl>IString"),
                                    getArg(0, "<vl>IString"),
                                    methodDesc(string(), "getValue", []),
                                    []
                                )),
                                \decl(integer(), "exp", init = recEval(1)),
                                \decl(object("java.lang.Integer"), "val", init = invokeStatic(
                                    object("java.lang.Integer"),
                                    methodDesc(
                                        object("java.lang.Integer"),
                                        "valueOf",
                                        [integer()]
                                    ),
                                    [load("exp")]
                                )),
                                \do(putObject(load("name"), load("val"))),
                                \return(load("exp"))
                            ]),
                            getCase(15, "seq", [
                                \decl(integer(), "lhs", init = recEval(0)),
                                \decl(integer(), "rhs", init = recEval(1)),
                                \do(load("lhs")),
                                \return(load("rhs"))
                            ]),
                            \default([\return(\const(integer(), 0))])
                        ],
                        option = table()
                    ),
                    \return(\const(integer(), 0))
                ],
                [
                    \catch(
                        object("EvalException"),
                        "e",
                        [
                            \do(invokeVirtual(
                                object("EvalException"),
                                load("e"),
                                methodDesc(
                                    \void(),
                                    "addNode",
                                    [object("<vl>IConstructor")]
                                ),
                                [load("arg")]
                            )),
                            \throw(load("e"))
                        ]
                    ),
                    \catch(
                        object("java.lang.Throwable"),
                        "t",
                        [
                            \throw(
                                newInstance(
                                    object("EvalException"),
                                    constructorDesc([object("<vl>IConstructor"), object("java.lang.Throwable")]),
                                    [load("arg"), load("t")]
                                )
                            )
                            /*\decl(object("java.io.PrintStream"), "out", init = getStatic(object("java.lang.System"), object("java.io.PrintStream"), "out")),
                            out([string()], [sconst("An error occurred while evaluating the following node:")]),
                            \do(invokeVirtual(
                                object("<vl>io.StandardTextWriter"),
                                newInstance(
                                    object("<vl>io.StandardTextWriter"),
                                    constructorDesc([boolean()]),
                                    [zconst(true)]
                                ),
                                methodDesc(
                                    \void(),
                                    "write",
                                    [object("<vl>IValue"), object("java.io.Writer")]
                                ),
                                [
                                    load("arg"),
                                    newInstance(
                                        object("java.io.PrintWriter"),
                                        constructorDesc([object("java.io.OutputStream")]),
                                        [load("out")]
                                    )
                                ]
                            )),
                            out([], []),
                            out([], []),
                            \throw(load("t"))//*/
                        ]
                    )
                ])
                ]   // =====   END OF EVALUATION =====
            )
        ]
    );
    compileClass(cl, |cwd:///PEval.class|);
}

void compileBinding() {
    str vl = "io.usethesource.vallang.";
    Class cl = class(
        object("PEvalBinding"),
        modifiers = {\public(), \final()},
        interfaces = [object("java.util.function.BiFunction")],
        fields = [
            field(
                object("<vl>IValueFactory"),
                "vf",
                modifiers = {\private(), \final()}
            ),
            field(
                object("Env"),
                "__FBEG_env",
                modifiers = {\private(), \final()}
            ),
            field(
                object("PEval"),
                "__FBEG_eval_exp",
                modifiers = {\private()}
            )
        ],
        methods = [
            constructor(
                \public(),
                [var(object("<vl>IValueFactory"), "vf")],
                [
                    invokeSuper([], []),
                    putField(object("<vl>IValueFactory"), "vf", load("vf")),
                    putField(object("Env"), "__FBEG_env", invokeStatic(
                        object("Env"),
                        methodDesc(
                            object("Env"),
                            "getInstance",
                            []
                        ),
                        []
                    )),
                    \return()
                ]
            ),
            method(
                \public(),
                object(),
                "apply",
                [
                    var(object(), "args"),
                    var(object(), "map")
                ],
                [
                    \do(
                        \invokeSpecial(                                             // void this.eval(IConstructor)
                            this(),
                            methodDesc(
                                \void(),
                                "eval",
                                [object("<vl>IConstructor")]
                            ),
                            [
                                checkcast(                                          // (IConstructor) ((IValue[]) args)[0]
                                    aload(
                                        checkcast(
                                            load("args"),
                                            array(object("<vl>IValue"))
                                        ),
                                        iconst(0)
                                    ),
                                    object("<vl>IConstructor")
                                )
                            ]
                        )
                    ),
                    \return(checkcast(null(), object()))
                ]
            ),
            method(
                \protected(),
                \void(),
                "eval",
                [
                    var(object("<vl>IConstructor"), "arg")
                ],
                [   // ===== START OF EVALUATION =====
                    \decl(string(), "name", init = \invokeInterface(
                        object("<vl>IConstructor"),
                        load("arg"),
                        methodDesc(string(), "getName", []),
                        []
                    )),
                    \decl(integer(), "key", init = \const(integer(), -1)),
                    \switch(
                        invokeVirtual(
                            string(),
                            load("name"),
                            methodDesc(integer(), "hashCode", []),
                            []
                        ),
                        [
                            \case(hashCode("binding"), [\store("key", \const(integer(), 0)), \break()])
                        ],
                        option = lookup()
                    ),
                    \switch(
                        load("key"),
                        [
                            getCase(0, "binding", [
                                \decl(string(), "ident", init = \invokeInterface(
                                    object("<vl>IString"),
                                    getArg(0, "<vl>IString"),
                                    methodDesc(string(), "getValue", []),
                                    []
                                )),
                                \decl(integer(), "exp", init = invokeVirtual(
                                    object("PEval"),
                                    getField(object("PEval"), "__FBEG_eval_exp"),
                                    methodDesc(
                                        integer(),
                                        "eval",
                                        [object("<vl>IConstructor")]
                                    ),
                                    [getArg(1, "<vl>IConstructor")]
                                )),
                                \decl(object("java.lang.Integer"), "val", init = invokeStatic(
                                    object("java.lang.Integer"),
                                    methodDesc(
                                        object("java.lang.Integer"),
                                        "valueOf",
                                        [integer()]
                                    ),
                                    [load("exp")]
                                )),
                                \do(putObject(load("ident"), load("val"))),
                                \return()
                            ]),
                            \default([\return()])
                        ],
                        option = table()
                    ),
                    \return()
                ]   // =====   END OF EVALUATION =====
            )
        ]
    );
    compileClass(cl, |cwd:///PEvalBinding.class|);
}

void compileFunc() {
    str vl = "io.usethesource.vallang.";
    Class cl = class(
        object("PEvalFunc"),
        modifiers = {\public(), \final()},
        interfaces = [object("java.util.function.BiFunction")],
        fields = [
            field(
                object("<vl>IValueFactory"),
                "vf",
                modifiers = {\private(), \final()}
            ),
            field(
                object("Env"),
                "__FBEG_env",
                modifiers = {\private(), \final()}
            ),
            field(
                object("PEval"),
                "__FBEG_eval_exp",
                modifiers = {\private()}
            )
        ],
        methods = [
            constructor(
                \public(),
                [
                    var(object("<vl>IValueFactory"), "vf"),
                    var(object("PEval"), "exp")
                ],
                [
                    invokeSuper([], []),
                    putField(object("<vl>IValueFactory"), "vf", load("vf")),
                    putField(object("Env"), "__FBEG_env", invokeStatic(
                        object("Env"),
                        methodDesc(
                            object("Env"),
                            "getInstance",
                            []
                        ),
                        []
                    )),
                    putField(object("PEval"), "__FBEG_eval_exp", load("exp")),
                    \return()
                ]
            ),
            method(
                \public(),
                object(),
                "apply",
                [
                    var(object(), "args"),
                    var(object(), "map")
                ],
                [
                    \do(
                        \invokeSpecial(                                             // void this.eval(IConstructor)
                            this(),
                            methodDesc(
                                \void(),
                                "eval",
                                [object("<vl>IConstructor")]
                            ),
                            [
                                checkcast(                                          // (IConstructor) ((IValue[]) args)[0]
                                    aload(
                                        checkcast(
                                            load("args"),
                                            array(object("<vl>IValue"))
                                        ),
                                        iconst(0)
                                    ),
                                    object("<vl>IConstructor")
                                )
                            ]
                        )
                    ),
                    \return(checkcast(null(), object()))
                ]
            ),
            method(
                \protected(),
                \void(),
                "eval",
                [
                    var(object("<vl>IConstructor"), "arg")
                ],
                [   // ===== START OF EVALUATION =====
                    \decl(string(), "name", init = \invokeInterface(
                        object("<vl>IConstructor"),
                        load("arg"),
                        methodDesc(string(), "getName", []),
                        []
                    )),
                    \decl(integer(), "key", init = \const(integer(), -1)),
                    \switch(
                        invokeVirtual(
                            string(),
                            load("name"),
                            methodDesc(integer(), "hashCode", []),
                            []
                        ),
                        [
                            \case(hashCode("func"), [\store("key", \const(integer(), 0)), \break()])
                        ],
                        option = lookup()
                    ),
                    \switch(
                        load("key"),
                        [
                            getCase(0, "func", [
                                \decl(string(), "name", init = \invokeInterface(
                                    object("<vl>IString"),
                                    getArg(0, "<vl>IString"),
                                    methodDesc(string(), "getValue", []),
                                    []
                                )),
                                \decl(object("<vl>ICollection"), "args", init = getArg(1, "<vl>ICollection")),
                                \decl(object("<vl>IConstructor"), "exp", init = getArg(2, "<vl>IConstructor")),
                                \do(putObject(
                                    load("name"),
                                    newInstance(
                                        object("FuncEnv"),
                                        constructorDesc([object("<vl>ICollection"), object("<vl>IConstructor"), object("PEval")]),
                                        [load("args"), load("exp"), getField(object("PEval"), "__FBEG_eval_exp")]
                                    ),
                                    iconst(0)
                                )),
                                \return()
                            ]),
                            \default([\return()])
                        ],
                        option = table()
                    ),
                    \return()
                ]   // =====   END OF EVALUATION =====
            )
        ]
    );
    compileClass(cl, |cwd:///PEvalFunc.class|);
}

void compileProg() {
    str vl = "io.usethesource.vallang.";
    Class cl = class(
        object("PEvalProg"),
        modifiers = {\public(), \final()},
        interfaces = [object("java.util.function.BiFunction")],
        fields = [
            field(
                object("<vl>IValueFactory"),
                "vf",
                modifiers = {\private(), \final()}
            ),
            field(
                object("Env"),
                "__FBEG_env",
                modifiers = {\private(), \final()}
            ),
            field(
                object("PEvalFunc"),
                "__FBEG_eval_func",
                modifiers = {\private()}
            )
        ],
        methods = [
            constructor(
                \public(),
                [
                    var(object("<vl>IValueFactory"), "vf"),
                    var(object("PEvalFunc"), "func")
                ],
                [
                    invokeSuper([], []),
                    putField(object("<vl>IValueFactory"), "vf", load("vf")),
                    putField(object("Env"), "__FBEG_env", invokeStatic(
                        object("Env"),
                        methodDesc(
                            object("Env"),
                            "getInstance",
                            []
                        ),
                        []
                    )),
                    putField(object("PEvalFunc"), "__FBEG_eval_func", load("func")),
                    \return()
                ]
            ),
            method(
                \public(),
                object(),
                "apply",
                [
                    var(object(), "args"),
                    var(object(), "map")
                ],
                [
                    \return(
                        \invokeInterface(                                           // IInteger this.vf.integer(int)
                            object("<vl>IValueFactory"),
                            getField(object("<vl>IValueFactory"), "vf"),
                            methodDesc(
                                object("<vl>IInteger"),
                                "integer",
                                [integer()]
                            ),
                            [
                                invokeSpecial(                                      // int this.eval(IConstructor)
                                    this(),
                                    methodDesc(
                                        integer(),
                                        "eval",
                                        [object("<vl>IConstructor")]
                                    ),
                                    [
                                        checkcast(                                  // (IConstructor) ((IValue[]) args)[0]
                                            aload(
                                                checkcast(
                                                    load("args"),
                                                    array(object("<vl>IValue"))
                                                ),
                                                iconst(0)
                                            ),
                                            object("<vl>IConstructor")
                                        )
                                    ]
                                )
                            ]
                        )
                    )
                ]
            ),
            method(
                \protected(),
                \integer(),
                "eval",
                [
                    var(object("<vl>IConstructor"), "arg")
                ],
                [   // ===== START OF EVALUATION =====
                    \decl(string(), "name", init = \invokeInterface(
                        object("<vl>IConstructor"),
                        load("arg"),
                        methodDesc(string(), "getName", []),
                        []
                    )),
                    \decl(integer(), "key", init = \const(integer(), -1)),
                    \switch(
                        invokeVirtual(
                            string(),
                            load("name"),
                            methodDesc(integer(), "hashCode", []),
                            []
                        ),
                        [
                            \case(hashCode("prog"), [\store("key", \const(integer(), 0)), \break()])
                        ],
                        option = lookup()
                    ),
                    \switch(
                        load("key"),
                        [
                            getCase(0, "prog", [
                                \decl(object("<vl>ICollection"), "funcs", init = getArg(0, "<vl>ICollection")),
                                \decl(object("java.util.Iterator"), "it", init = invokeInterface(
                                    object("<vl>ICollection"),
                                    load("funcs"),
                                    methodDesc(
                                        object("java.util.Iterator"),
                                        "iterator",
                                        []
                                    ),
                                    []
                                )),
                                \while(
                                    \invokeInterface(
                                        object("java.util.Iterator"),
                                        load("it"),
                                        methodDesc(
                                            boolean(),
                                            "hasNext",
                                            []
                                        ),
                                        []
                                    ),
                                    [
                                        \do(
                                            invokeVirtual(
                                                object("PEvalFunc"),
                                                getField(object("PEvalFunc"), "__FBEG_eval_func"),
                                                methodDesc(
                                                    \void(),
                                                    "eval",
                                                    [object("<vl>IConstructor")]
                                                ),
                                                [invokeInterface(
                                                    object("java.util.Iterator"),
                                                    load("it"),
                                                    methodDesc(
                                                        object(),
                                                        "next",
                                                        []
                                                    ),
                                                    []
                                                )]
                                            )
                                        )
                                    ]
                                ),
                                \return(invokeVirtual(
                                    object("FuncEnv"),
                                    findObjectLocal(object("FuncEnv"), sconst("main"), iconst(0)),
                                    methodDesc(
                                        integer(),
                                        "eval",
                                        [object("<vl>ICollection")]
                                    ),
                                    [invokeInterface(
                                        object("<vl>IValueFactory"),
                                        getField(object("<vl>IValueFactory"), "vf"),
                                        methodDesc(
                                            object("<vl>IList"),
                                            "list",
                                            [array(object("<vl>IValue"))]
                                        ),
                                        [newArray(array(object("<vl>IValue")), iconst(0))]
                                    )]
                                ))
                            ]),
                            \default([\return(iconst(0))])
                        ],
                        option = table()
                    ),
                    \return(iconst(0))
                ]   // =====   END OF EVALUATION =====
            )
        ]
    );
    compileClass(cl, |cwd:///PEvalProg.class|);
}

void compileFuncEnv() {
    str vl = "io.usethesource.vallang.";
    Class cl = class(
        object("FuncEnv"),
        modifiers = {\public(), \final()},
        interfaces = [],
        fields = [
            field(
                object("Env"),
                "__FBEG_env",
                modifiers = {\private(), \final()}
            ),
            field(
                array(string()),
                "args",
                modifiers = {\private(), \final()}
            ),
            field(
                object("<vl>IConstructor"),
                "exp",
                modifiers = {\private(), \final()}
            ),
            field(
                object("PEval"),
                "__FBEG_eval_exp",
                modifiers = {\private(), \final()}
            )
        ],
        methods = [
            constructor(
                \public(),
                [
                    var(object("<vl>ICollection"), "args"),
                    var(object("<vl>IConstructor"), "exp"),
                    var(object("PEval"), "evalExp")
                ],
                [
                    invokeSuper([], []),
                    putField(object("Env"), "__FBEG_env", invokeStatic(
                        object("Env"),
                        methodDesc(
                            object("Env"),
                            "getInstance",
                            []
                        ),
                        []
                    )),
                    \decl(integer(), "len", init = invokeInterface(
                        object("<vl>ICollection"),
                        load("args"),
                        methodDesc(
                            integer(),
                            "size",
                            []
                        ),
                        []
                    )),
                    \decl(object("java.util.Iterator"), "it", init = invokeInterface(
                        object("<vl>ICollection"),
                        load("args"),
                        methodDesc(
                            object("java.util.Iterator"),
                            "iterator",
                            []
                        ),
                        []
                    )),
                    putField(array(string()), "args", newArray(
                        array(object("java.lang.String")),
                        load("len")
                    )),
                    \for(
                        [\decl(integer(), "i", init = iconst(0))],
                        lt(load("i"), load("len")),
                        [\store("i", add(load("i"), iconst(1)))],
                        [
                            astore(
                                getField(array(string()), "args"),
                                load("i"),
                                invokeInterface(
                                    object("<vl>IString"),
                                    checkcast(
                                        invokeInterface(
                                            object("java.util.Iterator"),
                                            load("it"),
                                            methodDesc(
                                                object(),
                                                "next",
                                                []
                                            ),
                                            []
                                        ),
                                        object("<vl>IString")
                                    ),
                                    methodDesc(
                                        string(),
                                        "getValue",
                                        []
                                    ),
                                    []
                                )
                            )
                        ]
                    ),
                    putField(object("<vl>IConstructor"), "exp", load("exp")),
                    putField(object("PEval"), "__FBEG_eval_exp", load("evalExp")),
                    \return()
                ]
            ),
            method(
                \public(),
                integer(),
                "eval",
                [
                    var(object("<vl>ICollection"), "args")
                ],
                [
                    \decl(object("java.util.Iterator"), "it", init = invokeInterface(
                        object("<vl>ICollection"),
                        load("args"),
                        methodDesc(
                            object("java.util.Iterator"),
                            "iterator",
                            []
                        ),
                        []
                    )),
                    \do(addLevel({})),                                              // Add new Env level for function call
                    \for(                                                           // Put all args in Env at new function level
                        [\decl(integer(), "i", init = iconst(0))],
                        lt(load("i"), alength(getField(array(string()), "args"))),
                        [\store("i", add(load("i"), iconst(1)))],
                        [
                            \do(putObject(
                                aload(
                                    getField(array(string()), "args"),
                                    load("i")
                                ),
                                invokeStatic(
                                    object("java.lang.Integer"),
                                    methodDesc(
                                        object("java.lang.Integer"),
                                        "valueOf",
                                        [integer()]
                                    ),
                                    [
                                        invokeVirtual(
                                            object("PEval"),
                                            getField(object("PEval"), "__FBEG_eval_exp"),
                                            methodDesc(
                                                integer(),
                                                "eval",
                                                [object("<vl>IConstructor")]
                                            ),
                                            [
                                                checkcast(
                                                    invokeInterface(
                                                        object("java.util.Iterator"),
                                                        load("it"),
                                                        methodDesc(
                                                            object(),
                                                            "next",
                                                            []
                                                        ),
                                                        []
                                                    ),
                                                    object("<vl>IConstructor")
                                                )
                                            ]
                                        )
                                    ]
                                )
                            ))
                        ]
                    ),
                    addLevelToLadders({FUNC}),                                      // Add level to function ladder AFTER evaluating args
                    \decl(integer(), "ret", init = invokeVirtual(
                        object("PEval"),
                        getField(object("PEval"), "__FBEG_eval_exp"),
                        methodDesc(
                            integer(),
                            "eval",
                            [object("<vl>IConstructor")]
                        ),
                        [getField(object("<vl>IConstructor"), "exp")]
                    )),
                    \do(removeLevel()),
                    \return(load("ret"))
                ]
            )
        ]
    );
    compileClass(cl, |cwd:///FuncEnv.class|);
}

Case getCase(int key, str eq, list[Stat] block) {
    return \case(key, [
        \if(
            \invokeVirtual(
                string(),
                load("name"),
                methodDesc(
                    boolean(),
                    "equals",
                    [object("java.lang.Object")]
                ),
                [\const(string(), eq)]
            ),
            block
        ),
        \break()
    ]);
}

Exp getArg(int index, str cast) {
    return getArg("arg", index, cast);
}

Exp getArg(str arg, int index, str cast) {
    return checkcast(
        invokeInterface(
            object("io.usethesource.vallang.IConstructor"),
            load(arg),
            methodDesc(
                object("io.usethesource.vallang.IValue"),
                "get",
                [integer()]
            ),
            [\const(integer(), index)]
        ),
        object(cast)
    );
}

Exp recEval(int index) {
    return invokeSpecial(
        this(),
        methodDesc(
            integer(),
            "eval",
            [object("io.usethesource.vallang.IConstructor")]
        ),
        [getArg(index, "io.usethesource.vallang.IConstructor")]
    );
}

Stat out(list[Type] formals, list[Exp] args) {
    return \do(
        invokeVirtual(
            object("java.io.PrintStream"),
            load("out"),
            methodDesc(
                \void(),
                "println",
                formals
            ),
            args
        )
    );
}