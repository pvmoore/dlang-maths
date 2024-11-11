module test.test_simd;

import std.stdio : writefln;
import std.format : format;

import maths;

version(LDC) {

void testSimd() {
    writefln("Testing simd package...");

    testVec();
}

private:

void testVec() {
    Vec a;
    Vec b;

    rassert(a == [0f,0,0,0,0,0,0,0]);
    rassert(b == [0f,0,0,0,0,0,0,0]);

    a.set([1f,2,3,4,5,6,7,8]);
    b.set([2f,4,6,8,10,12,14,16]);

    rassert(a == [1f,2,3,4,5,6,7,8]);
    rassert(b == [2f,4,6,8,10,12,14,16]);

    //test3();

    //zero(&a);

    //addps(&a, &b);
}

// Assert for debug or release mode
void rassert(bool b, int line = __LINE__) { if(!b) throw new Exception("Fail at line %s".format(line)); }

} // version(LDC)
else {
    void testSimd() {}
}
