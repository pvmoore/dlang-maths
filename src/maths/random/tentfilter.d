module maths.random.tentfilter;

import maths.all;

final class TentFilter {
private:
    float[] values;
    uint index;
    const uint mask;
public:
    this(uint numValues, uint seed = unpredictableSeed()) {
        import core.bitop : popcnt;
        assert(numValues!=0, "Num values must not be 0");
        assert(popcnt(numValues)==1, "Num values must be a power of 2");

        this.values.length = numValues;
        this.mask          = numValues-1;

        auto rng = Mt19937(seed);

        foreach(ref v; values) {
            float r = uniform(0f, 2f, rng);
            v = r<1 ? sqrt(r)-1 : 1-sqrt(2-r);
        }
    }
    float next() {
        uint i = index++;
        return values[i&mask];
    }
}


