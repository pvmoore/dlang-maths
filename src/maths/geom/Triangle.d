module maths.geom.Triangle;

import maths.all;
import std.typecons : Tuple, tuple;

struct Triangle {
    float3 p0, p1, p2;

    AABB aabb() {
        return AABB(p0, p1, p2);
    }

    /**
     * Möller–Trumbore intersection algorithm.
     *
     * https://en.wikipedia.org/wiki/M%C3%B6ller%E2%80%93Trumbore_intersection_algorithm
     *
     * Note: This is currently untested
     */
    Tuple!(bool, "hit", float, "t") intersect(Ray ray) {
        enum E     = 0.00001f;
        auto edge1 = p1 - p0;
        auto edge2 = p2 - p0;
        auto h     = ray.direction.cross(edge2);
        auto det   = edge1.dot(h);
        if(det >= -E && det <= E) {
            // ray is parallel to triangle
            return tuple!("hit", "t")(false, 0f);
        }

        auto f = 1f / det;
        auto s = ray.origin - p0;
        auto u = f * s.dot(h);
        if((u < 0 && abs(u) > E) || (u > 1 && abs(u-1) > E)) {
            // ray is outside of triangle
            return tuple!("hit", "t")(false, 0f);
        }
        auto q = s.cross(edge1);
        auto v = f * ray.direction.dot(q);
        if((v < 0 && abs(v) > E) || (u+v > 1 && abs(u+v-1) > E)) {
            // ray is outside of triangle
            return tuple!("hit", "t")(false, 0f);
        }

        auto t = f * edge2.dot(q);
        if(t > E) {
            return tuple!("hit", "t")(true, t);
        }

        // There is a line intersection but no ray intersection
        return tuple!("hit", "t")(false, 0f);
    }
}
