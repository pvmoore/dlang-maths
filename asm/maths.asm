
;CHECK_STACK_ALIGNMENT = 1

include ../../../libs/common/asm/inc/includes.asm


YZX_ = 11001001b
ZXY_ = 11010010b

; (v1.x*v2.x) + (v1.y*v2.y) + (v1.z*v2.z)
dotProduct macro   v1,     ; in, const reg
                   v2,     ; in, const reg/mem
                   result  ; out

    vmulps result, v1, v2
    haddps result, result
    haddps result, result
endm

; result = (v1.y*v2.z - v1.z*v2.y, v1.z*v2.x - v1.x*v2.z, v1.x*v2.y - v1.y*v2.x, 0)
crossProduct macro v1,      ; in, const reg/mem
                   v2,      ; in, const reg/mem
                   result,  ; out
                   temp1,   ; clobbered
                   temp2    ; clobbered

    ; result = v1.yzx * v2.zyx
    vpermilps result, v1, YZX_  ;  v1.yzx
    vpermilps temp1, v2, ZXY_   ;  v2.zyx
    mulps result, temp1

    ; temp1 = v1.zxy * v2.yzx
    vpermilps temp1, v1, ZXY_   ;  v1.zxy
    vpermilps temp2, v2, YZX_   ;  v2.yzx
    mulps temp1, temp2

    ; result = result - temp1
    subps result, temp1
endm

tri_intersect_data struc
align 16
    rayorig xmmword ?   ; in - ray origin
    raydir  xmmword ?   ; in - ray direction
    p0      xmmword ?   ; in
    p1      xmmword ?   ; in
    p2      xmmword ?   ; in
align 4
    t       real4 ?     ; out if hit
    u       real4 ?     ; out if hit
    v       real4 ?     ; out if hit
    _unused real4 ?
tri_intersect_data ends

_TEXT segment

tri_intersect proc
    ; rcx = &tri_intersect_data
@tempXmm6  textequ <xmmword ptr [rsp+0*16]>
@tempXmm7  textequ <xmmword ptr [rsp+1*16]>
@tempXmm8  textequ <xmmword ptr [rsp+2*16]>
@LOCAL_SIZE = 3*16
        sub rsp, @LOCAL_SIZE

@rayorig textequ <[rcx]>
@raydir  textequ <[rcx+1*16]>
@p0      textequ <[rcx+2*16]>
@p1      textequ <[rcx+3*16]>
@p2      textequ <[rcx+4*16]>
@t       textequ <real4 ptr [rcx+5*16+0]> ; 50h
@u       textequ <real4 ptr [rcx+5*16+4]> ; 54h
@v       textequ <real4 ptr [rcx+5*16+8]> ; 58h

    movaps @tempXmm6, xmm6
    movaps @tempXmm7, xmm7
    movaps @tempXmm8, xmm8

    movaps xmm0, @p0
    movaps xmm3, @rayorig
    movaps xmm4, @raydir

    ; edge1 = p1 - p0
    movaps xmm1, @p1
    vsubps xmm5, xmm1, xmm0

    ; edge2 = p2 - p0
    movaps xmm1, @p2
    vsubps xmm6, xmm1, xmm0

    ; xmm0 =
    ; xmm1 =
    ; xmm2 =
    ; xmm3 = rayorig
    ; xmm4 = raydir
    ; xmm5 = edge1
    ; xmm6 = edge2
    ; xmm7 =
    ; xmm8 =

    ; h = r.direction.cross(edge2)
    crossProduct xmm4, xmm6, xmm0, xmm1, xmm2

    ; xmm0 = h

    ; a = edge1.dot(h)
    dotProduct xmm5, xmm0, xmm1

    ; xmm1.ss = a

    ; if(a >= -E && a <= E) return false
    ucomiss xmm1, MINUS_E
    jb @f
        ucomiss xmm1, E
        jbe _false
@@:
    ; f = 1f / a;
    movss xmm2, _1
    vdivss xmm1, xmm2, xmm1

    ; xmm1.ss = f

    ; s = r.origin - p0
    vsubps xmm2, xmm3, @p0

    ; xmm2 = s

    ; u = f * s.dot(h)
    dotProduct xmm2, xmm0, xmm0
    vmulss xmm0, xmm1, xmm0

    ; xmm0.ss = u

    ; if(u <= 0 || u >= 1) return false
    ucomiss xmm0, _0
    jbe _false
    ucomiss xmm0, _1
    jae _false

    movss @u, xmm0

    ; xmm0 = u
    ; xmm1 = f
    ; xmm2 = s
    ; xmm3 =
    ; xmm4 = raydir
    ; xmm5 = edge1
    ; xmm6 = edge2
    ; xmm7 =
    ; xmm8 =

    ; q = s.cross(edge1)
    crossProduct xmm2, xmm5, xmm7, xmm8, xmm3

    ; xmm7 = q

    ; v = f * r.direction.dot(q)
    dotProduct xmm4, xmm7, xmm2
    vmulss xmm2, xmm1, xmm2

    ; xmm2.ss = v

    ; if(v<=0 || u+v >= 1) return false
    ucomiss xmm2, _0
    jbe _false
    addss xmm0, xmm2
    ucomiss xmm0, _1
    jae _false

    ; xmm0 =

    movss @v, xmm2

    ; t = f * edge2.dot(q);
    dotProduct xmm6, xmm7, xmm0
    vmulss xmm0, xmm1, xmm0

    ; xmm0.ss = t

    movss @t, xmm0

    ;invoke dumpXMM_PS

    jmp _true
_false:
    xor al,al
    jmp _exit
_true:
    mov al,1
_exit:
    movaps xmm6, @tempXmm6
    movaps xmm7, @tempXmm7
    movaps xmm8, @tempXmm8
    ; al = 1 if possible hit else 0
    add rsp, @LOCAL_SIZE
    ret 0
tri_intersect endp

_TEXT ends

CONST	segment page read alias("local_const")
align 16
E       real4 0.00001
MINUS_E real4 -0.00001
_0      real4 0.0
_1      real4 1.0
CONST	ends

DATA 	segment page read write alias("local_data")
align 16

DATA	ends

end