package fbeg;

import io.usethesource.capsule.Map;

import io.usethesource.vallang.IMap;
import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;
import io.usethesource.vallang.type.Type;
import io.usethesource.vallang.type.TypeFactory;
import io.usethesource.vallang.visitors.IValueVisitor;

import java.lang.reflect.Array;
import java.util.Collection;
import java.util.Set;

import fbeg.wrapper.*;

public final class Env implements IValue {

    private final IValueFactory vf;

    private Map.Immutable map;

    public Env(final IValueFactory vf) {
        this.vf = vf;
    }

    public Env makeEnv() {
        return makeEnv(Map.Immutable.of());
    }

    public Env makeEnv(final Map.Immutable map) {
        return new Env(this.vf).setMap(map);
    }

    public Map.Immutable getMap() {
        return this.map;
    }

    public Env setMap(final Map.Immutable map) {
        this.map = map;
        return this;
    }

    public IMap envToMap(final Env env) {
        IMap imap = this.vf.map();
        var it = map.entryIterator();
        while (it.hasNext()) {
            var e = (java.util.Map.Entry<String,Object>) it.next();
            imap = imap.put(this.vf.string(e.getKey()), toRascal(e.getValue()));
        }
        return imap;
    }

    public IMap envToMap(final IValue val) {
        if (val instanceof Env) return envToMap((Env) val);
        throw new IllegalArgumentException("Value must be instance of Env");
    }

    private IValue toRascal(final Object obj) {
        if (obj instanceof IValue)          return (IValue) obj;
        if (obj instanceof Boolean)         return this.vf.bool   (((Boolean)   obj).booleanValue());
        if (obj instanceof Byte)            return this.vf.integer(((Byte)      obj).byteValue());
        if (obj instanceof Short)           return this.vf.integer(((Short)     obj).shortValue());
        if (obj instanceof Integer)         return this.vf.integer(((Integer)   obj).intValue());
        if (obj instanceof Long)            return this.vf.integer(((Long)      obj).longValue());
        if (obj instanceof Float)           return this.vf.real   (((Float)     obj).floatValue());
        if (obj instanceof Double)          return this.vf.real   (((Double)    obj).doubleValue());
        if (obj instanceof Character)       return this.vf.string (((Character) obj).charValue());
        if (obj instanceof ObjectWrapper)   return toRascal(((ObjectWrapper)    obj).value);
        if (obj instanceof Wrapper)         return ((Wrapper) obj).toIValue(this.vf);
        if (obj instanceof String)          return this.vf.string((String) obj);
        if (obj instanceof Set)             return this.vf.set((IValue[]) ((Set) obj).stream().map(this::toRascal).toArray(IValue[]::new));
        if (obj instanceof Collection)      return this.vf.list((IValue[]) ((Collection) obj).stream().map(this::toRascal).toArray(IValue[]::new));
        if (obj instanceof java.util.Map) {
            IMap imap = this.vf.map();
            for (var ee : ((java.util.Map) obj).entrySet()) {
                var e = (java.util.Map.Entry<Object,Object>) ee;
                imap = imap.put(toRascal(e.getKey()), toRascal(e.getValue()));
            }
            return imap;
        }
        if (obj.getClass().isArray()) {
            if (obj.getClass().getComponentType().isPrimitive()) {
                final int len = Array.getLength(obj);
                final IValue[] arr = new IValue[len];
                for (int i = 0; i < len; i++) arr[i] = toRascal(Array.get(obj, i));
                return this.vf.list(arr);
            }
            final Object[] oarr = (Object[]) obj;
            final IValue[] arr = new IValue[oarr.length];
            for (int i = 0; i < oarr.length; i++) arr[i] = toRascal(oarr[i]);
            return this.vf.list(arr);
        }
        return this.vf.string(obj.toString());
    }

    @Override
    public Type getType() {
        return TypeFactory.getInstance().valueType();
    }

    @Override
    public <T, E extends Throwable> T accept(final IValueVisitor<T, E> v) throws E {
        return v.visitMap(envToMap(this));
    }

    @Override
    public boolean equals(final Object o) {
        if (o == null || !(o instanceof Env)) return false;
        final Env env = (Env) o;
        return this.map.equals(env.map);
    }

    @Override
    public String toString() {
        return defaultToString();
    }

}