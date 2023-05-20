import io.usethesource.vallang.ISourceLocation;
import io.usethesource.vallang.IValueFactory;
import io.usethesource.vallang.type.TypeFactory;

import org.rascalmpl.ast.AbstractAST;
import org.rascalmpl.ast.FunctionDeclaration;
import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.interpreter.result.AbstractFunction;
import org.rascalmpl.interpreter.result.OverloadedFunction;
import org.rascalmpl.interpreter.result.ResultFactory;
import org.rascalmpl.values.functions.IFunction;

public class Func {

    private final IValueFactory vf;

    public Func(final IValueFactory vf) {
       this.vf = vf;
    }

    public ISourceLocation lalala(IFunction val, IEvaluatorContext ctx) {
        if (val instanceof AbstractFunction) {
            final AbstractFunction func = (AbstractFunction) val;
            final AbstractAST ast = func.getAst();
            return ast.getLocation();
        } else if (val instanceof OverloadedFunction) {
            final OverloadedFunction func = (OverloadedFunction) val;
            var prim = func.getPrimaryCandidates();
            for (var c : prim) {
                var ast = c.getAst();
                if (ast instanceof FunctionDeclaration) {
                    var decl = (FunctionDeclaration) ast;
                    var params = decl.getSignature().getParameters().getFormals().getFormals();
                    var matcher = params.get(0).getMatcher(ctx, true);
                    var result = ResultFactory.makeResult(TypeFactory.getInstance().stringType(), this.vf.string("homo"), ctx);
                    matcher.initMatch(result);
                    System.out.println("IVALUE: " + matcher.toIValue());
                }
                System.out.println(ast.getLocation());
            }
        }
        return null;
    }

}