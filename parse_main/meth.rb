
### copyright: Robert Wilkins, Newton North High School, class of 1984

class MethodDef
def parse()
@local_varnames = {}
@input_parameters = []
@statements = []
@special_opt = {}
@defaults = {}
@defaultexpr_keyword = {}
@block_type = :method_def

if $inside_def_args         then raise end
$stack.push(self)


#############################################################################

## parse early part of DEF     older code (Oct 2018)

must("def",fail: "")
space_must(fail: "")
if word_dot? || see("self")
  @prefix = go()
  if /\A[A-Z]/ !~ @prefix && @prefix!="self" then raise end 
  space_cannot(fail: "")
  must(".", fail: "")
  space_cannot(fail: "")
end
c = go(:punctu)
if c
  @method_name=c
  @redefinable_op=true
  if !$set_redefinable_ops.key?(c) then raise end
else
  @method_name = method_name_def()
end
register_as_def(@prefix,@method_name)
using_parens = see("(")
if using_parens then space_cannot(fail: "") end
if !using_parens
  while word?
    v=word
    add_local_varname(v)
    @input_parameters << v
    if go(",") then if !word? then raise end
    else break
    end
  end
  if !endline then raise end
else
  $inside_def_args = true
  parse_argument_list()
  $inside_def_args = false
end 

PROOFed once, above , Nov 15 2019, but more changes
not clear if this is end of def, after early part of def, must process 
body of method definition

##################################

while !seek_end_ensure_else_rescue?
  @statements << getST()
end
parse_rescue_else_ensure()
flush()
if !go("end")     then raise end
$stack.pop()
return self
end              # end def parse() - MethodDef



###########################################################################
###########################################################################


Both def parse and Ruby block parse will call this code section, 
   for  (arg,arg,arg)  or for  |arg,arg,arg ; arg|

def parse_argument_list()
sep = flush("(") || flush("|")
if sep=="(" then endsep=")"
elsif sep=="|" then endsep="|"
else raise
end
if go(endsep) then return end
@input_parameters=[]

go_on = word? || see("*") || see("**") || see("&")
while go_on
  if see("*") || see("**") || see("&")
    opt = go("*") || go("**") || go("&")
    if !word? then raise end
    v = word
    add_local_varname(v)
    @input_parameters << v
    @special_opt[v]=opt
  else
    if !word? then raise end
    v=word
    @input_parameters << v
    if see(":") || see("=")
      default_mode = flush(":") || flush("=")
      if default_mode==":" then @defaultexpr_keyword[v] = Expr.new.parse()
      else     @defaults[v] = Expr.new.parse()
      end
    end
    add_local_varname(v)
  end
  flush()
  go_on = flush(",")
end  # end while loop

if see(";") && @block_type==:ruby_block
  go(";")
  @local_to_block = []
  while word?
    @local_to_block << word
    if !go(",") then break end
  end
end

flush()
must(endsep, fail: "")

end   # end of def parse_argument_list()

### proofed above function once, Nov 15 2019, but ..
###  still establish where set/reset $inside_def_args, probably not here
###  still need to set @block_type flag
###  still transcribing code for parsing MethodDefn and RubyBlock


##########################################################################
##########################################################################


class RubyBlock
def parse()

@local_varnames = {}
@input_parameters = []
@statements = []
@special_opt = {}
@defaults = {}
@defaultexpr_keyword = {}
@block_type = :ruby_block
@local_to_block = []

a = flush("do") || flush("{")
if    a=="do" then fin = "end"
elsif a=="{"  then fin = "}"
else raise 
end
@block_style = a

if $inside_def_args    then raise end
@carry_over = $stack[-1].local_varnames.dup
$stack.push(self)

$inside_def_args = true
is see("|")
  parse_argument_list()
end
$inside_def_args = false

add_bunch_local_varnames(@carry_over,@input_parameters,@local_to_block)

while !seek_end_right_curlybracket?
  @statements << getST()
end
flush()
if !go(fin)    then raise end

$stack.pop()
return self
end              # end def parse() - RubyBlock













