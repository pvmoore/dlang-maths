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
    sqrt, acos, asin, atan, isClose, atan2;

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
