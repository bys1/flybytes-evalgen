module fbeg::api::Set

import fbeg::api::Types;

import lang::flybytes::Syntax;

private str vl = "io.usethesource.vallang.";

/**
 *  Returns whether the given set is empty.
 *
 *  @param obj The set to check.
 *
 *  @returns Whether the given set is empty.
 */
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

/**
 *  Returns the size of the given set.
 *
 *  @param obj The set to get the size from.
 *
 *  @returns The amount of elements in the given set.
 */
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

/**
 *  Returns whether the given set contains the specified element.
 *
 *  @param obj The set to check.
 *  @param val The element to check for presence in the set.
 *
 *  @returns Whether the given set contains the specified element.
 */
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

/**
 *  Returns whether the given set contains the specified element,
 *  while converting the specified element to a Rascal type.
 *
 *  @param obj  The set to check.
 *  @param val  The element to check for presence in the set.
 *  @param vf   An IValueFactory used to convert the element to a Rascal type.
 *  @param type The Rascal type to convert the element to.
 *
 *  @returns Whether the given set contains the specified element.
 */
Exp set_contains(Exp obj, Exp val, Exp vf, Type \type) {
    return set_contains(obj, toRascalType(vf, val, \type));
}