module maths.angle;

import maths.all;

@nogc:
nothrow:
pragma(inline,true):

/// eg. 90.degrees
Angle!float degrees(float d) pure {
    return Angle!float(d*f_PIdiv180);
}
/// eg. 90.radians
Angle!float radians(float d) pure {
    return Angle!float(d);
}
//=========================================================
struct Angle(T) {
    T radians;

    string toString() {
        return "%.2f deg".format(degrees());
    }
    Angle!T opUnary(string op)() const if(op=="-") {
        return Angle!T(-radians);
    }
    Angle!T opBinary(string op)(Angle!T o) const if(op=="+" || op=="-") {
        return Angle!T(radians + o.radians);
    }
@nogc:
nothrow:
pragma(inline,true):
    T degrees() const {
        return cast(T)(this.radians*f_180divPI);
    }
    bool opEquals(inout Angle!T o) const {
        return radians==o.radians;
    }
}
//=========================================================
