module maths.half_float;
/**
 *
 */
import maths.all;
import std.numeric : CustomFloat, CustomFloatFlags;

alias HALF = CustomFloat!16;
//CustomFloat!(10,5,CustomFloatFlags.signed);

struct HalfFloat {
private:
    HALF value;
public:
    this(float v) {
        this.value = HALF(v);
    }
    float getFloat() {
        return value.get!float;
    }
    ushort getBits() {
        ushort* p = cast(ushort*)&value;
        return *p;
    }
    void setFloat(float v) {
        value = HALF(v);
    }
    void setBits(ushort u) {
        ushort* p = cast(ushort*)&value;
        *p = u;
    }
}
static assert(HalfFloat.sizeof==2);
