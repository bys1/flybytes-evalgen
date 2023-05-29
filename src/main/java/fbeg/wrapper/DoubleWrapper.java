package fbeg.wrapper;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class DoubleWrapper extends Wrapper {

    public double value;

    public DoubleWrapper(final double value) {
        this.value = value;
    }

    @Override
    public IValue toIValue(final IValueFactory vf) {
        return vf.real(this.value);
    }

}