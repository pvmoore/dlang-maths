module test.bench;

import std.stdio 				: writefln;
import std.datetime.stopwatch	: StopWatch;

import maths;

void main() {
    writefln("Benchmarking ...");
    
	benchAABB();
}

private:


void benchAABB() {
    AABB box = AABB(
        Vector3(0,0,0),
        Vector3(10,10,10)
    );
    Ray r = Ray(
        Vector3(2,2,100),
        (box.middle-Vector3(2,2,100)).normalised()
    );
    writefln("%s %s", box, r);
    float t, t2;
    bool f;
    StopWatch watch;
    ulong totalTime;
    uint iterations = 10;
    for(auto j=0; j<iterations; j++) {
    watch.reset();
    watch.start();
    for(auto i=0; i<100_000_000; i++) {
        f = box.intersect(r, t, t2, 0.01, float.max);
    }
    watch.stop();
    totalTime += watch.peek().total!"nsecs";
    }
    writefln("intersect = %s t=%s", f, t);
    writefln("Elapsed time: %s millis", (totalTime/iterations)/1_000_000.0);
    // 745.252 -> 756 millis
}
/*void bench() {
	import std.random : uniform;
	const shift = 1L<<(64-9);
	auto dir = Vector3(uniform(-100.0, 100.0),
			  		   uniform(-100.0, 100.0),
					   uniform(-100.0, 100.0)).normalised();
	long dirX = cast(long)((cast(double)dir.x)*shift);
	long dirY = cast(long)((cast(double)dir.y)*shift);
	long dirZ = cast(long)((cast(double)dir.z)*shift);
	writefln("dir=%s", dir);
	//writefln("int dir=%s,%s,%s",dirX,dirY,dirZ);

	auto v = Vector3(0,0,0);	// 560 - 570
	long x,y,z;					//

	StopWatch watch;
	watch.start();
	{
		for(auto i=0;i<1_000_000;i++) {
			v = Vector3(0);
			x = y = z = 0;
			for(auto j=0;j<256;j++) {
				v += dir;

				x += dirX;
				y += dirY;
				z += dirZ;
			}
		}
	}
	double toFloat(long u) {
		if(u<0) return -(cast(double)-u)/shift;
		return cast(double)u/shift;
	}
	watch.stop();
	writefln("float result=%s", v);
	writefln("int   result=%s, %s, %s", toFloat(x), toFloat(y), toFloat(z));
	writefln("%s millis",watch.peek().nsecs/1_000_000.0);
}

void bench() {
	import std: approxEqual, isNaN;
	writefln("Bench");
	enum N = 100_000;//1_000_000;

	float3[] p0 = new float3[N];
	float3[] p1 = new float3[N];
	float3[] p2 = new float3[N];

	Ray[] rays = new Ray[N];

	auto fl = ()=> float3(uniform(-10f, 10f), uniform(-10f, 10f), uniform(-10f, 10f));

	auto check(float a, float b) {
		if(isNaN(a) && isNaN(b)) return true;
		if(isNaN(a) || isNaN(b)) return false;
		return approxEqual(a, b);
	}

	foreach(i; 0..N) {
		rays[i] = Ray(fl(), fl().normalised());
		p0[i] = fl();
		p1[i] = fl();
		p2[i] = fl();
	}

	auto a = new Intersector(float3(0,  0,  0),
							 float3(10, 0,  0),
							 float3(0,  10, 0));

	bool r1, r2;
	float t,u,v;

	writefln("Starting benchmark...");
	StopWatch w; w.start();

	foreach(i; 0..N) {
		a.p0 = p0[i];
		a.p1 = p1[i];
		a.p2 = p2[i];

		static if(false) {
			r1 = a.intersect(rays[i], float.max, 0.01);
			t = a.t;
			u = a.u;
			v = a.v;
		} else {
			r2 = a.intersect2(&rays[i], float.max, 0.01);
		}

		static if(false) {
			if(!check(t, a.t)) {
				throw new Error("Incorrect t = %f, %s".format(t, a.t));
			}
			if(!check(u, a.u)) {
				throw new Error("Incorrect u = %f, %s".format(u, a.u));
			}
			if(!check(v, a.v)) {
				throw new Error("Incorrect v = %f, %s".format(v, a.v));
			}
		}
	}
	w.stop();

	writefln("r1=%s, r2 = %s", r1, r2);

	int j = uniform(0,N);

	//writefln("[%s] = %s", j, array1r[j]);

	// writefln("g1 = %s", g1);
	// writefln("g2 = %s", g2);

	writefln("%03f ms", w.peek().total!"nsecs"/1000000.0);
}
*/

