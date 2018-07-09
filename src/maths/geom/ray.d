module maths.geom.ray;

import maths.all;

final struct Ray {
public:
	Vector3 origin;
	Vector3 direction;
	Vector3 invDirection;

	string toString() {
		return "[Ray %s -> %s]".format(origin, direction);
	}
nothrow:
	this(Vector3 o, Vector3 d) {
		set(o, d);
	}
	void set(Vector3 o, Vector3 d) {
        this.origin = o;
        setDirection(d);
    }
	void set(const ref Vector3 o, const ref Vector3 d) {
	    this.origin = o;
	    setDirection(d);
    }
    void setDirection(Vector3 d) {
        direction    = d;
        invDirection = d.reciprocalOf();
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


