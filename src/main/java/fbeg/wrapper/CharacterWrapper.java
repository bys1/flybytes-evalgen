package fbeg.wrapper;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;

public class CharacterWrapper extends Wrapper {

    public char value;

    public CharacterWrapper(final char value) {
        this.value = value;
    }

    @Override
    public IValue toIValue(final IValueFactory vf) {
        return vf.string(this.value);
    }

}