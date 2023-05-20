package fbeg;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.List;
import java.util.Map;
import java.util.function.BiFunction;

import io.usethesource.vallang.IConstructor;
import io.usethesource.vallang.IMap;
import io.usethesource.vallang.ISourceLocation;
import io.usethesource.vallang.IString;
import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;
import io.usethesource.vallang.type.ExternalType;
import io.usethesource.vallang.type.Type;
import io.usethesource.vallang.type.TypeFactory;

import org.rascalmpl.ast.AbstractAST;
import org.rascalmpl.ast.Expression.Closure;
import org.rascalmpl.ast.Expression.VoidClosure;
import org.rascalmpl.ast.FunctionDeclaration;
import org.rascalmpl.ast.Parameters;
import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.interpreter.result.OverloadedFunction;
import org.rascalmpl.values.RascalFunctionValueFactory; 
import org.rascalmpl.values.functions.IFunction;

public final class EvalGen {

    private final IValueFactory vf;

    public EvalGen(final IValueFactory vf) {
       this.vf = vf;
    }

    public final IFunction genEvalFunc(IValue funcType, IString name, IEvaluatorContext ctx) {
        final RascalFunctionValueFactory ff = new RascalFunctionValueFactory(ctx);
        final Type type = ((ExternalType) funcType.getType()).getTypeParameters().getFieldType(0);

        final BiFunction<IValue[], Map<String, IValue>, IValue> bifunc;
        try {
            final URL[] urls = new URL[] {getDirURI().toURL()};
            final ClassLoader cl = new URLClassLoader(urls);
            final Class<? extends BiFunction<IValue[], Map<String, IValue>, IValue>> clazz = cl.loadClass(name.getValue()).asSubclass(BiFunction.class);
            bifunc = clazz.getConstructor(IValueFactory.class).newInstance(this.vf);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }

        return ff.function(type, bifunc);
    }

    public final IMap getFuncSrc(IFunction function, IEvaluatorContext ctx) {
        IMap map = this.vf.map();
        if (!(function instanceof OverloadedFunction)) return map;
        final OverloadedFunction func = (OverloadedFunction) function;
        var candidates = func.getPrimaryCandidates();
        for (var candidate : candidates) {
            var params = getParameters(candidate.getAst());
            if (params == null) return map;
            var formals = params.getFormals().getFormals();
            final IValue string = formals.get(0).getMatcher(ctx, true).toIValue();
            map = map.put(string, candidate.getAst().getLocation());
        }
        return map;
    }

    private final Parameters getParameters(final AbstractAST ast) {
        if (ast instanceof FunctionDeclaration) return ((FunctionDeclaration) ast).getSignature().getParameters();
        if (ast instanceof Closure)             return ((Closure) ast).getParameters();
        if (ast instanceof VoidClosure)         return ((VoidClosure) ast).getParameters();
        return null;
    }

    public final ISourceLocation getDir() {
        return this.vf.sourceLocation(getDirURI());
    }

    private final URI getDirURI() {
        return new File("interpreters/").toURI();
    }

}