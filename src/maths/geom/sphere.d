module maths.geom.sphere;

import maths.all;

final class Sphere(T) {
public:
    Vector3 pos;
    float radius;
    float radiusSquared;
    T data;
nothrow:
@nogc:
    this(float radius, Vector3 pos, T data=T.init) {
        this.radius        = radius;
        this.pos           = pos;
        this.radiusSquared = radius*radius;
        this.data          = data;
    }
    // t = hit point
    bool intersect(const ref Ray r,
                   ref float t,
                   float tmin=0.01,
                   float tmax=float.max)
    {
        // Solve t^2*d.d + 2*t*(o-p).d + (o-p).(o-p)-R^2 = 0
        Vector3 op = pos - r.origin;
        float b    = op.dot(r.direction);
        float det  = (b*b)-op.dot(op) + radiusSquared;

        if(det<0) return false;

        det = sqrt(det);
        if((t=b-det)>tmin) {
            return t<tmax;
        }
        if((t=b+det)>tmin) {
            return t<tmax;
        }
        return false;
    }
}


