module fbeg::demo::func::Eval

import fbeg::demo::func::AST;

import List;
import IO;
import Type;

alias Res = tuple[int val, Env env];
alias Fun = tuple[list[str] args, Expr exp];
alias Env = map[str,value];

map[str,Fun] funcEnv = ();

Res eval(prog(list[Func] funcs), Env env) {
    funcEnv = ();
    for (Func f <- funcs) eval(f, env);
    return eval(call("main", []), env);
}

Res eval(func(str name, list[str] args, Expr exp), Env env) {
    funcEnv += (name : <args, exp>);
    return <0, env>;
}

Res eval(let(list[Binding] bindings, Expr exp), Env env) {
    Env copy = env;
    for (Binding binding <- bindings)
        copy = eval(binding, copy).env;
    Res res = eval(exp, copy);
    return <res.val, env + (res.env - (copy - env))>;
}

Res eval(xcond(Expr condition, Expr then, Expr alt), Env env) {
    Res res = eval(condition, env);
    return res.val == 0 ? eval(alt, res.env) : eval(then, res.env);
}

Res eval(loop(Expr condition, Expr then, Expr result), Env env) {
    Res res = <1,env>;
    while (true) {
        res = eval(condition, env);
        if (res.val == 0) break;
        env = eval(then, res.env).env;
    }
    return eval(result, res.env);
}

Res eval(var(str name), Env env) = <typeCast(#int, env[name]), env>;

Res eval(avar(str name, Expr index), Env env) {
    Res idx = eval(index, env);
    return <typeCast(#list[int], idx.env[name])[idx.val], idx.env>;
}

Res eval(nat(int n), Env env) = <n, env>;

Res eval(call(str name, list[Expr] args), Env env) {
    Fun f = funcEnv[name];
    Env newEnv = ();
    for (tuple[str name, Expr arg] t <- zip2(f.args, args)) {
        newEnv += (t.name : eval(t.arg, env).val);
    }
    Res res = eval(f.exp, newEnv);
    return <res.val, env>;
}

Res eval(add(Expr lhs, Expr rhs), Env env) {
    Res lres = eval(lhs, env);
    Res rres = eval(rhs, lres.env);
    return <lres.val + rres.val, rres.env>;
}

Res eval(sub(Expr lhs, Expr rhs), Env env) {
    Res lres = eval(lhs, env);
    Res rres = eval(rhs, lres.env);
    return <lres.val - rres.val, rres.env>;
}

Res eval(mul(Expr lhs, Expr rhs), Env env) {
    Res lres = eval(lhs, env);
    Res rres = eval(rhs, lres.env);
    return <lres.val * rres.val, rres.env>;
}

Res eval(div(Expr lhs, Expr rhs), Env env) {
    Res lres = eval(lhs, env);
    Res rres = eval(rhs, lres.env);
    return <lres.val / rres.val, rres.env>;
}

Res eval(eq(Expr lhs, Expr rhs), Env env) {
    Res lres = eval(lhs, env);
    Res rres = eval(rhs, lres.env);
    return <lres.val == rres.val ? 1 : 0, rres.env>;
}

Res eval(neq(Expr lhs, Expr rhs), Env env) {
    Res lres = eval(lhs, env);
    Res rres = eval(rhs, lres.env);
    return <lres.val != rres.val ? 1 : 0, rres.env>;
}

Res eval(gt(Expr lhs, Expr rhs), Env env) {
    Res lres = eval(lhs, env);
    Res rres = eval(rhs, lres.env);
    return <lres.val > rres.val ? 1 : 0, rres.env>;
}

Res eval(lt(Expr lhs, Expr rhs), Env env) {
    Res lres = eval(lhs, env);
    Res rres = eval(rhs, lres.env);
    return <lres.val < rres.val ? 1 : 0, rres.env>;
}

Res eval(geq(Expr lhs, Expr rhs), Env env) {
    Res lres = eval(lhs, env);
    Res rres = eval(rhs, lres.env);
    return <lres.val >= rres.val ? 1 : 0, rres.env>;
}

Res eval(leq(Expr lhs, Expr rhs), Env env) {
    Res lres = eval(lhs, env);
    Res rres = eval(rhs, lres.env);
    return <lres.val <= rres.val ? 1 : 0, rres.env>;
}

Res eval(assign(str name, Expr exp), Env env) {
    Res res = eval(exp, env);
    return <res.val, res.env + (name : res.val)>;
}

Res eval(aassign(str name, Expr index, Expr exp), Env env) {
    Res idx = eval(index, env);
    Res res = eval(exp, idx.env);
    list[int] arr = typeCast(#list[int], res.env[name]);
    arr[idx.val] = res.val;
    return <res.val, res.env + (name : arr)>;
}

Res eval(seq(Expr lhs, Expr rhs), Env env) {
    Res res = eval(lhs, env);
    return eval(rhs, res.env);
}

Res eval(binding(str ident, Expr exp), Env env) = eval(assign(ident, exp), env);

Res eval(array(str ident, Expr size), Env env) {
    Res res = eval(size, env);
    return <res.val, res.env + (ident : [0 | _ <- [0..res.val]])>;
}
