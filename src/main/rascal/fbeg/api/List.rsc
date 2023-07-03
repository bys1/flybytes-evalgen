module fbeg::api::List

import fbeg::api::Types;

import lang::flybytes::Syntax;

private str vl = "io.usethesource.vallang.";

/**
 *  Returns whether the given list is empty.
 *
 *  @param obj The list to check.
 *
 *  @returns Whether the given list is empty.
 */
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

/**
 *  Returns the size of the given list.
 *
 *  @param obj The list to get the size from.
 *
 *  @returns The amount of elements in the given list.
 */
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

/**
 *  Returns the element at the specified index of the given list,
 *  and converts the Rascal type to the given Java type.
 *
 *  @param obj      The list to get an element from.
 *  @param index    The index of the element to retrieve.
 *  @param type     The type to convert the element to.
 *
 *  @returns The element found at the given position in the list.
 */
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

/**
 *  Returns whether the given list contains the specified element.
 *
 *  @param obj The list to check.
 *  @param val The element to check for presence in the list.
 *
 *  @returns Whether the given list contains the specified element.
 */
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

/**
 *  Returns whether the given list contains the specified element,
 *  while converting the specified element to a Rascal type.
 *
 *  @param obj  The list to check.
 *  @param val  The element to check for presence in the list.
 *  @param vf   An IValueFactory used to convert the element to a Rascal type.
 *  @param type The Rascal type to convert the element to.
 *
 *  @returns Whether the given list contains the specified element.
 */
Exp list_contains(Exp obj, Exp val, Exp vf, Type \type) {
    return list_contains(obj, toRascalType(vf, val, \type));
}