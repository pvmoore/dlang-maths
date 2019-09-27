module maths.matrix4;

import maths.all;

struct Mat4(T) if(isFloatingPoint!T && isSupportedVecType!T) {
	/* column major format (openGL style)
	  [0] [1] [2] [3]
		0   4   8  12		[0][0]	[1][0]	[2][0]	[3][0]
		1   5   9  13		[0][1]	[1][1]	[2][1]	[3][1]
		2   6  10  14		[0][2]	[1][2]	[2][2]	[3][2]
		3   7  11  15		[0][3]	[1][3]	[2][3]	[3][3]
	*/
	Vec4!T[4] c = void;

	string toString() {
    	return format("%5.2f %5.2f %5.2f %5.2f\n%5.2f %5.2f %5.2f %5.2f\n%5.2f %5.2f %5.2f %5.2f\n%5.2f %5.2f %5.2f %5.2f\n",
					  c[0][0], c[1][0], c[2][0], c[3][0],
					  c[0][1], c[1][1], c[2][1], c[3][1],
					  c[0][2], c[1][2], c[2][2], c[3][2],
					  c[0][3], c[1][3], c[2][3], c[3][3]);
    }
//nothrow:
//@nogc:
	this(T v) {
		c[0] = Vec4!T(v);
		c[1] = Vec4!T(v);
		c[2] = Vec4!T(v);
		c[3] = Vec4!T(v);
	}
	static Mat4!T columnMajor(T[] v...) { assert(v.length==16);
		Mat4!T m = Mat4!T.init;
		m[0] = Vec4!T(v[0],  v[1],  v[2],  v[3]);
		m[1] = Vec4!T(v[4],  v[5],  v[6],  v[7]);
		m[2] = Vec4!T(v[8],  v[9],  v[10], v[11]);
		m[3] = Vec4!T(v[12], v[13], v[14], v[15]);
		return m;
	}
	static Mat4!T rowMajor(T[] v...) { assert(v.length==16);
		Mat4!T m = Mat4!T.init;
		m[0] = Vec4!T(v[0], v[4], v[8],  v[12]);
		m[1] = Vec4!T(v[1], v[5], v[9],  v[13]);
		m[2] = Vec4!T(v[2], v[6], v[10], v[14]);
		m[3] = Vec4!T(v[3], v[7], v[11], v[15]);
		return m;
	}
	static Mat4!T identity() {
		Mat4!T m = Mat4!T(0);
		m[0].x = m[1].y = m[2].z = m[3].w = 1f;
		return m;
	}
	static Mat4!T translate(Vec3!T v) {
		Mat4!T m = Mat4!T.identity();
		m[3][0] = v[0];
		m[3][1] = v[1];
		m[3][2] = v[2];
		return m;
	}
	static Mat4!T scale(Vec3!T v) {
		Mat4!T m = Mat4!T.identity();
		m[0][0] = v[0];
		m[1][1] = v[1];
		m[2][2] = v[2];
		return m;
	}
	static Mat4!T rotateX(Angle!T angle) {
	    const radians = angle.radians;
		Mat4!T m = Mat4!T.identity();
		T C = cos(radians);
		T S = sin(radians);
		m[1][1] = C;
		m[1][2] = S;
		m[2][1] = -S;
		m[2][2] = C;
		return m;
	}
	static Mat4!T rotateY(Angle!T angle) {
	    const radians = angle.radians;
		Mat4!T m = Mat4!T.identity();
		T C = cos(radians);
		T S = sin(radians);
		m[0][0] = C;
		m[0][2] = -S;
		m[2][0] = S;
		m[2][2] = C;
		return m;
	}
	static Mat4!T rotateZ(Angle!T angle) {
	    const radians = angle.radians;
		Mat4!T m = Mat4!T.identity();
		T C = cos(radians);
		T S = sin(radians);
		m[0][0] = C;
		m[0][1] = S;
		m[1][0] = -S;
		m[1][1] = C;
		return m;
	}
	static Mat4!T rotate(Vec3!T v, Angle!T angle) {
	    const radians = angle.radians;
		T C = cos(radians);
		T S = sin(radians);

		Vec3!T axis = v.normalised();
		Vec3!T temp = axis * (1.0f - C);

		Mat4!T Rotate = Mat4!T.identity();
		Rotate[0][0] = C + temp[0] * axis[0];
		Rotate[0][1] = 0 + temp[0] * axis[1] + S * axis[2];
		Rotate[0][2] = 0 + temp[0] * axis[2] - S * axis[1];

		Rotate[1][0] = 0 + temp[1] * axis[0] - S * axis[2];
		Rotate[1][1] = C + temp[1] * axis[1];
		Rotate[1][2] = 0 + temp[1] * axis[2] + S * axis[0];

		Rotate[2][0] = 0 + temp[2] * axis[0] + S * axis[1];
		Rotate[2][1] = 0 + temp[2] * axis[1] - S * axis[0];
		Rotate[2][2] = C + temp[2] * axis[2];

		Mat4!T m = Mat4!T.identity();
		Mat4!T result = Mat4!T.identity();
		result[0] = m[0] * Rotate[0][0] + m[1] * Rotate[0][1] + m[2] * Rotate[0][2];
		result[1] = m[0] * Rotate[1][0] + m[1] * Rotate[1][1] + m[2] * Rotate[1][2];
		result[2] = m[0] * Rotate[2][0] + m[1] * Rotate[2][1] + m[2] * Rotate[2][2];
		result[3] = m[3];
		return result;
	}
	static Mat4!T lookAt(Vec3!T eye, Vec3!T centre, Vec3!T up) {
		auto f = (centre - eye).normalised();
		auto s = f.cross(up).normalised();
		auto u = s.cross(f);

		auto result = Mat4!T.identity();
		result[0][0] = s.x;
		result[1][0] = s.y;
		result[2][0] = s.z;
		result[0][1] = u.x;
		result[1][1] = u.y;
		result[2][1] = u.z;
		result[0][2] =-f.x;
		result[1][2] =-f.y;
		result[2][2] =-f.z;
		result[3][0] =-s.dot(eye);
		result[3][1] =-u.dot(eye);
		result[3][2] = f.dot(eye);
		return result;
	}
	static Mat4!T ortho(T left, T right,
						T bottom, T top,
						T zNear, T zFar)
	{
		auto result = Mat4!T.identity();
		result[0][0] =  2.0f / (right - left);
		result[1][1] =  2.0f / (top - bottom);
		result[2][2] = -2.0f / (zFar - zNear);
		result[3][0] = - (right + left) / (right - left);
		result[3][1] = - (top + bottom) / (top - bottom);
		result[3][2] = - (zFar + zNear) / (zFar - zNear);
		return result;
	}
	static Mat4!T perspective(Angle!T fov, T aspect, T zNear, T zFar) {
		T tanHalfFov = tan(fov.radians / 2.0f);

        auto f = 1.0f / tanHalfFov;

		auto result = Mat4!T(0);
		result[0][0] = f/aspect;
		result[1][1] = f;

		result[2][2] = zFar  / (zFar - zNear);
		result[2][3] = - 1.0f;
		result[3][2] = (zFar * zNear) / (zFar - zNear);


        //result[0][0] = 1.0f / (aspect * tanHalfFov);
        //result[1][1] = 1.0f / (tanHalfFov);
        //
        //result[2][2] = - (zFar + zNear) / (zFar - zNear);
        //result[2][3] = - 1.0f;
        //result[3][2] = - (2.0f * zFar * zNear) / (zFar - zNear);


        //result[2][2] = zFar  / (zNear - zFar);
        //result[2][3] = - 1.0f;
        //result[3][2] = -(zFar * zNear) / (zFar - zNear);
		return result;
	}

	T* ptr() { return cast(T*)c.ptr; }

	void setTranslation(T x, T y, T z) {
	    c[3].x = x;
	    c[3].y = y;
	    c[3].z = z;
	}
	void setTranslation(Vec4!T v) {
        c[3].x = v.x;
        c[3].y = v.y;
        c[3].z = v.z;
    }

	// ------------------------------------------------------------------------------------

	bool opEquals(Mat4!T m) const {
		return c[0] == m[0] && c[1] == m[1] && c[2] == m[2] && c[3] == m[3];
	}
	size_t toHash() const @trusted {
		return c[0].toHash() ^
			   c[1].toHash() * 7 +
			   c[2].toHash() * 13 ^
			   c[3].toHash() * 19;
	}

	ref Vec4!T opIndex(int i) { assert(i>=0 && i<4); return c[i]; }

	Mat4!T opBinary(string op)(T s) const {
		static if(op=="+" || op=="-" || op=="*") {
			Mat4!T copy = this;
			mixin("copy[0] "~op~"= s;");
			mixin("copy[1] "~op~"= s;");
			mixin("copy[2] "~op~"= s;");
			mixin("copy[3] "~op~"= s;");
			return copy;
		} else static if(op=="/") {
			return opBinary!"*"(1.0f/s);
		} else static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
	}
	Mat4!T opBinary(string op)(ref Mat4!T o) const {
		static if(op=="*") {
			Mat4!T result = Mat4!T.init;
			result[1] = c[0] * o[1][0] + c[1] * o[1][1] + c[2] * o[1][2] + c[3] * o[1][3];
			result[2] = c[0] * o[2][0] + c[1] * o[2][1] + c[2] * o[2][2] + c[3] * o[2][3];
			result[3] = c[0] * o[3][0] + c[1] * o[3][1] + c[2] * o[3][2] + c[3] * o[3][3];
			result[0] = c[0] * o[0][0] + c[1] * o[0][1] + c[2] * o[0][2] + c[3] * o[0][3];
			return result;
		} else static if(op=="+" || op=="-") {
			Mat4!T result = Mat4!T.init;
			mixin("result[0] = c[0] "~op~" o[0];");
			mixin("result[1] = c[1] "~op~" o[1];");
			mixin("result[2] = c[2] "~op~" o[2];");
			mixin("result[3] = c[3] "~op~" o[3];");
			return result;
		} else static if(op=="/") {
			// check this
			auto inv = o.inversed;
			return this * inv;
		} else static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
	}
	Vec4!T opBinary(string op)(Vec4!T v) const {
		static if(op=="*") {
			return c[0] * v.x +
				   c[1] * v.y +
				   c[2] * v.z +
				   c[3] * v.w;
		} else static assert(false, "Binary op "~op~" for type %s not implemented".format(T.stringof));
	}

	Mat4!T transposed() const {
		return Mat4!T.rowMajor(
			c[0][0], c[0][1], c[0][2], c[0][3],
			c[1][0], c[1][1], c[1][2], c[1][3],
			c[2][0], c[2][1], c[2][2], c[2][3],
			c[3][0], c[3][1], c[3][2], c[3][3]
		);
	}

	Mat4!T inversed() const {
		T det = determinant;
		if(det==0) det = 1; // this matrix has no inverse
		T d = 1/det;
		Mat4!T result = Mat4!T.init;
		result.c[0][0] =  d * (c[1][1] * (c[2][2] * c[3][3] - c[3][2] * c[2][3]) + c[2][1] * (c[3][2] * c[1][3] - c[1][2] * c[3][3]) + c[3][1] * (c[1][2] * c[2][3] - c[2][2] * c[1][3]));
		result.c[0][1] = -d * (c[0][1] * (c[2][2] * c[3][3] - c[3][2] * c[2][3]) + c[2][1] * (c[3][2] * c[0][3] - c[0][2] * c[3][3]) + c[3][1] * (c[0][2] * c[2][3] - c[2][2] * c[0][3]));
		result.c[0][2] =  d * (c[0][1] * (c[1][2] * c[3][3] - c[3][2] * c[1][3]) + c[1][1] * (c[3][2] * c[0][3] - c[0][2] * c[3][3]) + c[3][1] * (c[0][2] * c[1][3] - c[1][2] * c[0][3]));
		result.c[0][3] = -d * (c[0][1] * (c[1][2] * c[2][3] - c[2][2] * c[1][3]) + c[1][1] * (c[2][2] * c[0][3] - c[0][2] * c[2][3]) + c[2][1] * (c[0][2] * c[1][3] - c[1][2] * c[0][3]));
		result.c[1][0] = -d * (c[1][0] * (c[2][2] * c[3][3] - c[3][2] * c[2][3]) + c[2][0] * (c[3][2] * c[1][3] - c[1][2] * c[3][3]) + c[3][0] * (c[1][2] * c[2][3] - c[2][2] * c[1][3]));
		result.c[1][1] =  d * (c[0][0] * (c[2][2] * c[3][3] - c[3][2] * c[2][3]) + c[2][0] * (c[3][2] * c[0][3] - c[0][2] * c[3][3]) + c[3][0] * (c[0][2] * c[2][3] - c[2][2] * c[0][3]));
		result.c[1][2] = -d * (c[0][0] * (c[1][2] * c[3][3] - c[3][2] * c[1][3]) + c[1][0] * (c[3][2] * c[0][3] - c[0][2] * c[3][3]) + c[3][0] * (c[0][2] * c[1][3] - c[1][2] * c[0][3]));
		result.c[1][3] =  d * (c[0][0] * (c[1][2] * c[2][3] - c[2][2] * c[1][3]) + c[1][0] * (c[2][2] * c[0][3] - c[0][2] * c[2][3]) + c[2][0] * (c[0][2] * c[1][3] - c[1][2] * c[0][3]));
		result.c[2][0] =  d * (c[1][0] * (c[2][1] * c[3][3] - c[3][1] * c[2][3]) + c[2][0] * (c[3][1] * c[1][3] - c[1][1] * c[3][3]) + c[3][0] * (c[1][1] * c[2][3] - c[2][1] * c[1][3]));
		result.c[2][1] = -d * (c[0][0] * (c[2][1] * c[3][3] - c[3][1] * c[2][3]) + c[2][0] * (c[3][1] * c[0][3] - c[0][1] * c[3][3]) + c[3][0] * (c[0][1] * c[2][3] - c[2][1] * c[0][3]));
		result.c[2][2] =  d * (c[0][0] * (c[1][1] * c[3][3] - c[3][1] * c[1][3]) + c[1][0] * (c[3][1] * c[0][3] - c[0][1] * c[3][3]) + c[3][0] * (c[0][1] * c[1][3] - c[1][1] * c[0][3]));
		result.c[2][3] = -d * (c[0][0] * (c[1][1] * c[2][3] - c[2][1] * c[1][3]) + c[1][0] * (c[2][1] * c[0][3] - c[0][1] * c[2][3]) + c[2][0] * (c[0][1] * c[1][3] - c[1][1] * c[0][3]));
		result.c[3][0] = -d * (c[1][0] * (c[2][1] * c[3][2] - c[3][1] * c[2][2]) + c[2][0] * (c[3][1] * c[1][2] - c[1][1] * c[3][2]) + c[3][0] * (c[1][1] * c[2][2] - c[2][1] * c[1][2]));
		result.c[3][1] =  d * (c[0][0] * (c[2][1] * c[3][2] - c[3][1] * c[2][2]) + c[2][0] * (c[3][1] * c[0][2] - c[0][1] * c[3][2]) + c[3][0] * (c[0][1] * c[2][2] - c[2][1] * c[0][2]));
		result.c[3][2] = -d * (c[0][0] * (c[1][1] * c[3][2] - c[3][1] * c[1][2]) + c[1][0] * (c[3][1] * c[0][2] - c[0][1] * c[3][2]) + c[3][0] * (c[0][1] * c[1][2] - c[1][1] * c[0][2]));
		result.c[3][3] =  d * (c[0][0] * (c[1][1] * c[2][2] - c[2][1] * c[1][2]) + c[1][0] * (c[2][1] * c[0][2] - c[0][1] * c[2][2]) + c[2][0] * (c[0][1] * c[1][2] - c[1][1] * c[0][2]));
		return result;
	}

	T determinant() const {
		return c[0][0]*c[1][1]*c[2][2]*c[3][3] - c[0][0]*c[1][1]*c[3][2]*c[2][3] + c[0][0]*c[2][1]*c[3][2]*c[1][3] - c[0][0]*c[2][1]*c[1][2]*c[3][3] +
			   c[0][0]*c[3][1]*c[1][2]*c[2][3] - c[0][0]*c[3][1]*c[2][2]*c[1][3] - c[1][0]*c[2][1]*c[3][2]*c[0][3] + c[1][0]*c[2][1]*c[0][2]*c[3][3] -
			   c[1][0]*c[3][1]*c[0][2]*c[2][3] + c[1][0]*c[3][1]*c[2][2]*c[0][3] - c[1][0]*c[0][1]*c[2][2]*c[3][3] + c[1][0]*c[0][1]*c[3][2]*c[2][3] +
			   c[2][0]*c[3][1]*c[0][2]*c[1][3] - c[2][0]*c[3][1]*c[1][2]*c[0][3] + c[2][0]*c[0][1]*c[1][2]*c[3][3] - c[2][0]*c[0][1]*c[3][2]*c[1][3] +
			   c[2][0]*c[1][1]*c[3][2]*c[0][3] - c[2][0]*c[1][1]*c[0][2]*c[3][3] - c[3][0]*c[0][1]*c[1][2]*c[2][3] + c[3][0]*c[0][1]*c[2][2]*c[1][3] -
			   c[3][0]*c[1][1]*c[2][2]*c[0][3] + c[3][0]*c[1][1]*c[0][2]*c[2][3] - c[3][0]*c[2][1]*c[0][2]*c[1][3] + c[3][0]*c[2][1]*c[1][2]*c[0][3];
	}
}

/*
static Mat4!T ortho(T left, T right,
						T bottom, T top,
						T zNear, T zFar)
	{
		auto result = Mat4!T.identity();
		result[0][0] =  2.0f / (right - left);
		result[1][1] =  2.0f / (top - bottom);
		result[2][2] = -2.0f / (zFar - zNear);
		result[3][0] = - (right + left) / (right - left);
		result[3][1] = - (top + bottom) / (top - bottom);
		result[3][2] = - (zFar + zNear) / (zFar - zNear);
		return result;
	}
*/

/*
vulkan orthoLH from joml
        MemUtil.INSTANCE.identity(this);
        this._m00(2.0f / (right - left));
        this._m11(2.0f / (top - bottom));
        this._m22(1.0f / (zFar - zNear));
        this._m30((right + left) / (left - right));
        this._m31((top + bottom) / (bottom - top));
        this._m32(zNear / (zNear - zFar));

vulkan ortho RH
        MemUtil.INSTANCE.identity(this);
        this._m00(2.0f / (right - left));
        this._m11(2.0f / (top - bottom));
        this._m22(1.0f / (zNear - zFar));
        this._m30((right + left) / (left - right));
        this._m31((top + bottom) / (bottom - top));
        this._m32(zNear / (zNear - zFar));

*/
/// works on Vulkan
Mat4!T vkOrtho(T)(T left, T right,
                  T bottom, T top,
                  T zNear, T zFar)
{
    auto result = Mat4!T.identity();
    result[0][0] = 2.0f / (right - left);
    result[1][1] = 2.0f / (top - bottom);
    result[2][2] = -1.0f / (zFar - zNear);
    result[3][0] = - (right + left) / (right - left);
    result[3][1] = - (top + bottom) / (top - bottom);
    result[3][2] = -zNear / (zFar - zNear);
    return result;
}
Mat4!T vkPerspective(T)(Angle!T fov, T aspect, T zNear, T zFar) {
    T tanHalfFov = tan(fov.radians / 2.0f);

    auto result = Mat4!T(0);
    result[0][0] = 1.0f / (aspect * tanHalfFov);
    result[1][1] = 1.0f / (tanHalfFov);
    result[2][2] = zFar / (zFar - zNear);
    //result[2][2] = zFar / (zNear - zFar);    // uncomment this if you need LH
    result[2][3] = - 1.0f;
    result[3][2] = -(zFar * zNear) / (zFar - zNear);
    return result;
}