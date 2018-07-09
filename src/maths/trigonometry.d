module maths.trigonometry;
/**
 *  Trigonometry for right-angled triangles.
 *
 *  http://www.mathsisfun.com/algebra/trigonometric-identities.html
 *
 *  Also note:
 *      - Angles inside a triangle always add up to 180 deg.
 */
import maths.all;

pragma(inline,true):

struct Opposite(T) {
    T value;
}
struct Adjacent(T) {
    T value;
}
struct Hypotenuse(T) {
    T value;
}
//------------------------------------------------------------------
// sin angle = opposite / hypotenuse
T sinAngle(T)(Opposite!T o, Hypotenuse!T h) {
    return o.value / h.value;
}
Angle!T angle(T)(Opposite!T o, Hypotenuse!T h) {
    return radians(asin(sinAngle(o,h)));
}
//------------------------------------------------------------------
// cos angle = adjacent / hypotenuse
T cosAngle(T)(Adjacent!T a, Hypotenuse!T h) {
    return a.value / h.value;
}
Angle!T angle(T)(Adjacent!T a, Hypotenuse!T h) {
    return radians(acos(cosAngle(a,h)));
}
//------------------------------------------------------------------
// tan angle = opposite / adjacent
T tanAngle(T)(Opposite!T o, Adjacent!T a) {
    return o.value / a.value;
}
Angle!T angle(T)(Opposite!T o, Adjacent!T a) {
    return radians(atan(tanAngle(o,a)));
}
//------------------------------------------------------------------
// opposite = sin angle * hypotenuse
T opposite(T)(Angle!T ang, Hypotenuse!T h) {
    return sin(ang.radians)*h.value;
}
// opposite = tan angle * adjacent
T opposite(T)(Angle!T ang, Adjacent!T a) {
    return tan(ang.radians)*a.value;
}
// opposite = sqrt(h*h - a*a)
T opposite(T)(Adjacent!T a, Hypotenuse!T h) {
    return sqrt(h.value*h.value - a.value*a.value);
}
//------------------------------------------------------------------
// adjacent = cos angle * hypotenuse
T adjacent(T)(Angle!T angle, Hypotenuse!T h) {
    return cos(angle.radians)*h.value;
}
// adjacent = opposite / tan angle
T adjacent(T)(Angle!T angle, Opposite!T o) {
    return o.value / tan(angle.radians);
}
// adjacent = sqrt(h*h - o*o)
T adjacent(T)(Opposite!T o, Hypotenuse!T h) {
    return sqrt(h.value*h.value - o.value*o.value);
}
//------------------------------------------------------------------
// hypotenuse = opposite / sin angle
T hypotenuse(T)(Angle!T angle, Opposite!T o) {
    return o.value / sin(angle.radians);
}
// hypotenuse = adjacent / cos angle
T hypotenuse(T)(Angle!T angle, Adjacent!T a) {
    return a.value / cos(angle.radians);
}
// hypotenuse = sqrt(a*a + o*o)
T hypotenuse(T)(Adjacent!T a, Opposite!T o) {
    return sqrt(a.value*a.value + o.value*o.value);
}

/**-----------------------------------------------------------------
 *  Non right-angled triangles.
 *  http://www.mathsisfun.com/algebra/triangle-identities.html
 *  http://www.mathsisfun.com/algebra/trig-cosine-law.html
 *  http://www.mathsisfun.com/algebra/trig-sine-law.html
 *----------------------------------------------------------------*/

// Find angle if lengths of all 3 sides are known.
// Where _c_ is the side opposite the desired angle.
// cos C = (a*a + b*b - c*c) / 2*a*b
T cosAngle(T)(T a, T b, T c) {
    return (a*a + b*b - c*c) / (2*a*b);
}
Angle!T angle(T)(T a, T b, T c) {
    return radians(acos(cosAngle(a,b,c)));
}
//------------------------------------------------------------------