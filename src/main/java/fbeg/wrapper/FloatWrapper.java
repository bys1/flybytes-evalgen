package fbeg.wrapper;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class FloatWrapper extends Wrapper {

    public float value;

    public FloatWrapper(final float value) {
        this.value = value;
    }

    @Override
    public IValue toIValue(final IValueFactory vf) {
        return vf.real(this.value);
    }

}