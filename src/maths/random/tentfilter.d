module maths.random.tentfilter;

import maths.all;

final class TentFilter {
private:
    float[] values;
    uint index;
public:
    this(uint numValues) {
        this.values.length = numValues;
        foreach(ref v; values) {
            float r = uniform(0f, 2f);
            v = r<1 ? sqrt(r)-1 : 1-sqrt(2-r);
        }
        this.index = uniform(0, cast(uint)values.length);
    }
    // may be called from different threads
    float next() {
        uint i = index++;
        if(i>=values.length) {
            index = 0;
            i = 0;
        }
        return values[i];
    }
}


