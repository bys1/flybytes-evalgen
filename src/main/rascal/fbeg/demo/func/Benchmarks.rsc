module fbeg::demo::func::Benchmarks

import fbeg::demo::func::AST;
import fbeg::demo::func::Compiler;
import fbeg::demo::func::Eval;
import fbeg::demo::func::Gen;

import IO;
import List;

import util::Benchmark;
import util::Math;

Prog p;
int(Prog) ev;

@reflect
@javaClass{fbeg.func.demo.Benchmarks}
private java &F getFunc(type[&F] t);

void benchmark(str program) = benchmark(parseProg(|cwd:///src/main/rascal/fbeg/demo/func/<program>.func|));

void benchmark(Prog program, bool compiled = true) {
    p = program;
    ev = getEval();
    if (compiled) {
        compileProg(p, "BMCProg");
        bmCompiled = getFunc(#(void()));
        benchmark(program, "Compiled", bmCompiled);
    }
    benchmark(program, "EvalGen", bmEvalGen);
    benchmark(program, "Eval", bmEval);
}

void benchmarkFunc(int count, bool compiled = true) {
    Prog p2 = getFuncProg(count);
    p = getFuncProgFind(count);
    ev = getEval();
    if (compiled) {
        compileProg(p2, "BMCProg");
        bmCompiled = getFunc(#(void()));
        benchmark(p2, "Compiled", bmCompiled);
    }
    ev(p2);
    benchmark(p, "EvalGen", bmEvalGen);
    eval(p2, ());
    benchmark(p, "Eval", bmEval);
}

void benchmark(Prog program, str name, void() func, bool print=false) {
    list[num] times = [];
    int cnt = 50;
    // Warming up
    for (_ <- [0..20]) {
        gc();
        func();
    }
    // Actual benchmarks
    for (_ <- [0..cnt]) {
        gc();
        times += cpuTimeOf(func);
        if (print) println(last(times));
    }
    println("<name>: <[time / 1000000 | time <- times]>");
    println("Average: <(0 | it + time | time <- times) / 1000000 / cnt>");
    list[num] sorted = sort(times);
    println("95th percentile: <sorted[ceil(cnt * 0.95) - 1] / 1000000>");
    println("90th percentile: <sorted[ceil(cnt * 0.90) - 1] / 1000000>");
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
        (nat(1) | add(it, nat(1)) | _ <- [1..count])
    )
]);

Prog getLetProg(int count) = prog([
    func(
        "main",
        [],
        let(
            [binding("x<i>", nat(1)) | i <- [0..count]],
            nat(1)
        )
    )
]);

Prog getFuncProg(int count) = prog(
    [func("main", [], call("f<floor(count/2)>", []))]
    + [func("f<i>", [], nat(1)) | i <- [0..count]]
);

Prog getFuncProgFind(int count) = prog([func("main", [], call("f0", []))]);