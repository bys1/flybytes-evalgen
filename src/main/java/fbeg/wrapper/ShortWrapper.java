package fbeg.wrapper;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class ShortWrapper extends Wrapper {

    public short value;

    public ShortWrapper(final short value) {
        this.value = value;
    }

    @Override
    public IValue toIValue(final IValueFactory vf) {
        return vf.integer(this.value);
    }

}