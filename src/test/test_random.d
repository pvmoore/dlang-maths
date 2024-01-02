module test.test_random;

import std.stdio                : writefln;
import std.datetime.stopwatch	: StopWatch;

import maths;

void testRandom() {
    testFastRNG();
    testRandomBuffer();
}

private:

void testFastRNG() {
	writefln("Testing random ...");
    auto r = new FastRNG();
    StopWatch w;
    w.start();
    double total = 0;
    ulong iterations = 10000;
    float[11] buckets = 0;
    for(auto i=0; i<iterations; i++) {
        float value = r.next();
        total += value;
        buckets[cast(int)(value*10)]++;
    }
    w.stop();
    writefln("average = %s", total/iterations);
    writefln("buckets=%s", buckets);
    writefln("Elapsed %s millis", w.peek().total!"nsecs"/1000000.0);
}
void testRandomBuffer() {
	writefln("Testing RandomBuffer ...");

	auto rb = new RandomBuffer(1024);
	for(auto i=0; i<1024; i++) {
		auto value = rb.next();
		assert(value>=0.0f);
		assert(value<1.0f);
	}

	writefln("OK");
}
