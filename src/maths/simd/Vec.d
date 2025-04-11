module maths.simd.Vec;

version(LDC):

import std.stdio : writefln;
import core.stdc.string : memcmp, memset, memcpy;
import ldc.llvmasm;
import ldc.attributes;

import common.utils : throwIf;

/**
 * Each Vec is a 256 bit (32 byte) AVX2 register.
 *
 * - 32 * ubyte or byte
 * - 16 * ushort or short
 * - 8 * uint, int or float
 * - 4 * ulong, long or double 
 *
 *  Vec a;
 */
align(32) 
struct Vec {
    T* ptr(T)() { return cast(T*)data.ptr; }

    void set(inout float[] array) {
        throwIf(array.length != 8);
        memcpy(data.ptr, array.ptr, 32);
    }

    bool opEquals(inout float[] array) const {
        return array.length*float.sizeof == 32 && memcmp(data.ptr, array.ptr, 32)==0;
    }

private:
    ubyte[32] data; 
}

//──────────────────────────────────────────────────────────────────────────────────────────────────

version(LDC) {

} // version(LDC)
version(DigitalMars) {

void zero(Vec* dest) nothrow @nogc @naked {
    // rcx = dest

    // FIXME: this assumes Vec is a single 256 bits 
    // FIXME: needs a loop
    __asm(`
        vpxor %ymm0, %ymm0, %ymm0
        vmovaps %ymm0, (%rdi)
        ret
        `,
        "");
}

/**
 * Packed floats. dest = dest + b
 */
void addps(Vec* dest, Vec* b) nothrow @nogc @naked {
    // rdx = dest
    // rcx = b 
    __asm(`
        vmovups (%rdx), %ymm0
        vaddps (%rcx), %ymm0, %ymm1
        vmovups %ymm1, (%rdx)
        ret
        `,
        "");
}
void addps(Vec* dest, Vec* b, uint count) nothrow @nogc @naked {
    // r8 = dest
    // rdx = b 
    // ecx = count
    __asm(`
    lp:
        vmovaps %ymm0, (%r8)
        vaddps (%rdx), %ymm0, %ymm0
        vmovaps (%r8), %ymm0

        add %r8, 32
        add %rdx, 32
        dec %ecx
        jne lp
        ret
        `,
        "");
}
/**
 * Packed floats. dest = dest - b
 */
void subps(Vec* dest, Vec* b) nothrow @nogc @naked {
    // rdx = dest
    // rcx = b 
    __asm(`
        vmovaps %ymm0, (%rdx)
        vsubps (%rcx), %ymm0, %ymm0
        vmovaps (%rdx), %ymm0
        ret
        `,
        "");
}

uint example1(void* ptr, uint expected, uint newValue) nothrow @nogc @naked {
    // r8 = ptr
    // edx = expected
    // ecx = newValue
    return __asm!uint(`
        mov %edx, %eax
        lock
        cmpxchg %ecx, (%r8)
        `,
        "={eax}");
}

} // version(DigitalMars)

private:

