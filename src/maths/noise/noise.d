module maths.noise.noise;

import maths.all;
/**
 * Simplex / Perlin noise.
 * https://en.wikipedia.org/wiki/Perlin_noise
 *
 * Read this:
 * http://gpfault.net/posts/perlin-noise.txt.html
 */

interface NoiseFunction1D {
    float get(float x);
}
interface NoiseFunction2D {
    float get(float x, float y);
    float get(vec2 v);
}
interface NoiseFunction3D {
    float get(float x, float y, float z);
    float get(vec3 v);
}

/* pre-generates white noise in the range [0..1] */
final class RandomNoise3D : NoiseFunction3D {
private:
    float[] values;
    uint mask;
public:
    this(uint numValues, uint seed = unpredictableSeed()) {
        import core.bitop : popcnt;
        assert(numValues!=0, "Num values must not be 0");
        assert(popcnt(numValues)==1, "Num values must be a power of 2");

        auto rng           = Mt19937(seed);
        this.mask          = numValues-1;
        this.values.length = numValues;
        foreach(ref v; values) {
            v = uniform(0f, 1f, rng);
        }
    }
    float get(Vector3 v) {
        return get(v.x, v.y, v.z);
    }
    float get(float x, float y, float z) {
        uint ix = cast(uint)(x*100);
        uint iy = cast(uint)(y*100);
        uint iz = cast(uint)(z*100);
        //uint hash = x^y^z;
        uint hash = 17;
        hash ^= 31 + ix;
        hash *= 31 + iy;
        hash ^= 31 + iz;
        return values[hash&mask];
    }
}



