
### copyright: Robert Wilkins, Newton North High School, class of 1984

class Token
def you_are_a_left_value()
if @type==:varname
  if !(self.start_with?("$","@"))
      add_local_varname(self)
  end
  return self
elsif @type==:const_name
  return self
elsif @type==:word
  # not supposed to happen
  # TermExpr parse does not leave :word unclassified
  raise
else 
  raise
end
end       # end def you_are_a_left_value() - Token





class MethodCall
def you_are_a_left_value()
## you sure about the following?? raise or return false?
if !legit_left_val_method_call?          then raise end
name = @method_name.chomp("=")
add_local_varname(name)
return Token.new(name,:varname)
## essentially, treat as a misclassification
## local variable name that was misclassified as a method invocation
end             # end def you_are_a_left_value() - MethodCall



THIS NEEDS REVIEW , ROLE OF @ruby_block
class MethodCall
def legit_left_val_method_call?()
return @omit_parens &&
       @under.empty?   &&           # don't worry :rval_tbd, doublecheck
       !(@ruby_block)  &&       huh, look at this???
       !(@method_name.end_with?("!","?","!=","?="))
end           # end def legit_left_val_method_call?()
      





class ChainExpr
def you_are_a_left_value()
if @type=="."
  if !(@right.legit_left_val_method_call?())    then raise end
  return self
elsif @type=="["
  return self
elsif @type=="::"
  return self
else
  raise
end 
end              # end def you_are_a_left_value() - ChainExpr
## because of way TermExpr-parse() done :
##    "::" -> has to be constant_name
##    "."  -> has to be MethodCall instance
##    "["  -> (OBVIOUSLY) is Array index reference 






