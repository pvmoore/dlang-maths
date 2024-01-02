module test.test_matrix4;

import std.stdio : writefln;

import maths;

void testMatrix4() {
	doTestMatrix4();
	testProject();
	testOrtho();
}

private:

void doTestMatrix4() {
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
void testOrtho() {
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
