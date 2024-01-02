module maths.simd.Vec;

import std.stdio : writefln;
import core.stdc.string : memcmp, memset;

/**
 *  Vec!(uint, 8) a;
 */
struct Vec(T, uint COUNT) if(isSupportedType!T) {
    T[COUNT] data;

    uint length() const { return COUNT; }
    uint sizeBytes() const { return COUNT*T.sizeof; }
    uint sizeBits() const { return sizeBytes()*8; }

    void zero() {
        data[] = 0;
    }

    bool opEquals(inout T[] array) const {
        return array.length == COUNT && memcmp(data.ptr, array.ptr, sizeBytes())==0;
    }

    TYPE opBinary(string op)(T s) const {
        switch(op) {
            default: assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        }
    }
private:
    alias TYPE = Vec!(T,COUNT);
}

private:

template isSupportedType(T) {
    const bool isSupportedType =
        is(T==byte) ||
        is(T==ubyte) ||
        is(T==short) ||
        is(T==ushort) ||
        is(T==int) ||
        is(T==uint) ||
        is(T==long) ||
        is(T==ulong) ||
        is(T==float) ||
        is(T==double);
}
