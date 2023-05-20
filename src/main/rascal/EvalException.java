import io.usethesource.vallang.IConstructor;
import io.usethesource.vallang.io.StandardTextWriter;

import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

class EvalException extends RuntimeException {

    private final List<IConstructor> nodeStackTrace = new ArrayList<>();

    private int more = 0;

    public EvalException(final IConstructor cons, final Throwable cause) {
        super(cause);
        addNode(cons);
    }

    public void addNode(final IConstructor cons) {
        if (this.nodeStackTrace.size() < 25) this.nodeStackTrace.add(cons);
        else this.more++;
    }

    public void printNodeStackTrace() {
        System.err.println("An error occurred while evaluating the following node:");
        try {
            new StandardTextWriter(true).write(this.nodeStackTrace.get(0), new PrintWriter(System.out));
        } catch (final Exception e) {
            System.err.println("Unable to print node:");
            e.printStackTrace();
        }
        System.err.println();
        System.err.println();
        System.err.println("Node stack trace:");
        for (final IConstructor cons : nodeStackTrace) {
            var kw = cons.asWithKeywordParameters();
            if (kw.hasParameter("src"))
                System.err.println("\tat " + cons.getName() + " (" + kw.getParameter("src") + ")");
            else
                System.err.println("\tat " + cons.getName() + " (Unknown Source)");
        }
        if (this.more > 0) System.err.println("\t... " + this.more + " more");
        System.err.println();
    }

}