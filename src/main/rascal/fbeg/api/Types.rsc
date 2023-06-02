module fbeg::api::Types

import lang::flybytes::Syntax;

import Type;
import Exception;

private str vl = "io.usethesource.vallang.";

private Exp rascalToInt(Exp obj) {
    return invokeInterface(
        object("<vl>IInteger"),
        obj,
        methodDesc(
            integer(),
            "intValue",
            []
        ),
        []
    );
}

private Exp intToRascal(Exp vf, Exp obj) {
    return invokeInterface(
        object("<vl>IValueFactory"),
        vf,
        methodDesc(
            object("<vl>IInteger"),
            "integer",
            [integer()]
        ),
        [obj]
    );
}

private Exp realToRascal(Exp vf, Exp obj) {
    return invokeInterface(
        object("<vl>IValueFactory"),
        vf,
        methodDesc(
            object("<vl>IReal"),
            "real",
            [double()]
        ),
        [obj]
    );
}

private Type primType(Type \type) {
    switch (\type) {
        case byte():        return object("java.lang.Byte");
        case boolean():     return object("java.lang.Boolean");
        case short():       return object("java.lang.Short");
        case character():   return object("java.lang.Character");
        case integer():     return object("java.lang.Integer");
        case float():       return object("java.lang.Float");
        case double():      return object("java.lang.Double");
        case long():        return object("java.lang.Long");
        default: return object();
    }
}

private str primMethod(Type \type) {
    switch (\type) {
        case byte():        return "byteValue";
        case boolean():     return "booleanValue";
        case short():       return "shortValue";
        case character():   return "charValue";
        case integer():     return "intValue";
        case float():       return "floatValue";
        case double():      return "doubleValue";
        case long():        return "longValue";
        default: return "";
    }
}

Exp toObject(Exp exp, Type \type) {
    Type obj = primType(\type);
    if (obj == object()) return exp;
    return invokeStatic(
        obj,
        methodDesc(
            obj,
            "valueOf",
            [\type]
        ),
        [exp]
    );
}

Exp fromObject(Exp exp, Type \type) {
    Type obj = primType(\type);
    if (obj == object()) return checkcast(exp, \type);
    return invokeVirtual(
        obj,
        checkcast(
            exp,
            obj
        ),
        methodDesc(
            \type,
            primMethod(\type),
            []
        ),
        []
    );
}

Exp toRascalType(Exp vf, Exp obj, Type \type) {
    switch (\type) {
        case byte():
            return intToRascal(vf, obj);
        case boolean():
            return invokeInterface(
                object("<vl>IValueFactory"),
                vf,
                methodDesc(
                    object("<vl>IBool"),
                    "bool",
                    [boolean()]
                ),
                [obj]
            );
        case short():
            return intToRascal(vf, obj);
        case character():
            return intToRascal(vf, obj);
        case integer():
            return intToRascal(vf, obj);
        case float():
            return realToRascal(vf, obj);
        case double():
            return realToRascal(vf, obj);
        case long():
            return invokeInterface(
                object("<vl>IValueFactory"),
                vf,
                methodDesc(
                    object("<vl>IInteger"),
                    "integer",
                    [long()]
                ),
                [obj]
            );
        case string():
            return invokeInterface(
                object("<vl>IValueFactory"),
                vf,
                methodDesc(
                    object("<vl>IString"),
                    "string",
                    [string()]
                ),
                [obj]
            );
        default: return obj;
    }
}

Exp fromRascalType(Exp obj, Type \type) {
    switch (\type) {
        case byte():
            return coerce(integer(), byte(), rascalToInt(obj));
        case boolean():
            return invokeInterface(
                object("<vl>IBool"),
                obj,
                methodDesc(
                    boolean(),
                    "getValue",
                    []
                ),
                []
            );
        case short():
            return coerce(integer(), short(), rascalToInt(obj));
        case character():
            return coerce(integer(), character(), rascalToInt(obj));
        case integer():
            return rascalToInt(obj);
        case float():
            return invokeInterface(
                object("<vl>IReal"),
                obj,
                methodDesc(
                    float(),
                    "floatValue",
                    []
                ),
                []
            );
        case double():
            return invokeInterface(
                object("<vl>IReal"),
                obj,
                methodDesc(
                    double(),
                    "doubleValue",
                    []
                ),
                []
            );
        case long():
            return invokeInterface(
                object("<vl>IInteger"),
                obj,
                methodDesc(
                    long(),
                    "longValue",
                    []
                ),
                []
            );
        case string():
            return invokeInterface(
                object("<vl>IString"),
                obj,
                methodDesc(
                    string(),
                    "getValue",
                    []
                ),
                []
            );
        default:
            return checkcast(obj, \type);
    }
}

/**
 *  Converts a Symbol representing a Rascal type to the Java class representing that type.
 *  For example, Symbol::int() is converted to object("io.usethesource.vallang.IInteger").
 *  Most common types are supported. Otherwise an IllegalArgument error is thrown.
 *
 *  @param sym Symbol representing the Rascal type to convert.
 *
 *  @returns A Flybytes Type representing the Rascal Java class.
 */
Type symbolToTypeClass(Symbol sym) {
    switch (sym) {
        case label(_, Symbol s): return symbolToTypeClass(s);
        case \int():        return object("<vl>IInteger");
        case \bool():       return object("<vl>IBool");
        case \real():       return object("<vl>IReal");
        case \rat():        return object("<vl>IRational");
        case \str():        return object("<vl>IString");
        case \num():        return object("<vl>INumber");
        case \node():       return object("<vl>INode");
        case \value():      return object("<vl>IValue");
        case \loc():        return object("<vl>ISourceLocation");
        case \datetime():   return object("<vl>IDateTime");
        case \set(_):       return object("<vl>ISet");
        case \tuple(_):     return object("<vl>ITuple");
        case \list(_):      return object("<vl>IList");
        case \map(_, _):    return object("<vl>IMap");
        case adt(_, _):     return object("<vl>IConstructor");
        default: throw IllegalArgument(sym, "Unknown type");
    }
}

Type getTreeType() {
    return object("<vl>IConstructor");
}