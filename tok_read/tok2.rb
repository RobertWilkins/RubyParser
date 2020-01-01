
### copyright: Robert Wilkins, Newton North High School, class of 1984

# THIS FILE, Nov 10 2018 -> 1 proofread
# THIS FILE, Nov 7 2019 -> proofread changes

## this version of tokenize uses regular expressions , and not InputString class
## (furthermore, changes and additions made in 2019 have not been made to the 
##  version of tokenize that uses InputString class, which means that other 
##  version is outdated )



# THIS FUNCTION, Nov 7 2019 proofread changes

def tokenize(s)   # here, use String, not InputString
  c=0             # and, hence, heavy use of regular expressions
  $tc=0
  $strm=[]
  inside_string = false     ##(this line Nov 2019)
  while c<s.length
    if /\A\s/ =~ s[c]
      if s[c]=="\n"
        $strm << Token.new("\n",:newline)
        c += 1
      else
        m = /\A[ \t\f\r]+/.match(s,c)
        if m==nil then raise end
        c = m.end(0)
        $strm << Token.new(" ",:space)
      end
##  elsif /\A['"]/ =~ s[c]            these FOUR lines replaced by below
##    str_tok , new_pos = get_string_token(s,c)
##    $strm << str_tok
##    c = new_pos


    #  add to tokenize() (Nov 2018, but typed Nov 2019)
    ## cannot have double quoted string inside #{..} expression
    ## cannot have { or } INSIDE #{..} (Ruby expr. embedded in str literal)
    elsif s[c]=="\""
      if inside_string      then raise end
      str_tok, c, embed_tok = get_string_token(s,c)
      $strm << str_tok
      if embed_tok
        inside_string = true
        $strm << embed_tok
      else
        inside_string = false
      end
    elsif s[c]=="\'"
      str_tok , c = get_singlequote_string(s,c)
      $strm << str_tok
      ## above 15 errata lines proofread

    ## THIS MAY BE A DUMB REGEXPR BUG    \.\d   vs s[c]    WTF?
    ## elsif /\A(\d)|(\.\d)/ =~ s[c]    i think this line is a bug
    ## elsif /\A(\d)|(\.\d)/ =~ s[c..c+1]  nah, too verbose
    elsif    /\A(\d)|(\.\d)/ =~ s[c,2]
      m = /\A(\d)*(\.)?(\d)*/.match(s,c)
      c2 = m.end(0)
      $strm << Token.new(s[c...c2],:num_lit)
      c = c2
    elsif /\A[A-Za-z_]/ =~ s[c]
      m = /\A(\w)+/.match(s,c)
      c2 = m.end(0)
      ## HERE IS ERRATA FROM OTHER PAGE
      w = s[c...c2]
      code = $keywords.key?(w) ? :keyword : :word
      $strm << Token.new(w,code)
      c = c2
    elsif $punctu_chars.key?(s[c])
      ## add to tokenize()      (Nov 2018, but typed Nov 2019)(6lines,proof=2)
      if s[c]=="/" && !numeric_operand_before?()
        regex , c2 = RegExpr.new.parse(s,c)
        t = Token.new(s[c...c2],:regexpr)
        t.tiny_parse = regex
        $strm << t
        c = c2


      elsif $punctu_triplets.key?(s[c,3])
        $strm << Token.new(s[c,3],:punctu)
        c += 3
      elsif $punctu_pairs.key?(s[c,2])
        $strm << Token.new(s[c,2],:punctu)
        c += 2


      ## add to tokenize      (Nov 2018, but typed Nov 2019) (12lines,proof=2)
      elsif s[c]=="{" && inside_string   then raise
      elsif s[c]=="}" && inside_string
        $strm << Token.new("}",:embed_code)
        c += 1
        str_tok, c, embed_tok = get_string_token(s,c,string_in_progress: true)
        $strm << str_tok
        if embed_tok
          $strm << embed_tok
          inside_string = true
        else 
          inside_string = false
        end



      elsif s[c]=="#"
        m = /\A#[^\n]*(\n)?/.match(s,c)
        if m==nil then raise end
        c = m.end(0)
      elsif s[c]=="\\" && c>0 && /\A[ \t\f\r]\\[\s]/.match(s,c-1)
        m = /\A([ \t\f\r]*)(#[^\n]*)?\n/.match(s,c+1)
        if m
          c = m.end(0)
          ## do not add extra space token, one should already be there
          if $strm.length<1 || $strm[-1].type!=:space then raise end 
        else
          c += 1
          $strm << Token.new("\\",:punctu)
        end
      else    # default case, simple single-char punctuation
        $strm << Token.new(s[c],:punctu)
        c += 1
      end
    else      # not punctuation character, hence illegal binary byte/char
      raise
    end 
  end         # end-huge while loop


end   #end-def tokenize() version with regular expressions
##     with numerous changes in November 2019, a year later
















#########################################################################

## if see "/"  , might be division operator
## is there arithmetic operand before that?    (on same line)
def numeric_operand_before?()
tc2 = $strm.size-1
while tc2>=0 && $strm[tc2]==" "   do tc2-=1 end
if tc2<0 || $strm[tc2]=="\n"   then return false end
return $strm[tc2].type==:word || $strm[tc2].type==:num_lit ||
       $strm[tc2]==")" || $strm[tc2]=="}" || $strm[tc2]=="]"  ||
       $strm[tc2]=="end" || $strm[tc2]=="self"
end          
## if this function returns false, treat "/" as start of regular expression
## above small function - proofread twice


#########################################################################


def get_string_token(s,k,string_in_progress: false)
collect = []
d1=d2=nil
embed_tok=nil
if !string_in_progress
  if s[k]!="\"" then raise end
  d1 = "\""
  k+=1
end

while k<s.size && s[k]!="\"" && s[k..k+1]!="\#{"
  if s[k]=="\\"
    if k+1>=s.size then raise end
    if $std_escapes.key?(s[k+1])
      collect << $std_escapes[s[k+1]]
      k+=2
    else   ## this is fudge, maybe raise instead
      collect << "\\"
      k+=1
    end
  else
    collect << s[k]
    k+=1
  end
end     #end while loop

if k>=s.size then raise end
if s[k]=="\""
  d2 = "\""
  k+=1
elsif s[k..k+1]=="\#{"
  k+=2
  embed_tok = Token.new("\#{",:embed_code)
else
  raise
end

## to avoid SUBTLE bug, string literal must retain double quotes, 
##   even if not in text, to distinguish from word/keyword tokens
tok = Token.new( "\"" + collect.join() + "\"" , :str_lit)
tok.delimiters = [d1,d2]
tok.quote_type = "\""
return tok, k, embed_tok

end      #end def get_string_token()

## single-quote str literal has it's own function, not this one
# ABOVE FUNCTION PROOF = 2, BUT DO another read of logic
# that third read (read of logic) done, found small typo

##################################################################

def get_singlequote_string(s,k)
collect=[]   

if s[k]!="\'"      then raise end
k+=1

while k<s.size && s[k]!="\'"
  if s[k]=="\\"
    if k+1>=s.size     then raise end
    if s[k+1]=="\\"
      collect << "\\"
      k+=2
    elsif s[k+1]=="\'"
      collect << "\'"
      k+=2
    else
      collect << "\\"
      k+=1
    end
  else
    collect << s[k]
    k+=1
  end
end           ## end while loop

if k>=s.size     then raise end
if s[k]!="\'"    then raise end
k+=1

tok = Token.new( "\'" + collect.join() + "\'" , :str_lit)
tok.delimiters = ["\'","\'"]
tok.quote_type = "\'"

return tok, k

end     # end def get_singlequote_string

## ABOVE QUICKIE FUNCTION NEEDS REVIEW  <- Nov 15 2019, looks good









