;  Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
;
;  This file is part of the GNU MP Library.
;
;  The GNU MP Library is free software; you can redistribute it and/or
;  modify it under the terms of the GNU Lesser General Public License as
;  published by the Free Software Foundation; either version 2.1 of the
;  License, or (at your option) any later version.
;
;  The GNU MP Library is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;  Lesser General Public License for more details.
;
;  You should have received a copy of the GNU Lesser General Public
;  License along with the GNU MP Library; see the file COPYING.LIB.  If
;  not, write to the Free Software Foundation, Inc., 59 Temple Place -
;  Suite 330, Boston, MA 02111-1307, USA.
;
;  Adapted by Brian Gladman AMD64 using the Microsoft VC++ v8 64-bit
;  compiler and the YASM assembler.

; AMD64 mpn_sqr_basecase -- square an mpn number.
;
;  Calling interface:
;
;  void mpn_sqr_basecase(
;     mp_ptr dst,       rcx
;     mp_srcptr src,    rdx
;     mp_size_t size     r8
;  )
;
; This is an SEH Frame Function with a leaf prologue

%define _SEH_

%define UNROLL_COUNT    31

%if UNROLL_COUNT > 31
%define DWORD_OFFSETS
%else
%undef DWORD_OFFSETS
%endif

%ifdef DWORD_OFFSETS
%define  ADR_BIAS  0
%elif UNROLL_COUNT > 15
%define  ADR_BIAS (UNROLL_COUNT - 15) * 8
%else
%define  ADR_BIAS  0
%endif

%define r_ptr  r10
%define x_ptr   r9
%define x_len   r8

%define  v_ctr r12
%define v_jmp  r13

   bits     64
   section  .text

   global   __gmpn_sqr_basecase

%ifdef DLL
   export   __gmpn_sqr_basecase
%endif

__gmpn_sqr_basecase:
    movsxd  x_len,r8d
    cmp     x_len,2
    je      sqr_2
    ja      sqr_3_plus
    mov     rax,[rdx]
    mul     rax
    mov     [rcx+8],rdx
    mov     [rcx],rax
    ret

sqr_2:
    mov     r_ptr,rcx
    mov     x_ptr,rdx
    mov     r8,[x_ptr]
    mov     r9,[x_ptr+8]
    mov     rax,r8
    mul     r8
    mov     [r_ptr],rax
    mov     [r_ptr+8],rdx
    mov     rax,r9
    mul     r9
    mov     [r_ptr+16],rax
    mov     [r_ptr+24],rdx
    xor     rcx,rcx
    mov     rax,r8
    mul     r9
    add     rax,rax
    adc     rdx,rdx
    adc     rcx,rcx
    add     [r_ptr+8],rax
    adc     [r_ptr+16],rdx
    adc     [r_ptr+24],rcx
    ret

%ifdef _SEH_
PROC_FRAME  sqr_3_plus
    push_reg    rbx
    push_reg    rsi
    push_reg    rdi
    push_reg    rbp
    push_reg    r12
    push_reg    r13
   alloc_stack  8           ; align to 16 byte boundary
END_PROLOGUE
%else
sqr_3_plus:
    push    rbx
    push    rsi
    push    rdi
    push    rbp
    push    r12
    push    r13
%endif
    mov     r_ptr,rcx
    mov     x_ptr,rdx
    cmp     x_len,4
    jae     sqr_4_plus
    mov     rax,[x_ptr]
    mul     rax
    mov     [r_ptr],rax
    mov     rax,[x_ptr+8]
    mov     [r_ptr+8],rdx
    mul     rax
    mov     [r_ptr+16],rax
    mov     rax,[x_ptr+16]
    mov     [r_ptr+24],rdx
    mul     rax
    mov     [r_ptr+32],rax
    mov     rax,[x_ptr]
    mov     [r_ptr+40],rdx
    mul     qword [x_ptr+8]
    mov     rsi,rax
    mov     rax,[x_ptr]
    mov     rdi,rdx
    mul     qword [x_ptr+16]
    add     rdi,rax
    mov     rbp,dword 0
    mov     rax,[x_ptr+8]
    adc     rbp,rdx
    mul     qword [x_ptr+16]
    xor     x_ptr,x_ptr
    add     rbp,rax
    adc     rdx,dword 0
    adc     rdx,dword 0
    add     rsi,rsi
    adc     rdi,rdi
    mov     rax,[r_ptr+8]
    adc     rbp,rbp
    adc     rdx,rdx
    adc     x_ptr,dword 0
    add     rsi,rax
    mov     rax,[r_ptr+16]
    adc     rdi,rax
    mov     rax,[r_ptr+24]
    mov     [r_ptr+8],rsi
    adc     rbp,rax
    mov     rax,[r_ptr+32]
    mov     [r_ptr+16],rdi
    adc     rdx,rax
    mov     rax,[r_ptr+40]
    mov     [r_ptr+24],rbp
    adc     rax,x_ptr
    mov     [r_ptr+32],rdx
    mov     [r_ptr+40],rax
    jmp     sqr_exit

sqr_4_plus:
    mov     rcx,x_len
    lea     rdi,[r_ptr+rcx*8]
    lea     rsi,[x_ptr+rcx*8]
    mov     rbp,[x_ptr]
    mov     rbx,dword 0
    dec     rcx
    neg     rcx
.0: mov     rax,[rsi+rcx*8]
    mul     rbp
    add     rax,rbx
    mov     [rdi+rcx*8],rax
    mov     rbx,dword 0
    adc     rbx,rdx
    inc     rcx
    jnz     .0
    mov     rcx,x_len
    mov     [rdi],rbx
    sub     rcx,4
    jz      L_corner
    neg     rcx
%if   ADR_BIAS != 0
    sub     rdi,ADR_BIAS
    sub     rsi,ADR_BIAS
%endif
    mov     rdx,rcx

%ifdef DWORD_OFFSETS

%define  CODE_BYTES_PER_LIMB  31    ; must be odd
%define dsiz dword

    shl     rcx,5
    sub     rcx,rdx
    lea     v_jmp,[rel .3]
    lea     rcx,[rcx+(UNROLL_COUNT - 2) * CODE_BYTES_PER_LIMB]

%else

%define  CODE_BYTES_PER_LIMB  25    ; must be odd
%define  dsiz byte

    shl     rcx,3
    lea     rcx,[rcx+rcx*2]
    lea     v_jmp,[rel .3]
    lea     rcx,[rcx+rdx+(UNROLL_COUNT - 2) * CODE_BYTES_PER_LIMB]

%endif

    lea     rcx,[rcx+v_jmp]
.2: lea     v_jmp,[rcx+CODE_BYTES_PER_LIMB]
    mov     rbp,[rsi+rdx*8-24+ADR_BIAS]
    mov     rax,[rsi+rdx*8-16+ADR_BIAS]
    mov     v_ctr,rdx
    mul     rbp
    test    cl,1
    mov     rbx,rdx
    mov     rcx,rax
%if (UNROLL_COUNT % 2)
    cmovnz  rbx,rax
    cmovnz  rcx,rdx
%else
    cmovz   rbx,rax
    cmovz   rcx,rdx
%endif
    xor     rdx,rdx
    lea     rdi,[rdi+8]
    jmp     v_jmp

   align    2
.3:
%assign  i UNROLL_COUNT
%rep  UNROLL_COUNT
%define  disp_src ADR_BIAS - 8 * i

%ifndef DWORD_OFFSETS
%if disp_src < -120 || disp_src >= 128
%error source dispacement too large
%endif
%endif

%if (i % 2) = 0     ; 25 bytes of code per limb
    nop
    mov     rax,[dsiz rsi + disp_src]
    adc     rbx,rdx
    mul     rbp
    add     [dsiz rdi + disp_src - 8],rcx
    mov     rcx,dword 0
    adc     rbx,rax
%else
    nop
    mov     rax,[dsiz rsi + disp_src]
    adc     rcx,rdx
    mul     rbp
    add     [dsiz rdi + disp_src - 8],rbx
%if   i != 1
    mov     rbx,dword 0
%endif
    adc     rcx,rax
%endif
%assign i i - 1
%endrep

    adc     rdx,dword 0
    add     [rdi-8+ADR_BIAS],rcx
    mov     rcx,v_jmp
    adc     rdx,dword 0
    mov     [rdi+ADR_BIAS],rdx
    mov     rdx,v_ctr
    inc     rdx
    jnz     .2

%if   ADR_BIAS != 0
    add     rsi,ADR_BIAS
    add     rdi,ADR_BIAS
%endif

L_corner:
    mov     rbp,[rsi-24]
    mov     rax,[rsi-16]
    mov     rcx,rax
    mul     rbp
    add     [rdi-8],rax
    mov     rax,[rsi-8]
    adc     rdx,dword 0
    mov     rbx,rdx
    mov     rsi,rax
    mul     rbp
    add     rax,rbx
    adc     rdx,dword 0
    add     [rdi],rax
    mov     rax,rsi
    adc     rdx,dword 0
    mov     rbx,rdx
    mul     rcx
    add     rax,rbx
    mov     [rdi+8],rax
    adc     rdx,dword 0
    mov     [rdi+16],rdx
    mov     rax,x_len    ; start of shift
    mov     rdi,r_ptr
    xor     rcx,rcx
    lea      r11,[rax+rax]
    lea     rdi,[rdi+r11*8]
    not     rax
    lea     rax,[rax+2]
.0: lea     r11,[rax+rax]
    rcl     qword [rdi+r11*8-8],1
    rcl     qword [rdi+r11*8],1
    inc     rax
    jnz     .0
    setc    al
    mov     rsi,x_ptr
    mov     [rdi-8],rax
    mov     rcx,x_len
    mov     rax,[rsi]
    mul     rax
    lea     rsi,[rsi+rcx*8]
    neg     rcx
    lea      r11,[rcx+rcx]
    mov     [rdi+r11*8],rax
    inc     rcx
.1: lea     r11,[rcx+rcx]
    mov     rax,[rsi+rcx*8]
    mov     rbx,rdx
    mul     rax
    add     [rdi+r11*8-8],rbx
    adc     [rdi+r11*8],rax
    adc     rdx,dword 0
    inc     rcx
    jnz     .1
    add     [rdi-8],rdx
sqr_exit:
%ifdef _SEH_
    add     rsp, 8
    pop     r13
    pop     r12
    pop     rbp
    pop     rdi
    pop     rsi
    pop     rbx
    ret
ENDPROC_FRAME
%else
    pop     r13
    pop     r12
    pop     rbp
    pop     rdi
    pop     rsi
    pop     rbx
    ret
%endif
    end
