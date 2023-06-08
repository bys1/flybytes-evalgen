package fbeg.demo.func;

import io.usethesource.vallang.IValueFactory;

import java.lang.management.ManagementFactory;

public class Memory {
    
    private IValueFactory vf;
    
    public Memory(final IValueFactory vf) {
        this.vf = vf;
    }
    
    private static long getUsedMemory() {
        return	ManagementFactory.getMemoryMXBean().getHeapMemoryUsage().getUsed()
            + 	ManagementFactory.getMemoryMXBean().getNonHeapMemoryUsage().getUsed();
    }
    
    private static long gcCount() {
        long sum = 0;
        for (var bean : ManagementFactory.getGarbageCollectorMXBeans()) {
            final long count = bean.getCollectionCount();
            if (count != -1) sum += count;
        }
        return sum;
    }
    
    private static long getReallyUsedMemory() {
        final long count = gcCount();
        System.gc();
        while (gcCount() == count) {
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {}
        }
        return getUsedMemory();
    }

    private static long getStabilizedMemory() {
        long m;
        long m2 = getReallyUsedMemory();
        do {
            try {
                Thread.sleep(500);
            } catch (Exception e) {}
            m = m2;
            m2 = getUsedMemory();
        } while (m2 < getReallyUsedMemory());
        return m;
    }

    public static void printMemory() {
        System.out.println(getReallyUsedMemory());
    }
    
    public void printMemoryR() {
        printMemory();
    }
    
}