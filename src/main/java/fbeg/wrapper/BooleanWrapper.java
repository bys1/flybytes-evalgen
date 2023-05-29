package fbeg.wrapper;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class BooleanWrapper extends Wrapper {

    public boolean value;

    public BooleanWrapper(final boolean value) {
        this.value = value;
    }

    @Override
    public IValue toIValue(final IValueFactory vf) {
        return vf.bool(this.value);
    }

}