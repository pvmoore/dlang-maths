module maths.util;

import maths.all;


/**
 *  More useful than sgn because it never returns 0.
 */
float sign(float f) {
    return f<0 ? -1 : 1;
}

float reciprocal(float value) {
	return 1f / value;
}

pragma(inline, true)
T clamp(T)(T value, T min, T max) pure nothrow {
    if(value<min) return min;
    if(value>max) return max;
    return value;
}
pragma(inline, true)
T min(T)(T a, T b) pure nothrow {
    return a<b ? a : b;
}
pragma(inline, true)
T min(T)(T a, T b, T c) pure nothrow {
    return a<b && a<c ? a :
           b<c ? b :
           c;
}
pragma(inline, true)
T min(T)(T a, T b, T c, T d) pure nothrow {
    return min(a, min(b,c,d));
}
pragma(inline, true)
T max(T)(T a, T b) pure nothrow {
    return a>b ? a : b;
}
pragma(inline, true)
T max(T)(T a, T b, T c) pure nothrow {
    return a>b && a>c ? a :
           b>c ? b :
           c;
}
pragma(inline, true)
T max(T)(T a, T b, T c, T d) pure nothrow {
    return max(a, max(b,c,d));
}
pragma(inline,true)
float signum(float f) {
    return f==0 ? 0 : f>0 ? 1 : -1;
}

float distanceFromLine(
	Vector2 p,	// point
	Vector2 v,	// line start
	Vector2 w)	// line end
{
	Vector2 pointvec = p-v;
	Vector2 linevec  = w-v;
	// Return minimum distance between line segment vw and point p
	float l2 = linevec.magnitudeSquared;  // i.e. |w-v|^2 -  avoid a sqrt
	if(l2==0) return pointvec.magnitude;   // v == w case
	// Consider the line extending the segment, parameterized as v + t (w - v).
	// We find projection of point p onto the line.
	// It falls where t = [(p-v) . (w-v)] / |w-v|^2
	float t = pointvec.dot(linevec) / l2;
	if(t < 0) return pointvec.magnitude;    // Beyond the 'v' end of the segment
	else if(t > 1) return (p-w).magnitude;  // Beyond the 'w' end of the segment
	// 0 <= t <=1
	Vector2 projection = v + linevec * t;  // Projection falls on the segment
	return (projection-p).magnitude;
}

string formatReal(real r, uint decimalPlaces=uint.max) {
	string s1;
	string s2;
	string pre;
	bool removeTrailing = false;
	if(decimalPlaces==uint.max) {
		removeTrailing = true;
		decimalPlaces = 9;
	} else if(decimalPlaces > 12) {
		decimalPlaces = 12;
	}

	// handle negative
	if(r<0) {
		pre = "-";
		r = -r;
	}
	// round up
	r += (0.5 / pow(10, decimalPlaces));

	// calculate remainder
	real rr = r - cast(long)r;

	// before decimal point
	if(r<1) {
		s1 ~= "0";
	} else {
		while(r >= 1) {
			s1 ~= (cast(int)(r%10)+'0');
			r /= 10;
		}
	}

	// after decimal point
	if(decimalPlaces != 0) {
		int i=0;
		while(i < decimalPlaces) {
			rr *= 10;
			int val = cast(int)rr;
			s2 ~= val+'0';
			rr -= val;
			i++;
		}

		if(removeTrailing) {
			// remove any excess right hand side zeros
			while(s2.length>0) {
				if(s2[s2.length-1]=='0') {
					s2 = s2[0..s2.length-1];
				} else break;
			}
		}
	}

	auto reversed = s1.dup;
	reverse(reversed);

	if(s2.length==0) {
		return (pre ~ reversed).idup;
	}
	return (pre ~ reversed ~ "." ~ s2).idup;
}

T[] factorsOf(T)(T n) pure nothrow {
    // this is not the best way of doing this
    T[] factors;
    factors.reserve(n/2);
    T i = n;
    while(i>0) {
        if((n%i)==0) factors ~= i;
        i--;
    }
    return factors;
}
/**
 *  Return the number of bits required to store
 *  _value_ given a total set of size _total_.
 *  eg. entropy(1, 256) == 8 (bits)
 *      entropy(1, 3)   == 1.58496 (bits)
 */
double entropyBits(double value, double total) {
    import std.math : log, log2;
    return log2(total/value);
	//return -log(cast(double)value / cast(double)total) * (1.0 / log(2.0));
}
/**
 *  Find intersection of lines a->b and c->d.
 *
 */
vec2 lineIntersection(vec2 a, vec2 b, vec2 c, vec2 d) {
    float A1 = b.y-a.y;
    float B1 = a.x-b.x;
    float C1 = A1*a.x+B1*a.y;

    float A2 = d.y-c.y;
    float B2 = c.x-d.x;
    float C2 = A2*c.x+B2*c.y;

    float det = A1*B2 - A2*B1;
    if(det==0){
        //Lines are parallel
        return vec2(0.0f/0.0f,0.0f/0.0f);
    }
    float x = (B2*C1 - B1*C2)/det;
    float y = (A1*C2 - A2*C1)/det;
    return vec2(x,y);
}