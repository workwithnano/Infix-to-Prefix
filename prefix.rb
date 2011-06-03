class Prefixer
  
  def initialize(infix_expression,reduce=false,verbose=false)
    
    # Check for "-r" or "--reduce" flag for reducing expressions
    # Defaults to false
    @reduce = reduce

    # Check for "-v" or "--verbose" flag for reducing expressions
    # Defaults to false
    @verbose = verbose
    
    # Initialize the infex/prefix expressions and the operators array
    @infix = infix_expression
    @infix_array = []
    @prefix = []
    @ops = []
    
  end
  
  def convert
    
    @infix_array = @infix.split(" ").reverse
    logger "> Converted '#{@infix}' to array #{@infix_array.to_s}"

    # Evaluate each variable
    @infix_array.each_with_index { |c,i|
      evaluate_variable(c)
    }

    logger "> looping @ops until we reach the end, popping it all into prefix"
    while (!(/^[A-Za-z]+$|^[0-9]+\.?[0-9]*$/.match(@ops.last))) && !@ops.empty?
      logger ">> pushing '#{@ops.last}' into @prefix from @ops.pop as long as it's not alphanumeric"
      @prefix << @ops.pop 
    end

    # Reduce the expression if requested
    # and output to screen
    if @reduce
      reduce_expression
    else
      @verbose ? "Converted '#{@infix_array.reverse.join(" ").to_s}' to '#{@prefix.reverse.join(" ").to_s}'" : @prefix.reverse.join(" ").to_s
    end

  end
  
  def evaluate_variable(c)
    if !(/[\*\/\+\-\(\)]/.match(c))
      # If c is a number/variable, pop it into the prefix expression
      logger "> '#{c}' is a number/variable, pushing into @prefix"
      @prefix << c
    else
      if c == ")"
        # If c is a closing paren ("curved bracket"), pop it into
        # the operators array
        logger "> '#{c}' is a closing paren, pushing into @ops"
        @ops << c
      elsif c == "("
        # If c is an opening paren, keep popping the contents of the
        # operators array into the prefix expression until you
        # hit the closing paren, then pop off that opening paren
        logger "> looping @ops until we reach a closing paren"
        until @ops.last == ")"
          logger ">> '#{@ops.last}' is not a closing param, pushing @ops.pop into @prefix"
          @prefix << @ops.pop
        end
        logger "> popping the opening paren: '#{@ops.last}'"
        @ops.pop
      else  
        # If c is not a paren, determine its order of operation
        # in order to order (so many "order"s!) the symbols correctly
        logger "> testing for order of operations"
        if ooo(c,'>')
          logger "> ooo('#{c}','>') returned true, pushing '#{c}' into @ops"
          @ops << c
        else
          logger "> ooo('#{c}','>') returned false, looping @ops until ooo(c,'<=') returns false"
          until !(ooo(c,'<='))
            logger ">> '#{@ops.last}' is not returning false in ooo('#{c}','<='), pushing @ops.pop into @prefix"
            @prefix << @ops.pop
          end
          logger "> pushing '#{c}' into @ops"
          @ops << c
        end
      end
    end
  end
  
  def reduce_expression
    # If the user used the "-r" reduce flag,
    # evaluate for answer if no variables are present,
    # otherwise attempt variable negation and then
    # evaluate if all variables are negated
    @prefix.reverse!
    if /[A-Za-z]/.match(@prefix.join(" ").to_s).nil?
      logger "> no letter variables found, attempting to evaluate '#{@prefix.join(" ").to_s}'"
      @verbose ? "Converted '#{@infix_array.reverse.join(" ").to_s}' to '#{@prefix.join(" ").to_s}', reduced to '#{evaluate}'" : evaluate.gsub(/[\[-\]]/,'')
    else
      logger "> letter variables found, attempting to remove any negate-able variables"
      # Remove negations
      prefix_copy = Array.new(@prefix)
      simplified = remove_negations
      if /[A-Za-z]/.match(simplified).nil?
        logger "> no letter variables remain in simplified expression, attempting to evaluate '#{@prefix.join(" ").to_s}'"
        @verbose ? "Converted '#{@infix_array.reverse.join(" ").to_s}' to '#{prefix_copy.join(" ").to_s}', reduced to '#{@prefix.join(" ")}' and evaluated to '#{evaluate}'" : evaluate.gsub(/[\[-\]]/,'')
      else
        logger "> letter variables remain, displaying reduced expression '#{@prefix.join(" ").to_s}'"
        new_p = @prefix.join(" ").to_s
        if !/^-\s[\/\*\+-].*0$/.match(new_p).nil?
          new_p.slice!(0..1)
          new_p.slice!((new_p.length-2)..(new_p.length-1))
        end
        @verbose ? "Converted '#{@infix_array.reverse.join(" ").to_s}' to '#{prefix_copy.join(" ").to_s}', reduced to '#{new_p}'" : new_p
      end
    end
  end

  # Order of operations function
  def ooo(c,symbol)
    if symbol == ">"
      case c
        when "(", ")", "a".."z", "A".."Z", Integer
          false
        when "+", "-"
          (@ops.last == "*" || @ops.last == "/") ? false : true
        when "*", "/"
          (@ops.last == "*" || @ops.last == "/") ? false : true
      end
    elsif symbol == "<="
      case c
        when "(", ")", "a".."z", "A".."Z", Integer
          true
        when "+", "-"
          (@ops.last == "*" || @ops.last == "/" || @ops.last == "+" || @ops.last == "-") ? true : false
        when "*", "/"
          (@ops.last == "*" || @ops.last == "/") ? true : false
      end
    end
  end
  
  # Simple negation removal function
  def remove_negations

    logger("Removing negations in #{@prefix.compact.join(" ").to_s}")

    prefix_array_reduced = @prefix.compact.join(" ").to_s.gsub(/[\/\*]\s0\s[A-Za-z1-9]+|-\s((([1-9][0-9]*\.?[0-9]*)|(\.[0-9]+)|[A-Za-z]+))\s\1|[\+-\/\*]\s0\s0|[\/\*]\s[A-Za-z0-9]+\s0/,"0").gsub(/\/\s([A-Za-z1-9])\s\1/,"1")

    logger("Reduced to #{prefix_array_reduced}")

    @prefix = prefix_array_reduced.split
    prefix_array_reduced = prefix_array_reduced.split.join(" ")

    if !/\/\s([A-Za-z1-9])\s\1|[\/\*]\s0\s[A-Za-z1-9]+|-\s((([1-9][0-9]*\.?[0-9]*)|(\.[0-9]+)|[A-Za-z]+))\s\2|[\+-\/\*]\s0\s0|[\/\*]\s[A-Za-z0-9]+\s0/.match(prefix_array_reduced).nil?
      remove_negations
    else
      if !/^-\s[\/\*\+-].*0$/.match(prefix_array_reduced).nil?
        prefix_array_reduced.slice!(0..1)
        prefix_array_reduced.slice!((prefix_array_reduced.length-2)..(prefix_array_reduced.length-1))
      end
      return prefix_array_reduced
    end

  end
  
  def evaluate

    # Making a copy of @prefix
    p_array = Array.new(@prefix)

    # Initialize and start the array loop with
    # CLARIFICATION: since we are working with reverse
    # indices, we do not want to use the each_index array method.
    # The each_index array method starts from 0, whereas reverse
    # indices start with -1. It makes sense logically, but in
    # this case we could not easily loop through just by making
    # the positive index negative.
    i = 1
    while i <= p_array.length do
      # Set up the reverse index since we're working backwards
      # from the end of the array
      ri = i * -1
      symbol = p_array[ri]
      case symbol
        when "+","-","*","/"
          # Get the next two numbers in the array which by
          # default are the operands for the current symbol.
          operands = p_array.next_two_objects(ri)
          # Then run the operation, which can be simply eval'd
          # since we're dealing with basic arithmetic operators
          # and not logs, exponents, etc.
          # Save the result into the current index to be reused
          # as a number to be evaluated
          logger("About to evaluate '#{operands[0][0]} #{symbol} #{operands[1][0]}'")
          expr = ("#{operands[0][0]} #{symbol} #{operands[1][0]}")
          p_array[ri] = eval(expr).to_f
          # Set the operand places to nil so that they are not
          # used again in a calculation.
          p_array[operands[0][1]],p_array[operands[1][1]] = nil
      end

      # Increment the counter
      i = i+1
    end

    p_array.compact.to_s

  end
  
  private
  
    # Output logger statements if @verbose == true
    def logger(statement)
      puts "Line #{/\:(\d+)\:/.match(caller(1)[0])[1]}: #{statement}" if @verbose == true
    end
  
end

# Extend the Array class
class Array
  
  def next_two_objects(i)
    # Initialize the first and second return vars
    # and the f_changed_now flag which determines which
    # index to search for the s variable
    f,s = nil
    f_changed_now = false

    # Test for positive or negative index
    if i > 0
      
      # Loop through the array starting w/ the positive index
      while i <= (self.length - 1) do

        f_changed_now = true if (f.nil? && !self[i+1].nil?)
        f = [self[i+1],i+1] if (f.nil? && !self[i+1].nil?)
        if f_changed_now
          s = [self[i+2],i+2] if !self[i+2].nil?
        else
          s = [self[i+1],i+1] if !f.nil? && !self[i+1].nil?
        end

        break unless (f.nil? || s.nil?)

        # Reset the f_changed_now flag
        f_changed_now = false
        i = i+1
      end
            
    elsif i < 0
      
      # Loop through the array starting w/ the reverse index
      while i >= (self.length * -1) do

        f_changed_now = true if (f.nil? && !self[i+1].nil?)
        f = [self[i+1],i+1] if (f.nil? && !self[i+1].nil?)
        if f_changed_now
          s = [self[i+2],i+2] if !self[i+2].nil?
        else
          s = [self[i+1],i+1] if !f.nil? && !self[i+1].nil?
        end

        break unless (f.nil? || s.nil?)

        # Reset the f_changed_now flag
        f_changed_now = false
        i = i+1
      end
      
    end
    
    # Return the next two objects as an array
    [f,s]
    
  end
  
end