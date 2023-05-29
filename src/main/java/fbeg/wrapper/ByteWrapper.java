package fbeg.wrapper;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class ByteWrapper extends Wrapper {

    public byte value;

    public ByteWrapper(final byte value) {
        this.value = value;
    }

    @Override
    public IValue toIValue(final IValueFactory vf) {
        return vf.integer(this.value);
    }

}