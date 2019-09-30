module maths.random.random_buffer;

import maths.all;

/**
 * Pre-populated random number buffer with distribution between 0 and 1
 */
final class RandomBuffer {
private:
    float[] values;
    uint index;
    const uint mask;
public:
    this(uint numValues, uint seed = unpredictableSeed()) {
        import core.bitop : popcnt;
        assert(numValues!=0, "Num values must not be 0");
        assert(popcnt(numValues)==1, "Num values must be a power of 2");

        this.mask          = numValues-1;
        this.values.length = numValues;
        auto rng = Mt19937(seed);

        foreach(ref v; values) {
            v = uniform(0f, 1f, rng);
        }
    }
    float next() {
        uint i = index++;
        return values[i&mask];
    }
}
