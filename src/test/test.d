module test.test;

import std.stdio				: writefln;
import std.math					: isClose;
import std.datetime.stopwatch	: StopWatch;
import std.random       		: uniform;
import std.format				: format;
import maths;

import test.test_camera;
import test.test_geom;
import test.test_simd;
import test.test_vector;
import test.test_matrix;
import test.test_matrix4;
import test.test_quaternion;
import test.test_noise;
import test.test_random;

void main() {
	writefln("Testing...\n");

    if(false) {
        testQuaternion();
        return;
    }

	testCamera();
	testGeom();
	testMatrix();
	testMatrix4();
	testNoise();
	testRandom();
	testSimd();
	testVector();
    testQuaternion();

	testTrigonomety();
    testHalfFloat();

	testUtil();

	writefln("Finished");
}

void testUtil() {
	writefln("testing util");
	assert("-0.1941"==formatReal(-0.19407, 4));
	assert("10.0"==formatReal(9.99, 1));
	assert("-100.0"==formatReal(-99.99, 1));
	assert("124" ==formatReal(123.5, 0));
	assert("64"==formatReal(64.000));

	StopWatch watch;
	watch.start();
	auto m = Matrix4.rowMajor(
		10,-2,3,4,
		1212,60,7,8,
		9,-10,12,-3,
		-7,-8,5,6);
	Matrix4 r = Matrix4.identity;
	for(auto n=0;n<100_000;n++) {
		r = r + m;
	}
	watch.stop();
	writefln("took %s usecs", watch.peek().total!"nsecs");
	writefln("r=%s", r);

    // factorsOf
	import std.algorithm.sorting : sort;
	import std.range : array;
	writefln("factorsOf(32)==%s", (32.factorsOf).sort().array());
    assert((32.factorsOf).sort().array()==[1,2,4,8,16,32]);
	assert((10.factorsOf).sort().array()==[1,2,5,10]);

    // test min
    assert(min(0,1,2)==0);
    assert(min(1,2,0)==0);
    assert(min(2,0,1)==0);
    assert(min(2,1,0)==0);
    assert(min(1,0,2)==0);
    assert(min(0,2,1)==0);

    {   // entropyBits
        assert(entropyBits(1, 256)==8);
        assert(entropyBits(2, 1024)==9);
        assert(entropyBits(4,1024)==8);
        writefln("%s", entropyBits(1,3));
    }

	{	// isPrime
		foreach(v; [1,2,3,5,7,11,13,17,19,23]) {
			assert(isPrime(v));
		}
		foreach(v; [0,4,6,8,9,10,12,14,15,16,18,20,21,22]) {
			assert(isPrime(v)==false);
		}
	}
    {
        // toDegrees
        assert(toDegrees(1.5708).isClose(90));
    }
    {
        // toRadians
        assert(toRadians(90).isClose(1.5708));
    }
}
void testTrigonomety() {
    writefln("testing trigonometry");

    {
        auto o = Opposite!float(3);
        auto h = Hypotenuse!float(5);
        auto a = Adjacent!float(4);
        auto a1 = angle(o,h);
        auto a2 = angle(a,h);
        auto a3 = angle(o,a);
        assert(isClose(a1.radians, 36.87.degrees.radians));
        assert(isClose(a2.radians, 36.87.degrees.radians));
        assert(isClose(a3.radians, 36.87.degrees.radians));

        auto o1 = opposite(a1, h);
        auto o2 = opposite(a1, a);
        auto o3 = opposite(a, h);
        assert(o1.isClose(3));
        assert(o2.isClose(3));
        assert(o3.isClose(3));

        auto ad1 = adjacent(a1, h);
        auto ad2 = adjacent(a1, o);
        auto ad3 = adjacent(o, h);
        assert(ad1.isClose(4));
        assert(ad2.isClose(4));
        assert(ad3.isClose(4));

        auto h1 = hypotenuse(a1, o);
        auto h2 = hypotenuse(a1, a);
        auto h3 = hypotenuse(a, o);
        assert(h1.isClose(5));
        assert(h2.isClose(5));
        assert(h3.isClose(5));
    }
    {
        float a = 5;
        float b = 9;
        float c = 8;
        auto angle = angle(a,b,c);
        assert(angle.degrees.isClose(62.18));
    }

    //{
    //    float c = 15;
    //    float r = 20;
    //    float h = 12;
    //    auto ca = cosAngle(r,h,c);
    //    writefln("%s", ca);
    //
    //    float a = ca*h;
    //    writefln("a=%s", a);
    //}
}
void testHalfFloat() {
    writefln("testing half float");

    float f = -3.14f;
    auto h  = HalfFloat(f);

    writefln("value=%s (%s)", h.getFloat(), f);

    ushort bits = h.getBits();
    h.setBits(bits);

    writefln("value=%s bits=%s", h.getFloat(), bits);
}

