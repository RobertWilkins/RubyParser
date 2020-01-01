
### copyright: Robert Wilkins, Newton North High School, class of 1984

class TermExpr
def parse()    # TermExpr < ParseNode
carry=nil
flush()
if see("(") then return ParenExpr.new.parse end

if possible_variablename_or_methodname?
  if methodname_nospace_leftparen?
    carry = MethodCall.new.parse
  elsif local_varname_equal_sign? || 
        next_token_in_list_of_local_variable_names?  ||
        prefix_dollar_at_doubleat?
    carry = variable_name
  else 
    carry = MethodCall.new.parse
  end
else    # carry still == nil
  if see("::") || constant_name?
    if constant_name?  then carry=constant_name end
    while see("::")
      if (space_before && carry) || space_after then raise end
      node = ChainExpr.new
      node.type = go("::")
      node.left = carry
      if !constant_name? then raise end
      node.right = constant_name
      carry = node
    end

  elsif doublequote_string_literal?
    carry = StringWithEmbedded.new.parse
    if carry.class == StringWithEmbedded
      # at least for now, string with embedded code, require it be stand alone
      if see_one_of(".","[")    then raise end
      return carry
    end
  elsif small_literal?    then  carry = small_literal
  elsif see("[")          then  carry = ArrayLiteral.new.parse
  elsif see("{")          then  carry = HashLiteral.new.parse
  elsif reg_expression?   then  carry = reg_expression
  elsif see("yield")      then  carry = MethodCall.new.parse
  elsif see("self")       then  carry = go("self")
  elsif see("nil")        then  carry = go("nil")
  elsif see("true")       then  carry = go("true")
  elsif see("false")      then  carry = go("false")
  end
  if carry==nil then raise end
end   # end large if-else statement


while (g=see(".")) || (g=see("["))
  if space_before then raise end
  if g=="." && space_after && !space_after_then_newline then raise end
  node=ChainExpr.new
  node.type=g
  node.left=carry
  if g=="."
    flush(".")
    if constant_name? then raise end
    if !method_name? then raise end
    node.right = MethodCall.new.parse
    carry = node
  elsif g=="["
    flush("[")
    node.right = CommaList.new
    go_on=true
    $inside_invoke+=1
    while go_on
      node.right.under << Expr.new.parse
      go_on = flush(",")
    end
    $inside_invoke-=1
    flush()
    if !see("]") then raise end
    go("]")
    carry = node
  end
end    # end while loop

return carry
end      #end def parse() TermExpr

## above 2-page TermExpr parse(), Nov 17 2019, proof=once

#########################################################################
#########################################################################

class StringWithEmbedded
def parse()
s1 = go(:str_lit)
if !s1   then raise end
if $inside_string_context   then raise end
if !see("\#{")    then return s1 end
@under << s1
$inside_string_context = true
while go("\#{")
  @under << Expr.new.parse
  must("}")
  s2 = go(:str_lit)
  if !s2    then raise end
  @under << s2
end                        # must BEGIN with strliteral, even if empty
                           # must  END  with strliteral, even if empty
$inside_string_context = false
return self
end            # end def parse - StringWithEmbedded
## above function proof=once  




