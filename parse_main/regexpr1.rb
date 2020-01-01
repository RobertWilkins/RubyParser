
### copyright: Robert Wilkins, Newton North High School, class of 1984

def region_parse(sep,s,k)

end_sep =   sep=="(" ? ")" : "/"
if k>=s.size || s[k]=="|" || s[k]==end_sep then raise end

while true
  items = []
  if k<s.size && s[k]=="^" 
    items << RegExAtom.new("^")
    k += 1
  end
  if k<s.size && s[k,2]=="\\A"
    items << RegExAtom.new("\\A")
    k += 2
  end
  while k<s.size && s[k]!="|" && s[k]!=end_sep
    g = RegExAtom.new
    if s[k] =~ /[.(\\\[]/
      if s[k]=="[" then g.atom , k = CharClass.new.parse(s,k) end
      elsif s[k]=="(" then g.atom, k = RegExpParenGrp.new.parse(s,k) end
      elsif s[k]=="." then g.atom = s[k] ; k+=1 end 
      elsif s[k]=="\\"
        if k+1 >= s.size then raise end
        if s[k+1] =~ /[dswDSWRnfrtbveaBzZ]/ then g.atom = s[k,2] ; k+= 2
        elsif s[k+1] =~ /\d/ then g.atom = NameAccess_AsDigit.new(s[k+1]) ; k+=2
        elsif s[k+1]=="k"
          if k+4 >= s.size then raise end
          m = /\A\<[A-Za-z_]\w*\>/.match(s,k+2)
          if m==nil then raise end
          c=m.end(0)
          g.atom = NameAccess.new(s[k+3..c-2])
          k=c
        elsif $RegExpMetaChars.key?(s[k+1]) then g.atom=s[k,2] ; k+=2
        else raise            # binary char or unnecessary backslash
        end
      else raise              # BUG, should never execute, has to be [.(\
      end
    else                      # not .(\[ and also not "|" and not end_sep
      if $RegExpNotMetaChars.key?(s[k]) then g.atom=s[k] ; k+=1
      else raise    
      # has to be letter,digit, or punctu char that does not need to be escaped
      end 
    end

# above page : proofread=once, Nov 15 2019, proofread again
#  at this point, still inside WHILE LOOP ( not | and not end_sep )
# SECOND PAGE TYPE HERE 
    if k<s.size && s[k]=~ /[*+?]/ then g.quantifier=s[k] ; k+=1
    elsif k+2 < s.size && s[k]=="{"
      v1=nil  ;v2=nil  ;pair=false  ;k+=1
      if s[k] =~ /\d/
        m = /\A\d+/.match(s,k)
        c = m.end(0)
        v1 = Integer(s[k...c])
        k=c
      end
      if k<s.size && s[k]=="," then pair=true ; k+=1 end
      if s[k] =~ /\d/
        m = /\A\d+/.match(s,k)
        c = m.end(0)
        v2 = Integer(s[k...c])
        k=c
      end
      if k>=s.size || s[k]!="}" then raise end
      k += 1
      if pair then 
         g.quantifier=[v1,v2]
         if v1==nil && v2==nil then raise end
      elsif v1!=nil then g.quantifier=v1
      else raise
      end
    end
    if k<s.size && (s[k]=="?" || s[k]=="+")
      g.quantifier2 = s[k]   
      k+=1
    end
    items << g
  end   # end large while loop (s[k]!="|" && s[k]!=end_sep)
  @or_regions << items
  if k>=s.size then raise end
  if s[k]=="|" then k+=1
  elsif s[k]==end_sep then break 
  else raise
  end
end   # end VERY LARGE WHILE LOOP (while true)

return k
end  #end-def    and: do not move past ) or / 

# above page: proofread=once 
# above page, and above function, proofread again, Nov 15 2019

############################################################################
############################################################################

class RegExpr
def parse(s,k)
if k>=s.size || s[k]!="/"   then raise end
k+=1                          # move past opening forward slash
k = region_parse("/",s,k)
# region_parse is instance method for class that is parent of both
#                               RegExpr and RegExpParenGrp (or imported module)
if !(k<s.size && s[k]=="/")    then raise end
k+=1
return self, k
end              #end def parse() for RegExpr
# proofread once, Nov 15 2019

class RegExpParenGrp
def parse(s,k)
if k>=s.size || s[k]!="("   then raise end
k+=1                          # move past opening left parenthesis

if k+3<s.size && ( m=/\A\?\<[A-Za-z_]\w*\>/.match(s,k) )
  c = m.end(0)
  @name = s[k+2..c-2]
  k=c
end

k = region_parse("(",s,k)
if !(k<s.size && s[k]==")")    then raise end
k+=1
return self, k
end              #end def parse() for RegExpParenGrp
# proofread once, Nov 15 2019

#########################################################################


class CharClass
def parse(s,k)
if k+3>=s.size      then raise end
if s[k]!="["        then raise end
k+=1             # move past opening [
items = []
if s[k]=="^" 
  items << "^"
  k+=1
end 

while k<s.size && s[k]!="]"
  if k+2<s.size && s[k+1]=="-" && /\w/=~s[k] && /\w/=~s[k+2]
    items << s[k,3]
    k+=3
  elsif s[k]=="\\"
    if k+1>=s.size     then raise end
    if s[k+1] =~ /[dswDSWRnfrtbvea]/
      items << s[k,2]
      k+=2
    elsif $RegExpMetaChars.key?(s[k+1])
      items << s[k,2]
      k+=2
    else
      items << "\\"
      k+=1
    end
  else 
    if $RegExpWhatever_Chars.key?(s[k])
      items << s[k]
      k+=1
    else
      raise
    end
  end
end         # end while loop

if k>=s.size || s[k]!="]"  then raise end
k+=1

@entries = items
return self, k
end              # end def parse() CharClass
## Nov 15 2019, proofread once 




