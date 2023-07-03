module fbeg::api::Iterator

import fbeg::api::Types;

import lang::flybytes::Syntax;

/**
 *  Returns an iterator from the given Iterable object.
 *
 *  @param obj  The Iterable object to get an Iterator from.
 *
 *  @returns The Iterator from the object.
 */
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

/**
 *  Declares a variable initialized with an iterator from the given Iterable object.
 *
 *  @param name The name of the variable to declare.
 *  @param obj  The Iterable object to get an Iterator from.
 *
 *  @returns A decl statement with a variable holding the iterator.
 */
Stat it_decl(str name, Exp obj) {
    return decl(
        object("java.util.Iterator"),
        name,
        init = it_get(obj)
    );
}

/**
 *  Returns the next element from the given Iterator.
 *
 *  @param obj The Iterator to get the next element from.
 *
 *  @returns The next element from the Iterator.
 */
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

/**
 *  Returns the next element from the given Iterator with Rascal types,
 *  and converts the element to the given Java type.
 *
 *  @param obj  The Iterator to get the next element from.
 *  @param type The Java type to convert the element to.
 *
 *  @returns The converted Java value.
 */
Exp it_next(Exp obj, Type \type) {
    return fromRascalType(it_next(obj), \type);
}

/**
 *  Returns whether the given Iterator has any more elements.
 *
 *  @param obj  The Iterator to check.
 *
 *  @returns Whether the Iterator has more elements.
 */
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