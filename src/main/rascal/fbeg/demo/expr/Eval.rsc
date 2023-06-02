module fbeg::demo::expr::Eval

import fbeg::demo::expr::AST;

alias Env = map[str,int];
alias Res = tuple[int val, Env env];

Res eval(prog(list[Expr] exprs, Expr ret), Env env) {
    for (Expr e <- exprs) env = eval(e, env).env;
    return eval(ret, env);
}

Res eval(nat(int n), Env env) = <n, env>;

Res eval(var(str name), Env env) = <env[name], env>;

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

Res eval(assign(str name, Expr val), Env env) {
    Res res = eval(val, env);
    return <res.val, res.env + (name : res.val)>;
}