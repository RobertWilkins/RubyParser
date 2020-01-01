
### copyright: Robert Wilkins, Newton North High School, class of 1984

# typing in 2018 AND changes in Nov 2019


## for parsing COMPLEX assignment statement, each entry may be comma-list
class BigAss
def parse()  # BigAss < ParseNode
@under=[]
@assign_ops=[]
@composite_statement_rvalue = false
@parallel_assignment = false
get_more=true

while get_more
  inner_list=[]
  go_on=true
  while go_on
    if see_one_of("if","case","begin","while","for")
      inner_list << parse_if_case_begin_while_for()
      @composite_statement_rvalue = true
      go_on = false
      if inner_list.size!=1 || see_one_of(",","=","if","while") ||
                       see_one_of("+=","-=","*=","/=","%=","||=","&&=")
        raise
      end
    else
      inner_list << Expr.new.parse()
      go_on = flush(",")
      if go_on then @parallel_assignment=true end
    end
  end
  get_more = assignment_op()
  if get_more  
    @assign_ops << get_more
    flush()
    inner2 = []
    for g in inner_list
      inner2 << g.you_are_a_left_value()
    end
    @under << inner2
  else
    @under << inner_list
  end
end   # end outer while loop


if @under.size==1 && @under[0].size==1
  return @under[0][0]
elsif @under.size==1 && @under[0].size>1
  return CommaListExpression.new(@under[0])
end 

if @parallel_assignment || @composite_statement_rvalue 
  return self
else
  g=SmallAss.new
  g.under = @under.flatten(1)
  g.assign_ops = @assign_ops
  return g
end  

end    # end def parse - BigAss

## ABOVE FUNCTION, proofread once , Nov 17 2019 again proofed

#########################################################

class SmallAss
def parse()
@under = []
@assign_ops=[]
get_more = true
while get_more
  @under << Expr.new.parse()
  get_more = assignment_op()
  if get_more
    @assign_ops << get_more
    flush()
    @under[-1] = @under[-1].you_are_a_left_value()
  end
end
if @under.size==1 then return @under[0] end
return self
end   # end def parse - SmallAss

## above function , proofread once, Nov 17 2019 again proofed




