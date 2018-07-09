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

final class RandomNoise3D : NoiseFunction3D {
    float[] values;
    this(uint numValues) {
        this.values.length = numValues;
        foreach(ref v; values) {
            v = uniform(0f, 2f);
        }
    }
    float get(Vector3 v) {
        return get(v.x, v.y, v.z);
    }
    float get(float x, float y, float z) {
        uint ix = cast(uint)(x*10);
        uint iy = cast(uint)(y*10);
        uint iz = cast(uint)(z*10);
        //uint hash = x^y^z;
        uint hash = 17;
        hash ^= 31 + ix;
        hash *= 31 + iy;
        hash ^= 31 + iz;
        return values[hash%values.length];
    }
}



