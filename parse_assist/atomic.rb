
### copyright: Robert Wilkins, Newton North High School, class of 1984

THIS FILE, Nov 11, 1 proofread

def atomic_token_with_plusminus(   fail: "  " )
skip_space
if $tc>=$strm.size then raise end
## if $strm[$tc]=="end" then raise end
if $strm[$tc].type==:str_lit || $strm[$tc].type==:num_lit || 
   $strm[$tc].type==:word
  $tc+=1
  return $strm[$tc-1]
end
if $strm[$tc]==":"
  if $tc+1>=$strm.size then raise end
  if $strm[$tc+1].type!=:word  then raise end
  v = Token.new(":"+$strm[$tc+1],:symbol)
  $tc+=2
  return v
end
if $strm[$tc]=="+" || $strm[$tc]=="-"
  if $tc+1>=$strm.size || $strm[$tc+1].type!=:num_lit  then raise end
  v = Token.new($strm[$tc]+$strm[$tc+1],:num_lit, signed: true)
  $tc+=2
  return v
end
if $strm[$tc]=="$" || $strm[$tc]=="@" || $strm[$tc]=="@@"
  if $tc+1>=$strm.size || $strm[$tc+1].type!=:word  then raise end
  v = Token.new($strm[$tc]+$strm[$tc+1], :varname)
  $tc+=2
  return v
end 
raise 
end     # end def atomic_token_with_plusminus()





def atomic_token?()
tc2=see_past_space
if tc2>=$strm.size     then return false end
## no that is not needed: end/if/else etc will be :keyword, not :word
## if $strm[tc2]=="end"   then return false end
return ($strm[tc2].type==:str_lit || $strm[tc2].type==:num_lit || 
        $strm[tc2].type==:word || 
        ($strm[tc2]==":" && tc2+1<$strm.size && $strm[tc2+1].type==:word) ||
        (($strm[tc2]=="$" || $strm[tc2]=="@" || $strm[tc2]=="@@") &&
          tc2+1<$strm.size && $strm[tc2+1].type==:word  )                    )
end      #end def atomic_token?()



def space_plusminus_number?()
tc2 = see_past_space
# there must be white space just before the +/- sign, that is important
if tc2==$tc  then return false end
if tc2+1>=$strm.size  then return false end
return (($strm[tc2]=="+" || $strm[tc2]=="-") && $strm[tc2+1].type==:num_lit)
end      #end def space_plusminus_number?()


def small_literal()
skip_space
if $tc>=$strm.size  then return false
if $strm[$tc].type==:str_lit || $strm[$tc].type==:num_lit
  $tc+=1
  return $strm[$tc-1]
elsif $strm[$tc]==":" && $tc+1<$strm.size && $strm[$tc+1].type==:word
  v = Token.new(":"+$strm[$tc+1],:symbol)
  $tc+=2
  return v
else 
  return false
end
end     #end def small_literal()



def small_literal?()
tc2 = see_past_space
if tc2>=$strm.size  then return false end
return ($strm[tc2].type==:str_lit || $strm[tc2].type==:num_lit ||
        ($strm[tc2]==":" && tc2+1<$strm.size && $strm[tc2+1].type==:word)  )
end      # end def small_literal?()



