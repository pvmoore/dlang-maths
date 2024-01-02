module maths.quaternion;

import maths.all;

struct Quaternion {
	float x, y, z, w;
	
	this(float x, float y, float z, float w) { 
		this.x = x; this.y = y; this.z = z; this.w = w; 
	}

	static Quaternion fromEulerZAxis(float radians) {
		return Quaternion(0, 0, sin(radians), cos(radians));
	}
	
	Quaternion opAdd(Quaternion rhs) { 
		return Quaternion(x+rhs.x, y+rhs.y, z+rhs.z, w+rhs.w); 
	}
	Quaternion opSub(Quaternion rhs) { 
		return Quaternion(x-rhs.x, y-rhs.y, z-rhs.z, w-rhs.w); 
	}
	Quaternion opMul(Quaternion o) { 
		return Quaternion(w*o.x + x*o.w + y*o.z - z*o.y,
						  w*o.y + y*o.w + z*o.x - x*o.z,
						  w*o.z + z*o.w + x*o.y - y*o.x,
						  w*o.w - x*o.x - y*o.y - z*o.z); 
	}

	auto opMul(float s) { return Quaternion(x*s, y*s, z*s, w*s); }

	//auto normalised() const {
	//	return Quaternion();
	//}
}
