module fbeg::Env

import lang::flybytes::Syntax;

import fbeg::api::Types;

alias Env = value;

private int cnt = 0;

/**
 * Expression returning the "env" field from the current class.
 */
Exp defaultEnvField = getField(object("fbeg.Env"), "env");

/**
 * Returns a new, empty environment.
 */
@javaClass{fbeg.Env}
java Env newEnv();

/**
 * Returns a Type representing the Env class.
 */
Type getEnvType() {
    return object("fbeg.Env");
}

/**
 * Returns the current highest level.
 *
 * @param env Expression representing the environment to use. Defaults to the "env" field.
 */
Exp getLevel(Exp env = defaultEnvField) {
    return invoke(env, integer(), "getLevel", [], []);
}

/**
 * Increases the level and returns the new highest level.
 * The newly created level will be empty.
 *
 * @param env Expression representing the environment to use. Defaults to the "env" field.
 */
Exp addEmptyLevel(Exp env = defaultEnvField) {
    return invoke(env, integer(), "addEmptyLevel", [], []);
}

/**
 * Increases the level and returns the new highest level.
 * The newly created level will hold all objects stored at the given level.
 * 
 * @param baseLevel The level from which the contents should be copied to the new level. By default, the current highest level is used.
 * @param env       Expression representing the environment to use. Defaults to the "env" field.
 */
Exp addLevel(Exp baseLevel = null(), Exp env = defaultEnvField) {
    return baseLevel == null()
        ? invoke(env, integer(), "addLevel", []         , []         )
        : invoke(env, integer(), "addLevel", [integer()], [baseLevel]);
}

/**
 * Decreases the level (removing the highest level) and returns the new highest level.
 *
 * @param env Expression representing the environment to use. Defaults to the "env" field.
 */
Exp removeLevel(Exp env = defaultEnvField) {
    return invoke(env, integer(), "removeLevel", [], []);
}

/**
 * Increases the level index without changing the levels.
 * This may be used to pretend having a different highest level for an evaluation.
 * Before increasing the index, a level at the increased index has to be created with addLevel or similar methods.
 * If this is not done, the behaviour of putObject/findObject and similar methods after this call is undefined.
 */
Exp levelUp(Exp env = defaultEnvField) {
    return invoke(env, integer(), "levelUp", [], []);
}

/**
 * Decreases the level index without changing the levels.
 * This may be used to pretend having a different highest level for an evaluation.
 */
Exp levelDown(Exp env = defaultEnvField) {
    return invoke(env, integer(), "levelDown", [], []);
}

/**
 * Finds the object with the given key at the given level.
 * 
 * @param key   The key of the object to find.
 * @param level The level to search at. By default, it will search at the highest level.
 * @param env   Expression representing the environment to use. Defaults to the "env" field.
 *
 * @return The value found in the environment.
 */
Exp findObject(Exp key, Exp level = null(), Exp env = defaultEnvField) {
    return level == null()
        ? invoke(env, object(), "findObject", [string()           ], [key       ])
        : invoke(env, object(), "findObject", [string(), integer()], [key, level]);
}

/**
 * Finds the object with the given key at the given level and converts it to the given type.
 * 
 * @param key   The key of the object to find.
 * @param type  The type to convert the found object to. If this is a primitive type, the ...value()
 *              method of the corresponding class will be found on the called object.
 *              For other types, a checkcast will be used to convert the object.
 * @param level The level to search at. By default, it will search at the highest level.
 * @param env   Expression representing the environment to use. Defaults to the "env" field.
 *
 * @return The value found in the environment.
 */
Exp findObject(Exp key, Type \type, Exp level = null(), Exp env = defaultEnvField) {
    return fromObject(findObject(key, level = level, env = env), \type);
}

/**
 * Finds the wrapped object with the given key at the given level, and returns the (unwrapped) value.
 *
 * @param key   The key of the object to find.
 * @param type  The type of the object to find. A value of this type will be returned.
 * @param level The levle to search at. By default, it will search at the highest level.
 * @param env   Expression representing the environment to use. Defaults to the "env" field.
 *
 * @return The (unwrapped) value found in the environment.
 */
Exp findWrapped(Exp key, Type \type, Exp level = null(), Exp env = defaultEnvField) {
    return getWrapper(findObject(key, level = level, env = env), \type);
}

/**
 * Maps the given key to the given object in the environment.
 * The object is stored in the environment at the given level.
 * The object will NOT be stored in any level above the given level.
 * 
 * @param key   The key to map to the object.
 * @param value The object to store in the environment.
 * @param level The level at which the object should be stored. By default, the object will be stored at the highest level.
 * @param env   Expression representing the environment to use. Defaults to the "env" field.
 * @param inc   Defaults to false. If set to true, the level is increased and the object is stored in the new highest
 *              level. The specified level (or the current highest level if unspecified) is the level that is copied
 *              to the newly created level.
 */
Stat putObject(Exp key, Exp val, Exp level = null(), Exp env = defaultEnvField, bool inc = false) {
    str method = inc ? "putObjectInc" : "putObject";
    return level == null()
        ? \do(invoke(env, \void(), method, [string(), object()           ], [key, val       ]))
        : \do(invoke(env, \void(), method, [string(), object(), integer()], [key, val, level]));
}

/**
 * Maps the given key to the given primitive object in the environment.
 * The provided value should be a primitive of the specified type, and will be
 * converted to the corresponding class by calling the valueOf(...) method of that class.
 * The object is stored in the environment at the given level.
 * The object will NOT be stored in any level above the given level.
 * 
 * @param key   The key to map to the object.
 * @param value The object to store in the environment.
 * @param type  The primitive type of the value to be stored.
 * @param level The level at which the object should be stored. By default, the object will be stored at the highest level.
 * @param env   Expression representing the environment to use. Defaults to the "env" field.
 * @param inc   Defaults to false. If set to true, the level is increased and the object is stored in the new highest
 *              level. The specified level (or the current highest level if unspecified) is the level that is copied
 *              to the newly created level.
 */
Stat putObject(Exp key, Exp val, Type \type, Exp level = null(), Exp env = defaultEnvField, bool inc = false) {
    return putObject(key, toObject(val, \type), level = level, env = env, inc = inc);
}

/**
 * Maps the given key to the given value in the environment, and wraps the value of the given type into a wrapper object.
 * The object is stored in the environment at the given level.
 * If a wrapper object with the given key is not present at the given level, a new object will be stored at the given level.
 * The new object will NOT be stored in any level above the given level.
 * If a wrapper object with the given key is present at the given level, its value will be replaced by the new value and this is
 * also reflected to other levels at which the wrapper object is stored. This can affect both lower and higher levels.
 * 
 * @param key       The key to map to the object.
 * @param value     The object to store in the environment.
 * @param level     The level at which the object should be stored. By default, the object will be stored at the highest level.
 * @param env       Expression representing the environment to use. Defaults to the "env" field.
 * @param inc       Defaults to false. If set to true, the level is increased and the object is stored in the new highest
 *                  level. The specified level (or the current highest level if unspecified) is the level that is copied
 *                  to the newly created level.
 * @param replace   Defaults to false. If set to true, this function will always create a new wrapper object and store it at the
 *                  given level. Any existing object will be replaced. This new object will NOT be stored in any other levels, even
 *                  if an existing object is present in other levels.
 */
Stat putWrapped(Exp key, Exp val, Type \type, Exp level = null(), Exp env = defaultEnvField, bool inc = false, bool replace = false) {
    Stat repl = putObject(key, newWrapper(val, \type), level = level, env = env, inc = inc);
    if (replace) return repl;
    tuple[Type w, Type v] t = wrapperType(\type);
    cnt += 1;
    str wrapper = "__FBEG_tmp_<cnt>";
    return block([
        decl(t.w, wrapper, init = findObject(key, t.w, level = level, env = env)),
        \if(
            eq(load(wrapper), null()),
            [repl],
            [putWrapper(load(wrapper), val, \type)]
        )
    ]);
}

private Exp newWrapper(Exp val, Type \type) {
    tuple[Type w, Type v] t = wrapperType(\type);
    return newInstance(
        t.w,
        constructorDesc([t.v]),
        [val]
    );
}

private Stat putWrapper(Exp wrapper, Exp val, Type \type) {
    tuple[Type w, Type v] t = wrapperType(\type);
    return putField(
        t.w,
        wrapper,
        t.v,
        "value",
        val
    );
}

private Exp getWrapper(Exp wrapper, Type \type) {
    tuple[Type w, Type v] t = wrapperType(\type);
    return getField(
        t.w,
        checkcast(wrapper, t.w),
        t.v,
        "value"
    );
}

private tuple[Type,Type] wrapperType(Type \type) {
    str name = "";
    switch (\type) {
        case byte():        name = "Byte";
        case boolean():     name = "Boolean";
        case short():       name = "Short";
        case character():   name = "Character";
        case integer():     name = "Integer";
        case float():       name = "Float";
        case double():      name = "Double";
        case long():        name = "Long";
        default:            return <object("fbeg.wrapper.ObjectWrapper"), object()>;
    }
    return <object("fbeg.wrapper.<name>Wrapper"), \type>;
}

private Exp invoke(Exp env, Type ret, str name, list[Type] argTypes, list[Exp] args) {
    return invokeVirtual(
        object("fbeg.Env"),
        env,
        methodDesc(ret, name, argTypes),
        args
    );
}