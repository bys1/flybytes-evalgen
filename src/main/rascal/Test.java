import java.io.File;
import java.io.PrintWriter;
import java.lang.reflect.Field;
import java.net.URL;
import java.net.URLClassLoader;
//import java.util.Map;
import java.util.function.BiFunction;

import io.usethesource.capsule.Map;

import io.usethesource.vallang.IConstructor;
import io.usethesource.vallang.IInteger;
import io.usethesource.vallang.IString;
import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;
import io.usethesource.vallang.io.StandardTextWriter;
import io.usethesource.vallang.type.Type;
import io.usethesource.vallang.type.TypeFactory;

import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.values.RascalFunctionValueFactory; 
import org.rascalmpl.values.functions.IFunction;

public final class Test {

    /*private final IValueFactory vf;

    public Test(final IValueFactory vf) {
       this.vf = vf;
    }*/

    /*public static void main(String[] arg) {
        Map.Immutable map = Map.Immutable.of();
    }//*/

    public void a() {
        Object x = new Object();
        int a = 300;
        if (x == null) {
            a = 400;
        }
    }

    /*public void extest(IConstructor cons, IEvaluatorContext ctx) {
        System.out.println("An error occurred while evaluating the following node:");
        try {
            new StandardTextWriter(true).write(cons, new PrintWriter(System.out));
        } catch (final Exception e) {
            e.printStackTrace();
        }
        System.out.println();
        System.out.println();
        throw new IllegalStateException();
    }

    public void genEval(IEvaluatorContext ctx) {
        final TypeFactory tf = TypeFactory.getInstance();
        final RascalFunctionValueFactory ff = new RascalFunctionValueFactory(ctx);

        final Object func;
        try {
            final File file = new File("src/main/rascal/");
            final URL[] urls = new URL[] {file.toURI().toURL()};
            final ClassLoader cl = new URLClassLoader(urls);
            final Class<?> exp = cl.loadClass("Neger");
            func = exp.getConstructor().newInstance();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }*/

}