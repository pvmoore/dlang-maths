module maths.geom.aabb;

import maths.all;
/**
 *  Axis-aligned bounding box.
 */
struct AABB {
public:
	float3[2] pp;

	string toString() {
		return "AABB(%s -> %s)".format(pp[0], pp[1]);
	}
	static struct Intersection { float near; float far; }
nothrow:
    float3 min() { return pp[0]; }
	float3 max() { return pp[1]; }
	float3 middle() {
	    return pp[0]+(pp[1]-pp[0])*0.5;
    }
    float3 size() { 
        return pp[1] - pp[0]; 
    }

	this(float3 a, float3 b) {
		set(a,b);
	}
	this(float3 a, float3 b, float3 c) {
        set(a,b);
        enclose(c);
    }
    void set(float3 a, float3 b) {
        pp[0] = a;
        pp[1] = a;
        enclose(b);
    }
	auto enclose(float3 v) {
        pp[0].x = .min(pp[0].x, v.x);
        pp[0].y = .min(pp[0].y, v.y);
        pp[0].z = .min(pp[0].z, v.z);
        pp[1].x = .max(pp[1].x, v.x);
        pp[1].y = .max(pp[1].y, v.y);
        pp[1].z = .max(pp[1].z, v.z);
        return this;
	}
    auto enclose(AABB b) {
	    enclose(b.min);
	    enclose(b.max);
	    return this;
	}
	auto enclose(ref AABB b) {
	    enclose(b.min);
	    enclose(b.max);
	    return this;
	}
    uint longestAxis() {
        auto x = pp[1].x - pp[0].x;
        auto y = pp[1].y - pp[0].y;
        auto z = pp[1].z - pp[0].z;
        return (x>y && x>z) ? 0 : y>z ? 1 : 2;
    }
    /*
     *  @param
     *  @return true if ray intersects this box.
     */
    bool intersect(const ref Ray r,
                   const float tmin,
                   const float tmax)
    {
        Intersection i;
        return inner(r, tmin, tmax, i);
    }
    /*
     *  @param tnear is the entry point if the ray enters the box
     *  @return true if ray intersects this box.
     */
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
        float t0;
        float t1;

        t0 = (pp[  r.posneg.x].x - r.origin.x) * r.invDirection.x;
        t1 = (pp[1-r.posneg.x].x - r.origin.x) * r.invDirection.x;
        if(t0>tmin) tmin = t0;
        if(t1<tmax) tmax = t1;
        if(tmin > tmax) return false;

        t0 = (pp[  r.posneg.y].y - r.origin.y) * r.invDirection.y;
        t1 = (pp[1-r.posneg.y].y - r.origin.y) * r.invDirection.y;
        if(t0>tmin) tmin = t0;
        if(t1<tmax) tmax = t1;
        if(tmin > tmax) return false;

        t0 = (pp[  r.posneg.z].z - r.origin.z) * r.invDirection.z;
        t1 = (pp[1-r.posneg.z].z - r.origin.z) * r.invDirection.z;
        if(t0>tmin) tmin = t0;
        if(t1<tmax) tmax = t1;
        if(tmin > tmax) return false;

        i.near = tmin;
        i.far  = tmax;
        return true;
	}
}
