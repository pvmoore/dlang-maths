module maths.vector2;

import maths.all;

final struct Vec2(T) if(isSupportedVecType!T) {
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
		if(!approxEqual!(T, T)(x, o.x)) return false;
		if(!approxEqual!(T, T)(y, o.y)) return false;
		return true;
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

    Vec2!T opBinary(string op)(int i) const {
        static if(isFloatingPoint!T) {
            static assert(0, "Operator "~op~" for type %s not implemented".format(T.stringof));
        } else {
            static if(op=="<<" || op==">>") {
                return mixin("Vec2!T(x"~op~"i,y"~op~"i)");
            }
            else static assert(0, "Operator "~op~" for type %s not implemented".format(T.stringof));
        }
    }

	auto opNeg() const { return Vec2!T(-x, -y); }
	auto opAdd(T s) const { return Vec2!T(x+s, y+s); }
	auto opSub(T s) const { return Vec2!T(x-s, y-s); }
	auto opMul(T s) const { return Vec2!T(x*s, y*s); }
	auto opDiv(T s) const { return Vec2!T(x/s, y/s); }
	auto opMod(T s) const { return Vec2!T(x%s, y%s); }

	auto opAdd(Vec2!T rhs) const { return Vec2!T(x+rhs.x, y+rhs.y); }
	auto opSub(Vec2!T rhs) const { return Vec2!T(x-rhs.x, y-rhs.y); }
	auto opMul(Vec2!T rhs) const { return Vec2!T(x*rhs.x, y*rhs.y); }
	auto opDiv(Vec2!T rhs) const { return Vec2!T(x/rhs.x, y/rhs.y); }

	void opAddAssign(T s) { x += s; y += s; }
	void opSubAssign(T s) { x -= s; y -= s; }
	void opMulAssign(T s) { x *= s; y *= s; }
	void opDivAssign(T s) { opMulAssign(1/s); }

	void opAddAssign(Vec2!T rhs) { x += rhs.x; y += rhs.y; }
	void opSubAssign(Vec2!T rhs) { x -= rhs.x; y -= rhs.y; }
	void opMulAssign(Vec2!T rhs) { x *= rhs.x; y *= rhs.y; }
	void opDivAssign(Vec2!T rhs) { x /= rhs.x; y /= rhs.y; }

    bool anyLT(T v) const { return x<v || y<v; }
    bool anyLTE(T v) const { return x<=v || y<=v; }
    bool anyGT(T v) const { return x>v || y>v; }
    bool anyGTE(T v) const { return x>=v || y>=v; }
    bool anyLT(Vec2!T v) const { return x<v.x || y<v.y; }
    bool anyLTE(Vec2!T v) const { return x<=v.x || y<=v.y; }
    bool anyGT(Vec2!T v) const { return x>v.x || y>v.y; }
    bool anyGTE(Vec2!T v) const { return x>=v.x || y>=v.y; }

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
