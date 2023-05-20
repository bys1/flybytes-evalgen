module Env

import Set;

import lang::flybytes::Syntax;
import lang::flybytes::api::System;

int c = 1; // Counter for variables

@javaClass{Env}
java void resetAll();

@javaClass{Env}
java void resetLevels();

@javaClass{Env}
java void resetLadders();

@javaClass{Env}
private java int addLadderR();

int addLadder() {
    return addLadderR();
}

Exp addLevel(set[int] ladders) {
    str arr = "__fbeg_arr<c>";
    c += 1;
    list[Stat] stats = [\decl(array(integer()), arr, init = newArray(array(integer()), iconst(size(ladders))))];
    int i = 0;
    for (int ladder <- ladders) {
        stats += \astore(load(arr), iconst(i), iconst(ladder));
        i += 1;
    }
    return sblock(
        stats,
        invokeVirtual(
            object("Env"),
            getEnv(),
            methodDesc(
                integer(),
                "addLevel",
                [array(integer())]
            ),
            [
                load(arr)
            ]
        )
    );
}

Exp removeLevel() {
    return invokeVirtual(
        object("Env"),
        getEnv(),
        methodDesc(
            \void(),
            "removeLevel",
            []
        ),
        []
    );
}

Exp getLevel() {
    return invokeVirtual(
        object("Env"),
        getEnv(),
        methodDesc(
            integer(),
            "getLevel",
            []
        ),
        []
    );
}

Stat addLevelToLadders(set[int] ladders) {
    str arr = "__FBEG_arr<c>";
    c += 1;
    list[Stat] stats = [\decl(array(integer()), arr, init = newArray(array(integer()), iconst(size(ladders))))];
    int i = 0;
    for (int ladder <- ladders) {
        stats += \astore(load(arr), iconst(i), iconst(ladder));
        i += 1;
    }
    stats += \do(invokeVirtual(
        object("Env"),
        getEnv(),
        methodDesc(
            \void(),
            "addLevelToLadders",
            [array(integer())]
        ),
        [load(arr)]
    ));
    return \block(stats);
}

Exp findObject(Type \type, Exp key, int minLadder) {
    return findObjectX(
        \type,
        "findObject",
        [string(), integer()],
        [key, iconst(minLadder)]
    );
}

Exp findObject(Type \type, Exp key, int minLadder, Exp level) {
    return findObjectX(
        \type,
        "findObject",
        [string(), integer(), integer()],
        [key, iconst(minLadder), level]
    );
}

Exp findObject(Type \type, int ladder, Exp key, int minLadder) {
    return findObjectX(
        \type,
        "findObject",
        [integer(), string(), integer()],
        [iconst(ladder), key, iconst(minLadder)]
    );
}

Exp findObject(Type \type, int ladder, Exp key, int minLadder, Exp level) {
    return findObjectX(
        \type,
        "findObject",
        [integer(), string(), integer(), integer()],
        [iconst(ladder), key, iconst(minLadder), level]
    );
}

Exp findObjectLocal(Type \type, Exp key) {
    return findObjectX(
        \type,
        "findObjectLocal",
        [string()],
        [key]
    );
}

Exp findObjectLocal(Type \type, Exp key, Exp level) {
    return findObjectX(
        \type,
        "findObjectLocal",
        [string(), integer()],
        [key, level]
    );
}

Exp findObjectLocal(Type \type, int ladder, Exp key) {
    return findObjectX(
        \type,
        "findObjectLocal",
        [integer(), string()],
        [iconst(ladder), key]
    );
}

Exp findObjectLocal(Type \type, int ladder, Exp key, Exp level) {
    return findObjectX(
        \type,
        "findObjectLocal",
        [integer(), string(), integer()],
        [iconst(ladder), key, level]
    );
}

Exp putObject(Exp key, Exp val) {
    return putObjectX(
        [string(), object()],
        [key, val]
    );
}

Exp putObject(Exp key, Exp val, Exp level) {
    return putObjectX(
        [string(), object(), integer()],
        [key, val, level]
    );
}

Exp putObject(int ladder, Exp key, Exp val) {
    return putObjectX(
        [integer(), string(), object()],
        [iconst(ladder), key, val]
    );
}

Exp putObject(int ladder, Exp key, Exp val, Exp level) {
    return putObjectX(
        [integer(), string(), object(), integer()],
        [iconst(ladder), key, val, level]
    );
}

private Exp findObjectX(Type \type, str name, list[Type] argTypes, list[Exp] args) {
    return checkcast(
        invokeVirtual(
            object("Env"),
            getEnv(),
            methodDesc(
                object(),
                name,
                argTypes
            ),
            args
        ),
        \type
    );
}

private Exp putObjectX(list[Type] argTypes, list[Exp] args) {
    return invokeVirtual(
        object("Env"),
        getEnv(),
        methodDesc(
            \void(),
            "putObject",
            argTypes
        ),
        args
    );
}

private Exp getEnv() {
    return getField(object("Env"), "__FBEG_env");
}