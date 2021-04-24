module maths.vector4;

import maths.all;

struct Vec4(T) if(isSupportedVecType!T) {
	T x=0,y=0,z=0,w=0;

	string toString(float dp=5) const {
        static if(isFloatingPoint!T) {
            string fmt = "[%%.%sf, %%.%sf, %%.%sf, %%.%sf]".format(dp, dp, dp, dp);
        } else {
            string fmt = "[%s, %s, %s, %s]";
        }
        return fmt.format(x, y, z, w);
    }
nothrow:
//@nogc:
	this(T v) {
		x = y = z = w = v;
	}
	this(T x, T y, T z, T w) {
		this.x = x; this.y = y; this.z = z; this.w = w;
	}
	this(Vec3!T v, T w) {
		this(v.x, v.y, v.z, w);
	}
	this(T x, Vec3!T v) {
        this(x, v.x, v.y, v.z);
    }
	this(Vec2!T v, T z, T w) {
		this(v.x, v.y, z, w);
	}
	this(T x, T y, Vec2!T v) {
        this(x, y, v.x, v.y);
    }
	this(Vec2!T v, Vec2!T v2) {
		this(v.x, v.y, v2.x, v2.y);
	}

    /// v.to!double;
    Vec4!B to(B)() const {
        return Vec4!B(cast(B)x, cast(B)y, cast(B)z, cast(B)w);
    }

pragma(inline,true) {
    // getters
	ref T r() { return x; }
	ref T g() { return y; }
	ref T b() { return z; }
	ref T a() { return w; }
	ref T width() { return z; }   // rect
    ref height() { return w; }  // rect
	Vec2!T xy() const { return Vec2!T(x,y); }
	Vec2!T yz() const { return Vec2!T(y,z); }
	Vec2!T zw() const { return Vec2!T(z,w); }
	Vec3!T xyz() const { return Vec3!T(x,y,z); }
	Vec3!T yzw() const { return Vec3!T(y,z,w); }
	Vec3!T rgb() const { return Vec3!T(x,y,z); }
	T* ptr() { return &x; }
	Vec2!T dimension() { return Vec2!T(width,height); }

	// setters
	void r(T v) { x = v; }
    void g(T v) { y = v; }
    void b(T v) { z = v; }
    void a(T v) { w = v; }
	void width(T v) { z = v; }
    void height(T v) { w = v; }

	T opIndex(int i) const { assert(i >= 0 && i<4); return (&x)[i]; }
	T opIndexAssign(T value, int i) { assert(i >= 0 && i<4); ptr[i] = value; return value; }
}
	bool opEquals(T[] array) const { return x==array[0] && y==array[1] && z==array[2] && w==array[3]; }

	bool opEquals(inout Vec4!T o) const {
        static if(isFloatingPoint!T) {
            if(!isClose!(T, T)(x, o.x)) return false;
            if(!isClose!(T, T)(y, o.y)) return false;
            if(!isClose!(T, T)(z, o.z)) return false;
            if(!isClose!(T, T)(w, o.w)) return false;
            return true;
        } else {
            return x==o.x && y==o.y && z==o.z && w==o.w;
        }
	}
	size_t toHash() const @trusted {
        static if(T.sizeof==4) {
            uint* p = cast(uint*)&x;
        } else static if(T.sizeof==8) {
            ulong* p = cast(ulong*)&x;
        }

        ulong a = 5381;
        a  = (a << 7) + p[0];
        a ^= (a << 13) + p[1];
        a  = (a << 19) + p[2];
        a ^= (a << 23) + p[3];
        return a;
    }

    auto opUnary(string op)() {
        static if(op == "-") {
            return Vec4!T(-x, -y, -z, -w);
        } else assert(false, "Unary operator "~op~" for type %s not implemented".format(T.stringof));
    }
    Vec4!T opBinary(string op)(T s) const {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
            return mixin("Vec4!T(x"~op~"s,y"~op~"s,z"~op~"s,w"~op~"s)");
        } else assert(false, "Vec4!%s"~op~"%s is not implemented".format(T.stringof, T.stringof));
    }
    Vec4!T opBinary(string op)(Vec4!T rhs) const {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
            return mixin("Vec4!T(x"~op~"rhs.x,y"~op~"rhs.y,z"~op~"rhs.z,w"~op~"rhs.w)");
        } else assert(false, "Vec4!%s"~op~"Vec4!%s is not implemented".format(T.stringof, T.stringof));
    }
    void opOpAssign(string op)(T s) {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
            mixin("x"~op~"=s; y"~op~"=s; z"~op~"=s; w"~op~"=s;");
        } else assert(false, "Vec4!%s"~op~"=%s is not implemented".format(T.stringof, T.stringof));
    }
    void opOpAssign(string op)(Vec4!T rhs) {
        static if(isFloatingPoint!T && isIntOnlyVectorBinaryOp!op) {
            static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
        } else static if(isSupportedVectorBinaryOp!op) {
           	mixin("x"~op~"=rhs.x; y"~op~"=rhs.y; z"~op~"=rhs.z; w"~op~"=rhs.w;");
        } else assert(false, "Vec4!%s"~op~"=Vec4!%s is not implemented".format(T.stringof, T.stringof));
    }

static if(isFloatingPoint!T) {
    Vec4!T opBinary(string op)(Mat4!T o) const {
        static if(op=="*") {
            return Vec4!T(
                o[0].x * x + o[0].y * y + o[0].z * z + o[0].w * w,
                o[1].x * x + o[1].y * y + o[1].z * z + o[1].w * w,
                o[2].x * x + o[2].y * y + o[2].z * z + o[2].w * w,
                o[3].x * x + o[3].y * y + o[3].z * z + o[3].w * w);
        } else assert(false, "Vec4!%s"~op~"Mat4!%s is not implemented".format(T.stringof, T.stringof));
    }
}

    bool anyLT(T v) const  { return x<v || y<v || z<v || w<v; }
    bool anyLTE(T v) const { return x<=v || y<=v || z<=v || w<=v; }
    bool anyGT(T v) const  { return x>v || y>v || z>v || w>v; }
    bool anyGTE(T v) const { return x>=v || y>=v || z>=v || w>=v; }
    bool anyLT(Vec4!T v) const  { return x<v.x || y<v.y || z<v.z || w<v.w; }
    bool anyLTE(Vec4!T v) const { return x<=v.x || y<=v.y || z<=v.z || w<=v.w; }
    bool anyGT(Vec4!T v) const  { return x>v.x || y>v.y || z>v.z || w>v.w; }
    bool anyGTE(Vec4!T v) const { return x>=v.x || y>=v.y || z>=v.z || w>=v.w; }

    bool allLT(T v) const  { return x<v && y<v && z<v && w<v; }
    bool allLTE(T v) const { return x<=v && y<=v && z<=v && w<=v; }
    bool allGT(T v) const  { return x>v && y>v && z>v && w>v; }
    bool allGTE(T v) const { return x>=v && y>=v && z>=v && w>=v; }
    bool allLT(Vec4!T v) const  { return x<v.x && y<v.y && z<v.z && w<v.w; }
    bool allLTE(Vec4!T v) const { return x<=v.x && y<=v.y && z<=v.z && w<=v.w; }
    bool allGT(Vec4!T v) const  { return x>v.x && y>v.y && z>v.z && w>v.w; }
    bool allGTE(Vec4!T v) const { return x>=v.x && y>=v.y && z>=v.z && w>=v.w; }

    T hadd() const { return x+y+z+w; }
    T hmul() const { return x*y*z*w; }

    Vec4!T floor() const {
        import std.math : fl = floor;
        return Vec4!T(cast(T)fl(cast(float)x),
                      cast(T)fl(cast(float)y),
                      cast(T)fl(cast(float)z),
                      cast(T)fl(cast(float)w));
    }

    T min() const { return .min(x,y,z,w); }
    T max() const { return .max(x,y,z,w); }

    Vec4!T min(Vec4!T o) const {
        return Vec4!T(
            .min(x, o.x),
            .min(y, o.y),
            .min(z, o.z),
            .min(w, o.w)
        );
    }
    Vec4!T max(Vec4!T o) const {
        return Vec4!T(
            .max(x, o.x),
            .max(y, o.y),
            .max(z, o.z),
            .max(w, o.w)
        );
    }

	T dot(Vec4!T rhs) const {
		return x*rhs.x + y*rhs.y + z*rhs.z + w*rhs.w;
	}

	T magnitude() const {
		return cast(T)sqrt(cast(float)(x*x + y*y + z*z + w*w));
	}
	T invMagnitude() const {
		return 1 / magnitude();
	}

	void normalise() {
		this *= invMagnitude();
	}
	Vec4!T normalised() const {
		return Vec4!T(x,y,z,w) * invMagnitude();
	}

    auto abs() const {
        return Vec4!T(.abs(x), .abs(y), .abs(z), .abs(w));
    }
}

/+
// use this to do lots of fast dot products
asm{
naked;
//vzeroall;
//vzeroupper;
push RSI;
push RDI;
mov RSI, p;
vmovaps XMM0, [RCX];	// inputs
vmulps XMM0, XMM0, [RSI];
//vhaddps XMM0, XMM0, XMM0;
//vhaddps XMM0, XMM0, XMM0;
//vmovss [RSI+8*4], XMM0;
pop RDI;
pop RSI;
ret 0;
}
+/

