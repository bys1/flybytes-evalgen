module fbeg::demo::func::FuncEnv

import lang::flybytes::Syntax;
import lang::flybytes::Compiler;

import fbeg::api::List;
import fbeg::api::Iterator;

private str vl = "io.usethesource.vallang.";

Class getFuncEnvClass() {
    return class(
        object("EvalFuncEnv"),
        modifiers = {\public(), final()},
        interfaces = [],
        fields = [
            field(
                array(string()),
                "args",
                modifiers = {\public(), \final()}
            ),
            field(
                object("<vl>IConstructor"),
                "exp",
                modifiers = {\public(), \final()}
            )
        ],
        methods = [
            constructor(
                \public(),
                [
                    var(object("<vl>IList"), "args"),
                    var(object("<vl>IConstructor"), "exp")
                ],
                [
                    invokeSuper([], []),
                    decl(integer(), "len", init = list_size(load("args"))),
                    it_decl("it", load("args")),
                    putField(array(string()), "args", newArray(
                        array(object("java.lang.String")),
                        load("len")
                    )),
                    \for(
                        [decl(integer(), "i", init = iconst(0))],
                        lt(load("i"), load("len")),
                        [store("i", add(load("i"), iconst(1)))],
                        [
                            astore(
                                getField(array(string()), "args"),
                                load("i"),
                                it_next(load("it"), string())
                            )
                        ]
                    ),
                    putField(object("<vl>IConstructor"), "exp", load("exp")),
                    \return()
                ]
            )
        ]
    );
}