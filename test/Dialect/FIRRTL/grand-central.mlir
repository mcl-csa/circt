// RUN: circt-opt -pass-pipeline='firrtl.circuit(firrtl-grand-central)' -split-input-file %s | FileCheck %s

firrtl.circuit "InterfaceGroundType" attributes {
  annotations = [
    {class = "sifive.enterprise.grandcentral.AugmentedBundleType",
     defName = "Foo",
     elements = [
       {description = "description of foo",
        name = "foo",
        tpe = "sifive.enterprise.grandcentral.AugmentedGroundType"},
       {name = "bar",
        tpe = "sifive.enterprise.grandcentral.AugmentedGroundType"}]}]} {
  firrtl.module @InterfaceGroundType() {
    %a = firrtl.wire {annotations = [
      {a},
      {class = "sifive.enterprise.grandcentral.AugmentedGroundType",
       defName = "Foo",
       name = "foo",
       target = []}]} : !firrtl.uint<2>
    %b = firrtl.wire {annotations = [
      {a},
      {class = "sifive.enterprise.grandcentral.AugmentedGroundType",
       defName = "Foo",
       name = "bar",
       target = []}]} : !firrtl.uint<4>
  }
}

// This block is checking that all annotations were removed.
// CHECK-LABEL: firrtl.circuit "InterfaceGroundType"
// CHECK-NOT: annotations
// CHECK-SAME: {

// All Grand Central annotations are removed from the wires.
// CHECK: firrtl.module @InterfaceGroundType
// CHECK: %a = firrtl.wire
// CHECK-SAME: annotations = [{a}]
// CHECK: %b = firrtl.wire
// CHECK-SAME: annotations = [{a}]

// CHECK: sv.interface @Foo
// CHECK-NEXT: sv.verbatim "\0A// description of foo"
// CHECK-NEXT: sv.interface.signal @foo : i2
// CHECK-NEXT: sv.interface.signal @bar : i4

// -----

firrtl.circuit "InterfaceVectorType" attributes {
  annotations = [
    {class = "sifive.enterprise.grandcentral.AugmentedBundleType",
     defName = "Foo",
     elements = [
       {description = "description of foo",
        name = "foo",
        tpe = "sifive.enterprise.grandcentral.AugmentedVectorType"}]}]} {
  firrtl.module @InterfaceVectorType(in %clock: !firrtl.clock, in %reset: !firrtl.uint<1>) {
    %a_0 = firrtl.reg %clock {
      annotations = [
        {a},
        {class = "sifive.enterprise.grandcentral.AugmentedGroundType",
         defName = "Foo",
         name = "foo"}]} : !firrtl.uint<1>
    %c0_ui1 = firrtl.constant 0 : !firrtl.uint<1>
    %a_1 = firrtl.regreset %clock, %reset, %c0_ui1 {
      annotations = [
        {a},
        {class = "sifive.enterprise.grandcentral.AugmentedGroundType",
         defName = "Foo",
         name = "foo"}]} : !firrtl.uint<1>, !firrtl.uint<1>, !firrtl.uint<1>
  }
}

// All annotations are removed from the circuit.
// CHECK-LABEL: firrtl.circuit "InterfaceVectorType"
// CHECK-NOT: annotations
// CHECK-SAME: {

// All Grand Central annotations are removed from the registers.
// CHECK: firrtl.module @InterfaceVectorType
// CHECK: %a_0 = firrtl.reg
// CHECK-SAME: annotations = [{a}]
// CHECK: %a_1 = firrtl.regreset
// CHECK-SAME: annotations = [{a}]

// CHECK: sv.interface @Foo
// CHECK-NEXT: sv.verbatim "\0A// description of foo"
// CHECK-NEXT: sv.interface.signal @foo : !hw.uarray<2xi1>

// -----

firrtl.circuit "InterfaceBundleType" attributes {
  annotations = [
    {class = "sifive.enterprise.grandcentral.AugmentedBundleType",
     defName = "Bar",
     elements = [
       {name = "b",
        tpe = "sifive.enterprise.grandcentral.AugmentedGroundType"},
       {name = "a",
        tpe = "sifive.enterprise.grandcentral.AugmentedGroundType"}]},
    {class = "sifive.enterprise.grandcentral.AugmentedBundleType",
     defName = "Foo",
     elements = [
       {description = "descripton of Bar",
        name = "Bar",
        tpe = "sifive.enterprise.grandcentral.AugmentedBundleType"}]}]}  {
  firrtl.module @InterfaceBundleType() {
    %x = firrtl.wire {
      annotations = [
        {a},
        {class = "sifive.enterprise.grandcentral.AugmentedGroundType",
         defName = "Bar",
         name = "a"}]} : !firrtl.uint<1>
    %y = firrtl.wire {
      annotations = [
        {a},
        {class = "sifive.enterprise.grandcentral.AugmentedGroundType",
         defName = "Bar",
         name = "b"}]} : !firrtl.uint<2>
  }
}

// All annotations are removed from the circuit.
// CHECK-LABEL: firrtl.circuit "InterfaceBundleType"
// CHECK-NOT: annotations
// CHECK-SAME: {

// All Grand Central annotations are removed from the wires.
// CHECK-LABEL: firrtl.module @InterfaceBundleType
// CHECK: %x = firrtl.wire
// CHECK-SAME: annotations = [{a}]
// CHECK: %y = firrtl.wire
// CHECK-SAME: annotations = [{a}]

// CHECK: sv.interface @Bar
// CHECK-NEXT: sv.interface.signal @b : i2
// CHECK-NEXT: sv.interface.signal @a : i1

// CHECK: sv.interface @Foo
// CHECK-NEXT: sv.verbatim "\0A// descripton of Bar"
// CHECK-NEXT: Bar Bar();

// -----

firrtl.circuit "InterfaceNode" attributes {
  annotations = [
    {class = "sifive.enterprise.grandcentral.AugmentedBundleType",
     defName = "Foo",
     elements = [
       {description = "some expression",
        name = "foo",
        tpe = "sifive.enterprise.grandcentral.AugmentedGroundType"}]}]} {
  firrtl.module @InterfaceNode() {
    %a = firrtl.wire : !firrtl.uint<2>
    %notA = firrtl.not %a : (!firrtl.uint<2>) -> !firrtl.uint<2>
    %b = firrtl.node %notA {
      annotations = [
        {a},
        {class = "sifive.enterprise.grandcentral.AugmentedGroundType",
         defName = "Foo",
         name = "foo",
         target = []}]} : !firrtl.uint<2>
  }
}

// All annotations are removed from the circuit.
// CHECK-LABEL: firrtl.circuit "InterfaceNode"
// CHECK-NOT: annotations
// CHECK-SAME: {

// The Grand Central annotation is removed from the node.
// CHECK: firrtl.node
// CHECK-SAME: annotations = [{a}]

// CHECK: sv.interface @Foo
// CHECK-NEXT: sv.verbatim "\0A// some expression"
// CHECK-NEXT: sv.interface.signal @foo : i2

// -----

firrtl.circuit "InterfacePort" attributes {
  annotations = [
    {class = "sifive.enterprise.grandcentral.AugmentedBundleType",
     defName = "Foo",
     elements = [
       {description = "description of foo",
        name = "foo",
        tpe = "sifive.enterprise.grandcentral.AugmentedGroundType"}]}]} {
  firrtl.module @InterfacePort(in %a : !firrtl.uint<4>) attributes {
    portAnnotations = [[
      {a},
      {class = "sifive.enterprise.grandcentral.AugmentedGroundType",
       defName = "Foo",
       name = "foo",
       target = []}]] } {
  }
}

// All annotations are removed from the circuit.
// CHECK-LABEL: firrtl.circuit "InterfacePort"
// CHECK-NOT: annotations
// CHECK-SAME: {

// The Grand Central annotations are removed.
// CHECK: firrtl.module @InterfacePort
// CHECK-SAME: firrtl.annotations = [{a}]

// CHECK: sv.interface @Foo
// CHECK-NEXT: sv.verbatim "\0A// description of foo"
// CHECK-NEXT: sv.interface.signal @foo : i4

// -----

firrtl.circuit "UnsupportedTypes" attributes {
  annotations = [
    {a},
    {class = "sifive.enterprise.grandcentral.AugmentedBundleType",
     defName = "Foo",
     elements = [
       {name = "string",
        tpe = "sifive.enterprise.grandcentral.AugmentedStringType"},
       {name = "boolean",
        tpe = "sifive.enterprise.grandcentral.AugmentedBooleanType"},
       {name = "integer",
        tpe = "sifive.enterprise.grandcentral.AugmentedIntegerType"},
       {name = "double",
        tpe = "sifive.enterprise.grandcentral.AugmentedDoubleType"}]}]} {
  firrtl.module @UnsupportedTypes() {}
}

// All Grand Central annotations are removed from the circuit.
// CHECK-LABEL: firrtl.circuit "UnsupportedTypes"
// CHECK-SAME: annotations = [{a}]

// CHECK: sv.interface @Foo
// CHECK-NEXT: sv.verbatim "// string = <unsupported string type>;"
// CHECK-NEXT: sv.verbatim "// boolean = <unsupported boolean type>;"
// CHECK-NEXT: sv.verbatim "// integer = <unsupported integer type>;"
// CHECK-NEXT: sv.verbatim "// double = <unsupported double type>;"

// -----

firrtl.circuit "BindTest" attributes {
  annotations = [
    {class = "sifive.enterprise.grandcentral.AugmentedBundleType",
     defName = "Foo",
     elements = []}]} {
  firrtl.module @Companion() attributes {
    annotations = [
      {class = "sifive.enterprise.grandcentral.ViewAnnotation",
       defName = "Foo",
       id = 42 : i64,
       type = "companion"}]} {}
  firrtl.module @BindTest() {
    firrtl.instance @Companion { name = "companion1" }
    firrtl.instance @Companion { name = "companion2" }
  }
}

// CHECK-LABEL: firrtl.circuit "BindTest"

// Annotations are remove from the companion module declaration.
// CHECK: firrtl.module @Companion()
// CHECK-NOT: annotations
// CHECK-SAME: {

// Each companion instance has "lowerToBind" set.
// CHECK: firrtl.module @BindTest
// CHECK-COUNT-2: firrtl.instance @Companion {lowerToBind = true

// -----

firrtl.circuit "BindInterfaceTest"  attributes {
  annotations = [{
    class = "sifive.enterprise.grandcentral.AugmentedBundleType",
    defName = "InterfaceName",
    elements = [{
      name = "_a",
      tpe = "sifive.enterprise.grandcentral.AugmentedGroundType"
    }]
  }]} {
  firrtl.module @BindInterfaceTest(
    in %a: !firrtl.uint<8>, out %b: !firrtl.uint<8>) attributes {
      annotations = [{
        class = "sifive.enterprise.grandcentral.ViewAnnotation",
        defName = "InterfaceName",
        id = 0 : i64,
        name = "instanceName",
        type = "parent"
      }],
      portAnnotations = [[
        #firrtl.subAnno<fieldID = 0, {
          class = "sifive.enterprise.grandcentral.AugmentedGroundType",
          defName = "InterfaceName",
          name = "_a"}>
      ], []
      ]
    }
      {
    firrtl.connect %b, %a : !firrtl.uint<8>, !firrtl.uint<8>
  }
}

// The bind is dropped in the outer module, outside the circuit.
// CHECK: module {
// CHECK-NEXT: sv.bind.interface @[[INTERFACE_INSTANCE_SYMBOL:.+]] {output_file

// CHECK-LABEL: firrtl.circuit "BindInterfaceTest"

// Annotations are removed from the circuit.
// CHECK-NOT: annotations
// CHECK-SAME: {

// Annotations are removed from the module.
// CHECK-NEXT: firrtl.module @BindInterfaceTest
// CHECK-NOT: annotations
// CHECK-SAME: %a

// An instance of the interface was added to the module.
// CHECK: sv.interface.instance sym @[[INTERFACE_INSTANCE_SYMBOL]] {
// CHECK-SAME: doNotPrint = true

// The interface is added.
// CHECK: sv.interface @InterfaceName {
// CHECK-NEXT: sv.interface.signal @_a : i8


// -----

  firrtl.circuit "GCTDataTap"  attributes {annotations = [{blackBox = "~GCTDataTap|DataTap", class = "sifive.enterprise.grandcentral.DataTapsAnnotation", keys = [{class = "sifive.enterprise.grandcentral.ReferenceDataTapKey", portName = "~GCTDataTap|DataTap>_0", source = "~GCTDataTap|GCTDataTap>r"}, {class = "sifive.enterprise.grandcentral.ReferenceDataTapKey", portName = "~GCTDataTap|DataTap>_1[0]", source = "~GCTDataTap|GCTDataTap>r"}, {class = "sifive.enterprise.grandcentral.ReferenceDataTapKey", portName = "~GCTDataTap|DataTap>_2", source = "~GCTDataTap|GCTDataTap>w.a"}, {class = "sifive.enterprise.grandcentral.ReferenceDataTapKey", portName = "~GCTDataTap|DataTap>_3[0]", source = "~GCTDataTap|GCTDataTap>w.a"}, {class = "sifive.enterprise.grandcentral.DataTapModuleSignalKey", internalPath = "baz.qux", module = "~GCTDataTap|BlackBox", portName = "~GCTDataTap|DataTap>_4"}, {class = "sifive.enterprise.grandcentral.DataTapModuleSignalKey", internalPath = "baz.quz", module = "~GCTDataTap|BlackBox", portName = "~GCTDataTap|DataTap>_5[0]"}, {class = "sifive.enterprise.grandcentral.DeletedDataTapKey", portName = "~GCTDataTap|DataTap>_6"}, {class = "sifive.enterprise.grandcentral.DeletedDataTapKey", portName = "~GCTDataTap|DataTap>_7[0]"}, {class = "sifive.enterprise.grandcentral.LiteralDataTapKey", literal = "UInt<16>(\22h2a\22)", portName = "~GCTDataTap|DataTap>_8"}, {class = "sifive.enterprise.grandcentral.LiteralDataTapKey", literal = "UInt<16>(\22h2a\22)", portName = "~GCTDataTap|DataTap>_9[0]"}]}, {class = "circt.testNT", unrelatedAnnotation}]}  {
    firrtl.extmodule @DataTap(out %_0: !firrtl.uint<1>, out %_1: !firrtl.vector<uint<1>, 1>, out %_2: !firrtl.uint<1>, out %_3: !firrtl.vector<uint<1>, 1>, out %_4: !firrtl.uint<1>, out %_5: !firrtl.vector<uint<1>, 1>, out %_6: !firrtl.uint<1>, out %_7: !firrtl.vector<uint<1>, 1>, out %_8: !firrtl.uint<1>, out %_9: !firrtl.vector<uint<1>, 1>) attributes {defname = "DataTap"}
    firrtl.extmodule @BlackBox() attributes {defname = "BlackBox"}
    firrtl.module @GCTDataTap(in %clock: !firrtl.clock, in %reset: !firrtl.uint<1>, in %a: !firrtl.uint<1>, out %b: !firrtl.uint<1>) {
      %r = firrtl.reg %clock  : !firrtl.uint<1>
      %w = firrtl.wire  : !firrtl.bundle<a: uint<1>>
      %DataTap__0, %DataTap__1, %DataTap__2, %DataTap__3, %DataTap__4, %DataTap__5, %DataTap__6, %DataTap__7, %DataTap__8, %DataTap__9 = firrtl.instance @DataTap  {name = "DataTap"} : !firrtl.uint<1>, !firrtl.vector<uint<1>, 1>, !firrtl.uint<1>, !firrtl.vector<uint<1>, 1>, !firrtl.uint<1>, !firrtl.vector<uint<1>, 1>, !firrtl.uint<1>, !firrtl.vector<uint<1>, 1>, !firrtl.uint<1>, !firrtl.vector<uint<1>, 1>
      firrtl.instance @BlackBox  {name = "BlackBox"}
    }
  }

// -----

  firrtl.circuit "GCTMemTap"  attributes {annotations = [{class = "sifive.enterprise.grandcentral.MemTapAnnotation", source = "~GCTMemTap|GCTMemTap>mem", taps = ["GCTMemTap.MemTap.mem[0]", "GCTMemTap.MemTap.mem[1]"]}, {class = "circt.testNT", unrelatedAnnotation}]}  {
    firrtl.extmodule @MemTap(out %mem: !firrtl.vector<uint<1>, 2>) attributes {defname = "MemTap"}
    firrtl.module @GCTMemTap(in %clock: !firrtl.clock, in %reset: !firrtl.uint<1>) {
      %mem = firrtl.cmem  {name = "mem"} : !firrtl.vector<uint<1>, 2>
      %MemTap_mem = firrtl.instance @MemTap  {name = "MemTap"} : !firrtl.vector<uint<1>, 2>
      %0 = firrtl.subindex %MemTap_mem[0] : !firrtl.vector<uint<1>, 2>
      %1 = firrtl.subindex %MemTap_mem[1] : !firrtl.vector<uint<1>, 2>
      %memTap = firrtl.wire  : !firrtl.vector<uint<1>, 2>
      %2 = firrtl.subindex %memTap[0] : !firrtl.vector<uint<1>, 2>
      %3 = firrtl.subindex %MemTap_mem[0] : !firrtl.vector<uint<1>, 2>
      firrtl.connect %2, %3 : !firrtl.uint<1>, !firrtl.uint<1>
      %4 = firrtl.subindex %memTap[1] : !firrtl.vector<uint<1>, 2>
      %5 = firrtl.subindex %MemTap_mem[1] : !firrtl.vector<uint<1>, 2>
      firrtl.connect %4, %5 : !firrtl.uint<1>, !firrtl.uint<1>
    }
  }

// -----

  firrtl.circuit "GCTInterface"  attributes {annotations = [{class = "sifive.enterprise.grandcentral.GrandCentralView$SerializedViewAnnotation", companion = "~GCTInterface|view_companion", name = "view", parent = "~GCTInterface|GCTInterface", view = {class = "sifive.enterprise.grandcentral.AugmentedBundleType", defName = "ViewName", elements = [{description = "the register in GCTInterface", name = "register", tpe = {class = "sifive.enterprise.grandcentral.AugmentedBundleType", defName = "register", elements = [{name = "_2", tpe = {class = "sifive.enterprise.grandcentral.AugmentedVectorType", elements = [{class = "sifive.enterprise.grandcentral.AugmentedGroundType", ref = {circuit = "GCTInterface", component = [{class = "firrtl.annotations.TargetToken$Field", value = "_2"}, {class = "firrtl.annotations.TargetToken$Index", value = 0 : i64}], module = "GCTInterface", path = [], ref = "r"}, tpe = {class = "sifive.enterprise.grandcentral.GrandCentralView$UnknownGroundType$"}}, {class = "sifive.enterprise.grandcentral.AugmentedGroundType", ref = {circuit = "GCTInterface", component = [{class = "firrtl.annotations.TargetToken$Field", value = "_2"}, {class = "firrtl.annotations.TargetToken$Index", value = 1 : i64}], module = "GCTInterface", path = [], ref = "r"}, tpe = {class = "sifive.enterprise.grandcentral.GrandCentralView$UnknownGroundType$"}}]}}, {name = "_0", tpe = {class = "sifive.enterprise.grandcentral.AugmentedBundleType", defName = "_0", elements = [{name = "_1", tpe = {class = "sifive.enterprise.grandcentral.AugmentedGroundType", ref = {circuit = "GCTInterface", component = [{class = "firrtl.annotations.TargetToken$Field", value = "_0"}, {class = "firrtl.annotations.TargetToken$Field", value = "_1"}], module = "GCTInterface", path = [], ref = "r"}, tpe = {class = "sifive.enterprise.grandcentral.GrandCentralView$UnknownGroundType$"}}}, {name = "_0", tpe = {class = "sifive.enterprise.grandcentral.AugmentedGroundType", ref = {circuit = "GCTInterface", component = [{class = "firrtl.annotations.TargetToken$Field", value = "_0"}, {class = "firrtl.annotations.TargetToken$Field", value = "_0"}], module = "GCTInterface", path = [], ref = "r"}, tpe = {class = "sifive.enterprise.grandcentral.GrandCentralView$UnknownGroundType$"}}}]}}]}}, {description = "the port 'a' in GCTInterface", name = "port", tpe = {class = "sifive.enterprise.grandcentral.AugmentedGroundType", ref = {circuit = "GCTInterface", component = [], module = "GCTInterface", path = [], ref = "a"}, tpe = {class = "sifive.enterprise.grandcentral.GrandCentralView$UnknownGroundType$"}}}]}}, {class = "circt.testNT", unrelatedAnnotation}]}  {
    firrtl.module @view_companion() {
      firrtl.skip
    }
    firrtl.module @GCTInterface(in %clock: !firrtl.clock, in %reset: !firrtl.uint<1>, in %a: !firrtl.uint<1>) {
      %r = firrtl.reg %clock  : !firrtl.bundle<_0: bundle<_0: uint<1>, _1: uint<1>>, _2: vector<uint<1>, 2>>
      firrtl.instance @view_companion  {name = "view_companion"}
    }
  }
// -----
  firrtl.circuit "Foo"  attributes {annotations = [{class = "sifive.enterprise.grandcentral.GrandCentralView$SerializedViewAnnotation", companion = "~Foo|Bar_companion", name = "Bar", parent = "~Foo|Foo", view = {class = "sifive.enterprise.grandcentral.AugmentedBundleType", defName = "View", elements = [{description = "a string", name = "string", tpe = {class = "sifive.enterprise.grandcentral.AugmentedStringType", value = "hello"}}, {description = "a boolean", name = "boolean", tpe = {class = "sifive.enterprise.grandcentral.AugmentedBooleanType", value = false}}, {description = "an integer", name = "integer", tpe = {class = "sifive.enterprise.grandcentral.AugmentedIntegerType", value = 42 : i64}}, {description = "a double", name = "double", tpe = {class = "sifive.enterprise.grandcentral.AugmentedDoubleType", value = 3.140000e+00 : f64}}]}}]}  {
    firrtl.extmodule @Bar_companion()
    firrtl.module @Foo() {
      firrtl.instance @Bar_companion  {name = "Bar_companion"}
    }
  }
