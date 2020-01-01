
### copyright: Robert Wilkins, Newton North High School, class of 1984

THIS FILE, Nov 11 , 1 proofread

SMALL PARSE FUNCTIONS (close to level of tokens)
more specifically, those small parse functions related to parse of TermExpr

(you are still figuring out how to sort and organize tokread functions)


def possible_variablename_or_methodname?
tc2 = see_past_space
if tc2>=$strm.size then return false end 
if $strm[tc2]=="$" || $strm[tc2]=="@" || $strm[tc2]=="@@"
  if tc2+1 >= $strm.size then return false end
  if $strm[tc2+1].type == :word then return true
  else return false
  end
end

if $strm[tc2].type != :word then return false end
if /\A[A-Z]/ =~ $strm[tc] && !(tc2+1<$strm.size && $strm[tc2+1]=="(")
  return false
end
if $keywords.key?($strm[tc2]) then return false end
return true
end   # end def possible_variablename_or_methodname?



def methodname_nospace_leftparen?
tc2 = see_past_space
if tc2+1>=$strm.size then return false end
if $strm[tc2].type != :word  then return false end
if $strm[tc2+1] == "("  then return true end
if $strm[tc2+1] == "!" || $strm[tc2+1] == "?"
  if tc2+2 >= $strm.size then return false end
  if $strm[tc2+2] == "(" then return true
  else return false
  end
end
return false
end  # end def methodname_nospace_leftparen?


def local_varname_equal_sign?
tc2 = see_past_space
if tc2+1 >= $strm.size then return false end
if $strm[tc2].type != :word then return false end
if /\A[A-Z]/ =~ $strm[tc2] then return false end
tc2 = see_past_space(tc2+1)
if tc2 >= $strm.size then return false end
return ( $strm[tc2]=="=" )
end   # end def local_varname_equal_sign?


def prefix_dollar_at_doubleat?
tc2 = see_past_space
if tc2+1 >= $strm.size then return false end
if !($strm[tc2]=="$" || $strm[tc2]=="@" || $strm[tc2]=="@@") 
  return false
end
return ( $strm[tc2].type == :word )
end   # end def prefix_dollar_at_doubleat?


def constant_name?
tc2 = see_past_space
if tc2 >= $strm.size then return false end
return ($strm[tc2].type == :word  &&  /\A[A-Z]/ =~ $strm[tc2] &&
        !(tc2+1 < $strm.size && $strm[tc2+1] == "(" )            )
end   # end def constant_name?


def constant_name
skip_space
if $tc >= $strm.size then raise end
if $strm[$tc].type != :word then raise end
if /\A[A-Z]/ !~ $strm[$tc] then raise end
if $tc+1 < $strm.size && $strm[$tc+1]=="(" then raise end
$tc += 1
return Token.new($strm[$tc-1], :const_name)
end   # end def constant_name



#######################################################################

def variable_name()
# assume already determined it's not a constant name
# not a "small go" function 
# assume choice between variable name and method call already been made
skip_space
pre=""
if $tc>=$strm.size then raise end
if ["$","@","@@"].find_index($strm[$tc])
  pre = pre + $strm[$tc]
  $tc+=1
  if $tc>=$strm.size then raise end
end
if $strm[$tc].type!=:word  then raise end
txt = pre + $strm[$tc]
$tc+=1
return Token.new(txt,:varname)
end   # end def variable_name



def method_name_call
# for method call, not method definition, do not care about EQUAL token
skip_space
if $tc>=$strm.size then raise end
if $strm[$tc].type != :word then raise end
if ( /\A[A-Z]/ =~ $strm[$tc] && !($tc+2<$strm.size && $strm[$tc+1]=="("))
   raise
end
quasiword = $strm[$tc]
if $tc+1<$strm.size && ($strm[$tc+1]=="!" || $strm[$tc+1]=="?")
  quasiword += $strm[$tc+1]
  $tc += 2
else
  $tc += 1
end
return Token.new(quasiword,:methodname)
end     # end def method_name_call()



def method_name_def
skip_space
if $tc+1>=$strm.size then raise end
if $strm[$tc].type != :word then raise end
if ( /\A[A-Z]/ =~ $strm[$tc] && !($tc+2<$strm.size && $strm[$tc+1]=="("))
   raise
end
quasiword = $strm[$tc]
if /\A[!?=]\z/ =~ $strm[$tc+1]
  quasiword += $strm[$tc+1]
  $tc += 2
else
  $tc += 1
end
return Token.new(quasiword,:methodname)
end    # end def method_name_def()



# maybe should call this possible_method_name?
def method_name?
# used for invoke, not method definition, this really means 
#   possible_method_name
tc2 = see_past_space
if tc2 >= $strm.size then return false end
if $strm[tc2].type != :word then return false end
if ( /\A[A-Z]/ =~ $strm[tc2] && !(tc2+1<$strm.size && $strm[tc2]=="("))
    return false
end
return true
# does not distinguish between possible method name and possible variable name
# does not look up dictionary of known local variable names
end    # end def method_name?()










