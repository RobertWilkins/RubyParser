
### copyright: Robert Wilkins, Newton North High School, class of 1984

Be careful here: these are very small and quick tokread functions from the 
final section of little black notepad, not yet finalized on paper, so typing 
maybe premature.
Make sure you back up the typed in TOKREAD files pretty soon.  :)

FROM SMALL BLACK NOTEPAD, near end of notepad

def skip_space()
while $tc<$strm.size && $strm[$tc].type==:space
  $tc+=1
end
end     # end def skip_space()


def see_past_space(where=nil)
c=where
if c==nil then c=$tc end
while c<$strm.size && $strm[c].type==:space
  c+=1
end
return c
end     # end def see_past_space()


# returns true if see newline character OR end of last line of file
def endline()
c = see_past_space
return c>=$strm.size || $strm[c].type==:newline
end     # end def endline()


def space_must( fail: "Expecting space char" )
if $tc>=$strm.size || $strm[$tc].type!=:space
  raise fail
end
skip_space
end     # end def space_must()


def space_cannot( fail: "Not expecting space char" )
if $tc<$strm.size && $strm[$tc].type==:space
  raise fail
end
end     # end def space_cannot()


def space_before()
return $tc>0 && $tc<$strm.size && $strm[$tc-1].type==:space
end     # end def space_before()


def space_after()
return $tc+1<$strm.size && $strm[$tc+1].type==:space
end     # end def space_after()


def space_after_then_newline()
c=$tc+1
if c>=$strm.size || $strm[c].type!=:space then return false end
while c<$strm.size && $strm[c].type==:space
  c+=1
end
return c<$strm.size && $strm[c].type==:newline
end     # end def space_after_then_newline
















