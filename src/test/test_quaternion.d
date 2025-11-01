module test.test_quaternion;

import std.stdio  : writefln;
import std.format : format;
import std.math   : isClose;

import maths;

void testQuaternion() {
    writefln("┌─────────────────────────────");
    writefln("| Testing quaternion...");
    writefln("└─────────────────────────────");

    const DEG_45 = 45.toRadians();
    const DEG_90 = 90.toRadians();

    { 
        writefln("----- unit quaternion if no args");
        Quaternion q;
        assert(q == Quaternion(0,0,0,1));
    }
    {
        writefln("----- fromEulerX");        
        auto q = Quaternion.fromEulerX(90.toRadians());
        writefln("q=%s, angle = %s degrees", q, q.angle().toDegrees());
        assert(q == Quaternion(0.707107, 0, 0, 0.707107));
        assert(isClose(q.angle(), DEG_90));
    }
    {
        writefln("----- fromEulerY");        
        auto q = Quaternion.fromEulerY(90.toRadians());
        writefln("q=%s, angle = %s degrees", q, q.angle().toDegrees());
        assert(q == Quaternion(0, 0.707107, 0, 0.707107));
        assert(isClose(q.angle(), DEG_90));
    }
    {
        writefln("----- fromEulerZ");        
        auto q = Quaternion.fromEulerZ(90.toRadians());
        writefln("q=%s, angle = %s degrees", q, q.angle().toDegrees());
        assert(q == Quaternion(0, 0, 0.707107, 0.707107));
        assert(isClose(q.angle(), DEG_90));
    }
    {
        writefln("----- fromEulerXYZ");
        auto q = Quaternion.fromEulerXYZ(float3(90.toRadians(),0,0));
        writefln("q=%s, angle = %s degrees", q, q.angle().toDegrees());
        assert(q == Quaternion(0.707107, 0, 0, 0.707107));
        assert(isClose(q.angle(), DEG_90));
    }

    {
        writefln("----- fromUnitVectorAndAngle");
        auto q1 = Quaternion.fromUnitVectorAndAngle(float3(1,0,0), DEG_90);
        auto q2 = Quaternion.fromUnitVectorAndAngle(float3(0,1,0), DEG_90);
        auto q3 = Quaternion.fromUnitVectorAndAngle(float3(0,0,1), DEG_90);
        writefln("q1=%s", q1);
        writefln("q2=%s", q2);
        writefln("q3=%s", q3);
        assert(q1 == Quaternion(0.707107, 0, 0, 0.707107));
        assert(q2 == Quaternion(0, 0.707107, 0, 0.707107));
        assert(q3 == Quaternion(0, 0, 0.707107, 0.707107));
    }
    {   
        writefln("----- fromVectorAndAngle");
        auto q1 = Quaternion.fromVectorAndAngle(float3(10,0,0), DEG_90);
        auto q2 = Quaternion.fromVectorAndAngle(float3(0,10,0), DEG_90);
        auto q3 = Quaternion.fromVectorAndAngle(float3(0,0,10), DEG_90);
        writefln("q1=%s", q1);
        writefln("q2=%s", q2);
        writefln("q3=%s", q3);
        assert(q1 == Quaternion(0.707107, 0, 0, 0.707107));
        assert(q2 == Quaternion(0, 0.707107, 0, 0.707107));
        assert(q3 == Quaternion(0, 0, 0.707107, 0.707107));
    }
    {
        writefln("----- Multiply by scalar");
        auto q1 = Quaternion.fromVectorAndAngle(float3(0,-1,0), DEG_45);
        auto q2 = q1 * 2;
        writefln("q1=%s", q1);
        writefln("q2=%s", q2);
        assert(q1 == Quaternion(0, -0.382683, 0, 0.92388));
        assert(q2 == Quaternion(0, -0.765367, 0, 1.84776));
    }
    {
        writefln("----- Multiply by Quaternion");
        auto q1 = Quaternion.fromVectorAndAngle(float3(0,-1,0), DEG_45);
        auto q2 = Quaternion.fromVectorAndAngle(float3(-1,0,0), DEG_90);
        auto q3 = q1 * q2;
        writefln("q1=%s", q1);
        writefln("q2=%s", q2);
        writefln("q3=%s", q3);
        assert(q1 == Quaternion(0, -0.382683, 0, 0.92388));
        assert(q2 == Quaternion(-0.707107, 0, 0, 0.707107));
        assert(q3 == Quaternion(-0.653281, -0.270598, -0.270598, 0.653281));
    }
    {
        writefln("----- Add by scalar");
        auto q1 = Quaternion.fromVectorAndAngle(float3(0,-1,0), DEG_45);
        auto q2 = q1 + 1;
        writefln("q1=%s", q1);
        writefln("q2=%s", q2);
        assert(q1 == Quaternion(0, -0.382683, 0, 0.92388));
        assert(q2 == Quaternion(1, 0.617317, 1, 1.92388));
    }
    {
        writefln("----- Add by Quaternion");
        auto q1 = Quaternion.fromVectorAndAngle(float3(0,0,-1), DEG_45);
        auto q2 = Quaternion.fromVectorAndAngle(float3(-1,0,0), DEG_90);
        auto q3 = q1 + q2;
        writefln("q1=%s", q1);
        writefln("q2=%s", q2);
        writefln("q3=%s", q3);
    }
    {
        writefln("----- normalise");
        auto q1 = Quaternion.fromVectorAndAngle(float3(0,0,-50), DEG_45);
        writefln("q1=%s", q1);
        assert(q1 == Quaternion(0, 0, -0.382683, 0.92388));
        q1 = q1 * 10;
        writefln("q1=%s", q1);
        q1.normalise();
        writefln("q1=%s", q1);
        assert(q1 == Quaternion(0, 0, -0.382683, 0.92388));
    }
    {
        writefln("----- dot");
        auto q1 = Quaternion.fromVectorAndAngle(float3(10,-3,1), DEG_90);
        auto q2 = Quaternion.fromVectorAndAngle(float3(4,3,10), DEG_90);
        writefln("q1=%s", q1);
        writefln("q2=%s", q2);
        float d = q1.dot(q2);
        writefln("dot=%s", d);
    }
    {
        writefln("----- toRotationMatrix");
        auto q1 = Quaternion.fromVectorAndAngle(float3(10,-3,1), DEG_90);
        writefln("q1=%s", q1);

        mat4 m = q1.toRotationMatrix();
        writefln("m=\n%s", m);

        assert(m == mat4.rowMajor(
             0.90909, -0.36807, -0.19513, 0,
            -0.17738,  0.08182, -0.98074, 0,
             0.37695,  0.92619,  0.00909, 0,
             0,        0,        0,       1
        ));
    }
    {
        writefln("----- rotate");
        auto q1 = Quaternion.fromVectorAndAngle(float3(10,-3,1), DEG_90);
        auto v1 = float3(1,0,0);
        auto v2 = q1.rotate(v1);
        writefln("v2=%s", v2);
    }
}
