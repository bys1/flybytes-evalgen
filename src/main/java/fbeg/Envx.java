package fbeg;

import io.usethesource.capsule.Map;

import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;
import io.usethesource.vallang.type.Type;
import io.usethesource.vallang.type.TypeFactory;
import io.usethesource.vallang.visitors.IValueVisitor;

/**
 * This is a helper class that can be used as an environment for interpreters, to store i.e. variables and functions.
 * The environment consists of several levels, each with a map that maps string keys to any type of object.
 * Initially, there is only one level with index 0.
 * The level can be increased and decreased, and created levels may hold contents of lower levels.
 * 
 * An example scenario is storing local variables in functions and nested code blocks, where a new nested code block
 * increases the level copying the previous level, so that a code block can access variables from parent blocks, but
 * its variables decease when the code block ends. On the other hand, a function call increases the level without copying
 * other levels, so that the called function cannot access variables declared in the calling function. When the called
 * function ends, the level is decreased again so that the calling function can continue using its own variables.
 */
public final class Envx implements IValue {

    private final IValueFactory vf;

    private int levelIndex = 0;
    private Map.Immutable<String,Object>[] levels = (Map.Immutable<String,Object>[]) new Map.Immutable<?,?>[16];

    public Envx(final IValueFactory vf) {
        this.vf = vf;
        this.levels[0] = Map.Immutable.of();
    }

    public Envx newEnv() {
        return new Envx(this.vf);
    }

    /**
     * Returns the current highest level.
     */
    public final int getLevel() {
        return this.levelIndex;
    }

    /**
     * Increases the level and returns the new highest level.
     * The newly created level will be empty.
     */
    public final int addEmptyLevel() {
        if (++this.levelIndex == this.levels.length) {
            final Map.Immutable<String,Object>[] levels = (Map.Immutable<String,Object>[]) new Map.Immutable<?,?>[this.levelIndex * 2];
            for (int i = 0; i < this.levelIndex; i++) levels[i] = this.levels[i];
            this.levels = levels;
        }
        this.levels[this.levelIndex] = Map.Immutable.of();
        return this.levelIndex;
    }

    /**
     * Increases the level and returns the new highest level.
     * The newly created level will hold all objects stored at the current highest level.
     */
    public final int addLevel() {
        final int level = this.levelIndex;
        if (++this.levelIndex == this.levels.length) {
            final Map.Immutable<String,Object>[] levels = (Map.Immutable<String,Object>[]) new Map.Immutable<?,?>[this.levelIndex * 2];
            for (int i = 0; i < this.levelIndex; i++) levels[i] = this.levels[i];
            this.levels = levels;
        }
        this.levels[this.levelIndex] = this.levels[level];
        return this.levelIndex;
    }

    /**
     * Increases the level and returns the new highest level.
     * The newly created level will hold all objects stored at the given level.
     * 
     * @param baseLevel The level from which the contents should be copied to the new level.
     */
    public final int addLevel(final int baseLevel) {
        if (++this.levelIndex == this.levels.length) {
            final Map.Immutable<String,Object>[] levels = (Map.Immutable<String,Object>[]) new Map.Immutable<?,?>[this.levelIndex * 2];
            for (int i = 0; i < this.levelIndex; i++) levels[i] = this.levels[i];
            this.levels = levels;
        }
        this.levels[this.levelIndex] = this.levels[baseLevel];
        return this.levelIndex;
    }

    /**
     * Decreases the level (removing the highest level) and returns the new highest level.
     */
    public final int removeLevel() {
        this.levels[this.levelIndex] = null;
        return --this.levelIndex;
    }

    /**
     * Increases the level index without changing the levels.
     * This may be used to pretend having a different highest level for an evaluation.
     * Before increasing the index, a level at the increased index has to be created with addLevel or similar methods.
     * If this is not done, the behaviour of putObject/findObject and similar methods after this call is undefined.
     */
    public final int levelUp() {
        return ++this.levelIndex;
    }

    /**
     * Decreases the level index without changing the levels.
     * This may be used to pretend having a different highest level for an evaluation.
     */
    public final int levelDown() {
        return --this.levelIndex;
    }

    /**
     * Finds the object with the given key at the highest level.
     * 
     * @param key The key of the object to find.
     * @return The value found in the environment.
     */
    public final Object findObject(final String key) {
        return this.levels[this.levelIndex].get(key);
    }

    /**
     * Finds the object with the given key at the given level.
     * 
     * @param key   The key of the object to find.
     * @param level The level to search at.
     * @return The value found in the environment.
     */
    public final Object findObject(final String key, final int level) {
        return this.levels[level].get(key);
    }

    /**
     * Maps the given key to the given object in the environment.
     * The object is stored in the environment at the highest level.
     * 
     * @param key   The key to map to the object.
     * @param value The object to store in the environment.
     */
    public final void putObject(final String key, final Object value) {
        this.levels[this.levelIndex] = this.levels[this.levelIndex].__put(key, value);
    }

    /**
     * Maps the given key to the given object in the environment.
     * The object is stored in the environment at the given level.
     * The object will NOT be stored in any level above the given level.
     * 
     * @param key   The key to map to the object.
     * @param value The object to store in the environment.
     * @param level The level at which the object should be stored.
     */
    public final void putObject(final String key, final Object value, final int level) {
        this.levels[level] = this.levels[level].__put(key, value);
    }

    /**
     * Maps the given key to the given object in the environment, and increases the level.
     * The object is stored at the newly created level, and all contents of the current highest
     * level will also be present in the new highest level.
     * 
     * @param key   The key to map to the object.
     * @param value The object to store in the environment.
     */
    public final void putObjectInc(final String key, final Object value) {
        final Map.Immutable<String,Object> map = this.levels[this.levelIndex].__put(key, value);
        this.levels[++this.levelIndex] = map;
    }

    /**
     * Maps the given key to the given object in the environment, and increases the level.
     * The object is stored at the newly created level, and all contents of the given level
     * will also be present in the new highest level. The new level will therefore not hold
     * any objects stored above the given level.
     * 
     * @param key   The key to map to the object.
     * @param value The object to store in the environment.
     * @param level The base level that should be copied to the new level.
     */
    public final void putObjectInc(final String key, final Object value, final int level) {
        this.levels[++this.levelIndex] = this.levels[level].__put(key, value);
    }

    @Override
    public Type getType() {
        return TypeFactory.getInstance().valueType();
    }

    @Override
    public <T, E extends Throwable> T accept(final IValueVisitor<T, E> v) throws E {
        return v.visitString(this.vf.string("FBEG Environment (" + (this.levelIndex + 1) + " levels)"));
    }

    @Override
    public boolean equals(final Object o) {
        if (o == null || !(o instanceof Envx)) return false;
        final Envx env = (Envx) o;
        if (env.levelIndex != this.levelIndex) return false;
        for (int i = 0; i <= this.levelIndex; i++)
            if (!this.levels[i].equals(env.levels[i])) return false;
        return true;
    }

    @Override
    public String toString() {
        return defaultToString();
    }

}