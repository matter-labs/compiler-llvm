; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=instcombine %s | FileCheck %s

; Eliminate the insertelement.

define <4 x float> @PR29126(<4 x float> %x) {
; CHECK-LABEL: @PR29126(
; CHECK-NEXT:    [[INS:%.*]] = shufflevector <4 x float> [[X:%.*]], <4 x float> <float poison, float 1.000000e+00, float 2.000000e+00, float 4.200000e+01>, <4 x i32> <i32 0, i32 5, i32 6, i32 7>
; CHECK-NEXT:    ret <4 x float> [[INS]]
;
  %shuf = shufflevector <4 x float> %x, <4 x float> <float undef, float 1.0, float 2.0, float undef>, <4 x i32> <i32 0, i32 5, i32 6, i32 3>
  %ins = insertelement <4 x float> %shuf, float 42.0, i32 3
  ret <4 x float> %ins
}

; A chain of inserts should collapse.

define <4 x float> @twoInserts(<4 x float> %x) {
; CHECK-LABEL: @twoInserts(
; CHECK-NEXT:    [[INS2:%.*]] = shufflevector <4 x float> [[X:%.*]], <4 x float> <float poison, float 0.000000e+00, float 4.200000e+01, float 1.100000e+01>, <4 x i32> <i32 0, i32 5, i32 6, i32 7>
; CHECK-NEXT:    ret <4 x float> [[INS2]]
;
  %shuf = shufflevector <4 x float> %x, <4 x float> zeroinitializer, <4 x i32> <i32 0, i32 5, i32 6, i32 3>
  %ins1 = insertelement <4 x float> %shuf, float 42.0, i32 2
  %ins2 = insertelement <4 x float> %ins1, float 11.0, i32 3
  ret <4 x float> %ins2
}

define <4 x i32> @shuffleRetain(<4 x i32> %base) {
; CHECK-LABEL: @shuffleRetain(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <4 x i32> [[BASE:%.*]], <4 x i32> <i32 poison, i32 poison, i32 poison, i32 1>, <4 x i32> <i32 1, i32 2, i32 undef, i32 7>
; CHECK-NEXT:    ret <4 x i32> [[SHUF]]
;
  %shuf = shufflevector <4 x i32> %base, <4 x i32> <i32 4, i32 3, i32 2, i32 1>, <4 x i32> <i32 1, i32 2, i32 undef, i32 7>
  ret <4 x i32> %shuf
}

; TODO: Transform an arbitrary shuffle with constant into a shuffle that is equivalant to a vector select.

define <4 x float> @disguisedSelect(<4 x float> %x) {
; CHECK-LABEL: @disguisedSelect(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <4 x float> [[X:%.*]], <4 x float> <float poison, float 1.000000e+00, float 2.000000e+00, float poison>, <4 x i32> <i32 undef, i32 6, i32 5, i32 3>
; CHECK-NEXT:    [[INS:%.*]] = insertelement <4 x float> [[SHUF]], float 4.000000e+00, i64 0
; CHECK-NEXT:    ret <4 x float> [[INS]]
;
  %shuf = shufflevector <4 x float> %x, <4 x float> <float undef, float 1.0, float 2.0, float 3.0>, <4 x i32> <i32 7, i32 6, i32 5, i32 3>
  %ins = insertelement <4 x float> %shuf, float 4.0, i32 0
  ret <4 x float> %ins
}

; TODO: Fold arbitrary (non-select-equivalent) shuffles if the new shuffle would have the same shuffle mask.

define <4 x float> @notSelectButNoMaskDifference(<4 x float> %x) {
; CHECK-LABEL: @notSelectButNoMaskDifference(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <4 x float> [[X:%.*]], <4 x float> <float poison, float 1.000000e+00, float 2.000000e+00, float poison>, <4 x i32> <i32 1, i32 5, i32 6, i32 undef>
; CHECK-NEXT:    [[INS:%.*]] = insertelement <4 x float> [[SHUF]], float 4.000000e+00, i64 3
; CHECK-NEXT:    ret <4 x float> [[INS]]
;
  %shuf = shufflevector <4 x float> %x, <4 x float> <float undef, float 1.0, float 2.0, float 3.0>, <4 x i32> <i32 1, i32 5, i32 6, i32 3>
  %ins = insertelement <4 x float> %shuf, float 4.0, i32 3
  ret <4 x float> %ins
}

; We purposely do not touch arbitrary (non-select-equivalent) shuffles because folding the insert may create a more expensive shuffle.

define <4 x float> @tooRisky(<4 x float> %x) {
; CHECK-LABEL: @tooRisky(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <4 x float> [[X:%.*]], <4 x float> <float 1.000000e+00, float poison, float poison, float poison>, <4 x i32> <i32 1, i32 4, i32 4, i32 undef>
; CHECK-NEXT:    [[INS:%.*]] = insertelement <4 x float> [[SHUF]], float 4.000000e+00, i64 3
; CHECK-NEXT:    ret <4 x float> [[INS]]
;
  %shuf = shufflevector <4 x float> %x, <4 x float> <float 1.0, float undef, float undef, float undef>, <4 x i32> <i32 1, i32 4, i32 4, i32 4>
  %ins = insertelement <4 x float> %shuf, float 4.0, i32 3
  ret <4 x float> %ins
}

; Don't transform insert to shuffle if the original shuffle is not removed.
; TODO: Ease the one-use restriction if the insert scalar would simplify the shuffle to a full vector constant?

define <3 x float> @twoShufUses(<3 x float> %x) {
; CHECK-LABEL: @twoShufUses(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <3 x float> [[X:%.*]], <3 x float> <float poison, float 1.000000e+00, float 2.000000e+00>, <3 x i32> <i32 0, i32 4, i32 5>
; CHECK-NEXT:    [[INS:%.*]] = insertelement <3 x float> [[SHUF]], float 4.200000e+01, i64 1
; CHECK-NEXT:    [[ADD:%.*]] = fadd <3 x float> [[SHUF]], [[INS]]
; CHECK-NEXT:    ret <3 x float> [[ADD]]
;
  %shuf = shufflevector <3 x float> %x, <3 x float> <float undef, float 1.0, float 2.0>, <3 x i32> <i32 0, i32 4, i32 5>
  %ins = insertelement <3 x float> %shuf, float 42.0, i2 1
  %add = fadd <3 x float> %shuf, %ins
  ret <3 x float> %add
}

; The inserted scalar constant index is out-of-bounds for the shuffle vector constant.

define <5 x i8> @longerMask(<3 x i8> %x) {
; CHECK-LABEL: @longerMask(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <3 x i8> [[X:%.*]], <3 x i8> <i8 poison, i8 1, i8 poison>, <5 x i32> <i32 2, i32 1, i32 4, i32 undef, i32 undef>
; CHECK-NEXT:    [[INS:%.*]] = insertelement <5 x i8> [[SHUF]], i8 42, i64 4
; CHECK-NEXT:    ret <5 x i8> [[INS]]
;
  %shuf = shufflevector <3 x i8> %x, <3 x i8> <i8 undef, i8 1, i8 2>, <5 x i32> <i32 2, i32 1, i32 4, i32 3, i32 0>
  %ins = insertelement <5 x i8> %shuf, i8 42, i17 4
  ret <5 x i8> %ins
}

; TODO: The inserted constant could get folded into the shuffle vector constant.

define <3 x i8> @shorterMask(<5 x i8> %x) {
; CHECK-LABEL: @shorterMask(
; CHECK-NEXT:    [[SHUF:%.*]] = shufflevector <5 x i8> [[X:%.*]], <5 x i8> poison, <3 x i32> <i32 undef, i32 1, i32 4>
; CHECK-NEXT:    [[INS:%.*]] = insertelement <3 x i8> [[SHUF]], i8 42, i64 0
; CHECK-NEXT:    ret <3 x i8> [[INS]]
;
  %shuf = shufflevector <5 x i8> %x, <5 x i8> <i8 undef, i8 1, i8 2, i8 3, i8 4>, <3 x i32> <i32 2, i32 1, i32 4>
  %ins = insertelement <3 x i8> %shuf, i8 42, i21 0
  ret <3 x i8> %ins
}
