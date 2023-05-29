package fbeg.wrapper;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class LongWrapper extends Wrapper {

    public long value;

    public LongWrapper(final long value) {
        this.value = value;
    }

    @Override
    public IValue toIValue(final IValueFactory vf) {
        return vf.integer(this.value);
    }

}