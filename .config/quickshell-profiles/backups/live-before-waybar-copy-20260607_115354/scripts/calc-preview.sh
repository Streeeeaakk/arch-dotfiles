#!/usr/bin/env bash
set -euo pipefail

expr="${1:-}"

python - "$expr" <<'PY'
import ast
import math
import operator
import sys

expr = sys.argv[1].strip()

allowed_names = {
    "pi": math.pi,
    "e": math.e,
    "tau": math.tau,
    "sqrt": math.sqrt,
    "sin": math.sin,
    "cos": math.cos,
    "tan": math.tan,
    "log": math.log,
    "log10": math.log10,
    "abs": abs,
    "round": round,
    "floor": math.floor,
    "ceil": math.ceil,
}

ops = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
    ast.FloorDiv: operator.floordiv,
    ast.Mod: operator.mod,
    ast.Pow: operator.pow,
    ast.USub: operator.neg,
    ast.UAdd: operator.pos,
}

def eval_node(node):
    if isinstance(node, ast.Expression):
        return eval_node(node.body)

    if isinstance(node, ast.Constant):
        if isinstance(node.value, (int, float)):
            return node.value
        raise ValueError("Invalid value")

    if isinstance(node, ast.Name):
        if node.id in allowed_names:
            return allowed_names[node.id]
        raise ValueError("Unknown name")

    if isinstance(node, ast.BinOp):
        op = type(node.op)
        if op not in ops:
            raise ValueError("Invalid operator")
        return ops[op](eval_node(node.left), eval_node(node.right))

    if isinstance(node, ast.UnaryOp):
        op = type(node.op)
        if op not in ops:
            raise ValueError("Invalid operator")
        return ops[op](eval_node(node.operand))

    if isinstance(node, ast.Call):
        fn = eval_node(node.func)
        args = [eval_node(a) for a in node.args]
        return fn(*args)

    raise ValueError("Invalid expression")

try:
    if not expr:
        sys.exit(1)

    tree = ast.parse(expr.replace("^", "**"), mode="eval")
    result = eval_node(tree)

    if isinstance(result, float):
        if result.is_integer():
            print(int(result))
        else:
            print(f"{result:.10g}")
    else:
        print(result)

except Exception:
    sys.exit(1)
PY
