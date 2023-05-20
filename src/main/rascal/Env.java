import java.util.HashMap;
import java.util.Map;

import io.usethesource.vallang.IInteger;
import io.usethesource.vallang.IValueFactory;

public final class Env {

    private static Env instance = null;

    private final IValueFactory vf;

    private int levelSize;
    private int levelIndex;
    private Map<String, Object>[] levels;

    private int ladderSize;
    private int ladderIndex;
    private Ladder[] ladders;

    public Env(final IValueFactory vf) {
        this.vf = vf;
        resetAll();
        Env.instance = this;
    }

    public static final Env getInstance() {
        return Env.instance;
    }

    public final void resetAll() {
        resetLevels();
        resetLadders();
    }

    public final void resetLevels() {
        this.levelSize = 16;
        this.levelIndex = 0;
        this.levels = (Map<String, Object>[]) new Map<?,?>[this.levelSize];
        this.levels[0] = new HashMap<>();
        for (int i = 1; i <= this.ladderIndex; i++) this.ladders[i].levelIndex = 0;
    }

    public final void resetLadders() {
        this.ladderSize = 16;
        this.ladderIndex = 0;
        this.ladders = new Ladder[this.ladderSize];
        this.ladders[0] = new Ladder(); // Add ladder at index 0 with the only level being 0
    }

    public final int addLadder() {
        if (++this.ladderIndex == this.ladderSize) {
            final Ladder[] ladders = new Ladder[this.ladderSize *= 2];
            for (int i = 0; i < this.ladderIndex; i++) ladders[i] = this.ladders[i];
            this.ladders = ladders;
        }
        this.ladders[this.ladderIndex] = new Ladder();
        return this.ladderIndex;
    }

    public final IInteger addLadderR() {
        return vf.integer(addLadder());
    }

    public final int addLevel(final int... ladders) {
        if (++this.levelIndex == this.levelSize) {
            final Map<String, Object>[] levels = (Map<String, Object>[]) new Map<?,?>[this.levelSize *= 2];
            for (int i = 0; i < this.levelIndex; i++) levels[i] = this.levels[i];
            this.levels = levels;
        }
        this.levels[this.levelIndex] = new HashMap<>();
        for (final int ladder : ladders) {
            final Ladder lad = this.ladders[ladder];
            if (++lad.levelIndex == lad.levelSize) {
                final int[] levels = new int[lad.levelSize *= 2];
                for (int i = 0; i < lad.levelIndex; i++) levels[i] = lad.levels[i];
                lad.levels = levels;
            }
            lad.levels[lad.levelIndex] = this.levelIndex;
        }
        return this.levelIndex;
    }

    public final void addLevelToLadders(final int... ladders) {
        for (final int ladder : ladders) {
            final Ladder lad = this.ladders[ladder];
            if (++lad.levelIndex == lad.levelSize) {
                final int[] levels = new int[lad.levelSize *= 2];
                for (int i = 0; i < lad.levelIndex; i++) levels[i] = lad.levels[i];
                lad.levels = levels;
            }
            lad.levels[lad.levelIndex] = this.levelIndex;
        }
    }

    public final void removeLevel() {
        this.levels[this.levelIndex] = null;
        for (int i = 0; i <= this.ladderIndex; i++) {
            final Ladder ladder = this.ladders[i];
            if (ladder.levels[ladder.levelIndex] == this.levelIndex) ladder.levelIndex--;
        }
        this.levelIndex--;
    }

    public final int getLevel() {
        return this.levelIndex;
    }

    public final Object findObject(final String key, final int minLadder) {
        final Ladder lad = this.ladders[minLadder];
        final int min = lad.levels[lad.levelIndex];
        Object o;
        for (int i = this.levelIndex; i >= min; i--) {
            o = this.levels[i].get(key);
            if (o != null) return o;
        }
        throw new IllegalStateException("Unable to find key " + key + " (minLadder " + minLadder + ", min " + min + ", level " + this.levelIndex + ")");
    }

    public final Object findObjectLocal(final String key) {
        return this.levels[this.levelIndex].get(key);
    }

    public final Object findObject(final String key, final int minLadder, final int level) {
        final Ladder lad = this.ladders[minLadder];
        final int min = lad.levels[lad.levelIndex];
        Object o;
        for (int i = level; i >= min; i--) {
            o = this.levels[i].get(key);
            if (o != null) return o;
        }
        throw new IllegalStateException("Unable to find key " + key + " (minLadder " + minLadder + ", min " + min + ", level " + level + ")");
    }

    public final Object findObjectLocal(final String key, final int level) {
        return this.levels[level].get(key);
    }

    public final void putObject(final String key, final Object o) {
        this.levels[this.levelIndex].put(key, o);
    }

    public final void putObject(final String key, final Object o, final int level) {
        this.levels[level].put(key, o);
    }

    public final Object findObject(final int ladder, final String key, final int minLadder) {
        final Ladder lad = this.ladders[ladder];
        final Ladder minLad = this.ladders[minLadder];
        final int min = minLad.levels[minLad.levelIndex];
        Object o;
        for (int i = lad.levelIndex; i >= min; i--) {
            o = this.levels[lad.levels[i]].get(key);
            if (o != null) return o;
        }
        throw new IllegalStateException("Unable to find key " + key + " (ladder " + ladder + ", minLadder " + minLadder + ", level " + lad.levelIndex + ")");
    }

    public final Object findObjectLocal(final int ladder, final String key) {
        final Ladder lad = this.ladders[ladder];
        return this.levels[lad.levels[lad.levelIndex]].get(key);
    }

    public final Object findObject(final int ladder, final String key, final int minLadder, final int level) {
        final Ladder lad = this.ladders[ladder];
        final Ladder minLad = this.ladders[minLadder];
        final int min = minLad.levels[minLad.levelIndex];
        Object o;
        for (int i = level; i >= min; i--) {
            o = this.levels[lad.levels[i]].get(key);
            if (o != null) return o;
        }
        throw new IllegalStateException("Unable to find key " + key + " (ladder " + ladder + ", minLadder " + minLadder + ", level " + level + ")");
    }

    public final Object findObjectLocal(final int ladder, final String key, final int level) {
        return this.levels[this.ladders[ladder].levels[level]].get(key);
    }

    public final void putObject(final int ladder, final String key, final Object o) {
        final Ladder lad = this.ladders[ladder];
        this.levels[lad.levels[lad.levelIndex]].put(key, o);
    }

    public final void putObject(final int ladder, final String key, final Object o, final int level) {
        this.levels[this.ladders[ladder].levels[level]].put(key, o);
    }

    private static final class Ladder {

        private int levelSize;
        private int levelIndex;
        private int[] levels;

        private Ladder() {
            this.levelSize = 16;
            this.levelIndex = 0;
            this.levels = new int[this.levelSize];
            this.levels[0] = 0;
        }

    }

}