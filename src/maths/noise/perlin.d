module maths.noise.perlin;

import maths.all;

final class PerlinNoise2D : NoiseFunction2D {
    Mt19937 rng;
    uint width, height;
    float persistence = 0.5f;
    uint octaveCount  = 7;
    float[] whiteNoise;
    float[] perlinNoise;
public:
    this(uint width, uint height) {
        this.width  = width;
        this.height = height;
        this.rng    = Mt19937(unpredictableSeed());
        this.whiteNoise.length  = width*height;
        this.perlinNoise.length = width*height;
        generateWhiteNoise();
    }
    auto setSeed(uint s) {
        rng = Mt19937(s);
        generateWhiteNoise();
        return this;
    }
    auto setOctaves(uint o) {
        this.octaveCount = o;
        return this;
    }
    auto setPersistence(float p) {
        this.persistence = p;
        return this;
    }
    auto generate() {
        generatePerlinNoise();
        return this;
    }
    float[] get() {
        return perlinNoise;
    }
    float get(float x, float y) {
        return perlinNoise[cast(int)x+cast(int)y*width];
    }
    float get(vec2 v) {
        return get(v.x, v.y);
    }
private:
    void generatePerlinNoise() {
       float[][] smoothNoise;
       smoothNoise.length = octaveCount;

       perlinNoise[] = 0f;

       //generate smooth noise
       for(int i = 0; i < octaveCount; i++) {
           smoothNoise[i] = generateSmoothNoise(i);
       }

        float amplitude      = 1.0f;
        float totalAmplitude = 0.0f;

        //blend noise together
        for(int octave = octaveCount - 1; octave >= 0; octave--)
        {
           amplitude      *= persistence;
           totalAmplitude += amplitude;

           for(int i = 0; i < width; i++) {
              for(int j = 0; j < height; j++) {
                 perlinNoise[i+j*width] += smoothNoise[octave][i+j*width] * amplitude;
              }
           }
        }

       //normalisation
       for(int i = 0; i < width; i++) {
          for(int j = 0; j < height; j++) {
             perlinNoise[i+j*width] /= totalAmplitude;
          }
       }
    }
    void generateWhiteNoise() {
        for(auto i = 0; i<whiteNoise.length; i++) {
            whiteNoise[i] = uniform(0.0f, 1.0f, rng);
        }
    }
    float[] generateSmoothNoise(int octave) {
       float[] smoothNoise   = new float[width*height];
       int samplePeriod      = 1 << octave; // calculates 2 ^ k
       float sampleFrequency = 1.0f / samplePeriod;

       for(int i = 0; i<width; i++) {
          //calculate the horizontal sampling indices
          int sample_i0 = (i / samplePeriod) * samplePeriod;
          int sample_i1 = (sample_i0 + samplePeriod) % width; //wrap around
          float horizontal_blend = (i - sample_i0) * sampleFrequency;

          for(int j = 0; j<height; j++) {
             //calculate the vertical sampling indices
             int sample_j0 = (j / samplePeriod) * samplePeriod;
             int sample_j1 = (sample_j0 + samplePeriod) % height; //wrap around
             float vertical_blend = (j - sample_j0) * sampleFrequency;

             //blend the top two corners
             float top = Interpolate(
                whiteNoise[sample_i0+sample_j0*width],
                whiteNoise[sample_i1+sample_j0*width],
                horizontal_blend
            );

            //blend the bottom two corners
             float bottom = Interpolate(
                whiteNoise[sample_i0+sample_j1*width],
                whiteNoise[sample_i1+sample_j1*width],
                horizontal_blend
            );

             //final blend
             smoothNoise[i+j*width] = Interpolate(top, bottom, vertical_blend);
          }
       }
       return smoothNoise;
    }
    // linear interpolation
    float Interpolate(float x0,
                      float x1,
                      float alpha)
    {
       return x0 * (1 - alpha) + alpha * x1;
    }
}

/**
 *  Adapted from Ken Perlin's improved noise:
 *  http://mrl.nyu.edu/~perlin/noise/
 */
final class ImprovedPerlin : NoiseFunction1D,
                             NoiseFunction2D,
                             NoiseFunction3D
{
private:
    Mt19937 rng;
    int[512] p;
public:
    this(uint seed=unpredictableSeed()) {
        rng.seed(seed);
        for(int i=0; i<256 ;i++) {
            p[256+i] = p[i] = uniform(0,256, rng);
        }
    }
    /// returns a value in the range -0.5 -> +0.5
    float get(float x) {
        return get(x,0,0);
    }
    /// returns a value in the range -0.5 -> +0.5
    float get(Vector2 v) {
        return get(v.x,v.y,0);
    }
    /// returns a value in the range -0.5 -> +0.5
    float get(float x, float y) {
        return get(x,y,0);
    }
    /// returns a value in the range -0.5 -> +0.5
    float get(Vector3 v) {
        return get(v.x, v.y, v.z);
    }
    /// returns a value in the range -0.5 -> +0.5
    float get(float x, float y, float z) {
        int fx = cast(int)x;
        int fy = cast(int)y;
        int fz = cast(int)z;
        int X = fx & 255;   // FIND UNIT CUBE THAT
        int Y = fy & 255;   // CONTAINS POINT.
        int Z = fz & 255;
        x -= fx;            // FIND RELATIVE X,Y,Z
        y -= fy;            // OF POINT IN CUBE.
        z -= fz;
        float u = fade(x);  // COMPUTE FADE CURVES
        float v = fade(y);  // FOR EACH OF X,Y,Z.
        float w = fade(z);
        int A  = p[X]+Y;    // HASH COORDINATES OF
        int AA = p[A]+Z;    // THE 8 CUBE CORNERS,
        int AB = p[A+1]+Z;
        int B  = p[X+1]+Y;
        int BA = p[B]+Z;
        int BB = p[B+1]+Z;

        float f = lerp(w, lerp(v, lerp(u,  grad(p[AA  ], x  , y  , z   ),  // AND ADD
                                           grad(p[BA  ], x-1, y  , z   )), // BLENDED
                                   lerp(u, grad(p[AB  ], x  , y-1, z   ),  // RESULTS
                                           grad(p[BB  ], x-1, y-1, z   ))),// FROM  8
                           lerp(v, lerp(u, grad(p[AA+1], x  , y  , z-1 ),  // CORNERS
                                           grad(p[BA+1], x-1, y  , z-1 )), // OF CUBE
                                   lerp(u, grad(p[AB+1], x  , y-1, z-1 ),
                                           grad(p[BB+1], x-1, y-1, z-1 ))));
        return f;
   }
   float get(float x, float y, float z, int octaves, float persistence) {
       float total = 0;
       float frequency = 1;
       float amplitude = 1;
       float maxValue = 0;  // Used for normalizing result to 0.0 - 1.0
       for(int i=0; i<octaves; i++) {
           total += get(x * frequency, y * frequency, z * frequency) * amplitude;

           maxValue += amplitude;

           amplitude *= persistence;
           frequency *= 2;
       }

       return total/maxValue;
   }
private:
    static float fade(float t) {
        return t * t * t * (t * (t * 6 - 15) + 10);
    }
    static float lerp(float t, float a, float b) {
        return a + t * (b - a);
    }
    static float grad(int hash, float x, float y, float z)
    {
//        int h   = hash & 15;    // CONVERT LO 4 BITS OF HASH CODE
//        float u = h<8 ? x : y;  // INTO 12 GRADIENT DIRECTIONS.
//        float v = h<4 ? y : h==12||h==14 ? x : z;
//        return ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);
        switch(hash & 0xF) {
            case 0x0: return  x + y;
            case 0x1: return -x + y;
            case 0x2: return  x - y;
            case 0x3: return -x - y;
            case 0x4: return  x + z;
            case 0x5: return -x + z;
            case 0x6: return  x - z;
            case 0x7: return -x - z;
            case 0x8: return  y + z;
            case 0x9: return -y + z;
            case 0xA: return  y - z;
            case 0xB: return -y - z;
            case 0xC: return  y + x;
            case 0xD: return -y + z;
            case 0xE: return  y - x;
            case 0xF: return -y - z;
            default: return 0; // never happens
        }
    }
}