package fbeg;

import io.usethesource.vallang.IString;
import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class Switch {

    private final IValueFactory vf;

    public Switch(final IValueFactory vf) {
       this.vf = vf;
    }

    public IValue hashCode(final IString str) {
        return vf.integer(str.getValue().hashCode());
    }

}