module Test

import lang::flybytes::Syntax;
import lang::flybytes::api::System;
import lang::flybytes::api::String;
import lang::flybytes::api::Object;

import lang::flybytes::Compiler;
import lang::flybytes::Decompiler;

import IO;

data Oeakari(loc src = |unknown:///|) = aap(int x) | rec(int n, Oeakari r);

/*@reflect
@javaClass{Test}
java void extest(Oeakari oe);//*/

void test1() {
    loc l = |cwd:///src/main/rascal/Test.rsc|;
    Oeakari h1 = aap(10, src = l(100, 10, <21, 5>, <21, 50>));
    Oeakari h2 = rec(20, h1, src = l(200, 10, <22, 5>, <22, 50>));
    Oeakari h3 = rec(30, h2, src = l(300, 10, <23, 5>, <23, 50>));
    Oeakari h4 = rec(40, h3, src = l(400, 10, <24, 5>, <24, 50>));
    extest(h4);
}

void compileTest() {
    loc l = |cwd:///src/main/rascal/Test.rsc|(314, 16, <18, 5>, <18, 21>);
    str  mcl = "io.usethesource.capsule.Map$Immutable";
    Class cl = class(
        object("Test"),
        modifiers = {\public(), \final()},
        methods = [
            main(
                "args",
                [
                    decl(integer(), "a"),
                    \if(
                        eq(iconst(1), iconst(1)),
                        [
                            decl(integer(), "b", init = add(
                                iconst(2),
                                sblock(
                                    [
                                        decl(integer(), "aaa", init = iconst(20)),
                                        store("a", iconst(10))
                                    ],
                                    load("aaa")
                                )
                            ))
                        ]
                    ),
                    \return()
                ]
            )
        ],
        src=l
    );
    compileClass(cl, |cwd:///Test.class|);
}

Class decompileTest() {
    return decompile(|cwd:///Test.class|);
}