module fbeg::demo::func::Benchmarks

import fbeg::demo::func::AST;
import fbeg::demo::func::Compiler;
import fbeg::demo::func::Eval;
import fbeg::demo::func::Gen;

import IO;
import Map;

import util::Benchmark;
import util::ShellExec;

Prog p;
int(Prog) ev;

@reflect
@javaClass{fbeg.func.demo.Benchmarks}
private java &F getFunc(type[&F] t);

map[str,num] benchmark(str program) = benchmark(parseProg(|cwd:///src/main/rascal/fbeg/demo/func/<program>.func|));

map[str,num] benchmark(Prog program) {
    p = program;
    ev = getEval();
    compileProg(p, "BMCProg");
    bmCompiled = getFunc(#(void()));
    gc();
    map[str,num] bm = benchmark((
        "Compiled": bmCompiled,
        "Eval": bmEval,
        "EvalGen": bmEvalGen
    ), cpuTimeOf);
    return mapper(bm, id, nanoToMilli);
}

str id(str s) = s;

num nanoToMilli(num time) = time / 1000000;

void() bmCompiled;

void bmEval() {
    int res = eval(p, ()).val;
}

void bmEvalGen() {
    int res = ev(p);
}

void benchmarkAdds() {
    list[int] counts = [1,10,100,1000,5000,10000,20000,30000];
    for (int count <- counts) 
        println(benchmark(getAddProg(count)));
}

Prog getAddProg(int count) = prog([
    func(
        "main",
        [],
        addNode(count)
    )
]);

Expr addNode(int n) = n <= 1 ? nat(1) : add(addNode(n-1), nat(1));