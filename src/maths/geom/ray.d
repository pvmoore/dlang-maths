module maths.geom.ray;

import maths.all;

struct Ray {
public:
	float3 origin;
	float3 direction;
	float3 invDirection;
	uint3 posneg;			// 0=positive, 1=negative

	string toString() {
		return "[Ray %s -> %s]".format(origin, direction);
	}
nothrow:
	this(float3 o, float3 d) {
		set(o, d);
	}
	void set(float3 o, float3 d) {
        this.origin = o;
        setDirection(d);
    }
	void set(const ref float3 o, const ref float3 d) {
	    this.origin = o;
	    setDirection(d);
    }
    void setDirection(float3 d) {
        direction    = d;
        invDirection = d.reciprocalOf();
		posneg       = uint3(direction.x<0, direction.y<0, direction.z<0);
    }
	void copyTo(ref Ray toRay) const {
		toRay.origin 		= this.origin;
		toRay.direction 	= this.direction;
		toRay.invDirection 	= this.invDirection;
	}
	/+
	/**
	 * Returns a ray with the same origin but a direction
	 * such that:
	 * this.direction.dot(newRay.direction)==0
	 * eg. the new ray points in a perpendicular direction.
	 */
	Ray getPerpendicular() {
	    // a (x,y,z) = this.direction
	    // b (A,B,C) = perpendicular to a
	    // a.dot(b) = 0
	    // a.dot(b) = a.length*b.length*cos(90)
	    // 1*1*cos(90) = 0
	    Ray r;

	    return r;
	}+/
}


