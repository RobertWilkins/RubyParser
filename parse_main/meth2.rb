
### copyright: Robert Wilkins, Newton North High School, class of 1984

def parse()   # for MethodCall < ParseNode
if see("yield") then @method_name = go("yield")
else @method_name = method_name_call()
end
subclause = currently_for_while_subclause?()
ctr=0
@under=[]
if endline then return self end
@omit_parens = !flush("(")
if !@omit_parens
  go_on = !see(")")
  $inside_invoke += 1
  while go_on
    if word_colon?
      t = word
      flush(":")
      @keys[ctr] = t
      @input_arg_mode[ctr] = :key_value_pair
    elsif t = go("&") || go("*") || go("**")
      @input_arg_mode[ctr] = t
    else 
      @input_arg_mode[ctr] = nil
    end
    @under << Expr.new.parse() 
    flush()
    go_on = flush(",")
    ctr += 1
  end  # end while loop

  $inside_invoke -= 1
  if !go(")") then raise end
  if see("{") || (see("do") && !subclause)
    @ruby_block = RubyBlock.new.parse()
  end
  return self
end   # end section for parentheses NOT omitted


# for rest of code this parse function, @omit_parens is true
if atomic_token? || space_plusminus_number?
  go_on = true
  while go_on
    v = atomic_token_with_plusminus(fail: "Only simple input args, no parens")
    if v.type==:word 
      v = generic_word_clarify(v)
    end
    @under << v 
    go_on = go(",")
  end
  if !endline && !see(";") && !see("}") && !see("end")   && !see(")")  &&
      !see("if") && !see("unless") && !see("while") && !see("until") 
    raise
  end
  return self
end   # end section for: no parentheses and at least one input argument

if see("{") || (see("do") && !subclause)
  @ruby_block = RubyBlock.new.parse()
  return self
end
if see("=")
  if @method_name=="yield"  then raise end
  @method_name += "="
  ## @under << :rval_tbd , change, not needed flag with @see_equal_sign instead
  @see_equal_sign = true
  # let assignment parse code do that work, "=" token is not touched
  return self
end
return self
end   # end of def parse() < MethodCall

## above function proofed once, Nov 15 2019 (plus last year)
##   however, might be a few small changes yet to be added



#################################################################
#################################################################


class ReturnBreak
def parse()
## cannot do go(:keyword), go() does not work like that
@type = go()
@under = []
@omit_parens = !flush("(")

if !@omit_parens
  go_on = !see(")")
  $inside_invoke += 1
  while go_on
    @under << Expr.new.parse() 
    flush()
    go_on = flush(",")
  end
  $inside_invoke -= 1
  if !go(")") then raise end
  return self
end   # end section for parentheses NOT omitted

if atomic_token? || space_plusminus_number?
  go_on = true
  while go_on
    v = atomic_token_with_plusminus(fail: "Only simple input args, no parens")
    if v.type==:word 
      v = generic_word_clarify(v)
    end
    @under << v 
    go_on = go(",")
  end
  if !endline && !see_one_of(";","}","end","if","while",")")
    raise
  end
  return self
end   # end section for: no parentheses and at least one input argument

return self
end   # end def parse(), ReturnBreak

above function (returnbreak parse) proofread once
