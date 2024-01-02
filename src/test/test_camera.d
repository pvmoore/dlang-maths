module test.test_camera;

import std.stdio : writefln;

import maths;

void testCamera() {
    testCamera2D();
}

private:

void testCamera2D() {
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
