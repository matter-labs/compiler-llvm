; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; RUN: opt -attributor -enable-new-pm=0 -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=2 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=2 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -enable-new-pm=0 -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM

; Don't constant-propagate byval pointers, since they are not pointers!
; PR5038
%struct.MYstr = type { i8, i32 }
@mystr = internal global %struct.MYstr zeroinitializer ; <%struct.MYstr*> [#uses=3]

declare void @use(i8)
;.
; CHECK: @[[MYSTR:[a-zA-Z0-9_$"\\.-]+]] = internal global [[STRUCT_MYSTR:%.*]] zeroinitializer
;.
define internal void @vfu1(%struct.MYstr* byval(%struct.MYstr) align 4 %u) nounwind {
; IS________OPM: Function Attrs: nounwind
; IS________OPM-LABEL: define {{[^@]+}}@vfu1
; IS________OPM-SAME: (%struct.MYstr* noalias nocapture nofree noundef nonnull byval([[STRUCT_MYSTR:%.*]]) align 8 dereferenceable(8) [[U:%.*]]) #[[ATTR0:[0-9]+]] {
; IS________OPM-NEXT:  entry:
; IS________OPM-NEXT:    [[TMP0:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U]], i32 0, i32 1
; IS________OPM-NEXT:    store i32 99, i32* [[TMP0]], align 4
; IS________OPM-NEXT:    [[TMP1:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U]], i32 0, i32 0
; IS________OPM-NEXT:    store i8 97, i8* [[TMP1]], align 4
; IS________OPM-NEXT:    [[L:%.*]] = load i8, i8* [[TMP1]], align 4
; IS________OPM-NEXT:    call void @use(i8 [[L]])
; IS________OPM-NEXT:    br label [[RETURN:%.*]]
; IS________OPM:       return:
; IS________OPM-NEXT:    ret void
;
; IS________NPM: Function Attrs: nounwind
; IS________NPM-LABEL: define {{[^@]+}}@vfu1
; IS________NPM-SAME: (i8 [[TMP0:%.*]], i32 [[TMP1:%.*]]) #[[ATTR0:[0-9]+]] {
; IS________NPM-NEXT:  entry:
; IS________NPM-NEXT:    [[U_PRIV:%.*]] = alloca [[STRUCT_MYSTR:%.*]], align 8
; IS________NPM-NEXT:    [[U_PRIV_CAST:%.*]] = bitcast %struct.MYstr* [[U_PRIV]] to i8*
; IS________NPM-NEXT:    store i8 [[TMP0]], i8* [[U_PRIV_CAST]], align 1
; IS________NPM-NEXT:    [[U_PRIV_0_1:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U_PRIV]], i64 0, i32 1
; IS________NPM-NEXT:    store i32 [[TMP1]], i32* [[U_PRIV_0_1]], align 4
; IS________NPM-NEXT:    [[TMP2:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U_PRIV]], i32 0, i32 1
; IS________NPM-NEXT:    store i32 99, i32* [[TMP2]], align 4
; IS________NPM-NEXT:    [[TMP3:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U_PRIV]], i32 0, i32 0
; IS________NPM-NEXT:    store i8 97, i8* [[TMP3]], align 4
; IS________NPM-NEXT:    [[L:%.*]] = load i8, i8* [[TMP3]], align 4
; IS________NPM-NEXT:    call void @use(i8 [[L]])
; IS________NPM-NEXT:    br label [[RETURN:%.*]]
; IS________NPM:       return:
; IS________NPM-NEXT:    ret void
;
entry:
  %0 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 1 ; <i32*> [#uses=1]
  store i32 99, i32* %0, align 4
  %1 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 0 ; <i8*> [#uses=1]
  store i8 97, i8* %1, align 4
  %l = load i8, i8* %1
  call void @use(i8 %l)
  br label %return

return:                                           ; preds = %entry
  ret void
}

define internal i32 @vfu2(%struct.MYstr* byval(%struct.MYstr) align 4 %u) nounwind readonly {
; IS________OPM: Function Attrs: argmemonly nofree norecurse nosync nounwind readonly willreturn
; IS________OPM-LABEL: define {{[^@]+}}@vfu2
; IS________OPM-SAME: (%struct.MYstr* noalias nocapture nofree noundef nonnull readonly byval([[STRUCT_MYSTR:%.*]]) align 8 dereferenceable(8) [[U:%.*]]) #[[ATTR1:[0-9]+]] {
; IS________OPM-NEXT:  entry:
; IS________OPM-NEXT:    [[TMP0:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U]], i32 0, i32 1
; IS________OPM-NEXT:    [[TMP1:%.*]] = load i32, i32* [[TMP0]], align 4
; IS________OPM-NEXT:    [[TMP2:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U]], i32 0, i32 0
; IS________OPM-NEXT:    [[TMP3:%.*]] = load i8, i8* [[TMP2]], align 4
; IS________OPM-NEXT:    [[TMP4:%.*]] = zext i8 [[TMP3]] to i32
; IS________OPM-NEXT:    [[TMP5:%.*]] = add i32 [[TMP4]], [[TMP1]]
; IS________OPM-NEXT:    ret i32 [[TMP5]]
;
; IS________NPM: Function Attrs: argmemonly nofree norecurse nosync nounwind readonly willreturn
; IS________NPM-LABEL: define {{[^@]+}}@vfu2
; IS________NPM-SAME: (i8 [[TMP0:%.*]], i32 [[TMP1:%.*]]) #[[ATTR1:[0-9]+]] {
; IS________NPM-NEXT:  entry:
; IS________NPM-NEXT:    [[U_PRIV:%.*]] = alloca [[STRUCT_MYSTR:%.*]], align 8
; IS________NPM-NEXT:    [[U_PRIV_CAST:%.*]] = bitcast %struct.MYstr* [[U_PRIV]] to i8*
; IS________NPM-NEXT:    store i8 [[TMP0]], i8* [[U_PRIV_CAST]], align 1
; IS________NPM-NEXT:    [[U_PRIV_0_1:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U_PRIV]], i64 0, i32 1
; IS________NPM-NEXT:    store i32 [[TMP1]], i32* [[U_PRIV_0_1]], align 4
; IS________NPM-NEXT:    [[TMP2:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U_PRIV]], i32 0, i32 1
; IS________NPM-NEXT:    [[TMP3:%.*]] = load i32, i32* [[TMP2]], align 4
; IS________NPM-NEXT:    [[TMP4:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U_PRIV]], i32 0, i32 0
; IS________NPM-NEXT:    [[TMP5:%.*]] = load i8, i8* [[TMP4]], align 4
; IS________NPM-NEXT:    [[TMP6:%.*]] = zext i8 [[TMP5]] to i32
; IS________NPM-NEXT:    [[TMP7:%.*]] = add i32 [[TMP6]], [[TMP3]]
; IS________NPM-NEXT:    ret i32 [[TMP7]]
;
entry:
  %0 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 1 ; <i32*> [#uses=1]
  %1 = load i32, i32* %0
  %2 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 0 ; <i8*> [#uses=1]
  %3 = load i8, i8* %2
  %4 = zext i8 %3 to i32
  %5 = add i32 %4, %1
  ret i32 %5
}

define i32 @unions() nounwind {
; IS__TUNIT_OPM: Function Attrs: nounwind
; IS__TUNIT_OPM-LABEL: define {{[^@]+}}@unions
; IS__TUNIT_OPM-SAME: () #[[ATTR0]] {
; IS__TUNIT_OPM-NEXT:  entry:
; IS__TUNIT_OPM-NEXT:    call void @vfu1(%struct.MYstr* nocapture nofree noundef nonnull readonly byval([[STRUCT_MYSTR:%.*]]) align 8 dereferenceable(8) @mystr) #[[ATTR0]]
; IS__TUNIT_OPM-NEXT:    [[RESULT:%.*]] = call i32 @vfu2(%struct.MYstr* nocapture nofree noundef nonnull readonly byval([[STRUCT_MYSTR]]) align 8 dereferenceable(8) @mystr) #[[ATTR2:[0-9]+]]
; IS__TUNIT_OPM-NEXT:    ret i32 [[RESULT]]
;
; IS__TUNIT_NPM: Function Attrs: nounwind
; IS__TUNIT_NPM-LABEL: define {{[^@]+}}@unions
; IS__TUNIT_NPM-SAME: () #[[ATTR0]] {
; IS__TUNIT_NPM-NEXT:  entry:
; IS__TUNIT_NPM-NEXT:    [[MYSTR_CAST:%.*]] = bitcast %struct.MYstr* @mystr to i8*
; IS__TUNIT_NPM-NEXT:    [[TMP0:%.*]] = load i8, i8* [[MYSTR_CAST]], align 8
; IS__TUNIT_NPM-NEXT:    [[MYSTR_0_1:%.*]] = getelementptr [[STRUCT_MYSTR:%.*]], %struct.MYstr* @mystr, i64 0, i32 1
; IS__TUNIT_NPM-NEXT:    [[TMP1:%.*]] = load i32, i32* [[MYSTR_0_1]], align 8
; IS__TUNIT_NPM-NEXT:    call void @vfu1(i8 [[TMP0]], i32 [[TMP1]]) #[[ATTR0]]
; IS__TUNIT_NPM-NEXT:    [[MYSTR_CAST1:%.*]] = bitcast %struct.MYstr* @mystr to i8*
; IS__TUNIT_NPM-NEXT:    [[TMP2:%.*]] = load i8, i8* [[MYSTR_CAST1]], align 8
; IS__TUNIT_NPM-NEXT:    [[MYSTR_0_12:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* @mystr, i64 0, i32 1
; IS__TUNIT_NPM-NEXT:    [[TMP3:%.*]] = load i32, i32* [[MYSTR_0_12]], align 8
; IS__TUNIT_NPM-NEXT:    [[RESULT:%.*]] = call i32 @vfu2(i8 [[TMP2]], i32 [[TMP3]]) #[[ATTR2:[0-9]+]]
; IS__TUNIT_NPM-NEXT:    ret i32 [[RESULT]]
;
; IS__CGSCC_OPM: Function Attrs: nounwind
; IS__CGSCC_OPM-LABEL: define {{[^@]+}}@unions
; IS__CGSCC_OPM-SAME: () #[[ATTR0]] {
; IS__CGSCC_OPM-NEXT:  entry:
; IS__CGSCC_OPM-NEXT:    call void @vfu1(%struct.MYstr* noalias nocapture nofree noundef nonnull readonly byval([[STRUCT_MYSTR:%.*]]) align 8 dereferenceable(8) @mystr) #[[ATTR0]]
; IS__CGSCC_OPM-NEXT:    [[RESULT:%.*]] = call i32 @vfu2(%struct.MYstr* noalias nocapture nofree noundef nonnull readonly byval([[STRUCT_MYSTR]]) align 8 dereferenceable(8) @mystr) #[[ATTR0]]
; IS__CGSCC_OPM-NEXT:    ret i32 [[RESULT]]
;
; IS__CGSCC_NPM: Function Attrs: nounwind
; IS__CGSCC_NPM-LABEL: define {{[^@]+}}@unions
; IS__CGSCC_NPM-SAME: () #[[ATTR0]] {
; IS__CGSCC_NPM-NEXT:  entry:
; IS__CGSCC_NPM-NEXT:    [[TMP0:%.*]] = load i8, i8* getelementptr inbounds ([[STRUCT_MYSTR:%.*]], %struct.MYstr* @mystr, i32 0, i32 0), align 8
; IS__CGSCC_NPM-NEXT:    [[MYSTR_0_1:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* @mystr, i64 0, i32 1
; IS__CGSCC_NPM-NEXT:    [[TMP1:%.*]] = load i32, i32* [[MYSTR_0_1]], align 8
; IS__CGSCC_NPM-NEXT:    call void @vfu1(i8 [[TMP0]], i32 [[TMP1]]) #[[ATTR0]]
; IS__CGSCC_NPM-NEXT:    [[TMP2:%.*]] = load i8, i8* getelementptr inbounds ([[STRUCT_MYSTR]], %struct.MYstr* @mystr, i32 0, i32 0), align 8
; IS__CGSCC_NPM-NEXT:    [[MYSTR_0_12:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* @mystr, i64 0, i32 1
; IS__CGSCC_NPM-NEXT:    [[TMP3:%.*]] = load i32, i32* [[MYSTR_0_12]], align 8
; IS__CGSCC_NPM-NEXT:    [[RESULT:%.*]] = call i32 @vfu2(i8 [[TMP2]], i32 [[TMP3]]) #[[ATTR0]]
; IS__CGSCC_NPM-NEXT:    ret i32 [[RESULT]]
;
entry:
  call void @vfu1(%struct.MYstr* byval(%struct.MYstr) align 4 @mystr) nounwind
  %result = call i32 @vfu2(%struct.MYstr* byval(%struct.MYstr) align 4 @mystr) nounwind
  ret i32 %result
}

define internal i32 @vfu2_v2(%struct.MYstr* byval(%struct.MYstr) align 4 %u) nounwind readonly {
; IS________OPM: Function Attrs: argmemonly nofree norecurse nosync nounwind readonly willreturn
; IS________OPM-LABEL: define {{[^@]+}}@vfu2_v2
; IS________OPM-SAME: (%struct.MYstr* noalias nocapture nofree noundef nonnull byval([[STRUCT_MYSTR:%.*]]) align 8 dereferenceable(8) [[U:%.*]]) #[[ATTR1]] {
; IS________OPM-NEXT:  entry:
; IS________OPM-NEXT:    [[Z:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U]], i32 0, i32 1
; IS________OPM-NEXT:    store i32 99, i32* [[Z]], align 4
; IS________OPM-NEXT:    [[TMP0:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U]], i32 0, i32 1
; IS________OPM-NEXT:    [[TMP1:%.*]] = load i32, i32* [[TMP0]], align 4
; IS________OPM-NEXT:    [[TMP2:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U]], i32 0, i32 0
; IS________OPM-NEXT:    [[TMP3:%.*]] = load i8, i8* [[TMP2]], align 4
; IS________OPM-NEXT:    [[TMP4:%.*]] = zext i8 [[TMP3]] to i32
; IS________OPM-NEXT:    [[TMP5:%.*]] = add i32 [[TMP4]], [[TMP1]]
; IS________OPM-NEXT:    ret i32 [[TMP5]]
;
; IS________NPM: Function Attrs: argmemonly nofree norecurse nosync nounwind readonly willreturn
; IS________NPM-LABEL: define {{[^@]+}}@vfu2_v2
; IS________NPM-SAME: (i8 [[TMP0:%.*]], i32 [[TMP1:%.*]]) #[[ATTR1]] {
; IS________NPM-NEXT:  entry:
; IS________NPM-NEXT:    [[U_PRIV:%.*]] = alloca [[STRUCT_MYSTR:%.*]], align 8
; IS________NPM-NEXT:    [[U_PRIV_CAST:%.*]] = bitcast %struct.MYstr* [[U_PRIV]] to i8*
; IS________NPM-NEXT:    store i8 [[TMP0]], i8* [[U_PRIV_CAST]], align 1
; IS________NPM-NEXT:    [[U_PRIV_0_1:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U_PRIV]], i64 0, i32 1
; IS________NPM-NEXT:    store i32 [[TMP1]], i32* [[U_PRIV_0_1]], align 4
; IS________NPM-NEXT:    [[Z:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U_PRIV]], i32 0, i32 1
; IS________NPM-NEXT:    store i32 99, i32* [[Z]], align 4
; IS________NPM-NEXT:    [[TMP2:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U_PRIV]], i32 0, i32 1
; IS________NPM-NEXT:    [[TMP3:%.*]] = load i32, i32* [[TMP2]], align 4
; IS________NPM-NEXT:    [[TMP4:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U_PRIV]], i32 0, i32 0
; IS________NPM-NEXT:    [[TMP5:%.*]] = load i8, i8* [[TMP4]], align 4
; IS________NPM-NEXT:    [[TMP6:%.*]] = zext i8 [[TMP5]] to i32
; IS________NPM-NEXT:    [[TMP7:%.*]] = add i32 [[TMP6]], [[TMP3]]
; IS________NPM-NEXT:    ret i32 [[TMP7]]
;
entry:
  %z = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 1
  store i32 99, i32* %z, align 4
  %0 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 1 ; <i32*> [#uses=1]
  %1 = load i32, i32* %0
  %2 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 0 ; <i8*> [#uses=1]
  %3 = load i8, i8* %2
  %4 = zext i8 %3 to i32
  %5 = add i32 %4, %1
  ret i32 %5
}

define i32 @unions_v2() nounwind {
; IS__TUNIT_OPM: Function Attrs: nounwind
; IS__TUNIT_OPM-LABEL: define {{[^@]+}}@unions_v2
; IS__TUNIT_OPM-SAME: () #[[ATTR0]] {
; IS__TUNIT_OPM-NEXT:  entry:
; IS__TUNIT_OPM-NEXT:    call void @vfu1(%struct.MYstr* nocapture nofree noundef nonnull readonly byval([[STRUCT_MYSTR:%.*]]) align 8 dereferenceable(8) @mystr) #[[ATTR0]]
; IS__TUNIT_OPM-NEXT:    [[RESULT:%.*]] = call i32 @vfu2_v2(%struct.MYstr* nocapture nofree noundef nonnull readonly byval([[STRUCT_MYSTR]]) align 8 dereferenceable(8) @mystr) #[[ATTR2]]
; IS__TUNIT_OPM-NEXT:    ret i32 [[RESULT]]
;
; IS__TUNIT_NPM: Function Attrs: nounwind
; IS__TUNIT_NPM-LABEL: define {{[^@]+}}@unions_v2
; IS__TUNIT_NPM-SAME: () #[[ATTR0]] {
; IS__TUNIT_NPM-NEXT:  entry:
; IS__TUNIT_NPM-NEXT:    [[MYSTR_CAST:%.*]] = bitcast %struct.MYstr* @mystr to i8*
; IS__TUNIT_NPM-NEXT:    [[TMP0:%.*]] = load i8, i8* [[MYSTR_CAST]], align 8
; IS__TUNIT_NPM-NEXT:    [[MYSTR_0_1:%.*]] = getelementptr [[STRUCT_MYSTR:%.*]], %struct.MYstr* @mystr, i64 0, i32 1
; IS__TUNIT_NPM-NEXT:    [[TMP1:%.*]] = load i32, i32* [[MYSTR_0_1]], align 8
; IS__TUNIT_NPM-NEXT:    call void @vfu1(i8 [[TMP0]], i32 [[TMP1]]) #[[ATTR0]]
; IS__TUNIT_NPM-NEXT:    [[MYSTR_CAST1:%.*]] = bitcast %struct.MYstr* @mystr to i8*
; IS__TUNIT_NPM-NEXT:    [[TMP2:%.*]] = load i8, i8* [[MYSTR_CAST1]], align 8
; IS__TUNIT_NPM-NEXT:    [[MYSTR_0_12:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* @mystr, i64 0, i32 1
; IS__TUNIT_NPM-NEXT:    [[TMP3:%.*]] = load i32, i32* [[MYSTR_0_12]], align 8
; IS__TUNIT_NPM-NEXT:    [[RESULT:%.*]] = call i32 @vfu2_v2(i8 [[TMP2]], i32 [[TMP3]]) #[[ATTR2]]
; IS__TUNIT_NPM-NEXT:    ret i32 [[RESULT]]
;
; IS__CGSCC_OPM: Function Attrs: nounwind
; IS__CGSCC_OPM-LABEL: define {{[^@]+}}@unions_v2
; IS__CGSCC_OPM-SAME: () #[[ATTR0]] {
; IS__CGSCC_OPM-NEXT:  entry:
; IS__CGSCC_OPM-NEXT:    call void @vfu1(%struct.MYstr* noalias nocapture nofree noundef nonnull readonly byval([[STRUCT_MYSTR:%.*]]) align 8 dereferenceable(8) @mystr) #[[ATTR0]]
; IS__CGSCC_OPM-NEXT:    [[RESULT:%.*]] = call i32 @vfu2_v2(%struct.MYstr* noalias nocapture nofree noundef nonnull readonly byval([[STRUCT_MYSTR]]) align 8 dereferenceable(8) @mystr) #[[ATTR0]]
; IS__CGSCC_OPM-NEXT:    ret i32 [[RESULT]]
;
; IS__CGSCC_NPM: Function Attrs: nounwind
; IS__CGSCC_NPM-LABEL: define {{[^@]+}}@unions_v2
; IS__CGSCC_NPM-SAME: () #[[ATTR0]] {
; IS__CGSCC_NPM-NEXT:  entry:
; IS__CGSCC_NPM-NEXT:    call void @vfu1(i8 noundef 0, i32 noundef 0) #[[ATTR0]]
; IS__CGSCC_NPM-NEXT:    [[RESULT:%.*]] = call i32 @vfu2_v2(i8 noundef 0, i32 noundef 0) #[[ATTR0]]
; IS__CGSCC_NPM-NEXT:    ret i32 [[RESULT]]
;
entry:
  call void @vfu1(%struct.MYstr* byval(%struct.MYstr) align 4 @mystr) nounwind
  %result = call i32 @vfu2_v2(%struct.MYstr* byval(%struct.MYstr) align 4 @mystr) nounwind
  ret i32 %result
}
;.
; IS__TUNIT____: attributes #[[ATTR0:[0-9]+]] = { nounwind }
; IS__TUNIT____: attributes #[[ATTR1:[0-9]+]] = { argmemonly nofree norecurse nosync nounwind readonly willreturn }
; IS__TUNIT____: attributes #[[ATTR2:[0-9]+]] = { nounwind readonly }
;.
; IS__CGSCC____: attributes #[[ATTR0:[0-9]+]] = { nounwind }
; IS__CGSCC____: attributes #[[ATTR1:[0-9]+]] = { argmemonly nofree norecurse nosync nounwind readonly willreturn }
;.