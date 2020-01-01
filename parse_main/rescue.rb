
### copyright: Robert Wilkins, Newton North High School, class of 1984

class BeginStatement
def parse()
@statements = []
must("begin")
flush()
while !seek_end_ensure_else_rescue?
  @statements << getST()
end
parse_rescue_else_ensure()
flush()
must("end")
return self
end         # end def BeginSt-parse


########################################################################


def parse_rescue_else_ensure()
@rescues = []
@else_statements = []
@ensure_statements = []
flush()
while go("rescue")
  r=Rescue.new
  r.error_classes = []
  r.statements = []
  r.error_varname = nil
  if see(:word)
    r.error_classes << SimpleChainExpr.new.parse
    while go(",")
        r.error_classes << SimpleChainExpr.new.parse
    end
  end
  if go("=>")
    c = go(:word)
    if !c    then raise end
    if /\A[a-z_]/ !~ c   then raise end
    r.error_varname = c
  end
  if !endline     then raise end
  flush()
  while !seek_end_ensure_else_rescue?
    r.statements << getST()
  end
  @rescue << r
  flush()
end          # end while go(rescue) loop

if go("else")
  flush()
  while !seek_end_ensure?
    @else_statements << getST()
  end
  flush()
end
if go("ensure")
  flush()
  while !seek_end?
    @ensure_statements << getST()
  end
  flush()
end
if !see("end")       then raise end
# do not move past "end" token
end     # end def parse_rescue_else_ensure()




############################################################################



class SimpleChainExpr
def parse()
@words = []
if !see(:word)    then raise end
@words << go(:word)
if see("::") && /\A[A-Z]/ !~ @words[0]      then raise end
while go("::")
  c = go(:word)
  if !c                  then raise end
  if /\A[A-Z]/ !~ c      then raise end
  @words << c
end
while go(".")
  c = go(:word)
  if !c                 then raise end
  if /\A[a-z_]/ !~ c    then raise end
  @words << c
end
return self
end          #end def parse() - SimpleChainExpr









