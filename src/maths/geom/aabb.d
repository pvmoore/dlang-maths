module maths.geom.aabb;

import maths.all;
/**
 *  Axis-aligned bounding box.
 */
final struct AABB {
public:
	Vector3[2] pp;

	string toString() {
		return "[BBox %s -> %s]".format(pp[0], pp[1]);
	}
	static struct Intersection { float near; float far; }
nothrow:
    pragma(inline,true) {
    @property Vector3 min() { return pp[0]; }
	@property Vector3 max() { return pp[1]; }
	@property Vector3 middle() {
	    return pp[0]+(pp[1]-pp[0])*0.5;
    }
	}

	this(Vector3 a, Vector3 b) {
		set(a,b);
	}
	this(Vector3 a, Vector3 b, Vector3 c) {
        set(a,b);
        enclose(c);
    }
    void set(Vector3 a, Vector3 b) {
        pp[0] = a;
        pp[1] = a;
        enclose(b);
    }
	auto enclose(Vector3 v) {
        pp[0].x = .min(pp[0].x, v.x);
        pp[0].y = .min(pp[0].y, v.y);
        pp[0].z = .min(pp[0].z, v.z);
        pp[1].x = .max(pp[1].x, v.x);
        pp[1].y = .max(pp[1].y, v.y);
        pp[1].z = .max(pp[1].z, v.z);
        return this;
	}
	auto enclose(ref AABB b) {
	    enclose(b.min);
	    enclose(b.max);
	    return this;
	}
	/// Returns true if ray intersects this box.
    bool intersect(const ref Ray r,
                   const float tmin,
                   const float tmax)
    {
        Intersection i;
        return inner(r, tmin, tmax, i);
    }
	/// Returns true if ray intersects this box.
	/// tnear is the entry point
    bool intersect(const ref Ray r,
                   ref float tnear,
                   const float tmin,
                   const float tmax)
    {
        Intersection i;
        if(inner(r, tmin, tmax, i)) {
            tnear = i.near;
            return true;
        }
        return false;
    }
	/// Returns true if ray intersects this box.
	/// tnear is the entry point
	/// tfar is the exit point
	bool intersect(const ref Ray r,
	               ref float tnear,
	               ref float tfar,
	               const float tmin,
	               const float tmax)
    {
        Intersection i;
        if(inner(r, tmin, tmax, i)) {
            tnear = i.near;
            tfar  = i.far;
            return true;
        }
		return false;
	}
private:
	bool inner(const ref Ray r,
               float tmin,
               float tmax,
               ref Intersection i)
    {
	    int posneg;
        float t0;
        float t1;

        posneg = r.direction.x < 0;
        t0 = (pp[posneg].x - r.origin.x) * r.invDirection.x;
        t1 = (pp[1-posneg].x - r.origin.x) * r.invDirection.x;
        if(t0>tmin) tmin = t0;
        if(t1<tmax) tmax = t1;
        if(tmin > tmax) return false;

        posneg = r.direction.y < 0;
        t0 = (pp[posneg].y - r.origin.y) * r.invDirection.y;
        t1 = (pp[1-posneg].y - r.origin.y) * r.invDirection.y;
        if(t0>tmin) tmin = t0;
        if(t1<tmax) tmax = t1;
        if(tmin > tmax) return false;

        posneg = r.direction.z < 0;
        t0 = (pp[posneg].z - r.origin.z) * r.invDirection.z;
        t1 = (pp[1-posneg].z - r.origin.z) * r.invDirection.z;
        if(t0>tmin) tmin = t0;
        if(t1<tmax) tmax = t1;
        if(tmin > tmax) return false;

        i.near = tmin;
        i.far  = tmax;
        return true;
	}
}
