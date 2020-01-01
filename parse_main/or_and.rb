
### copyright: Robert Wilkins, Newton North High School, class of 1984

class OrAndMaster
def parse()
flush()
if see_one_of("not","return","break","next","redo")
    return OrAndExpr.new.parse()
end

g = BigAss.new.parse()

if g.class==BigAss
  if see_one_of("or","and")    then raise end
  return g
end

if ( p=see_one_of("or","and") )
  h = OrAndExpr.new
  h.under << g
  while p
    p2 = flush(p)
    h.under_ops << p2
    if see_one_of("return","break","next","redo")
      h.under << ReturnBreak.new.parse()
      if see_one_of("or","and")   then raise end
    else
      h.under << NotExpr.new.parse()
    end
    p = see_one_of("or","and")
  end
  return h
else
  return g
end

end         # end def parse() OrAndMaster
## above parse() proof=once(Nov 17 2019)


##########################################################################



class OrAndExpr
def parse()
flush()
if see_one_of("return","break","next","redo")
  if currently_any_subclause?()     then raise end
  g = ReturnBreak.new.parse()
  if see_one_of("or","and")         then raise end
  return g
end

g = NotExpr.new.parse()

if ( p=see_one_of("or","and") )
  @under << g
  while p
    p2 = flush(p)
    @under_ops << p2
    if see_one_of("return","break","next","redo")
      if currently_any_subclause?()    then raise end
      @under << ReturnBreak.new.parse()
      if see_one_of("or","and")       then raise end
    else
      @under << NotExpr.new.parse()
    end
    p = see_one_of("or","and")
  end
  return self
else 
  return g
end

end         ## end def parse() - OrAndExpr
## above parse function, proof=once, Nov 17 2019



#######################################################################



class NotExpr
def parse()
if see_one_of("return","break","next","redo")    then raise end
if see("not")
  flush("not")
  if see_one_of("return","break","next","redo")    then raise end
  @under = NotExpr.new.parse()
  return self
else
  return SmallAss.new.parse()
end
end             # end def parse() - NotExpr
## above Not parse function, proof=twice












