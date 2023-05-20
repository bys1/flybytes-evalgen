module fbeg::api::List

import fbeg::api::Types;

import lang::flybytes::Syntax;

private str vl = "io.usethesource.vallang.";

Exp list_isEmpty(Exp obj) {
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

Exp list_size(Exp obj) {
    return invokeInterface(
        object("<vl>IList"),
        obj,
        methodDesc(
            integer(),
            "length",
            []
        ),
        []
    );
}

Exp list_get(Exp obj, Exp index, Type \type) {
    return fromRascalType(
        invokeInterface(
            object("<vl>IList"),
            obj,
            methodDesc(
                object("<vl>IValue"),
                "get",
                [integer()]
            ),
            [index]
        ),
        \type
    );
}

Exp list_contains(Exp obj, Exp val) {
    return invokeInterface(
        object("<vl>IList"),
        obj,
        methodDesc(
            boolean(),
            "contains",
            [object("<vl>IValue")]
        ),
        [val]
    );
}

Exp list_contains(Exp obj, Exp val, Exp vf, Type \type) {
    return list_contains(obj, toRascalType(vf, val, \type));
}