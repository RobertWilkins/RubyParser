
### copyright: Robert Wilkins, Newton North High School, class of 1984

THIS FILE, Nov 11, -> 1 proofread

def go(v=nil)
skip_space
a=false
if $tc>=$strm.size || $strm[$tc].type==:newline then return false end
if v.class==String || v.class==Token
  if v==$strm[$tc]
    a=$strm[$tc]
    $tc+=1
  end
elsif v.class==Symbol
  if v==$strm[$tc].type
    a=$strm[$tc]
    $tc+=1
  end
elsif v==nil
  if $strm[$tc].type != :newline && $strm[$tc].type != :space
    a=$strm[$tc]
    $tc+=1
  end
else raise
end
return a
end   # end def go()


def flush(v=nil)
if v==nil
  skip_space_and_newline
  return false
end
g=go(v)
if g
  skip_space_and_newline
end
return g
end   # end def flush()


def see(v=nil)
c=see_past_space
if c>=$strm.size || $strm[c].type==:newline then return false end
if v.class==String || v.class==Token
  return  v==$strm[c]  ? $strm[c] : false
elsif v.class==Symbol
  return  v==$strm[c].type  ? $strm[c] : false
elsif v==nil
  return  $strm[c]
else raise
end
end   # end def see()


def must(v  , fail: "Expecting value " )
# very specific use, no Symbol argument
if v.class!=String then raise end
skip_space
if $tc>=$strm.size then raise fail end
if $strm[$tc]!=v   then raise fail end
$tc+=1
end   # end def must()









