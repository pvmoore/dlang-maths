module test.test_geom;

import std.stdio : writefln;

import maths;

void testGeom() {

}

private:

align(16)
struct tri_intersect_data { static assert (tri_intersect_data.sizeof == 16*6);
align(16):
    float3 rayorig;// in - ray origin
    float3 raydir; // in - rayn direction
    float3 p0;     // in
    float3 p1;     // in
    float3 p2;     // in
align(4):
    float _padding;

    float t;       // out if hit
    float u;       // out if hit
    float v;       // out if hit
    float _unused;
}
extern(C) bool tri_intersect(tri_intersect_data*);


/+
align(4):
float f1,f2,f3,f4;
void testIntersector() {
	writefln("testing Intersector");

	auto ray = Ray(float3(1, 0.5, 0.5), float3(0.5, 1, -1).normalised());
	auto a = new Intersector(float3(0,  0,  0),
							 float3(10, 0,  0),
							 float3(0,  10, 0));

	//auto r = a.intersect(ray, float.max, 0.01);

	//auto r2 = a.intersect2(&ray, float.max, 0.01);

	//auto r3 = a.intersect3(&ray, float.max, 0.01);


	bench();
}
final class Intersector {
	enum E   = 0.00001f;
	enum YZX = 0b00_00_10_01;
    enum ZXY = 0b00_01_00_10;
align(16):
	float3 p0, p1, p2;
	float4 temp;
	tri_intersect_data data;
align(4):
	float t, u, v;
	float EPSILON     = E;
	float NEG_EPSILON = -E;
	float ONE		  = 1f;

	this(float3 p0, float3 p1, float3 p2) {
		this.p0 = p0; this.p1 = p1; this.p2 = p2;
		this.temp = float4(9,8,7,6);

		auto p = cast(float*)&data;
		p[0..tri_intersect_data.sizeof/4] = 0.0f;
	}
	bool intersect(ref Ray r, float tbest, float tmin) {

		// writefln("rayorigin = %s", r.origin);
		// writefln("raydir = %s", r.direction);
		// writefln("p0 = %s", p0);
		// writefln("p1 = %s", p1);
		// writefln("p2 = %s\n", p2);
		auto edge1 = p1 - p0;
		auto edge2 = p2 - p0;
		//writefln("edge1 = %s", edge1);
		//writefln("edge2 = %s", edge2);
		auto h     = r.direction.cross(edge2);
		//writefln("h = %s", h);
		auto a     = edge1.dot(h);
		//writefln("a = %s", a);
		if(a >= -E && a <= E) return false;

		auto f = 1f / a;
		//writefln("f = %s", f);
		auto s = r.origin - p0;
		//writefln("s = %s", s);
		auto u = f * s.dot(h);
		//writefln("u = %s", u);
		if(u <= 0 || u >= 1) return false;

		auto q = s.cross(edge1);
		auto v = f * r.direction.dot(q);
		//writefln("q = %s", q);
		//writefln("v = %s", v);
		if(v<=0 || u+v >= 1) return false;

		auto t = f * edge2.dot(q);
		//writefln("old: t = %f u = %f, v = %f", t, u, v);

		if(t >= tmin && t < tbest) {
			this.t = t;
			this.u = u;
			this.v = v;
			return true;
		}

		return false;
	}
	bool intersect2(Ray* r, float tbest, float tmin) {

		data.rayorig = r.origin;
		data.raydir = r.direction;
		data.p0 = p0;
		data.p1 = p1;
		data.p2 = p2;

		bool result = tri_intersect(&data);
		//writefln("result = %s", result);
		//writefln("new: t = %f u = %f, v = %f", data.t, data.u, data.v);

		if(result && data.t >= tmin && data.t < tbest) {
			t = data.t;
			u = data.u;
			v = data.v;
			return true;
		}

		return false;
	}
}
+/
