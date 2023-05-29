package fbeg.wrapper;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class IntegerWrapper extends Wrapper {

    public int value;

    public IntegerWrapper(final int value) {
        this.value = value;
    }

    @Override
    public IValue toIValue(final IValueFactory vf) {
        return vf.integer(this.value);
    }

}