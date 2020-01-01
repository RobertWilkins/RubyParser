
### copyright: Robert Wilkins, Newton North High School, class of 1984

class UnaryOpExpr
def parse()
flush()
p = see()
if    p=="!"    then g = ExclamExpr.new
elsif p=="~"    then g = TildaExpr.new
elsif p=="+"    then g = UnaryPlus.new
elsif p=="-"    then g = UnaryMinus.new
else        return ExponentExpr.new.parse()
end

p2 = go(p)
if p!=p2   then raise end
if endline then raise end
p3 = see()
if p3=="!" || p3=="~" || p3=="+" || p3=="-"
  g.under = UnaryOpExpr.new.parse()
else
  g.under = ExponentExpr.new.parse()
end
return g
end       # end - def parse() - UnaryOpExpr
#### above fctn, proof=once Nov 24


class ExponentExpr
def parse()
g1 = TermExpr.new.parse()
if see("**")
  @under << g1
  while see("**")
    flush("**")
    @under << TermExpr.new.parse()
  end
  return self
else
  return g1
end
end       #end - def parse() - ExponentExpr
#### not yet proofed


###########################################################################


###########################################################################


class PlusMinusExpr
def parse()
g1 = MultDivExpr.new.parse()
if ( p=see_one_of("+","-") )
  @under << g1
  while p
    p2 = flush(p)
    if p2!="+" && p2!="-"   then raise end
    @under_ops << p2
    @under << MultDivExpr.new.parse()
    p = see_one_of("+","-")
  end
  return self
else 
  return g1
end
end        #end def parse() - PlusMinusExpr
#### above function, proof=twice, Nov 24 2019

############################################################################


class MultDivExpr
def parse()
g1 = UnaryOpExpr.new.parse()
if ( p=see_one_of("*","/","%") )
  @under << g1
  while p
    p2 = flush(p)
    @under_ops << p2
    @under << UnaryOpExpr.new.parse()
    p = see_one_of("*","/","%")
  end
  return self
else 
  return g1
end
end        #end def parse() - MultDivExpr


############################################################################


class ShiftExpr
def parse()
g1 = PlusMinusExpr.new.parse()
if ( p=see_one_of("<<",">>") )
  @under << g1
  while p
    p2 = flush(p)
    @under_ops << p2
    @under << PlusMinusExpr.new.parse()
    p = see_one_of("<<",">>")
  end
  return self
else 
  return g1
end
end        #end def parse() - ShiftExpr


############################################################################


class LessGreaterExpr
def parse()
g1 = ShiftExpr.new.parse()
p = see_one_of("<=","<",">",">=")
if ( p )
  @under << g1
  @under_operand = p
  flush(p)
  @under << ShiftExpr.new.parse()
  return self
else
  return g1
end
end             # end def parse() - LessGreaterExpr
## above function, Nov 24 2019, proof=once


############################################################################


class EqualityExpr
def parse()
g1 = LessGreaterExpr.new.parse()
p = see_one_of("==","!=","===","!==")    CHECK THE BOOK FOR OPERATORS
if ( p )
  @under << g1
  @under_operand = p
  flush(p)
  @under << LessGreaterExpr.new.parse()
  return self
else
  return g1
end
end             # end def parse() - EqualityExpr


##########################################################################


class AndBoolExpr
def parse()
g1 = EqualityExpr.new.parse()
if ( p=see("&&") )
  @under << g1
  while ( p=see("&&") )
    flush(p)
    @under << EqualityExpr.new.parse()
  end
  return self
else
  return g1
end
end             # end def parse() - AndBoolExpr
## above function, Nov 24 2019, proof=once

##########################################################################


class OrBoolExpr
def parse()
g1 = AndBoolExpr.new.parse()
if ( p=see("||") )
  @under << g1
  while ( p=see("||") )
    flush(p)
    @under << AndBoolExpr.new.parse()
  end
  return self
else
  return g1
end
end             # end def parse() - OrBoolExpr


##########################################################################


class RangeExpr
def parse()
g1 = OrBoolExpr.new.parse()
p = see_one_of("..","...")
if ( p )
  @under << g1
  @under_operand = p
  flush(p)
  @under << OrBoolExpr.new.parse()
  return self
else
  return g1
end
end             # end def parse() - RangeExpr


#########################################################################


class TernaryOpExpr
def parse()
g1 = RangeExpr.new.parse()
if ( p=see("?") )
  @under << g1
  flush(p)
  @under << RangeExpr.new.parse()
  if !flush(":")     then raise end
  @under << RangeExpr.new.parse()
  return self
else
  return g1
end
end                 # end def parse() - TernaryOpExpr









