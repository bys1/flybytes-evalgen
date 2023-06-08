package fbeg.demo.func;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;
import io.usethesource.vallang.type.ExternalType;
import io.usethesource.vallang.type.Type;
import io.usethesource.vallang.type.TypeFactory;

import java.io.File;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.Map;
import java.util.function.BiFunction;

import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.values.RascalFunctionValueFactory; 
import org.rascalmpl.values.functions.IFunction;

public class Benchmarks implements BiFunction<IValue[], Map<String, IValue>, IValue> {

    private final IValueFactory vf;
    
    private Method method;
    private Object args;

    public Benchmarks(final IValueFactory vf) {
        this.vf = vf;
    }

    @Override
    public final IValue apply(final IValue[] args, final Map<String, IValue> map) {
        try {
            this.method.invoke(null, this.args);
        } catch (Exception e) {}
        return null;
    }

    public final IFunction getFunc(IValue funcType, IEvaluatorContext ctx) {
        final RascalFunctionValueFactory ff = new RascalFunctionValueFactory(ctx);
        final Type type = ((ExternalType) funcType.getType()).getTypeParameters().getFieldType(0);

        final BiFunction<IValue[], Map<String, IValue>, IValue> bifunc;
        try {
            final URL[] urls = new URL[] {new File("").toURI().toURL()};
            final ClassLoader cl = new URLClassLoader(urls);
            final Class<?> clazz = cl.loadClass("BMCProg");
            this.method = clazz.getMethod("main", String[].class);
            this.args = new String[0];
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }

        return ff.function(type, this);
    }

}