package fbeg.wrapper;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class ObjectWrapper extends Wrapper {

    public Object value;

    public ObjectWrapper(final Object value) {
        this.value = value;
    }

    @Override
    public IValue toIValue(final IValueFactory vf) {
        return vf.string(this.value.toString());
    }

}