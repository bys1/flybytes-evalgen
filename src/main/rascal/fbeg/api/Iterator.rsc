module fbeg::api::Iterator

import fbeg::api::Types;

import lang::flybytes::Syntax;

Exp it_get(Exp obj) {
    return invokeInterface(
        object("java.lang.Iterable"),
        obj,
        methodDesc(
            object("java.util.Iterator"),
            "iterator",
            []
        ),
        []
    );
}

Stat it_decl(str name, Exp obj) {
    return decl(
        object("java.util.Iterator"),
        name,
        init = it_get(obj)
    );
}

Exp it_next(Exp obj) {
    return invokeInterface(
        object("java.util.Iterator"),
        obj,
        methodDesc(
            object(),
            "next",
            []
        ),
        []
    );
}

Exp it_next(Exp obj, Type \type) {
    return fromRascalType(it_next(obj), \type);
}

Exp it_hasNext(Exp obj) {
    return invokeInterface(
        object("java.util.Iterator"),
        obj,
        methodDesc(
            boolean(),
            "hasNext",
            []
        ),
        []
    );
}