
### copyright: Robert Wilkins, Newton North High School, class of 1984

# getST() does not call DEF-parse(), cannot have DEF inside DEF
def getST()     # class? can just put in module and import it
flush()
if ( g=go(";"))   then return g end
if ( p=see_one_of("if","case","while","for","begin","unless","until") )
  if    p=="if" || p=="unless"    then h=IfStatement.new.parse
  elsif p=="while" || p=="until"  then h=WhileStatement.new.parse
  elsif p=="case"                 then h=CaseStatement.new.parse
  elsif p=="for"                  then h=ForStatement.new.parse
  elsif p=="begin"                then h=BeginStatement.new.parse
else
      h = OrAndMaster.new.parse
end
if ( p2=see_one_of("if","while","unless","until") )
  h.modifier_keyword = go(p2)
  h.modifier = ExprEq.new.parse
end

if go(";")  then return h      # move past semicolon (it's part of statement)
elsif endline
            flush()
            return h
elsif see_one_of("end","}",")","]")
            return h
else 
            raise    # see start of another statement on same line -> BAD!
end

end       # end def getST()






############################################################################
############################################################################

class CaseStatement
def parse()

@target = nil
@splat_index = {}
@expr = []
@statements = []
@else_st = []
must("case")
flush() 
if !see("when") then
  $inside_case_clause = true
  @target = Expr.new.parse
  $inside_case_clause = false
  flush()
end

while flush("when")
  go_on = true
  list_comp = [] 
  list_st = []
  while go_on
    if go("*")
      @splat_index[[@expr.size,list_comp.size]] = "*"
    end
    $inside_case_clause = true
    list_comp << Expr.new.parse
    $inside_case_clause = false
    go_on = flush(",")
  end
  @expr << list_comp
  must_then_or_newline()

  while !seek_end_else_when?
    list_st << getST()
  end
  @statements << list_st
end                      # end big while loop

if flush("else")
  while !seek_end?
    @else_st << getST()
  end
end

flush()
must("end")
return self
end           # end def parse() - CaseStatement
# above fctn, CaseSt , proof=once


#########################################################################
#########################################################################

class IfStatement
def parse()
@if_statements = []
@elsif_statements = []
@else_statements = []
@elsif_test = []
@if_or_unless = go(:keyword)
$inside_if_clause = true
@if_test = ExprEq.new.parse
$inside_if_clause = false
must_then_or_newline()
while !seek_end_else_elsif?
  @if_statements << getST()
end
flush()
while go("elsif")
  $inside_if_clause = true
  @elsif_test << ExprEq.new.parse
  $inside_if_clause = false
  list_st = []
  must_then_or_newline()
  while !seek_end_else_elsif?
    list_st << getST()
  end
  @elsif_statements << list_st
  flush()
end
if go("else")
  flush()
  while !seek_end?
    @else_statements << getST()
  end
end
flush()
must("end")
return self
end              # end def parse() - IfStatement



#########################################################################
#########################################################################


class ForStatement
def parse()
must("for")
if !see(:word)       then raise end
@loop_vars = []
@statements = []
@loop_vars << go(:word)
while go(",")
  v = go(:word)
  if !v    then raise end
  @loop_vars << v
end
must("in")
flush()
$inside_for_clause = true
@container = Expr.new.parse
$inside_for_clause = false

for v2 in @loop_vars
  add_local_varname(v2)
end
must_do_or_newline()
while !seek_end?
  @statements << getST()
end
flush()
must("end")
return self
end           # end def parse() - ForStatement


#########################################################################


class WhileStatement
def parse()
@while_statements = []
@while_or_until = go(:keyword)
$inside_while_clause = true
@while_test = ExprEq.new.parse
$inside_while_clause = false
must_do_or_newline()
while !seek_end?
  @while_statements << getST()
end
flush()
must("end")
return self
end              # end def parse() - WhileStatement





