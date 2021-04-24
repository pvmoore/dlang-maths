module maths.vector2;

import maths.all;



struct Vec2(T) if(isSupportedVecType!T) {
	T x=0,y=0;

	string toString(float dp=5) const {
        static if(isFloatingPoint!T) {
            string fmt = "[%%.%sf, %%.%sf]".format(dp, dp);
        } else {
            string fmt = "[%s, %s]";
        }
        return fmt.format(x, y);
    }
//nothrow:
//@nogc:
	this(T v) {
		x = y = v;
	}
	this(T x, T y) {
		this.x = x; this.y = y;
	}

pragma(inline,true) {
    // getters
    ref T u() { return x; }
    ref T v() { return y; }
    ref T width() { return x; }
    ref T height() { return y; }
	T* ptr() { return &x; }

    // setters
    void u(T v) { x = v; }
    void v(T v) { y = v; }
	void width(T v) { x = v; }
    void height(T v) { y = v; }

    /// v.to!double;
    auto to(B)() const {
        return Vec2!B(cast(B)x, cast(B)y);
    }

	T opIndex(int i) const { assert(i >= 0 && i<2); return i==0 ? x : y; }
	T opIndexAssign(T value, int i) { assert(i >= 0 && i<2); if(i==0) x = value; else y = value; return value; }
}
	bool opEquals(T[] array) const { return array.length==2 && x==array[0] && y==array[1]; }
	bool opEquals(inout Vec2!T o) const {
        static if(isFloatingPoint!T) {
            if(!isClose!(T, T)(x, o.x)) return false;
            if(!isClose!(T, T)(y, o.y)) return false;
            return true;
        } else {
            return x==o.x && y==o.y;
        }
	}
	//size_t toHash() @trusted const {
	//	Object o;
	//	ulong* p = cast(ulong*)&x;
	//	return *p;
	//}
	size_t toHash() const @trusted {
        static if(T.sizeof==4) {
            uint* p = cast(uint*)&x;
        } else static if(T.sizeof==8) {
            ulong* p = cast(ulong*)&x;
        }

        ulong a = 5381;
        a  = ((a << 7) ) + p[0];
        a ^= ((a << 13) ) + p[1];
        return a;
    }

    auto opUnary(string op)() {
        static if(op == "-") {
            return Vec2!T(-x, -y);
        } else assert(false, "Unary operator "~op~" for type %s not implemented".format(T.stringof));
    }
    Vec2!T opBinary(string op)(T s) const {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
            return mixin("Vec2!T(x"~op~"s,y"~op~"s)");
        } else assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
    }
    Vec2!T opBinary(string op)(Vec2!T rhs) const {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
            return mixin("Vec2!T(x"~op~"rhs.x,y"~op~"rhs.y)");
        } else assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
    }
    void opOpAssign(string op)(T s) {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
            mixin("x"~op~"=s; y"~op~"=s;");
        } else assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
    }
    void opOpAssign(string op)(Vec2!T rhs) {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
            mixin("x"~op~"=rhs.x; y"~op~"=rhs.y;");
        } else assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
    }

    bool anyLT(T v) const  { return x<v || y<v; }
    bool anyLTE(T v) const { return x<=v || y<=v; }
    bool anyGT(T v) const  { return x>v || y>v; }
    bool anyGTE(T v) const { return x>=v || y>=v; }
    bool anyLT(Vec2!T v) const  { return x<v.x || y<v.y; }
    bool anyLTE(Vec2!T v) const { return x<=v.x || y<=v.y; }
    bool anyGT(Vec2!T v) const  { return x>v.x || y>v.y; }
    bool anyGTE(Vec2!T v) const { return x>=v.x || y>=v.y; }

    bool allLT(T v) const  { return x<v && y<v; }
    bool allLTE(T v) const { return x<=v && y<=v; }
    bool allGT(T v) const  { return x>v && y>v; }
    bool allGTE(T v) const { return x>=v && y>=v; }
    bool allLT(Vec2!T v) const  { return x<v.x && y<v.y; }
    bool allLTE(Vec2!T v) const { return x<=v.x && y<=v.y; }
    bool allGT(Vec2!T v) const  { return x>v.x && y>v.y; }
    bool allGTE(Vec2!T v) const { return x>=v.x && y>=v.y; }

    T hadd() const { return x+y; }
    T hmul() const { return x*y; }

    Vec2!T floor() const {
        import std.math : fl = floor;
        return Vec2!T(cast(T)fl(cast(float)x),
                      cast(T)fl(cast(float)y));
    }

    T min() const { return .min(x,y); }
    T max() const { return .max(x,y); }

    Vec2!T min(Vec2!T o) const {
        return Vec2!T(
            .min(x, o.x),
            .min(y, o.y)
        );
    }
    Vec2!T max(Vec2!T o) const {
        return Vec2!T(
            .max(x, o.x),
            .max(y, o.y)
        );
    }
    /**
     * if A and B are unit vectors:
     * A B           A            A |
     * ^ ^           ^            ^ |
     * | |           |            | |
     * | |           |            | v
     * | |     <-----|------> B   | B
     * A.B = 1    A.B = 0         A.B = -1
     */
	T dot(Vec2!T rhs) const {
		return (x*rhs.x) + (y*rhs.y);
	}

    alias length = magnitude;
	T magnitude() const {
		return cast(T)sqrt(cast(float)magnitudeSquared);
	}
	T magnitudeSquared() const {
		return x*x + y*y;
	}
	T invMagnitude() const {
		return 1 / magnitude;
	}

	void normalise() {
		this *= invMagnitude();
	}
	auto normalised() const {
		return Vec2!T(x,y) * invMagnitude;
	}

	auto abs() const {
        return Vec2!T(.abs(x), .abs(y));
    }

static if(isFloatingPoint!T) {

    void floor() {
        import std.math : floor;
        this.x = floor(x);
        this.y = floor(y);
    }
    void ceil() {
        import std.math : ceil;
        this.x = ceil(x);
        this.y = ceil(y);
    }
    void truncate() {
        import std.math : trunc;
        this.x = trunc(x);
        this.y = trunc(y);
    }
    void fract() {
        import std.math : floor;
        this.x -= floor(x);
        this.y -= floor(y);
    }
    auto floored() {
        import std.math : floor;
        return Vec2!T(floor(x), floor(y));
    }
    auto ceiled() {
        import std.math : ceil;
        return Vec2!T(ceil(x), ceil(y));
    }
    /**
     *  Return truncated version eg. (1.25, 10.4) --> (1, 10)
     */
    auto truncated() const {
        import std.math : trunc;
        return Vec2!T(trunc(x), trunc(y));
    }
    /**
     *  Return fractional components eg. (1.25, 10.4) --> (0.25, 0.4)
     */
    auto fract() const {
        return Vec2!T(x,y) - truncated();
    }
}

static if(isFloatingPoint!T) {
	/// assumes 0 is up (0,1). degrees = v.toRadians.toDegrees;
	Angle!T angle() const {
		auto n = normalised;
		return Angle!T(cast(T)-atan2(cast(float)n.x, cast(float)n.y));
	}

	/// radians_angle = acos(|v1|.|v2|)
	Angle!T angleTo(Vec2!T v) const {
		return Angle!T(cast(T)acos(cast(float)normalised().dot(v.normalised())));
	}

	/// this can probably be done more quickly
	bool isLeftOfLine(Vec2!T v, Vec2!T w) {
		Vec2!T pointvec = (this-v).normalised;
		Vec2!T linevec  = (w-v).normalised;
		Vec2!T left	 = linevec.left;
		return left.dot(pointvec) >= 0;
	}
	T distanceFromLine(Vec2!T a, Vec2!T b) {
        Vec2!T n  = b - a;
        Vec2!T pa = a - this;
        Vec2!T c  = n * pa.dot(n) / n.dot(n);
        Vec2!T d  = pa - c;
        return sqrt(d.dot(d));
    }
    T distanceFromLineSquared(Vec2!T a, Vec2!T b) {
        Vec2!T ab = b - a;
        Vec2!T ap = this - a;
        Vec2!T bp = this - b;

        T e = ap.dot(ab);
        return ap.dot(ap) - e*e / ab.dot(ab);
	}
	void rotate(Angle!T angle) {
	    const radians = angle.radians;
		double cs = cos(cast(float)radians);
		double sn = sin(cast(float)radians);
		double xx = x;
		x = cast(T)(x*cs-y*sn);
		y = cast(T)(xx*sn+y*cs);
	}
	auto rotated(Angle!T angle) const {
	    const radians = angle.radians;
		double cs = cos(cast(float)radians);
		double sn = sin(cast(float)radians);
		return Vec2!T(cast(T)(x*cs-y*sn), cast(T)(x*sn+y*cs));
	}
}
	/// returns a new Vec2!T which is perpendicular to this one (pointing to the left)
	auto left() const {
		return Vec2!T(-y,x);
	}
	auto right() const {
		return -left;
	}
}

Vec2!T minOf(T)(Vec2!T[] others) {
    assert(others.length > 0);

    auto lowest = others[0];
    foreach(v; others[1..$]) {
        lowest = lowest.min(v);
    }
    return lowest;
}
Vec2!T maxOf(T)(Vec2!T[] others) {
    assert(others.length > 0);

    auto highest = others[0];
    foreach(v; others[1..$]) {
        highest = highest.max(v);
    }
    return highest;
}