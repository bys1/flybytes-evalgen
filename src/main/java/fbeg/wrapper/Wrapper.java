package fbeg.wrapper;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public abstract class Wrapper {

    public abstract IValue toIValue(final IValueFactory vf);

}