import java.io.File;
import java.lang.reflect.Field;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.Map;
import java.util.function.BiFunction;

import io.usethesource.vallang.IConstructor;
import io.usethesource.vallang.IInteger;
import io.usethesource.vallang.IString;
import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;
import io.usethesource.vallang.type.Type;
import io.usethesource.vallang.type.TypeFactory;

import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.values.RascalFunctionValueFactory; 
import org.rascalmpl.values.functions.IFunction;

public final class Proto {

    private final IValueFactory vf;

    private BiFunction<IValue[], Map<String, IValue>, IValue> funcEval;
    private BiFunction<IValue[], Map<String, IValue>, IValue> progEval;

    public Proto(final IValueFactory vf) {
       this.vf = vf;
    }

    public final IInteger hashCode(IString string) {
        return vf.integer(string.getValue().hashCode());
    }

    public IFunction genEval(IValue evalType, IEvaluatorContext ctx) {
        final TypeFactory tf = TypeFactory.getInstance();
        final RascalFunctionValueFactory ff = new RascalFunctionValueFactory(ctx);
        final Type type = tf.functionType(tf.integerType(), new Type[] {evalType.getType()}, new Type[0]);

        final BiFunction<IValue[], Map<String, IValue>, IValue> func;
        try {
            final File file = new File("src/main/rascal/");
            final URL[] urls = new URL[] {file.toURI().toURL()};
            final ClassLoader cl = new URLClassLoader(urls);
            final Class<?> binding = cl.loadClass("PEvalBinding");
            final Class<? extends BiFunction<IValue[], Map<String, IValue>, IValue>> exp = cl.loadClass("PEval").asSubclass(BiFunction.class);
            final Class<? extends BiFunction<IValue[], Map<String, IValue>, IValue>> fun = cl.loadClass("PEvalFunc").asSubclass(BiFunction.class);
            final Class<? extends BiFunction<IValue[], Map<String, IValue>, IValue>> prg = cl.loadClass("PEvalProg").asSubclass(BiFunction.class);
            
            final Object bindingInstance = binding.getConstructor(IValueFactory.class).newInstance(this.vf);
            func = exp.getConstructor(IValueFactory.class, binding).newInstance(this.vf, bindingInstance);
            final Field field = binding.getDeclaredField("__FBEG_eval_exp");
            field.setAccessible(true);
            field.set(bindingInstance, func);
            field.setAccessible(false);
            this.funcEval = fun.getConstructor(IValueFactory.class, exp).newInstance(this.vf, func);
            this.progEval = prg.getConstructor(IValueFactory.class, fun).newInstance(this.vf, this.funcEval);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }

        return ff.function(type, func);
    }

    public IFunction genEvalFunc(IValue evalType, IEvaluatorContext ctx) {
        final TypeFactory tf = TypeFactory.getInstance();
        final RascalFunctionValueFactory ff = new RascalFunctionValueFactory(ctx);
        final Type type = tf.functionType(tf.voidType(), new Type[] {evalType.getType()}, new Type[0]);
        return ff.function(type, this.funcEval);
    }
    
    public IFunction genEvalProg(IValue evalType, IEvaluatorContext ctx) {
        final TypeFactory tf = TypeFactory.getInstance();
        final RascalFunctionValueFactory ff = new RascalFunctionValueFactory(ctx);
        final Type type = tf.functionType(tf.integerType(), new Type[] {evalType.getType()}, new Type[0]);
        return ff.function(type, this.progEval);
    }

}