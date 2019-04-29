require "minruby"

def evaluate(tree, genv, lenv)
  case tree
  in "lit", lit
    lit
  in "+", exp1, exp2
    evaluate(exp1, genv, lenv) + evaluate(exp2, genv, lenv)
  in "-", exp1, exp2
    evaluate(exp1, genv, lenv) - evaluate(exp2, genv, lenv)
  in "*", exp1, exp2
    evaluate(exp1, genv, lenv) * evaluate(exp2, genv, lenv)
  in "/", exp1, exp2
    evaluate(exp1, genv, lenv) / evaluate(exp2, genv, lenv)
  in "%", exp1, exp2
    evaluate(exp1, genv, lenv) % evaluate(exp2, genv, lenv)
  in "<", exp1, exp2
    evaluate(exp1, genv, lenv) < evaluate(exp2, genv, lenv)
  in "<=", exp1, exp2
    evaluate(exp1, genv, lenv) <= evaluate(exp2, genv, lenv)
  in "==", exp1, exp2
    evaluate(exp1, genv, lenv) == evaluate(exp2, genv, lenv)
  in "!=", exp1, exp2
    evaluate(exp1, genv, lenv) != evaluate(exp2, genv, lenv)
  in ">=", exp1, exp2
    evaluate(exp1, genv, lenv) >= evaluate(exp2, genv, lenv)
  in ">", exp1, exp2
    evaluate(exp1, genv, lenv) > evaluate(exp2, genv, lenv)
  in "stmts", *stmts
    last = nil
    i = 0
    while stmts[i]
      last = evaluate(stmts[i], genv, lenv)
      i = i + 1
    end
    last
  in "var_assign", var_name, var_value
    lenv[var_name] = evaluate(var_value, genv, lenv)
  in "var_ref", var_name
    lenv[var_name]
  in "if", cond, exp1, exp2
    if evaluate(cond, genv, lenv)
      evaluate(exp1, genv, lenv)
    else
      evaluate(exp2, genv, lenv)
    end
  in "while", cond, exp
    while evaluate(cond, genv, lenv)
      evaluate(exp, genv, lenv)
    end
  in "func_def", func_name, func_args, func_body
    genv[func_name] = ["user_defined", func_args, func_body]
  in "func_call", func_name, *func_args
    args = []
    i = 0
    while func_args[i]
      args[i] = evaluate(func_args[i], genv, lenv)
      i = i + 1
    end
    mhd = genv[func_name]
    if mhd[0] == "builtin"
      minruby_call(mhd[1], args)
    else
      new_lenv = {}
      params = mhd[1]
      i = 0
      while params[i]
        new_lenv[params[i]] = args[i]
        i = i + 1
      end
      evaluate(mhd[2], genv, new_lenv)
    end
  in "ary_new", ary_values
    ary = []
    i = 0
    while ary_values[i]
      ary [i] = evaluate(ary_values[i], genv, lenv)
      i = i + 1
    end
  in "ary_ref", ary_exp, idx_exp
    ary = evaluate(ary_exp, genv, lenv)
    idx = evaluate(idx_exp, genv, lenv)
    ary[idx]
  in "ary_assign", ary_exp, idx_exp, value_exp
    ary = evaluate(ary_exp, genv, lenv)
    idx = evaluate(idx_exp, genv, lenv)
    val = evaluate(value_exp, genv, lenv)
    ary[idx] = val
  in "hash_new", *key_values
    hsh = {}
    i = 0
    while key_values[i]
      key = evaluate(key_values[i], genv, lenv)
      val = evaluate(key_values[i + 1], genv, lenv)
      hsh[key] = val
      i = i + 2
    end
    hsh
  end
end

str = minruby_load()

tree = minruby_parse(str)

genv = {
  "p" => ["builtin", "p"],
  "require" => ["builtin", "require"],
  "minruby_parse" => ["builtin", "minruby_parse"],
  "minruby_load" => ["builtin", "minruby_load"],
  "minruby_call" => ["builtin", "minruby_call"],
}
lenv = {}
evaluate(tree, genv, lenv)
