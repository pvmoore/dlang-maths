
import std.stdio				: writefln;
import std.math					: approxEqual;
import std.datetime.stopwatch	: StopWatch;
import std.random       		: uniform;
import maths.all;

void main() {

    {
        vec2 windowSize = vec2(1000, 600);
        float width  = windowSize.width  * 1;
        float height = windowSize.height * 1;
        //if(mode == Mode.VULKAN)
        //    proj = vkOrtho(
        //        -width/2,   width/2,
        //        -height/2,  height/2,
        //        0f,        100f
        //    );
        //else
        auto proj = Matrix4.ortho(
                -width/2,   width/2,
                height/2,  -height/2,
                0f,        100f
            );

        vec2 _position = vec2(500, 300);
        vec2 up = vec2(0,1);
        auto view = Matrix4.lookAt(
				Vector3(_position, 1), // camera _position in World Space
				Vector3(_position, 0), // look at the _position
				Vector3(up,0)	   // head is up
			);

        auto w1 = Matrix4.translate(vec3(10,10,0));
        auto w2 = Matrix4.scale(vec3(300,300,0));

        auto w = w1*w2;

        writefln("proj=\n%s", proj);
        writefln("view=\n%s", view);
        writefln("w=\n%s", w);
        writefln("vp=\n%s", proj*view);

        writefln("wvp=\n%s", proj*view*w);
    }

    //float ff = 0;
    //if(ff<1) return;

	//bench();
	//benchAABB();


    {
        auto cam = Camera2D.forVulkan(Dimension(1000,600));
        auto v = Vector4(0,0,0,1);
        auto r = v*cam.VP;

        writefln("cam=%s", cam);
        writefln("v=\n%s", cam.V);
        writefln("p=\n%s", cam.P);
        writefln("vp=\n%s", cam.VP);
        writefln("result=%s", r);

        //float f = 0.1;
        //if(f<1) return;

        // 1.00 -0.00  0.00 -500.00
        // 0.00  1.00  0.00 -300.00
        //-0.00 -0.00  1.00 -1.00
        // 0.00  0.00  0.00  1.00

        // result=[499.998, -299.997, 1.000, 1.000]

        //auto a = vec2(0,40);
        //auto b = vec2(150,130);
        //auto c = vec2(50,0);
        //auto d = vec2(60,190);
        //writefln("intersect=%s", lineIntersection(a,b,c,d));
        //
        //float aa = 1;
        //if(aa==1) return;
    }

	testVector2();
	testVector3();
	testVector4();
	testMatrix4();
	testMatrix();
	testTranspose();
	testDeterminant();
	testMultiplyByMatrix();
	testInverse();
	testProject();
	testTrigonomety();
    testHalfFloat();

	testNoise();
	testRandom();
	testRandomBuffer();
	testRandomNoise3D();

	testUtil();
}
void testNoise() {
	PerlinNoise2D noise = new PerlinNoise2D(10,10).generate();
    StopWatch w;
    w.start();
    for(auto i=0; i<1; i++) {
        // test here
		writefln("noise=%s", noise.get());
    }
    w.stop();
    writefln("Noise took %s millis", w.peek().total!"nsecs"/1000000.0);
}
void testRandom() {
	writefln("Testing random ...");
    auto r = new FastRNG();
    StopWatch w;
    w.start();
    double total = 0;
    ulong iterations = 10000;
    float[11] buckets = 0;
    for(auto i=0; i<iterations; i++) {
        float value = r.next();
        total += value;
        buckets[cast(int)(value*10)]++;
    }
    w.stop();
    writefln("average = %s", total/iterations);
    writefln("buckets=%s", buckets);
    writefln("Elapsed %s millis", w.peek().total!"nsecs"/1000000.0);
}
void testRandomBuffer() {
	writefln("Testing RandomBuffer ...");

	auto rb = new RandomBuffer(1024);
	for(auto i=0; i<1024; i++) {
		auto value = rb.next();
		assert(value>=0.0f);
		assert(value<1.0f);
	}

	writefln("OK");
}
void testRandomNoise3D() {
	writefln("Testing RandomNoise3D ...");

	uint[20] distribution;

	auto noise = new RandomNoise3D(1024);
	for(auto i=0; i<1024; i++) {
		auto x = uniform(-10f, 10f);
		auto y = uniform(-1f, 1f);
		auto z = uniform(-3f, 1f);

		auto v = noise.get(x,y,z);

		distribution[cast(uint)(v*20)]++;

		writefln("v=%s", v);
	}

	writefln("Distribution = %s", distribution);

	writefln("OK");
}
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
}*/

void testVector2() {
	auto v1 = Vector2(1,2);
	auto v2 = Vector2(2,1);
	writefln("Vector2(1,2) hash=%16x", v1.toHash);
	writefln("Vector2(2,1) hash=%16x", v2.toHash);
	assert(v1.toHash == Vector2(1,2).toHash);
	assert(v2.toHash == Vector2(2,1).toHash);
	assert(v1.toHash != v2.toHash);

	// magnitude
	assert(approxEqual(Vector2(10,10).magnitude, 14.1421));

	// magnitudeSquared
	assert(Vector2(10,10).magnitudeSquared == 200);

	// normalised
	assert(Vector2(10,10).normalised == Vector2(0.707107, 0.707107));

	// angleTo
	//     v3
	//      |
	// v6---|--- v4
	//      |
	//     v5
	auto v3 = Vector2(0,1);
	auto v4 = Vector2(1,0);
	auto v5 = Vector2(0,-1);
	auto v6 = Vector2(-1,0);
	assert(v3.angleTo(v3).degrees==0);
	assert(v3.angleTo(v4).degrees==90);
	assert(v3.angleTo(v5).degrees==180);
	assert(v3.angleTo(v6).degrees==90);

	// distanceFromLine
	assert(approxEqual(2.12132, Vector2(10,13).distanceFromLine(Vector2(10,10), Vector2(15,15))));

	// isLeftOfLine
	assert(true == Vector2(10,11).isLeftOfLine(Vector2(10,10), Vector2(15,15)));
	assert(false == Vector2(10,9).isLeftOfLine(Vector2(10,10), Vector2(15,15)));

	// rotated
	auto v7 = Vector2(0,1);
	assert(v7.rotated(0.degrees)==Vector2(0,1));
	assert(v7.rotated(360.degrees)==Vector2(0,1));
	assert(v7.rotated(45.degrees)==Vector2(-0.7071, 0.7071));
	assert(v7.rotated(90.degrees)==Vector2(-1, 0));
	assert(v7.rotated(180.degrees)==Vector2(0, -1));
	assert(v7.rotated(270.degrees)==Vector2(1, 0));

	// toRadians
	assert(Vector2(0,1).rotated(0.degrees).angle.degrees == 0);
	assert(Vector2(0,1).rotated(90.degrees).angle.degrees == 90);
	assert(approxEqual(Vector2(0,1).rotated(180.degrees).angle.degrees, -180));	// equivalent to 180
	assert(Vector2(0,1).rotated(270.degrees).angle.degrees == -90);

	// left
	assert(Vector2(0,1).left == Vector2(-1,0));
	writefln("%s", Vector2(0.7071, 0.7071).left);
	assert(Vector2(0.7071, 0.7071).left == Vector2(-0.7071, 0.7071));
	assert(Vector2(-1,0).left == Vector2(0,-1));

	// to
	auto v8         = Vec2!float(1,2);
	Vec2!float v8f  = v8.to!float;
	Vec2!double v8d = v8.to!double;
	Vec2!int v8i    = v8.to!int;
	Vec2!uint v8u   = v8.to!uint;
	assert(v8f==[1,2]);
	assert(v8d==[1,2]);
	assert(v8i==[1,2]);
	assert(v8u==[1,2]);

	// anyLT
	auto v9 = Vector2(0,3);
	assert(v9.anyLT(0)==false);
	assert(v9.anyLT(0.1)==true);
	assert(v9.anyLT(Vector2(0,3))==false);
	assert(v9.anyLT(Vector2(0.1,3))==true);
	assert(v9.anyLT(Vector2(0,3.1))==true);
	// anyLTE
    auto v10 = Vector2(0,3);
    assert(v10.anyLTE(-0.1)==false);
    assert(v10.anyLTE(0)==true);
    assert(v10.anyLTE(Vector2(-0.1, 2.9))==false);
    assert(v10.anyLTE(Vector2(0,3))==true);
    assert(v10.anyLTE(Vector2(-1, 3))==true);

	// anyGT
	auto v11 = Vector2(0,3);
    assert(v11.anyGT(3)==false);
    assert(v11.anyGT(2.9)==true);
    assert(v11.anyGT(Vector2(0,3))==false);
    assert(v11.anyGT(Vector2(-0.1,3))==true);
    assert(v11.anyGT(Vector2(0,2.9))==true);
    // anyGTE
    auto v12 = Vector2(0,3);
    assert(v12.anyGTE(3.1)==false);
    assert(v12.anyGTE(3)==true);
    assert(v12.anyGTE(Vector2(0.1, 3.1))==false);
    assert(v12.anyGTE(Vector2(0, 3.1))==true);
    assert(v12.anyGTE(Vector2(0.1, 3))==true);

    // hadd
    auto v13 = Vector2(1,2);
    assert(v13.hadd()==3);

    // hmul
    auto v14 = Vector2(2,3);
    assert(v14.hmul()==6);

    // opBinary
    auto v15 = Vec2!uint(1,2);
    assert(v15 << 1 == [2,4]);
}
void testVector3() {
    writefln("Test Vec3");
    {
        auto v1 = Vector3(1,2,3);
        auto v2 = Vector3(3,2,1);
        auto v3 = Vector3(3.1,2.1,1.1);
        auto v4 = Vector3(1.1,2.1,3.1);
        uint* p = cast(uint*)v1.ptr;
        writefln("%8x_%8x_%8x", p[0], p[1], p[2]);
        writefln("Vector3(1,2,3) hash=%16x", v1.toHash);
        writefln("Vector3(3,2,1) hash=%16x", v2.toHash);
        writefln("Vector3(3.1,2.1,1.1) hash=%16x", v3.toHash);
        writefln("Vector3(1.1,2.1,3.1) hash=%16x", v4.toHash);
        assert(v1.toHash == Vector3(1,2,3).toHash);
        assert(v2.toHash == Vector3(3,2,1).toHash);
        assert(v1.toHash != v2.toHash);
	}

	{   // right
		auto dir = Vector3(0,0,-1);
		auto up  = Vector3(0,1,0);
		writefln("right=\n%s", dir.right(up));
		assert(dir.right(up)==[1,0,0]);
		// left
		assert(dir.left(up)==[-1,0,0]);
	}


	{   // to
        auto v8         = Vec3!float(1,2,3);
        Vec3!float v8f  = v8.to!float;
        Vec3!double v8d = v8.to!double;
        Vec3!int v8i    = v8.to!int;
        Vec3!uint v8u   = v8.to!uint;
        assert(v8f==[1,2,3]);
        assert(v8d==[1,2,3]);
        assert(v8i==[1,2,3]);
        assert(v8u==[1,2,3]);
    }
    {   // opBinary
        auto v9 = Vec3!uint(1,2,3);
        assert(v9 << 1 == [2,4,6]);
    }
    //const Vec3!int aa  = const Vec3!int(1,2,3);
    //const Vec3!uint bb = const Vec3!uint(1,2,3);
    //writefln("==%s", typeof(bb).stringof);
    //auto cc = aa+bb.to!int;

    {   // distanceFromPlane
        // origin is (0,0,0)
        auto v  = vec3(0,20,0);
        auto v1 = vec3(10,0,0);
        auto v2 = vec3(0,0,10);
        float d = v.distanceFromPlane(v1,v2);
        assert(d==20);
    }

    {   // &
        auto v =  int3(0b000, 0b010, 0b100);
        v &=      int3(0b111, 0b111, 0b111);
        assert(v==int3(0b000, 0b010, 0b100));

        assert((int3(0b000, 0b010, 0b100) & int3(0b111, 0b111, 0b111)) == int3(0b000, 0b010, 0b100));
    }
    {   // |
        auto v =  int3(0b000, 0b010, 0b100);
        v |=      int3(0b101, 0b101, 0b101);
        assert(v==int3(0b101, 0b111, 0b101));

        assert((int3(0b000, 0b010, 0b100) | int3(0b101, 0b101, 0b101)) == int3(0b101, 0b111, 0b101));
    }
    {   // ^
        auto v =  int3(0b000, 0b010, 0b100);
        v ^=      int3(0b111, 0b111, 0b111);
        assert(v==int3(0b111, 0b101, 0b011));

        assert((int3(0b000, 0b010, 0b100) ^ int3(0b111, 0b111, 0b111)) == int3(0b111, 0b101, 0b011));
    }
}
void testVector4() {
    writefln("Test Vec4");
	// new Vector4
	Vector4 v1 = Vector4();
	writefln("new Vector4 = %s", v1);

	Vector4 v2 = Vector4(1);
	writefln("new Vector4(1) = %s", v2);

	Vector4 v3 = Vector4(1,2,3,4);
	writefln("new Vector4(1,2,3,4) = %s", v3);

	// []
	Vector4 v4 = Vector4(1,2,3,4);
	writefln("v4[0] = %s", v4[0]);
	assert(v4[0]==1 && v4[1]==2 && v4[2]==3 && v4[3]==4);
	v4[0] = 7;
	assert(v4[0] == 7);

	// ==
	assert(Vector4(1,2,3,4) == Vector4(1,2,3,4));
	assert(Vector4(1) != Vector4(2));
	assert(Vector4(1,2,3,4) == [1f,2,3,4]);
	assert(Vector4(1,2,3,4) != [1f,0,3,4]);

	// -
	Vector4 v5 = Vector4(1,2,3,4);
	assert(-v5 == [-1,-2,-3,-4]);
	writefln("-v5 = %s", -v5);

	// * scalar
	Vector4 v6 = Vector4(1,2,3,4);
	assert(v6 * 2 == [2,4,6,8]);
	writefln("* = %s", v6*2);

	// / scalar
	Vector4 v7 = Vector4(1,2,3,4);
	assert(v7 / 2 == [0.5, 1, 1.5, 2]);
	writefln("/ = %s", v7/2);

	// + scalar
	Vector4 v8 = Vector4(1,2,3,4);
	assert(v8+1 == [2,3,4,5]);
	writefln("+ = %s", v8+1);

	// - scalar
	Vector4 v9 = Vector4(1,2,3,4);
	assert(v9-1 == [0,1,2,3]);
	writefln("- = %s", v9-1);

	// + Vector4
	Vector4 v10 = Vector4(1,2,3,4);
	assert(v10+Vector4(1) == [2,3,4,5]);
	writefln("+ = %s", v10+Vector4(1));

	// - Vector4
	Vector4 v11 = Vector4(1,2,3,4);
	assert(v11-Vector4(1) == [0,1,2,3]);
	writefln("- = %s", v11-Vector4(1));

	// * Vector4
	Vector4 v12 = Vector4(1,2,3,4);
	assert(v12*Vector4(2) == [2,4,6,8]);
	writefln("* = %s", v12*Vector4(2));

	// / Vector4
	Vector4 v13 = Vector4(1,2,3,4);
	assert(v13/Vector4(2) == [0.5,1,1.5,2]);
	writefln("/ = %s", v13/Vector4(2));

	// += scalar
	Vector4 v14 = Vector4(1,2,3,4);
	v14 += Vector4(1);
	assert(v14 == [2,3,4,5]);
	writefln("+= = %s", v14);

	// -= scalar
	Vector4 v15 = Vector4(1,2,3,4);
	v15 -= 1;
	assert(v15 == [0,1,2,3]);
	writefln("-= = %s", v15);

	// *= scalar
	Vector4 v16 = Vector4(1,2,3,4);
	v16 *= 2;
	assert(v16 == [2,4,6,8]);
	writefln("*= = %s", v16);

	// /= scalar
	Vector4 v17 = Vector4(1,2,3,4);
	v17 /= Vector4(2,4,6,8);
	assert(v17 == [0.5,0.5,0.5,0.5]);
	writefln("/= = %s", v17);

	// += Vector4
	Vector4 v18 = Vector4(1,2,3,4);
	v18 += Vector4(1,2,3,4);
	assert(v18 == [2,4,6,8]);
	writefln("+= = %s", v18);

	// -= Vector4
	Vector4 v19 = Vector4(1,2,3,4);
	v19 -= Vector4(1,2,3,4);
	assert(v19 == [0,0,0,0]);
	writefln("-= = %s", v19);

	// *= Vector4
	Vector4 v20 = Vector4(1,2,3,4);
	v20 *= Vector4(2,3,4,5);
	assert(v20 == [2,6,12,20]);
	writefln("*= = %s", v20);

	// /= Vector4
	Vector4 v21 = Vector4(1,2,3,4);
	v21 /= Vector4(2,4,6,8);
	assert(v21 == [0.5,0.5,0.5,0.5]);
	writefln("/= = %s", v21);

	// dot
	Vector4 v22 = Vector4(1,2,3,4);
	assert(v22.dot(Vector4(2,3,4,5)) == 2 + 6 + 12 + 20);

	// magnitude
	Vector4 v23 = Vector4(1,2,3,4);
	assert(v23.magnitude >= 5.47722 && v23.magnitude <= 5.47723);

	// inverse magnitude
	Vector4 v24 = Vector4(1,2,3,4);
	assert(v23.invMagnitude >= 0.18257 && v23.invMagnitude <= 0.18258);

	// normalise
	Vector4 v25 = Vector4(1,2,3,4);
	Vector4 v26 = v25.normalised();
	assert(v25 == [1,2,3,4]);
	//assert(v26 == [0.182574, 0.365148, 0.547723, 0.730297]);

	// Vector4 * Matrix4
	auto m0 = Matrix4.rowMajor(
		1,2,3,4,
		5,6,7,8,
		9,10,11,12,
		13,14,15,16);
	auto v27 = Vector4(1,2,3,4);
	auto r27 = v27 * m0;
	writefln("Vector4 * Matrix4 = %s", r27);
	assert(r27 == Vector4(90.0, 100.0, 110.0, 120.0));

	// to
    auto v28        = Vec4!float(1,2,3,4);
    Vec4!float v8f  = v28.to!float;
    Vec4!double v8d = v28.to!double;
    Vec4!int v8i    = v28.to!int;
    Vec4!uint v8u   = v28.to!uint;
    assert(v8f==[1,2,3,4]);
    assert(v8d==[1,2,3,4]);
    assert(v8i==[1,2,3,4]);
    assert(v8u==[1,2,3,4]);

    {   // <<  <<=
        auto v =  int4(1,1,1,1);
        v <<=     int4(1,2,3,4);
        assert(v==int4(0b0010, 0b0100, 0b1000, 0b10000));

        assert((int4(1,1,1,1) << int4(1,2,3,4)) == int4(0b0010, 0b0100, 0b1000, 0b10000));
    }
    {   // >>  >>=
        auto v =  int4(0b10000,0b10000,0b10000,0b10000);
        v >>=     int4(1,2,3,4);
        assert(v==int4(0b1000,0b100,0b10,0b1));

        assert((int4(0b10000,0b10000,0b10000,0b10000) >> int4(1,2,3,4)) == int4(0b1000,0b100,0b10,0b1));
    }
    {   // >>>  >>>=
        auto v =  int4(0b10000,0b10000,0b10000,0b10000);
        v >>>=     int4(1,2,3,4);
        assert(v==int4(0b1000,0b100,0b10,0b1));

        assert((int4(0b10000,0b10000,0b10000,0b10000) >>> int4(1,2,3,4)) == int4(0b1000,0b100,0b10,0b1));
    }
    {   // &  &=
         auto v =  int4(0b1110,0b1110,0b1110,0b1110);
         v &=      int4(0b0001,0b0010,0b0010,0b0100);
         assert(v==int4(0b0000,0b0010,0b0010,0b0100));

         assert((int4(0b1110,0b1110,0b1110,0b1110) &
                 int4(0b0001,0b0010,0b0011,0b0100))
              == int4(0b0000,0b0010,0b0010,0b0100));
    }
    {   // |  |=
        auto v =  int4(0b1000,0b1000,0b1000,0b1000);
        v |=      int4(0b0001,0b0010,0b0011,0b0100);
        assert(v==int4(0b1001,0b1010,0b1011,0b1100));

        assert((int4(0b1000,0b1000,0b1000,0b1000) |
                int4(0b0001,0b0010,0b0011,0b0100))
             == int4(0b1001,0b1010,0b1011,0b1100));
    }
    {   // ^  ^=
        auto v =  int4(0b1010,0b1010,0b1010,0b1010);
        v ^=      int4(0b0001,0b0010,0b0011,0b0100);
        assert(v==int4(0b1011,0b1000,0b1001,0b1110));

        assert((int4(0b1010,0b1010,0b1010,0b1010) ^
                int4(0b0001,0b0010,0b0011,0b0100))
             == int4(0b1011,0b1000,0b1001,0b1110));
    }
	{   // allLT
		auto v = int4(1,2,3,4);
        assert(v.allLT(5));
        assert(!v.allLT(4));

        assert(v.allLT(int4(2,3,4,5)));
        assert(!v.allLT(int4(1,2,3,4)));
	}
    {   // allLTE
        auto v = int4(1,2,3,4);
        assert(v.allLTE(5));
        assert(v.allLTE(4));
        assert(!v.allLTE(3));

        assert(v.allLTE(int4(2,3,4,5)));
        assert(v.allLTE(int4(1,2,3,4)));
        assert(!v.allLTE(int4(0,1,2,3)));
    }
    {   // allGT
        auto v = int4(1,2,3,4);
        assert(v.allGT(0));
        assert(!v.allGT(1));

        assert(v.allGT(int4(0,1,2,3)));
        assert(!v.allGT(int4(1,2,3,4)));
    }
    {   // allGTE
        auto v = int4(1,2,3,4);
        assert(v.allGTE(0));
        assert(v.allGTE(1));
        assert(!v.allGTE(2));

        assert(v.allGTE(int4(0,1,2,3)));
        assert(v.allGTE(int4(1,2,3,4)));
        assert(!v.allGTE(int4(2,3,4,5)));
    }
}

void testMatrix4() {
	// new Matrix4
	auto m1 = Matrix4(0);
	writefln("new Matrix4(0)=\n%s", m1);

	auto ma = Matrix4(1);
	writefln("new Matrix4(1)=\n%s", ma);

	// identity
	auto i = Matrix4.identity();
	writefln("identity=\n%s", i);

	// []
	auto m2 = Matrix4(0);
	m2[0] = Vector4(1,2,3,4);
	m2[1] = Vector4(5,6,7,8);
	m2[2] = Vector4(9,10,11,12);
	m2[3] = Vector4(13,14,15,16);
	writefln("m2[0] = %s", m2[0]);
	writefln("m2[1] = %s", m2[1]);
	writefln("m2[2] = %s", m2[2]);
	writefln("m2[3] = %s\n", m2[3]);
	m2[0][0] = 7;
	writefln("m[0][0] = %s", m2[0][0]);
	assert(m2[0][0] == 7);

	// + scalar
	auto m3 = Matrix4.identity() + 1;
	writefln("identity + 1 =\n%s", m3);

	// - scalar
	auto m4 = Matrix4.identity() - 1;
	writefln("identity - 1 =\n%s", m4);

	// * scalar
	auto m5 = Matrix4.identity() * 2;
	writefln("identity * 2 =\n%s", m5);

	// / scalar
	auto m6 = Matrix4.identity() / 2;
	writefln("identity / 2 =\n%s", m6);

	{	// + Matrix4
		auto opadd1 = Matrix4.rowMajor(
			1,2,3,4,
			5,6,7,8,
			9,10,11,12,
			13,14,15,16);
		auto opadd2 = Matrix4.rowMajor(
			10,20,30,40,
			50,60,70,80,
			90,100,110,120,
			130,140,150,160);
		assert(opadd1 + opadd2 == Matrix4.rowMajor(
			11,22,33,44,
			55,66,77,88,
			99,110,121,132,
			143,154,165,176));
	}

	{ // - Matrix4
		auto opsub1 = Matrix4.rowMajor(
			10,20,30,40,
			50,60,70,80,
			90,100,110,120,
			130,140,150,160);
		auto opsub2 = Matrix4.rowMajor(
			1,2,3,4,
			5,6,7,8,
			9,10,11,12,
			13,14,15,16);
		assert(opsub1 - opsub2 == Matrix4.rowMajor(
			9,18,27,36,
			45,54,63,72,
			81,90,99,108,
			117,126,135,144));
	}

	// * Matrix4
	auto m9a = Matrix4.identity();
	auto m9b = Matrix4.identity();
	auto m9 = m9a * m9b;
	writefln("identity + identity =\n%s", m9);
	writefln("m9a =\n%s", m9a);
	writefln("m9b =\n%s", m9b);

	auto projection = Matrix4.rowMajor(
		1.344443, 0.000000, 0.000000, 0.000000,
		0.000000, 1.792591, 0.000000, 0.000000,
		0.000000, 0.000000, -1.002002, -0.200200,
		0.000000, 0.000000, -1.000000, 0.000000);
	auto view = Matrix4.rowMajor(
		0.600000, 0.000000, -0.800000, -0.000000,
		-0.411597, 0.857493, -0.308697, -0.000000,
		0.685994, 0.514496, 0.514496, -5.830953,
		0.000000, 0.000000, 0.000000, 1.000000);
	auto model = Matrix4.identity();

	assert(projection*view*model == Matrix4.rowMajor(
		0.806666, 0.000000, -1.075554, 0.000000,
		-0.737824, 1.537134, -0.553368, 0.000000,
		-0.687368, -0.515526, -0.515526, 5.642426,
		-0.685994, -0.514496, -0.514496, 5.830953));
	writefln("Projection * View * Model =\n%s", projection*view*model);

	// Matrix4 * Vector4
	auto m10a = Matrix4.rowMajor(
		1,2,3,4,
		5,6,7,8,
		9,10,11,12,
		13,14,15,16);
	auto v1 = Vector4(1,2,3,4);
	auto v2 = m10a * v1;
	writefln("Matrix4 * Vector4 = \n%s", v2);
	assert(v2 == Vector4(30.0, 70.0, 110.0, 150.0));

	// / Matrix4

	// lookAt
	auto lookAt = Matrix4.lookAt(Vector3(4,3,3), Vector3(0,0,0), Vector3(0,1,0));
    writefln("lookAt=\n%s", lookAt);
	assert(lookAt == Matrix4.rowMajor(
		0.6,	   0,		-0.8,	   -0,
	   -0.411597, 0.857493, -0.308697, -0,
		0.685994,  0.514496, 0.514496, -5.83095,
		0,		   0,		 0,			1
	));


	// ortho
	auto ortho = Matrix4.ortho(-10.0f, 10.0f, -10.0f, 10.0f, 0.0f, 100.0f);
    writefln("ortho=\n%s", ortho);
	assert(ortho == Matrix4.rowMajor(
		0.1, 0,   0,    -0,
		0,   0.1, 0,    -0,
		0,   0,  -0.02, -1,
		0,   0,   0,     1
	));


	// perspective
	auto perspective = Matrix4.perspective(45.0f.degrees, 4.0f / 3.0f, 0.1f, 100.0f);
    writefln("perspective=\n%s", perspective);
	//assert(perspective == Matrix4.rowMajor(
	//    1.81,  0.00,  0.00,  0.00,
    //    0.00,  2.41,  0.00,  0.00,
    //    0.00,  0.00, -1.00, -0.20,
    //    0.00,  0.00, -1.00,  0.00
    //));

	// scale
	auto scale1 = Matrix4.scale(Vector3(10,10,10));
	auto scale2 = Matrix4.rowMajor(
		0.806666, 0.000000, -1.075554, 0.000000,
		-0.737824, 1.537134, -0.553368, 0.000000,
		-0.687368, -0.515526, -0.515526, 5.642426,
		-0.685994, -0.514496, -0.514496, 5.830953
	) * scale1;
	writefln("scale1=\n%s", scale1);
	writefln("scale2=\n%s", scale2);
	assert(scale1 == Matrix4.rowMajor(
		10, 0,  0,  0,
		0,  10, 0,  0,
		0,  0,  10, 0,
		0,  0,  0,  1
	));
	assert(scale2 == Matrix4.rowMajor(
		8.066659, 0.000000, -10.755545, 0.000000,
		-7.378243, 15.371341, -5.533683, 0.000000,
		-6.873677, -5.155258, -5.155258, 5.642426,
		-6.859944, -5.144958, -5.144958, 5.830953
	));

	// translate
	auto trans1 = Matrix4.translate(Vector3(10,10,10));
	writefln("trans1=\n%s", trans1);
	assert(trans1 == Matrix4.rowMajor(
		1, 0, 0, 10,
		0, 1, 0, 10,
		0, 0, 1, 10,
		0, 0, 0, 1,
	));

	// rotate
	auto rotatex = Matrix4.rotate(Vector3(1,0,0), 45.degrees);
	auto rotatey = Matrix4.rotate(Vector3(0,1,0), 45.degrees);
	auto rotatez = Matrix4.rotate(Vector3(0,0,1), 45.degrees);
	writefln("rotatex=\n%s", rotatex);
	writefln("rotatey=\n%s", rotatey);
	writefln("rotatez=\n%s", rotatez);

	// rotate X Y Z
	assert(Matrix4.rotateX(45.degrees) == Matrix4.rotate(Vector3(1,0,0), 45.degrees));
	assert(Matrix4.rotateY(45.degrees) == Matrix4.rotate(Vector3(0,1,0), 45.degrees));
	assert(Matrix4.rotateZ(45.degrees) == Matrix4.rotate(Vector3(0,0,1), 45.degrees));

	// ptr
	auto mptr = Matrix4.identity();
	assert(cast(void*)&mptr == cast(void*)mptr.ptr);
	writefln("mptr.ptr = %s &mptr %s", cast(void*)&mptr, cast(void*)mptr.ptr);

	{	// determinant
		auto m = Matrix4.rowMajor(
			10,-2,3,4,
			1212,60,7,8,
			9,-10,12,-3,
			-7,-8,5,6);
		writefln("det=%s", cast(long)m.determinant);
		assert(m.determinant == -228594);
	}

	{	// inverse
		auto m = Matrix4.rowMajor(
			10,-2,3,4,
			1212,60,7,8,
			9,-10,12,-3,
			-7,-8,5,6);
		auto inv = m.inversed;
		writefln("inv=\n%s", inv);
		writefln("m*inv=\n%s", m*inv);
		assert(m*inv == Matrix4.identity);
	}

	{	// transposed
		auto m = Matrix4.rowMajor(
			10,-2,3,4,
			1212,60,7,8,
			9,-10,12,-3,
			-7,-8,5,6);
		assert(m.transposed == Matrix4.rowMajor(
			10,1212,9,-7,
			-2,60,-10,-8,
			3,7,12,5,
			4,8,-3,6
		));
		assert(m.transposed.transposed == m);
	}
}
void testMatrix() {
	auto m = new Matrix!float(4, 4);
	writefln("%s", m);

	assert(m.numRows()==4);
	assert(m.numColumns()==4);
	assert(m.totalCells()==16);

	StopWatch watch;
	watch.start();
	m.setValue(1);
	watch.stop();
	writefln("%s", m);
	writefln("took %s nanos", watch.peek().total!"nsecs");

	assert(m[0,0]==1);

	m.setIdentity();
	writefln("%s", m);

	auto m2 = new Matrix!float(4, 4, 1);
	auto m3 = m + 1;
	auto m4 = m2 + m3;
	writefln("%s", m3);
	writefln("%s", m4);
}

void testTranspose() {
	writefln("testing transpose");
	{
		auto m = new Matrix!float(4, 4, [0, 1, 2, 3,
		                                 4, 5, 6, 7,
		                                 8, 9,10,11,
		                                 12,13,14,15
		                                 ]);
		writefln("%s", m.getTransposed());
		assert(m.getTransposed() == [0, 4, 8,12,
		                             1, 5, 9,13,
		                             2, 6,10,14,
		                             3, 7,11,15
		                             ]);
	}
	{
		auto m = new Matrix!float(2, 3, [1, 2, 3,
		                                 4, 5, 6]);
		writefln("%s", m.getTransposed());
		assert(m.getTransposed() == [1, 4,
		                             2, 5,
		                             3, 6]);
	}
}

void testDeterminant() {
	writefln("testing determinant");
	{
		auto m = new Matrix!float(2, 2);
		m.set([3, 2,
		       5, 2]);
		writefln("%s determinant=%s", m, m.getDeterminant());
		assert(approxEqual!(float, float)(m.getDeterminant(), -4f));
	}
	{
		auto m = new Matrix!float(3, 3);
		m.set([4,1,2,
		       3,2,1,
		       9,3,1]);
		writefln("%s determinant=%s", m, m.getDeterminant());
		assert(approxEqual!(float, float)(m.getDeterminant(), -16f));
	}
	{
		auto m = new Matrix!float(4, 4);
		m.set([3, 2, 0, 1,
		       4, 0, 1, 2,
		       3, 0, 2, 1,
		       9, 2, 3, 1]);
		writefln("%s determinant=%s", m, m.getDeterminant());
		assert(approxEqual!(float, float)(m.getDeterminant(), 24f));
	}
}

void testMultiplyByMatrix() {
	writefln("testing multiply by matrix");
	{
		auto m = new Matrix!float(2, 2, [3,2,
		                                 5,2]);
		auto m2 = new Matrix!float(2, 2, [3,2,
		                                  5,2]);
		writefln("%s", m*m2);
		assert(m*m2 == [19,10,
		                25,14]);
	}
	{
		auto m = new Matrix!float(2, 2, [3,2,
		                                 5,2]);
		m *= m;
		writefln("%s", m);
		assert(m == [19,10,
		             25,14]);
	}
}

void testInverse() {
	writefln("testing inverse");
	{
		auto m = new Matrix!float(2, 2, [3,2,
		                                 5,2]);
		writefln("%s det = %s inverse=\n%s", m, m.getDeterminant(), m.getInverse());
		writefln("%s", m*m.getInverse());
		assert(m*m.getInverse() == [1,0,
		                            0,1]);
	}
	{
		auto m = new Matrix!float(3, 3, [3,2,1,
		                                 5,2,1,
		                                 7,1,9
		                                 ]);
		writefln("%s det = %s inverse=\n%s", m, m.getDeterminant(), m.getInverse());
		writefln("%s", m*m.getInverse());
	}
	{
		auto m = new Matrix!float(4, 4, [3,2,1,5,
		                                 5,2,1,4,
		                                 7,1,9,5,
		                                 1,5,6,7
		                                 ]);
		writefln("%s det = %s inverse=\n%s", m, m.getDeterminant(), m.getInverse());
		writefln("%s", m*m.getInverse());
	}
}

void testProject() {
	//writefln("testing project");
	//Matrix4 View = Matrix4.lookAt(
	//	Vector3(4, 3, 3), // Camera is at (4,3,3), in World Space
	//	Vector3(0, 0, 0), // and looks at the origin
	//	Vector3(0, 1, 0)  // Head is up (set to 0,-1,0 to look upside-down)
	//);
	//Matrix4 Projection = Matrix4.perspective(45.0f.degrees, 4.0f / 3.0f, 0.1f, 100.0f);
	//{
	//	auto obj = Vector3(10,20,30);
	//	auto p = Vector3.project(obj, View, Projection, Rect(0,0,1024,768));
	//	writefln("p=\n%s", p);
	//	assert(p==[1135.72644, 253.26105, 1.00474]);
    //
	//	auto invViewProj = (Projection*View).inversed();
	//	auto p2 = Vector3.unProject(p,
	//								invViewProj,
	//								Rect(0,0,1024,768));
	//	writefln("p2=\n%s", p2);
	//	assert(p2==[10.0001, 20.0002, 30.0004]);
	//}
}

void testUtil() {
	writefln("testing util");
	assert("-0.1941"==formatReal(-0.19407, 4));
	assert("10.0"==formatReal(9.99, 1));
	assert("-100.0"==formatReal(-99.99, 1));
	assert("124" ==formatReal(123.5, 0));
	assert("64"==formatReal(64.000));

	StopWatch watch;
	watch.start();
	auto m = Matrix4.rowMajor(
		10,-2,3,4,
		1212,60,7,8,
		9,-10,12,-3,
		-7,-8,5,6);
	Matrix4 r = Matrix4.identity;
	for(auto n=0;n<100_000;n++) {
		r = r + m;
	}
	watch.stop();
	writefln("took %s usecs", watch.peek().total!"nsecs");
	writefln("r=%s", r);

    // factorsOf
	import std.algorithm.sorting : sort;
	import std.range : array;
	writefln("factorsOf(32)==%s", (32.factorsOf).sort().array());
    assert((32.factorsOf).sort().array()==[1,2,4,8,16,32]);
	assert((10.factorsOf).sort().array()==[1,2,5,10]);

    // test min
    assert(min(0,1,2)==0);
    assert(min(1,2,0)==0);
    assert(min(2,0,1)==0);
    assert(min(2,1,0)==0);
    assert(min(1,0,2)==0);
    assert(min(0,2,1)==0);

    {   // entropyBits
        assert(entropyBits(1, 256)==8);
        assert(entropyBits(2, 1024)==9);
        assert(entropyBits(4,1024)==8);
        writefln("%s", entropyBits(1,3));
    }

	{	// isPrime
		foreach(v; [1,2,3,5,7,11,13,17,19,23]) {
			assert(isPrime(v));
		}
		foreach(v; [0,4,6,8,9,10,12,14,15,16,18,20,21,22]) {
			assert(isPrime(v)==false);
		}
	}
}
void testTrigonomety() {
    writefln("testing trigonometry");

    {
        auto o = Opposite!float(3);
        auto h = Hypotenuse!float(5);
        auto a = Adjacent!float(4);
        auto a1 = angle(o,h);
        auto a2 = angle(a,h);
        auto a3 = angle(o,a);
        assert(approxEqual(a1.radians, 36.87.degrees.radians));
        assert(approxEqual(a2.radians, 36.87.degrees.radians));
        assert(approxEqual(a3.radians, 36.87.degrees.radians));

        auto o1 = opposite(a1, h);
        auto o2 = opposite(a1, a);
        auto o3 = opposite(a, h);
        assert(o1.approxEqual(3));
        assert(o2.approxEqual(3));
        assert(o3.approxEqual(3));

        auto ad1 = adjacent(a1, h);
        auto ad2 = adjacent(a1, o);
        auto ad3 = adjacent(o, h);
        assert(ad1.approxEqual(4));
        assert(ad2.approxEqual(4));
        assert(ad3.approxEqual(4));

        auto h1 = hypotenuse(a1, o);
        auto h2 = hypotenuse(a1, a);
        auto h3 = hypotenuse(a, o);
        assert(h1.approxEqual(5));
        assert(h2.approxEqual(5));
        assert(h3.approxEqual(5));
    }
    {
        float a = 5;
        float b = 9;
        float c = 8;
        auto angle = angle(a,b,c);
        assert(angle.degrees.approxEqual(62.18));
    }

    //{
    //    float c = 15;
    //    float r = 20;
    //    float h = 12;
    //    auto ca = cosAngle(r,h,c);
    //    writefln("%s", ca);
    //
    //    float a = ca*h;
    //    writefln("a=%s", a);
    //}
}
void testHalfFloat() {
    writefln("testing half float");

    float f = -3.14f;
    auto h  = HalfFloat(f);

    writefln("value=%s (%s)", h.getFloat(), f);

    ushort bits = h.getBits();
    h.setBits(bits);

    writefln("value=%s bits=%s", h.getFloat(), bits);
}
