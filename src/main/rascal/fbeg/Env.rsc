module fbeg::Env

import lang::flybytes::Syntax;

import fbeg::api::Types;

private Type cmi = object("io.usethesource.capsule.Map$Immutable");
private Type cpm = object("io.usethesource.capsule.core.PersistentTrieMap");

private int cnt = 0;

alias Env = value;

@javaClass{fbeg.Env}
java Env makeEnv();

@javaClass{fbeg.Env}
java map[str,value] envToMap(Env env);

/**
 *  Returns a new, empty environment.
 */
Exp newEnv() = invokeStatic(cpm, methodDesc(cmi, "of", []), []);

/**
 *  Returns the environment stored in the field "globalEnv".
 */
Exp globalEnv() = getField(cmi, "globalEnv");

/**
 *  Returns the environment stored in the field "retEnv".
 *  This field holds the environment returned by the most recent recEval call.
 */
Exp retEnv() = getField(cmi, "retEnv");

/**
 *  Stores the environment returned by the last recEval call in the given variable.
 *
 *  @param envVar The variable to store the updated environment in. Defaults to "env".
 */
Stat recEnv(str envVar = "env") = store(envVar, retEnv());

/**
 *  Stores an environment in the field "retEnv". This is used to return an environment
 *  from a recEval call, or can for example be used to initialize the retEnv field to
 *  the current environment prior to a loop that uses and assigns to this field.
 */
Stat setRetEnv(Exp val = load("env")) = putField(cmi, "retEnv", val);

/**
 *  Returns the environment Type.
 */
Type envType() = cmi;

/**
 *  Finds the object with the given key in the given environment.
 *
 *  @param key The key of the object to find.
 *  @param env The environment in which to search. Defaults to the local variable "env".
 *
 *  @return The value found in the environment.
 */
Exp findObject(Exp key, Exp env = load("env"))
    = invokeInterface(cmi, env, methodDesc(object(), "get", [object()]), [key]);

/**
 *  Finds the object with the given key in the given environment and converts it to the given type.
 *
 *  @param key  The key of the object to find.
 *  @param type The type of the object to find. A value of this type will be returned.
 *  @param env  The environment in which to search. Defaults to the local variable "env".
 *
 *  @return The value found in the environment.
 */
Exp findObject(Exp key, Type \type, Exp env = load("env"))
    = fromObject(findObject(key, env = env), \type);

/**
 * Finds the wrapped object with the given key at the given level, and returns the (unwrapped) value.
 *
 * @param key   The key of the object to find.
 * @param type  The type of the object to find. A value of this type will be returned.
 * @param env   The environment in which to search. Defaults to the local variable "env".
 *
 * @return The (unwrapped) value found in the environment.
 */
Exp findWrapped(Exp key, Type \type, Exp env = load("env"))
    = getWrapper(findObject(key, env = env), \type);

/**
 *  Maps the given key to the given object and returns the new environment.
 *
 *  @param key  The key to map to the object.
 *  @param val  The object to store in the environment.
 *  @param env  The (immutable) environment to which the object should be added.
 *              Defaults to the local variable "env".
 *
 *  @return     The new (immutable) environment containing the newly added object.
 */
Exp putObjectCopy(Exp key, Exp val, Exp env = load("env"))
    = invokeInterface(cmi, env, methodDesc(cmi, "__put", [object(), object()]), [key, val]);

/**
 *  Maps the given key to the given object in the environment, and stores the new
 *  environment in the given field.
 *
 *  @param key      The key to map to the object.
 *  @param val      The object to store in the environment.
 *  @param env      The environment to which the object should be added. Defaults to the local variable "env".
 *  @param field    The name of the field in which the new environment should be stored. Defaults to "retEnv".
 */
Stat putObjectField(Exp key, Exp val, Exp env = load("env"), str field = "retEnv")
    = putField(envType(), field, putObjectCopy(key, val, env = env));

/**
 *  Maps the given key to the given object in the environment in the given variable.
 *  This function stores the new environment in the variable with the given name.
 *
 *  @param key      The key to map to the object.
 *  @param val      The object to store in the environment.
 *  @param env      The environment to which the object should be added. Defaults to the local variable "env".
 *  @param envVar   The name of the (non-final) local variable holding the environment. Defaults to "env".
 */
Stat putObject(Exp key, Exp val, Exp env = load("env"), str envVar = "env")
    = store(envVar, putObjectCopy(key, val, env = env));

/**
 *  Maps the given key to the given primitive object in the environment.
 *  The provided value should be a primitive of the specified type, and will be
 *  converted to the corresponding class by calling the valueOf(...) method of that class.
 * 
 *  @param key      The key to map to the object.
 *  @param value    The object to store in the environment.
 *  @param type     The primitive type of the value to be stored.
 *  @param env      The environment to use. Defaults to the local variable "env".
 */
Exp putObjectCopy(Exp key, Exp val, Type \type, Exp env = load("env"))
    = putObjectCopy(key, toObject(val, \type), env = env);

/**
 *  Maps the given key to the given object in the environment, and stores the new
 *  environment in the given field. 
 *  The provided value should be a primitive of the specified type, and will be
 *  converted to the corresponding class by calling the valueOf(...) method of that class.
 *
 *  @param key      The key to map to the object.
 *  @param val      The object to store in the environment.
 *  @param type     The primitive type of the value to be stored.
 *  @param env      The environment to which the object should be added. Defaults to the local variable "env".
 *  @param field    The name of the field in which the new environment should be stored. Defaults to "retEnv".
 */
Stat putObjectField(Exp key, Exp val, Type \type, Exp env = load("env"), str field = "retEnv")
    = putField(envType(), field, putObjectCopy(key, toObject(val, \type), env = env));

/**
 *  Maps the given key to the given primitive object in the environment.
 *  The provided value should be a primitive of the specified type, and will be
 *  converted to the corresponding class by calling the valueOf(...) method of that class.
 *  This function loads the environment variable with the given name and stores the
 *  new environment in the same variable, thus overwriting the old environment.
 * 
 *  @param key      The key to map to the object.
 *  @param value    The object to store in the environment.
 *  @param type     The primitive type of the value to be stored.
 *  @param envVar   The name of the (non-final) local variable holding the environment. Defaults to "env".
 */
Stat putObject(Exp key, Exp val, Type \type, Exp env = load("env"), str envVar = "env")
    = putObject(key, toObject(val, \type), env = env, envVar = envVar);

/**
 *  Maps the given key to the given value in the environment, and wraps the value of the given type into a wrapper object.
 *  If a wrapper object with the given key is not present in the given environment, a new object will be stored in it.
 *  If a wrapper object with the given key is present in the given environment, its value will be replaced by the new value
 *  and this is also reflected to all other environments in which the wrapper object is stored; the wrapper acts as a reference.
 * 
 *  @param key      The key to map to the object.
 *  @param value    The object to store in the environment.
 *  @param env      Expression representing the environment to use. Defaults to local variable "env".
 *  @param replace  Defaults to false. If set to true, this function will always create a new wrapper object and store it at the
 *                  given level. Any existing object will be replaced. This new object will NOT be stored in any other levels, even
 *                  if an existing object is present in other levels.
 */
Exp putWrappedCopy(Exp key, Exp val, Type \type, Exp env = load("env"), bool replace = false) {
    Exp repl = putObjectCopy(key, newWrapper(val, \type), env = env);
    if (replace) return repl;
    tuple[Type w, Type v] t = wrapperType(\type);
    cnt += 1;
    str wrapper = "__FBEG_tmp_<cnt>";
    return sblock(
        [decl(t.w, wrapper, init = findObject(key, t.w, env = env))],
        cond(
            eq(load(wrapper), null()),
            repl,
            sblock(
                [putWrapper(load(wrapper), val, \type)],
                env
            )
        )
    );
}

/**
 *  Maps the given key to the given value in the environment, and wraps the value of the given type into a wrapper object.
 *  The new environment with the added value will be stored in the given field.
 *  If a wrapper object with the given key is not present in the given environment, a new object will be stored in it.
 *  If a wrapper object with the given key is present in the given environment, its value will be replaced by the new value
 *  and this is also reflected to all other environments in which the wrapper object is stored; the wrapper acts as a reference.
 * 
 *  @param key      The key to map to the object.
 *  @param value    The object to store in the environment.
 *  @param env      Expression representing the environment to use. Defaults to local variable "env".
 *  @param field    The name of the field in which the new environment should be stored. Defaults to "retEnv".
 *  @param replace  Defaults to false. If set to true, this function will always create a new wrapper object and store it at the
 *                  given level. Any existing object will be replaced. This new object will NOT be stored in any other levels, even
 *                  if an existing object is present in other levels.
 */
Stat putWrappedField(Exp key, Exp val, Type \type, Exp env = load("env"), str field = "retEnv", bool replace = false) {
    Stat repl = putObjectField(key, newWrapper(val, \type), env = env, field = field);
    if (replace) return repl;
    tuple[Type w, Type v] t = wrapperType(\type);
    cnt += 1;
    str wrapper = "__FBEG_tmp_<cnt>";
    return block([
        decl(t.w, wrapper, init = findObject(key, t.w, env = env)),
        \if(
            eq(load(wrapper), null()),
            [repl],
            [putWrapper(load(wrapper), val, \type), putField(envType(), field, env)]
        )
    ]);
}

/**
 *  Maps the given key to the given value in the environment, and wraps the value of the given type into a wrapper object.
 *  If a wrapper object with the given key is not present in the given environment, a new object will be stored in it.
 *  If a wrapper object with the given key is present in the given environment, its value will be replaced by the new value
 *  and this is also reflected to all other environments in which the wrapper object is stored; the wrapper acts as a reference.
 *  This function stores the new environment in the variable with the given name.
 * 
 *  @param key      The key to map to the object.
 *  @param value    The object to store in the environment.
 *  @param env      The environment to which the object should be added. Defaults to the local variable "env".
 *  @param envVar   The name of the (non-final) local variable to store the new environment in. Defaults to "env".
 *  @param replace  Defaults to false. If set to true, this function will always create a new wrapper object and store it at the
 *                  given level. Any existing object will be replaced.
 */
Stat putWrapped(Exp key, Exp val, Type \type, Exp env = load("env"), str envVar = "env", bool replace = false) {
    Stat repl = putObject(key, newWrapper(val, \type), env = env, envVar = envVar);
    if (replace) return repl;
    tuple[Type w, Type v] t = wrapperType(\type);
    cnt += 1;
    str wrapper = "__FBEG_tmp_<cnt>";
    return block([
        decl(t.w, wrapper, init = findObject(key, t.w, env = load(envVar))),
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