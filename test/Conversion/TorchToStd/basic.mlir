// RUN: torch-mlir-opt <%s -convert-torch-to-std | FileCheck %s


// CHECK-LABEL:   func @torch.aten.dim(
// CHECK-SAME:                         %[[ARG:.*]]: !torch.vtensor<*,f32>) -> !torch.int {
// CHECK:           %[[BUILTIN_TENSOR:.*]] = torch_c.to_builtin_tensor %[[ARG]] : !torch.vtensor<*,f32> -> tensor<*xf32>
// CHECK:           %[[RANK:.*]] = tensor.rank %[[BUILTIN_TENSOR]] : tensor<*xf32>
// CHECK:           %[[RANK_I64:.*]] = arith.index_cast %[[RANK]] : index to i64
// CHECK:           %[[RANK_TORCH_INT:.*]] = torch_c.from_i64 %[[RANK_I64]]
// CHECK:           return %[[RANK_TORCH_INT]] : !torch.int
func @torch.aten.dim(%arg0: !torch.vtensor<*,f32>) -> !torch.int {
  %0 = torch.aten.dim %arg0 : !torch.vtensor<*,f32> -> !torch.int
  return %0 : !torch.int
}

// CHECK-LABEL:   func @torch.runtime.assert(
// CHECK-SAME:                            %[[X:.*]]: !torch.int,
// CHECK-SAME:                            %[[Y:.*]]: !torch.int) {
// CHECK:           %[[X_I64:.*]] = torch_c.to_i64 %[[X]]
// CHECK:           %[[Y_I64:.*]] = torch_c.to_i64 %[[Y]]
// CHECK:           %[[CMP:.*]] = arith.cmpi ne, %[[X_I64]], %[[Y_I64]] : i64
// CHECK:           assert %[[CMP]], "x must not be equal to y"
// CHECK:           return
func @torch.runtime.assert(%arg0: !torch.int, %arg1: !torch.int) {
  %0 = torch.aten.ne.int %arg0, %arg1 : !torch.int, !torch.int -> !torch.bool
  torch.runtime.assert %0, "x must not be equal to y"
  return
}

// CHECK-LABEL:   func @torch.aten.ne.int(
// CHECK-SAME:                            %[[LHS:.*]]: !torch.int,
// CHECK-SAME:                            %[[RHS:.*]]: !torch.int) -> !torch.bool {
// CHECK:           %[[LHS_I64:.*]] = torch_c.to_i64 %[[LHS]]
// CHECK:           %[[RHS_I64:.*]] = torch_c.to_i64 %[[RHS]]
// CHECK:           %[[CMP:.*]] = arith.cmpi ne, %[[LHS_I64]], %[[RHS_I64]] : i64
// CHECK:           %[[CMP_TORCH_BOOL:.*]] = torch_c.from_i1 %[[CMP]]
// CHECK:           return %[[CMP_TORCH_BOOL]] : !torch.bool
func @torch.aten.ne.int(%arg0: !torch.int, %arg1: !torch.int) -> !torch.bool {
  %0 = torch.aten.ne.int %arg0, %arg1 : !torch.int, !torch.int -> !torch.bool
  return %0 : !torch.bool
}

// CHECK-LABEL:   func @torch.aten.eq.int(
// CHECK-SAME:                            %[[LHS:.*]]: !torch.int,
// CHECK-SAME:                            %[[RHS:.*]]: !torch.int) -> !torch.bool {
// CHECK:           %[[LHS_I64:.*]] = torch_c.to_i64 %[[LHS]]
// CHECK:           %[[RHS_I64:.*]] = torch_c.to_i64 %[[RHS]]
// CHECK:           %[[CMP:.*]] = arith.cmpi eq, %[[LHS_I64]], %[[RHS_I64]] : i64
// CHECK:           %[[CMP_TORCH_BOOL:.*]] = torch_c.from_i1 %[[CMP]]
// CHECK:           return %[[CMP_TORCH_BOOL]] : !torch.bool
func @torch.aten.eq.int(%arg0: !torch.int, %arg1: !torch.int) -> !torch.bool {
  %0 = torch.aten.eq.int %arg0, %arg1 : !torch.int, !torch.int -> !torch.bool
  return %0 : !torch.bool
}

// CHECK-LABEL:   func @torch.aten.gt.int(
// CHECK-SAME:                            %[[LHS:.*]]: !torch.int,
// CHECK-SAME:                            %[[RHS:.*]]: !torch.int) -> !torch.bool {
// CHECK:           %[[LHS_I64:.*]] = torch_c.to_i64 %[[LHS]]
// CHECK:           %[[RHS_I64:.*]] = torch_c.to_i64 %[[RHS]]
// CHECK:           %[[CMP:.*]] = arith.cmpi sgt, %[[LHS_I64]], %[[RHS_I64]] : i64
// CHECK:           %[[CMP_TORCH_BOOL:.*]] = torch_c.from_i1 %[[CMP]]
// CHECK:           return %[[CMP_TORCH_BOOL]] : !torch.bool
func @torch.aten.gt.int(%arg0: !torch.int, %arg1: !torch.int) -> !torch.bool {
  %0 = torch.aten.gt.int %arg0, %arg1 : !torch.int, !torch.int -> !torch.bool
  return %0 : !torch.bool
}

// CHECK-LABEL:   func @torch.vtensor.literal() -> !torch.vtensor<[],f32> {
// CHECK:           %[[CST:.*]] = arith.constant dense<0.000000e+00> : tensor<f32>
// CHECK:           %[[VTENSOR:.*]] = torch_c.from_builtin_tensor %[[CST]] : tensor<f32> -> !torch.vtensor<[],f32>
// CHECK:           return %[[VTENSOR]] : !torch.vtensor<[],f32>
func @torch.vtensor.literal() -> !torch.vtensor<[],f32> {
  %0 = torch.vtensor.literal(dense<0.0> : tensor<f32>) : !torch.vtensor<[],f32>
  return %0 : !torch.vtensor<[],f32>
}

// CHECK-LABEL:   func @torch.constant.bool() -> !torch.bool {
// CHECK:           %[[CST:.*]] = arith.constant true
// CHECK:           %[[BOOL:.*]] = torch_c.from_i1 %[[CST]]
// CHECK:           return %[[BOOL]] : !torch.bool
func @torch.constant.bool() -> !torch.bool {
  %true = torch.constant.bool true
  return %true : !torch.bool
}

// CHECK-LABEL:   func @torch.constant.float() -> !torch.float {
// CHECK:           %[[CST:.*]] = arith.constant 1.000000e+00 : f64
// CHECK:           %[[FLOAT:.*]] = torch_c.from_f64 %[[CST]]
// CHECK:           return %[[FLOAT]] : !torch.float
func @torch.constant.float() -> !torch.float {
  %float = torch.constant.float 1.000000e+00
  return %float : !torch.float
}

// CHECK-LABEL:  func @torch.constant.int() -> !torch.int {
// CHECK:          %[[CST:.*]]  = arith.constant 1 : i64
// CHECK:          %[[INT:.*]] = torch_c.from_i64 %[[CST]]
// CHECK:          return %[[INT]] : !torch.int
func @torch.constant.int() -> !torch.int {
  %int1 = torch.constant.int 1
  return %int1 : !torch.int
}

// CHECK-LABEL:  func @torch.aten.add.int(
// CHECK-SAME:                            %[[LHS:.*]]: !torch.int,
// CHECK-SAME:                            %[[RHS:.*]]: !torch.int) -> !torch.int {
// CHECK:          %[[LHS_I64:.*]] = torch_c.to_i64 %[[LHS]]
// CHECK:          %[[RHS_I64:.*]] = torch_c.to_i64 %[[RHS]]
// CHECK:          %[[ADD:.*]] = arith.addi %[[LHS_I64:.*]], [[RHS_I64:.*]] : i64
// CHECK:          %[[OUT:.*]] = torch_c.from_i64 %[[INT:.*]]
// CHECK:          return %[[OUT:.*]] : !torch.int
func @torch.aten.add.int(%arg0: !torch.int, %arg1: !torch.int) -> !torch.int {
  %0 = torch.aten.add.int %arg0, %arg1 : !torch.int, !torch.int -> !torch.int
  return %0 : !torch.int
}

// CHECK-LABEL:  func @torch.aten.sub.int(
// CHECK-SAME:                            %[[LHS:.*]]: !torch.int,
// CHECK-SAME:                            %[[RHS:.*]]: !torch.int) -> !torch.int {
// CHECK:          %[[LHS_I64:.*]] = torch_c.to_i64 %[[LHS]]
// CHECK:          %[[RHS_I64:.*]] = torch_c.to_i64 %[[RHS]]
// CHECK:          %[[SUB:.*]] = arith.subi %[[LHS_I64:.*]], [[RHS_I64:.*]] : i64
// CHECK:          %[[OUT:.*]] = torch_c.from_i64 %[[INT:.*]]
// CHECK:          return %[[OUT:.*]] : !torch.int
func @torch.aten.sub.int(%arg0: !torch.int, %arg1: !torch.int) -> !torch.int {
  %0 = torch.aten.sub.int %arg0, %arg1 : !torch.int, !torch.int -> !torch.int
  return %0 : !torch.int
}

// CHECK-LABEL:  func @torch.aten.sub.float(
// CHECK-SAME:                            %[[LHS:.*]]: !torch.float,
// CHECK-SAME:                            %[[RHS:.*]]: !torch.float) -> !torch.float {
// CHECK:          %[[LHS_F64:.*]] = torch_c.to_f64 %[[LHS]]
// CHECK:          %[[RHS_F64:.*]] = torch_c.to_f64 %[[RHS]]
// CHECK:          %[[SUB:.*]] = arith.subf %[[LHS_F64:.*]], [[RHS_F64:.*]] : f64
// CHECK:          %[[OUT:.*]] = torch_c.from_f64 %[[SUB:.*]]
// CHECK:          return %[[OUT:.*]] : !torch.float
func @torch.aten.sub.float(%arg0: !torch.float, %arg1: !torch.float) -> !torch.float {
  %0 = torch.aten.sub.float %arg0, %arg1 : !torch.float, !torch.float -> !torch.float
  return %0 : !torch.float
}

// CHECK-LABEL:  func @torch.aten.mul.int(
// CHECK-SAME:                            %[[LHS:.*]]: !torch.int,
// CHECK-SAME:                            %[[RHS:.*]]: !torch.int) -> !torch.int {
// CHECK:          %[[LHS_I64:.*]] = torch_c.to_i64 %[[LHS]]
// CHECK:          %[[RHS_I64:.*]] = torch_c.to_i64 %[[RHS]]
// CHECK:          %[[MUL:.*]] = arith.muli %[[LHS_I64:.*]], [[RHS_I64:.*]] : i64
// CHECK:          %[[OUT:.*]] = torch_c.from_i64 %[[MUL:.*]]
// CHECK:          return %[[OUT:.*]] : !torch.int
func @torch.aten.mul.int(%arg0: !torch.int, %arg1: !torch.int) -> !torch.int {
  %0 = torch.aten.mul.int %arg0, %arg1 : !torch.int, !torch.int -> !torch.int
  return %0 : !torch.int
}

// CHECK-LABEL:  func @torch.aten.div.float(
// CHECK-SAME:                            %[[LHS:.*]]: !torch.float,
// CHECK-SAME:                            %[[RHS:.*]]: !torch.float) -> !torch.float {
// CHECK:          %[[LHS_F64:.*]] = torch_c.to_f64 %[[LHS]]
// CHECK:          %[[RHS_F64:.*]] = torch_c.to_f64 %[[RHS]]
// CHECK:          %[[SUB:.*]] = arith.divf %[[LHS_F64:.*]], [[RHS_F64:.*]] : f64
// CHECK:          %[[OUT:.*]] = torch_c.from_f64 %[[SUB:.*]]
// CHECK:          return %[[OUT:.*]] : !torch.float
func @torch.aten.div.float(%arg0: !torch.float, %arg1: !torch.float) -> !torch.float {
  %0 = torch.aten.div.float %arg0, %arg1 : !torch.float, !torch.float -> !torch.float
  return %0 : !torch.float
}
