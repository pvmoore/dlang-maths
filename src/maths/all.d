module maths.all;

public:

import std.format : format;
import std.random : uniform, Mt19937, unpredictableSeed;
import std.conv   : to;
import std.stdio  : writefln;
import std.algorithm : reverse;
import std.traits   : isFloatingPoint, isImplicitlyConvertible;
import std.math   :
    abs, cos, floor, sin, tan, pow,
    sqrt, acos, asin, atan, isClose, atan2, approxEqual;

import common : dumpGPR, dumpXMM_PS, dumpXMM_PD;

import maths;

template isSupportedVecType(T) {
    const bool isSupportedVecType =
        is(T==int) ||
        is(T==uint) ||
        is(T==float) ||
        is(T==double) ||
        is(T==long) ||
        is(T==ulong);
}
template isIntOnlyVectorBinaryOp(string op) {
    const bool isIntOnlyVectorBinaryOp =
        op=="&" || op=="|" || op=="^" || op=="<<" || op==">>" || op==">>>";
}
template isSupportedVectorBinaryOp(string op) {
    const bool isSupportedVectorBinaryOp =
        op=="&" || op=="|" || op=="^" || op=="<<" || op==">>" || op==">>>" ||
        op=="+" || op=="-" || op=="*" || op=="/" || op=="%";
}

/**
 * https://en.wikipedia.org/wiki/IEEE_754
 *
 * [31  30------23  22---------------------0]
 *  ^   ^           ^
 *  |   |           |
 *  |    \           \
 *  |     \           |
 *  sign   exponent   mantissa
 *    
 * [ 1  bit] sign bit (F >>> 31)
 * [ 8 bits] exponent ((F >>> 22) & 0xff)
 * [23 bits] mantissa (F & 7f_ffff)
 * 
 */
string dumpFloat(float f) {
    string s;

    uint u = *cast(uint*)cast(float*)&f;

    if(u == 0) return "0.0";
    if(u == 0x7f800000) return "+Inf";
    if(u == 0xff800000) return "-Inf";
    if(u == 0x7fc00000) return "NaN";

    uint sign     = u >>> 31;
    int exponent  = (u >>> 23) & 0xff;
    uint mantissa = u & 0x7fffff;
    
    if(exponent == 0) {
        mantissa <<= 1;
    } else {
        mantissa |= 0x800000;
    }

    double value = (sign ? -1.0 : 1.0) * mantissa * pow(2.0, exponent-150.0);

    s ~= "(%08x) Sign %s, Exponent %08b (%s), Mantissa %023b (%s) value = %s".format(
        u, sign, exponent, exponent, mantissa, mantissa, value);

    return s;
}
