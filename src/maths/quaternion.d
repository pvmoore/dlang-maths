module maths.quaternion;

import maths.all;

/** 
 * Unit Quaternion.
 * 
 * Needs more functionality and testing ... 
 */
struct Quaternion {
	// Initialise to a unit quaternion (0,0,0,1)
	float x = 0, y = 0, z = 0, w = 1;

	float3 vector() const {
		return float3(x, y, z);
	}
	float angle() const {
		return acos(w) * 2;
	}

	/**
	 *  Create quaternion from euler X angle (in radians).
	 */
	static Quaternion fromEulerX(float radians) {
		auto halfAngle = radians*0.5f;
		auto sinHalf = sin(halfAngle);
		return Quaternion(sinHalf, 0, 0, cos(halfAngle));
	}
	/**
	 *  Create quaternion from euler Y angle (in radians).
	 */
	static Quaternion fromEulerY(float radians) {
		auto halfAngle = radians*0.5f;
		auto sinHalf = sin(halfAngle);
		return Quaternion(0, sinHalf, 0, cos(halfAngle));
	}
	/**
	 *  Create quaternion from euler Z angle (in radians).
	 */
	static Quaternion fromEulerZ(float radians) {
		auto halfAngle = radians*0.5f;
		auto sinHalf = sin(halfAngle);
		return Quaternion(0, 0, sinHalf, cos(halfAngle));
	}
	
	/**
	 *  Create quaternion from euler angles (in radians).
	 */
	static Quaternion fromEulerXYZ(float3 euler) {
		float3 r = euler * 0.5;
		float3 c = float3(cos(r.x), cos(r.y), cos(r.z));
		float3 s = float3(sin(r.x), sin(r.y), sin(r.z));
		return Quaternion(
			s.x * c.y * c.z - c.x * s.y * s.z,
			c.x * s.y * c.z + s.x * c.y * s.z,
			c.x * c.y * s.z - s.x * s.y * c.z,
			c.x * c.y * c.z + s.x * s.y * s.z
		);
	}

	/**
	 *  Create quaternion from unit vector and angle (in radians).
	 */
	static Quaternion fromUnitVectorAndAngle(float3 u, float radians) {
		auto halfAngle = radians*0.5f;
		auto sinHalf = sin(halfAngle);
		return Quaternion(u.x*sinHalf, u.y*sinHalf, u.z*sinHalf, cos(halfAngle));
	}

	/**
	 *  Create quaternion from possibly non-unit vector and angle (in radians).
	 */
	static Quaternion fromVectorAndAngle(float3 u, float radians) {
		return fromUnitVectorAndAngle(u.normalised(), radians);
	}

	/**
	 *  this * scalar
	 *  this + scalar
	 */
	auto opBinary(string op)(float s) const if(op == "*" || op == "+") { 
		return mixin("Quaternion(x"~op~"s, y"~op~"s, z"~op~"s, w"~op~"s)"); 
	}
	/**
	 *  this * Quaternion
	 *  this + Quaternion
	 */
	auto opBinary(string op)(Quaternion o) const if(op == "*" || op == "+") { 
		static if(op == "*") {
			return Quaternion(w*o.x + x*o.w + y*o.z - z*o.y,
							w*o.y + y*o.w + z*o.x - x*o.z,
							w*o.z + z*o.w + x*o.y - y*o.x,
							w*o.w - x*o.x - y*o.y - z*o.z); 
		} else {
			return Quaternion(x+o.x, y+o.y, z+o.z, w+o.w); 
		}
	}

	void normalise() {
		float invMagnitude = 1 / sqrt(x*x + y*y + z*z + w*w);
		x *= invMagnitude;
		y *= invMagnitude;
		z *= invMagnitude;
		w *= invMagnitude;
	}

	float dot(Quaternion o) const {
		return x*o.x + y*o.y + z*o.z + w*o.w;
	}

	/**
	 *  Return vector v rotated by this quaternion.
	 */
	float3 rotate(float3 v) const {
		float3 u = float3(x, y, z);
		return u.dot(v)*u*2 + (w*w - u.dot(u))*v + w*u.cross(v)*2;
	}

	mat4 toRotationMatrix() const {
		return mat4.rowMajor(
			1-2*y*y-2*z*z,   2*x*y-2*w*z,   2*x*z+2*w*y, 0,
			  2*x*y+2*w*z, 1-2*x*x-2*z*z,   2*y*z-2*w*x, 0,
			  2*x*z-2*w*y,   2*y*z+2*w*x, 1-2*x*x-2*y*y, 0,
			            0,             0,             0, 1
		);
	}

	

	// auto lerp(Quaternion o, float a) const {
	// 	return this * (1-a) + o * a;
	// }

	// auto slerp(Quaternion a, Quaternion b, float t) const {
	// 	float cosHalfTheta = a.w * b.w + a.x * b.x + a.y * b.y + a.z * b.z;
	// 	if (abs(cosHalfTheta) >= 1.0) {
	// 		return a;
	// 	}
	// 	if (cosHalfTheta < 0.0) {
	// 		b = -b;
	// 		cosHalfTheta = -cosHalfTheta;
	// 	}
	// 	float halfTheta = acos(cosHalfTheta);
	// 	float sinHalfTheta = sqrt(1.0 - cosHalfTheta * cosHalfTheta);

	// 	if (abs(sinHalfTheta) < 0.001) {
	// 		return a * (1.0 - t) + b * t;
	// 	}
	// 	float ratioA = sin((1.0 - t) * halfTheta) / sinHalfTheta;
	// 	float ratioB = sin(t * halfTheta) / sinHalfTheta;
	// 	return a * ratioA + b * ratioB;
	// }

	bool opEquals(Quaternion other) const {
		return isClose(x, other.x) && isClose(y, other.y) && isClose(z, other.z) && isClose(w, other.w);	
	}

	string toString() const {
		return "(%s, %s, %s, %s)".format(x, y, z, w);
	}
	string toString(string fmt = "%.5f") const {
		string f = format("(%s, %s, %s, %s)", fmt, fmt, fmt, fmt);
		return f.format(x, y, z, w);
	}
}
