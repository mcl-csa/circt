#include "circt/Dialect/Comb/CombOps.h"
#include "circt/Dialect/HIR/IR/HIR.h"
#include "circt/Dialect/HIR/IR/HIRDialect.h"
#include "circt/Dialect/HW/HWOps.h"
#include "circt/Dialect/SV/SVOps.h"

using namespace circt;

class FuncToHWModulePortMap {
public:
  void addFuncInput(StringAttr name, hw::PortDirection direction, Type type);
  void addFuncResult(StringAttr name, Type type);
  void addClk(OpBuilder &);
  ArrayRef<hw::PortInfo> getPortInfoList();
  const hw::PortInfo getPortInfoForFuncInput(size_t inputArgNum);

private:
  size_t hwModuleInputArgNum = 0;
  size_t hwModuleResultArgNum = 0;
  SmallVector<hw::PortInfo> portInfoList;
  SmallVector<hw::PortInfo> mapFuncInputToHWPortInfo;
};

Type convertToHWType(Type type);

bool isRecvBus(DictionaryAttr busAttr);

std::pair<SmallVector<Value>, SmallVector<Value>>
filterCallOpArgs(hir::FuncType funcTy, OperandRange args);

FuncToHWModulePortMap getHWModulePortMap(OpBuilder &builder,
                                         hir::FuncType funcTy,
                                         ArrayAttr inputNames,
                                         ArrayAttr resultNames);

Operation *getConstantX(OpBuilder *, Type);

ArrayAttr getHWParams(Attribute, bool ignoreValues = false);

Value getDelayedValue(OpBuilder *builder, Value input, int64_t delay,
                      Optional<StringRef> name, Location loc, Value clk);

Value convertToNamedValue(OpBuilder &builder, StringRef name, Value val);
Value convertToOptionalNamedValue(OpBuilder &builder, Optional<StringRef> name,
                                  Value val);
