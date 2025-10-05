module maths.vector3;

import maths.all;

struct Vec3(T) if(isSupportedVecType!T) {
	T x=0,y=0,z=0;

	string toString(float dp=5) const {
	    static if(isFloatingPoint!T) {
		    string fmt = "[%%.%sf, %%.%sf, %%.%sf]".format(dp, dp, dp);
		} else {
		    string fmt = "[%s, %s, %s]";
		}
		return fmt.format(x, y, z);
	}
nothrow:
@nogc:
    this(T v) {
        x=y=z=v;
    }
	this(T x, T y, T z) {
		this.x = x; this.y = y; this.z = z;
	}
	this(Vec2!T v, T z) {
		this(v.x, v.y, z);
	}
	this(T x, Vec2!T yz) {
        this(x, yz.x, yz.y);
    }

    /// v.to!double;
    Vec3!B to(B)() const {
        return Vec3!B(cast(B)x, cast(B)y, cast(B)z);
    }

static if(isFloatingPoint!T) {
	static Vec3!T project(
		Vec3!T obj,
		ref Mat4!T view,
		ref Mat4!T proj,
		Rect viewport)
	{
		auto tmp = Vec4!T(obj, 1);
		tmp = view * tmp;
		tmp = proj * tmp;
		tmp /= tmp.w;
		tmp *= 0.5;
		tmp	+= 0.5;
		tmp.x = tmp.x * viewport.width + viewport.x;
		tmp.y = tmp.y * viewport.height + viewport.y;
		return tmp.xyz;
	}
	static Vec3!T unProject(
		Vec3!T screenPos,
		ref Mat4!T invViewProj,	// (proj * view).inversed()
		Rect viewport)
	{
		auto tmp = Vec4!T(screenPos, 1);
		tmp.x = (tmp.x - viewport.x) / viewport.width;
		tmp.y = (tmp.y - viewport.y) / viewport.height;
		tmp = tmp * 2 - 1;

		auto obj = invViewProj * tmp;
		obj /= obj.w;

		return obj.xyz;
	}
}
pragma(inline,true) {
    // getters
	ref T r() { return x; }
	ref T g() { return y; }
	ref T b() { return z; }
	Vec2!T xy() const { return Vec2!T(x,y); }
	Vec2!T xz() const { return Vec2!T(x,z); }
	Vec2!T yx() const { return Vec2!T(y,x); }
    Vec2!T yz() const { return Vec2!T(y,z); }
    Vec2!T zx() const { return Vec2!T(z,x); }
    Vec2!T zy() const { return Vec2!T(z,y); }
	T* ptr() { return &x; }

    // setters
	void r(T v) { x = v; }
    void g(T v) { y = v; }
    void b(T v) { z = v; }

	T opIndex(int i) const { assert(i >= 0 && i<3); return (&x)[i]; }
	T opIndexAssign(T value, int i) { assert(i >= 0 && i<3); ptr[i] = value; return value; }
}
	bool opEquals(T[] array) const {
		return opEquals(Vec3!T(array[0], array[1], array[2]));
	}
	bool opEquals(inout Vec3!T o) const {
		static if(isFloatingPoint!T) {
			const maxRelDiff = 10.0 ^^ -((T.dig + 1) / 2 + 1);
            const maxAbsDiff = T.epsilon*2;

			if(!isClose!(T, T)(x, o.x, maxRelDiff, maxAbsDiff)) return false;
			if(!isClose!(T, T)(y, o.y, maxRelDiff, maxAbsDiff)) return false;
			if(!isClose!(T, T)(z, o.z, maxRelDiff, maxAbsDiff)) return false;
			return true;
		} else {
			return x==o.x && y==o.y && z==o.z;
		}
	}
	//size_t toHash() @trusted const {
	//	uint* p = cast(uint*)&x;
	//	return (cast(ulong)p[0]<<32 | cast(ulong)p[1]) ^
	//		   (cast(ulong)p[2]<<32 | cast(ulong)p[2]);
	//}
    size_t toHash() const @trusted {
        static if(T.sizeof==4) {
            uint* p = cast(uint*)&x;
        } else static if(T.sizeof==8) {
            ulong* p = cast(ulong*)&x;
        }

        ulong a = 5381;
        a  = ((a << 7) )  + p[0];
        a ^= ((a << 13) ) + p[1];
        a  = ((a << 19) ) + p[2];
        return a;
    }

	auto opUnary(string op)() {
        static if(op == "-") {
            return Vec3!T(-x, -y, -z);
        } else assert(false, "Unary operator "~op~" for type %s not implemented".format(T.stringof));
    }
    Vec3!T opBinary(string op)(T s) const {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
            return mixin("Vec3!T(x"~op~"s,y"~op~"s,z"~op~"s)");
        } else assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
    }
    Vec3!T opBinary(string op)(Vec3!T rhs) const {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
            return mixin("Vec3!T(x"~op~"rhs.x,y"~op~"rhs.y,z"~op~"rhs.z)");
        } else assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
    }
    void opOpAssign(string op)(T s) {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
            mixin("x"~op~"=s; y"~op~"=s; z"~op~"=s;");
        } else assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
    }
    void opOpAssign(string op)(Vec3!T rhs) {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
           	mixin("x"~op~"=rhs.x; y"~op~"=rhs.y; z"~op~"=rhs.z;");
        } else assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
    }

    bool anyLT(T v) const  { return x<v || y<v || z<v; }
    bool anyLTE(T v) const { return x<=v || y<=v || z<=v; }
    bool anyGT(T v) const  { return x>v || y>v || z>v; }
    bool anyGTE(T v) const { return x>=v || y>=v || z>=v; }
    bool anyLT(Vec3!T v) const  { return x<v.x || y<v.y || z<v.z; }
    bool anyLTE(Vec3!T v) const { return x<=v.x || y<=v.y || z<=v.z; }
    bool anyGT(Vec3!T v) const  { return x>v.x || y>v.y || z>v.z; }
    bool anyGTE(Vec3!T v) const { return x>=v.x || y>=v.y || z>=v.z; }

	bool allLT(T v) const  { return x<v && y<v && z<v; }
    bool allLTE(T v) const { return x<=v && y<=v && z<=v; }
    bool allGT(T v) const  { return x>v && y>v && z>v; }
    bool allGTE(T v) const { return x>=v && y>=v && z>=v; }
    bool allLT(Vec3!T v) const  { return x<v.x && y<v.y && z<v.z; }
    bool allLTE(Vec3!T v) const { return x<=v.x && y<=v.y && z<=v.z; }
    bool allGT(Vec3!T v) const  { return x>v.x && y>v.y && z>v.z; }
    bool allGTE(Vec3!T v) const { return x>=v.x && y>=v.y && z>=v.z; }

    T hadd() const { return x+y+z; }
    T hmul() const { return x*y*z; }

    Vec3!T floor() const {
        import std.math : fl = floor;
        return Vec3!T(cast(T)fl(cast(float)x),
                      cast(T)fl(cast(float)y),
                      cast(T)fl(cast(float)z));
    }
	Vec3!T round() const {
        import std.math : round;
        return Vec3!T(cast(T)round(cast(float)x),
                      cast(T)round(cast(float)y),
                      cast(T)round(cast(float)z));
    }

    uint indexOfMin() const {
        return x<y && x<z ? 0 :
               y<z ? 1 : 2;
    }
    uint indexOfMax() const {
        return x>y && x>z ? 0 :
               y>z ? 1 : 2;
    }

    T min() const { return .min(x,y,z); }
    T max() const { return .max(x,y,z); }

    Vec3!T min(Vec3!T o) const {
        return Vec3!T(
            .min(x, o.x),
            .min(y, o.y),
            .min(z, o.z)
        );
    }
    Vec3!T max(Vec3!T o) const {
        return Vec3!T(
            .max(x, o.x),
            .max(y, o.y),
            .max(z, o.z)
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
	T dot(Vec3!T rhs) const {
		return (x*rhs.x) + (y*rhs.y) + (z*rhs.z);
	}
	/**
	 *  True if this vector is approx. parallel to rhs.
	 *  Assumes this and rhs are unit vectors.
	 */
	bool isParallelTo(Vec3!T rhs) {
        T d = dot(rhs);
        return d==1 || d==-1;
	}
	// U.cross(V).length == U.length * V.length * sin(a)
	// where a is the angle between U amd V
	auto cross(Vec3!T rhs) const {
		return Vec3!T(y*rhs.z - z*rhs.y,
					  z*rhs.x - x*rhs.z,
					  x*rhs.y - y*rhs.x);
	}
	float tripleProduct(Vec3!T a, Vec3!T b) const {
		Vec3!T temp = Vec3!T(x,y,z);
		return temp.cross(a).dot(b);
	}
	alias length = magnitude;
	T magnitude() const {
		return cast(T)sqrt(cast(float)(x*x + y*y + z*z));
	}
	alias squaredLength = squaredMagnitude;
	T squaredMagnitude() const {
	    return x*x + y*y + z*z;
	}
	alias invLength = invMagnitude;
	T invMagnitude() const {
		return 1 / magnitude();
	}

	void normalise() {
	    float sqlen = squaredLength;
	    if(sqlen==1) return;
	    this *= cast(T)(1/sqrt(sqlen));
	}
	auto normalised() const {
	    float sqlen = squaredLength;
	    if(sqlen==1) return Vec3!T(x,y,z);
		return Vec3!T(x,y,z) * cast(T)(1/sqrt(sqlen));
	}

    /// returns 1/this
	auto reciprocalOf() const {
	    return Vec3!T(1/x, 1/y, 1/z);
	}

	auto abs() const {
        return Vec3!T(.abs(x), .abs(y), .abs(z));
	}

	/** Compare two Vec3 structs component-wise */
    auto compareTo(Vec3!T rhs) {
        return Vec3!T(
            x == rhs.x ? 0 : x > rhs.x ? 1 : -1,
            y == rhs.y ? 0 : y > rhs.y ? 1 : -1,
			z == rhs.z ? 0 : z > rhs.z ? 1 : -1
        );
    }

    /// v1.v2 / (|v1|.|v2|)
    Angle!T angleTo(Vec3!T v) const {
        T angle = cast(T)acos(cast(float)(dot(v) / (magnitude * v.magnitude)));
        return Angle!T(angle);
    }

    /// rotate this by d degrees toward vector v
    void rotateTo(Vec3!T v, Angle!T angle) {
        this = this.rotatedTo(v, angle);
    }

    /// this rotated by d degrees toward vector v
    auto rotatedTo(Vec3!T v, Angle!T angle) const {
        float radians = angle.radians;
        auto v1       = this.left(v);
        auto v2       = this.cross(v1);
        auto v3       = this.normalised() * cast(T)cos(radians) +
                          v2.normalised() * cast(T)sin(radians);
        return v3*length();
    }
	/**
	 *  Assumes this, v1 and v2 all have the
	 *  same origin ie (0,0,0).
	 *  If result is positive then point is in front of
	 *  the plane else it is behind it.
	 */
	T distanceFromPlane(Vec3!T v1, Vec3!T v2) {
		const normal = v2.cross(v1).normalised();
		return normal.dot(this);
	}
	void rotateAroundX(Angle!T angle) {
	    float radians = angle.radians;
		double c  = cos(radians);
		double s  = sin(radians);
		double yy = y;
		double zz = z;
		y = cast(T)(yy*c - zz*s);
		z = cast(T)(yy*s + zz*c);
	}
	void rotateAroundY(Angle!T angle) {
	    float radians = angle.radians;
		double c  = cos(radians);
		double s  = sin(radians);
		double xx = x;
		double zz = z;
		x = cast(T)(xx*c + zz*s);
		z = cast(T)(-xx*s + zz*c);
	}
	void rotateAroundZ(Angle!T angle) {
	    float radians = angle.radians;
		double c  = cos(radians);
		double s  = sin(radians);
		double xx = x;
		double yy = y;
		x = cast(T)(xx*c - yy*s);
		y = cast(T)(xx*s + yy*c);
	}
	Vec3!T rotatedAroundX(Angle!T angle) const {
	    float radians = angle.radians;
        double c  = cos(radians);
        double s  = sin(radians);
        double yy = y;
        double zz = z;
        return Vec3!T(x, cast(T)(yy*c - zz*s), cast(T)(yy*s + zz*c));
    }
    Vec3!T rotatedAroundY(Angle!T angle) const {
        float radians = angle.radians;
        double c  = cos(radians);
        double s  = sin(radians);
        double xx = x;
        double zz = z;
        return Vec3!T(cast(T)(xx*c + zz*s), y, cast(T)(-xx*s + zz*c));
    }
    Vec3!T rotatedAroundZ(Angle!T angle) const {
        float radians = angle.radians;
        double c  = cos(radians);
        double s  = sin(radians);
        double xx = x;
        double yy = y;
        return Vec3!T(cast(T)(xx*c - yy*s), cast(T)(xx*s + yy*c), z);
    }

	T distanceTo(T)(Vec3!T b) nothrow @nogc {
		return (this-b).magnitude;
	}
	T distanceToSquared(T)(Vec3!T b) nothrow @nogc {
		return (this-b).magnitudeSquared;
	}
}
// -------------------------------------------------------------------------
Vec3!T normal(T)(Vec3!T a, Vec3!T b) nothrow @nogc {
	return Vec3!T(
		(b[1] * a[2]) - (b[2] * a[1]),
		(b[2] * a[0]) - (b[0] * a[2]),
		(b[0] * a[1]) - (b[1] * a[0])
	);
}
Vec3!T right(T)(Vec3!T dir, Vec3!T up) nothrow @nogc {
	return dir.cross(up);
}
Vec3!T left(T)(Vec3!T dir, Vec3!T up) nothrow @nogc {
	return -dir.right(up);
}
