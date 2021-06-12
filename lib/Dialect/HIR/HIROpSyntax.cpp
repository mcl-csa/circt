#include "HIROpSyntax.h"
#include "circt/Dialect/HIR/helper.h"

namespace helper {} // namespace helper.

// parser and printer for Time and offset.
ParseResult
parseTimeAndOffset(mlir::OpAsmParser &parser, OpAsmParser::OperandType &tstart,
                   llvm::Optional<OpAsmParser::OperandType> &varOffset,
                   IntegerAttr &constOffset) {
  OpAsmParser::OperandType tempOffset;

  constOffset = helper::getIntegerAttr(parser.getBuilder().getContext(), 32, 0);
  if (parser.parseOperand(tstart))
    return failure();

  // early exit if no offsets.
  if (parser.parseOptionalPlus())
    return success();

  // try to parse varOffset
  OptionalParseResult result = parser.parseOptionalOperand(tempOffset);
  if (result.hasValue() && succeeded(result.getValue()))
    varOffset = tempOffset;
  // otherwise constOffset
  else if (parser.parseAttribute(constOffset))
    return failure();

  return success();
}

void printTimeAndOffset(OpAsmPrinter &printer, Operation *op, Value tstart,
                        Value varOffset, IntegerAttr constOffset) {
  printer << tstart;

  if (varOffset)
    printer << "+" << varOffset;
  if (constOffset.getInt() != 0)
    printer << " + " << constOffset.getInt();
}

// parser and printer for array address indices.
ParseResult
parseOptionalArrayAccess(OpAsmParser &parser,
                         SmallVectorImpl<OpAsmParser::OperandType> &varAddrs,
                         ArrayAttr &constAddrs) {
  // If constAddr[i] is -ve then its an operand and the operand is at
  // varAddrs[-constAddr[i]-1], i.e. constAddr[i]>=0 is const and <0 is operand.
  llvm::SmallVector<Attribute, 4> tempConstAddrs;
  // early exit.
  if (parser.parseOptionalLSquare())
    return success();
  do {
    int val;
    OpAsmParser::OperandType var;
    OptionalParseResult result = parser.parseOptionalInteger(val);
    if (result.hasValue() && !result.getValue()) {
      tempConstAddrs.push_back(
          helper::getIntegerAttr(parser.getBuilder().getContext(), 32, val));
    } else if (!parser.parseOperand(var)) {
      varAddrs.push_back(var);
      tempConstAddrs.push_back(helper::getIntegerAttr(
          parser.getBuilder().getContext(), 32, -varAddrs.size()));
    } else
      return failure();
  } while (!parser.parseOptionalComma());
  constAddrs = ArrayAttr::get(parser.getBuilder().getContext(), tempConstAddrs);
  if (parser.parseRSquare())
    return failure();
  return success();
}

void printOptionalArrayAccess(OpAsmPrinter &printer, Operation *op,
                              OperandRange varAddrs, ArrayAttr constAddrs) {
  if (constAddrs.size() == 0)
    return;
  printer << "[";
  for (size_t i = 0; i < constAddrs.size(); i++) {
    int idx = constAddrs[i].dyn_cast<IntegerAttr>().getInt();
    if (i > 0)
      printer << ", ";
    if (idx >= 0)
      printer << idx;
    else
      printer << varAddrs[-idx - 1];
  }
  printer << "]";
}

// parser and printer for array address types.
ParseResult parseOptionalArrayAccessTypes(mlir::OpAsmParser &parser,
                                          ArrayAttr &constAddrs,
                                          SmallVectorImpl<Type> &varAddrTypes) {
  // Early exit if no address types.
  if (parser.parseOptionalLSquare())
    return success();
  // Parse the types list.
  int i = 0;
  do {
    int idx = constAddrs[i].dyn_cast<IntegerAttr>().getInt();
    i++;
    Type t;
    if (!parser.parseOptionalKeyword("const"))
      t = helper::getConstIntType(parser.getBuilder().getContext());
    else if (parser.parseType(t))
      return failure();

    if (idx < 0)
      varAddrTypes.push_back(t);
    else if (!t.isa<hir::ConstType>())
      return parser.emitError(parser.getCurrentLocation(),
                              "Expected const/!hir.const type");
  } while (!parser.parseOptionalComma());

  // Finish parsing.
  if (parser.parseRSquare())
    return failure();

  return success();
}

void printOptionalArrayAccessTypes(OpAsmPrinter &printer, Operation *op,
                                   ArrayAttr constAddrs,
                                   TypeRange varAddrTypes) {
  if (constAddrs.size() == 0)
    return;
  printer << "[";
  for (size_t i = 0; i < constAddrs.size(); i++) {
    if (i > 0)
      printer << ", ";
    int idx = constAddrs[i].dyn_cast<IntegerAttr>().getInt();
    if (idx >= 0)
      printer << "const";
    else if (varAddrTypes[-idx - 1].isa<hir::ConstType>())
      printer << "const";
    else
      printer << varAddrTypes[-idx - 1];
  }
  printer << "]";
}

ParseResult parseMemrefAndElementType(OpAsmParser &parser,
                                      OpAsmParser::OperandType mem,
                                      Type &memrefTy, Type &resTy) {
  if (parser.parseType(memrefTy))
    return failure();
  auto memTyLoc = parser.getCurrentLocation();
  auto memTy = memrefTy.dyn_cast<hir::MemrefType>();
  if (!memTy)
    return parser.emitError(memTyLoc, "Expected hir.memref type!");
  resTy = memTy.getElementType();
  return success();
}

void printMemrefAndElementType(OpAsmPrinter &printer, Operation *op, Value mem,
                               Type memrefTy, Type resTy) {
  printer << memrefTy;
}
