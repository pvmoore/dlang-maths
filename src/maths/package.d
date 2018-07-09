module maths;

public:

import maths.angle;
import maths.half_float;
import maths.matrix;
import maths.matrix4;
import maths.quaternion;
import maths.util;
import maths.vector2;
import maths.vector3;
import maths.vector4;

import maths.trigonometry;

import maths.noise;     // noise sub package
import maths.random;    // random sub package
import maths.camera;    // camera sub package

import maths.geom.aabb;
import maths.geom.ray;
import maths.geom.sphere;

import std.math : PI;
import std.math : sin,cos;

const f_1div180 	= 1 / 180.0;
const f_1divPI		= 1 / PI;
const f_180divPI	= 180.0 / PI;
const f_PIdiv180	= PI / 180.0;

alias Point        = Vec2!float;
alias IntPoint     = Vec2!int;
alias Dimension    = Vec2!float;
alias IntDimension = Vec2!int;
alias Rect         = Vec4!float;
alias IntRect      = Vec4!int;

alias Vector2 = Vec2!float;
alias Vector3 = Vec3!float;
alias Vector4 = Vec4!float;
alias Matrix4 = Mat4!float;

alias vec2  = Vec2!float;
alias vec3  = Vec3!float;
alias vec4  = Vec4!float;
alias ivec2 = Vec2!int;
alias ivec3 = Vec3!int;
alias ivec4 = Vec4!int;
alias uvec2 = Vec2!uint;
alias uvec3 = Vec3!uint;
alias uvec4 = Vec4!uint;

alias mat4  = Mat4!float;
