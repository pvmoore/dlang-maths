module test.test_vector;

import std.stdio    : writefln;
import std.random   : uniform;
import std.math	    : isClose;

import maths;

void testVector() {
    testVector2();
	testVector3();
	testVector4();
}

private:

void testVector2() {
	writefln("Testing Vector2 ::::::::::::::::::::::::::::::::::::::::::::::::");

	auto v1 = Vector2(1,2);
	auto v2 = Vector2(2,1);
	writefln("Vector2(1,2) hash=%16x", v1.toHash);
	writefln("Vector2(2,1) hash=%16x", v2.toHash);
	assert(v1.toHash == Vector2(1,2).toHash);
	assert(v2.toHash == Vector2(2,1).toHash);
	assert(v1.toHash != v2.toHash);

	// magnitude
	assert(isClose(Vector2(10,10).magnitude, 14.1421));

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
	assert(isClose(2.12132, Vector2(10,13).distanceFromLine(Vector2(10,10), Vector2(15,15))));

	// isLeftOfLine
	assert(true == Vector2(10,11).isLeftOfLine(Vector2(10,10), Vector2(15,15)));
	assert(false == Vector2(10,9).isLeftOfLine(Vector2(10,10), Vector2(15,15)));

	// rotated
	auto v7 = Vector2(0,1);
	assert(v7.rotated(0.degrees)==Vector2(0,1));
	assert(v7.rotated(360.degrees)==Vector2(-0.0f, 1.0f));
	assert(v7.rotated(45.degrees)==Vector2(-0.7071, 0.7071));
	assert(v7.rotated(90.degrees)==Vector2(-1, 0));
	assert(v7.rotated(180.degrees)==Vector2(0, -1));
	assert(v7.rotated(270.degrees)==Vector2(1, 0));

	// toRadians
	assert(Vector2(0,1).rotated(0.degrees).angle.degrees == 0);
	assert(Vector2(0,1).rotated(90.degrees).angle.degrees == 90);
	assert(isClose(Vector2(0,1).rotated(180.degrees).angle.degrees, -180));	// equivalent to 180
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

	{
		// opBinaryRight
		auto v = float2(1,2);
		auto r = 1.0f / v;
		assert(r == float2(1, 0.5));
	}

	{	// dot
		float2 a = float2(0,1);  // up
		float2 b = float2(1,0);  // right
		float2 c = float2(0,-1); // down
		float2 d = float2(-1,0); // left

		writefln("a.a = %s", a.dot(a));	// 1
		writefln("a.b = %s", a.dot(b)); // 0
		writefln("a.c = %s", a.dot(c)); // -1
		writefln("a.d = %s", a.dot(d)); // 0
		assert(a.dot(a) == 1);
		assert(a.dot(b) == 0);
		assert(a.dot(c) == -1);
		assert(a.dot(d) == 0);
	}
	{ 	// compareTo
		float2 a = float2(10, 10);
		float2 b = float2(-10, -10);

		assert(a.compareTo(a) == float2(0, 0));
		assert(b.compareTo(b) == float2(0, 0));

		assert(a.compareTo(b) == float2(1, 1));
		assert(b.compareTo(a) == float2(-1, -1));
	}
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
	{ 	// compareTo
		float3 a = float3(10, 10, 10);
		float3 b = float3(-10, -10, -10);

		assert(a.compareTo(a) == float3(0, 0, 0));
		assert(b.compareTo(b) == float3(0, 0, 0));

		assert(a.compareTo(b) == float3(1, 1, 1));
		assert(b.compareTo(a) == float3(-1, -1, -1));
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
	{ 	// compareTo
		float4 a = float4(10, 10, 10, 10);
		float4 b = float4(-10, -10, -10, -10);

		assert(a.compareTo(a) == float4(0, 0, 0, 0));
		assert(b.compareTo(b) == float4(0, 0, 0, 0));

		assert(a.compareTo(b) == float4(1, 1, 1, 1));
		assert(b.compareTo(a) == float4(-1, -1, -1, -1));
	}
}
