module test.test_noise;

import std.stdio                : writefln;
import std.random               : uniform;
import std.datetime.stopwatch	: StopWatch;

import maths;

void testNoise() {
    testPerlinNoise();
    testRandomNoise3D();
}

private:

void testPerlinNoise() {
	PerlinNoise2D noise = new PerlinNoise2D(10,10).generate();
    StopWatch w;
    w.start();
    for(auto i=0; i<1; i++) {
        // test here
		writefln("noise=%s", noise.get());
    }
    w.stop();
    writefln("Noise took %s millis", w.peek().total!"nsecs"/1000000.0);
}

void testRandomNoise3D() {
	writefln("Testing RandomNoise3D ...");

	uint[20] distribution;

	auto noise = new RandomNoise3D(1024);
	for(auto i=0; i<1024; i++) {
		auto x = uniform(-10f, 10f);
		auto y = uniform(-1f, 1f);
		auto z = uniform(-3f, 1f);

		auto v = noise.get(x,y,z);

		distribution[cast(uint)(v*20)]++;

		writefln("v=%s", v);
	}

	writefln("Distribution = %s", distribution);

	writefln("OK");
}
