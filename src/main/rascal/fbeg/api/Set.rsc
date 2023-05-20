module fbeg::api::Set

import fbeg::api::Types;

import lang::flybytes::Syntax;

private str vl = "io.usethesource.vallang.";

Exp set_isEmpty(Exp obj) {
    return invokeInterface(
        object("<vl>ICollection"),
        obj,
        methodDesc(
            boolean(),
            "isEmpty",
            []
        ),
        []
    );
}

Exp set_size(Exp obj) {
    return invokeInterface(
        object("<vl>ICollection"),
        obj,
        methodDesc(
            integer(),
            "size",
            []
        ),
        []
    );
}

Exp set_contains(Exp obj, Exp val) {
    return invokeInterface(
        object("<vl>ISet"),
        obj,
        methodDesc(
            boolean(),
            "contains",
            [object("<vl>IValue")]
        ),
        [val]
    );
}

Exp set_contains(Exp obj, Exp val, Exp vf, Type \type) {
    return set_contains(obj, toRascalType(vf, val, \type));
}