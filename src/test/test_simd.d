module test.test_simd;

import std.stdio : writefln;

import maths;

void testSimd() {
    writefln("Testing simd package...");

    testVec();
}

private:

void testVec() {
    Vec!(uint, 8) a;

    assert(a.sizeBits() == 256);
    assert(a == [cast(uint)0,0,0,0,0,0,0,0]);
}
