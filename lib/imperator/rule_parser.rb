class RuleParser
  # :stopdoc:

    # This is distinct from setup_parser so that a standalone parser
    # can redefine #initialize and still have access to the proper
    # parser setup code.
    def initialize(str, debug=false)
      setup_parser(str, debug)
    end



    # Prepares for parsing +str+.  If you define a custom initialize you must
    # call this method before #parse
    def setup_parser(str, debug=false)
      @string = str
      @pos = 0
      @memoizations = Hash.new { |h,k| h[k] = {} }
      @result = nil
      @failed_rule = nil
      @failing_rule_offset = -1

      setup_foreign_grammar
    end

    attr_reader :string
    attr_reader :failing_rule_offset
    attr_accessor :result, :pos

    
    def current_column(target=pos)
      if c = string.rindex("\n", target-1)
        return target - c - 1
      end

      target + 1
    end

    def current_line(target=pos)
      cur_offset = 0
      cur_line = 0

      string.each_line do |line|
        cur_line += 1
        cur_offset += line.size
        return cur_line if cur_offset >= target
      end

      -1
    end

    def lines
      lines = []
      string.each_line { |l| lines << l }
      lines
    end



    def get_text(start)
      @string[start..@pos-1]
    end

    def show_pos
      width = 10
      if @pos < width
        "#{@pos} (\"#{@string[0,@pos]}\" @ \"#{@string[@pos,width]}\")"
      else
        "#{@pos} (\"... #{@string[@pos - width, width]}\" @ \"#{@string[@pos,width]}\")"
      end
    end

    def failure_info
      l = current_line @failing_rule_offset
      c = current_column @failing_rule_offset

      if @failed_rule.kind_of? Symbol
        info = self.class::Rules[@failed_rule]
        "line #{l}, column #{c}: failed rule '#{info.name}' = '#{info.rendered}'"
      else
        "line #{l}, column #{c}: failed rule '#{@failed_rule}'"
      end
    end

    def failure_caret
      l = current_line @failing_rule_offset
      c = current_column @failing_rule_offset

      line = lines[l-1]
      "#{line}\n#{' ' * (c - 1)}^"
    end

    def failure_character
      l = current_line @failing_rule_offset
      c = current_column @failing_rule_offset
      lines[l-1][c-1, 1]
    end

    def failure_oneline
      l = current_line @failing_rule_offset
      c = current_column @failing_rule_offset

      char = lines[l-1][c-1, 1]

      if @failed_rule.kind_of? Symbol
        info = self.class::Rules[@failed_rule]
        "@#{l}:#{c} failed rule '#{info.name}', got '#{char}'"
      else
        "@#{l}:#{c} failed rule '#{@failed_rule}', got '#{char}'"
      end
    end

    class ParseError < RuntimeError
    end

    def raise_error
      raise ParseError, failure_oneline
    end

    def show_error(io=STDOUT)
      error_pos = @failing_rule_offset
      line_no = current_line(error_pos)
      col_no = current_column(error_pos)

      io.puts "On line #{line_no}, column #{col_no}:"

      if @failed_rule.kind_of? Symbol
        info = self.class::Rules[@failed_rule]
        io.puts "Failed to match '#{info.rendered}' (rule '#{info.name}')"
      else
        io.puts "Failed to match rule '#{@failed_rule}'"
      end

      io.puts "Got: #{string[error_pos,1].inspect}"
      line = lines[line_no-1]
      io.puts "=> #{line}"
      io.print(" " * (col_no + 3))
      io.puts "^"
    end

    def set_failed_rule(name)
      if @pos > @failing_rule_offset
        @failed_rule = name
        @failing_rule_offset = @pos
      end
    end

    attr_reader :failed_rule

    def match_string(str)
      len = str.size
      if @string[pos,len] == str
        @pos += len
        return str
      end

      return nil
    end

    def scan(reg)
      if m = reg.match(@string[@pos..-1])
        width = m.end(0)
        @pos += width
        return true
      end

      return nil
    end

    if "".respond_to? :getbyte
      def get_byte
        if @pos >= @string.size
          return nil
        end

        s = @string.getbyte @pos
        @pos += 1
        s
      end
    else
      def get_byte
        if @pos >= @string.size
          return nil
        end

        s = @string[@pos]
        @pos += 1
        s
      end
    end

    def parse(rule=nil)
      # We invoke the rules indirectly via apply
      # instead of by just calling them as methods because
      # if the rules use left recursion, apply needs to
      # manage that.

      if !rule
        apply(:_root)
      else
        method = rule.gsub("-","_hyphen_")
        apply :"_#{method}"
      end
    end

    class MemoEntry
      def initialize(ans, pos)
        @ans = ans
        @pos = pos
        @result = nil
        @set = false
        @left_rec = false
      end

      attr_reader :ans, :pos, :result, :set
      attr_accessor :left_rec

      def move!(ans, pos, result)
        @ans = ans
        @pos = pos
        @result = result
        @set = true
        @left_rec = false
      end
    end

    def external_invoke(other, rule, *args)
      old_pos = @pos
      old_string = @string

      @pos = other.pos
      @string = other.string

      begin
        if val = __send__(rule, *args)
          other.pos = @pos
          other.result = @result
        else
          other.set_failed_rule "#{self.class}##{rule}"
        end
        val
      ensure
        @pos = old_pos
        @string = old_string
      end
    end

    def apply_with_args(rule, *args)
      memo_key = [rule, args]
      if m = @memoizations[memo_key][@pos]
        @pos = m.pos
        if !m.set
          m.left_rec = true
          return nil
        end

        @result = m.result

        return m.ans
      else
        m = MemoEntry.new(nil, @pos)
        @memoizations[memo_key][@pos] = m
        start_pos = @pos

        ans = __send__ rule, *args

        lr = m.left_rec

        m.move! ans, @pos, @result

        # Don't bother trying to grow the left recursion
        # if it's failing straight away (thus there is no seed)
        if ans and lr
          return grow_lr(rule, args, start_pos, m)
        else
          return ans
        end

        return ans
      end
    end

    def apply(rule)
      if m = @memoizations[rule][@pos]
        @pos = m.pos
        if !m.set
          m.left_rec = true
          return nil
        end

        @result = m.result

        return m.ans
      else
        m = MemoEntry.new(nil, @pos)
        @memoizations[rule][@pos] = m
        start_pos = @pos

        ans = __send__ rule

        lr = m.left_rec

        m.move! ans, @pos, @result

        # Don't bother trying to grow the left recursion
        # if it's failing straight away (thus there is no seed)
        if ans and lr
          return grow_lr(rule, nil, start_pos, m)
        else
          return ans
        end

        return ans
      end
    end

    def grow_lr(rule, args, start_pos, m)
      while true
        @pos = start_pos
        @result = m.result

        if args
          ans = __send__ rule, *args
        else
          ans = __send__ rule
        end
        return nil unless ans

        break if @pos <= m.pos

        m.move! ans, @pos, @result
      end

      @result = m.result
      @pos = m.pos
      return m.ans
    end

    class RuleInfo
      def initialize(name, rendered)
        @name = name
        @rendered = rendered
      end

      attr_reader :name, :rendered
    end

    def self.rule_info(name, rendered)
      RuleInfo.new(name, rendered)
    end


  # :startdoc:


attr_reader :ast


  # :stopdoc:

  module AST
    class Node; end
    class Conj < Node
      def initialize(op)
        @op = op
      end
      attr_reader :op
    end
    class Tag < Node
      def initialize(name)
        @name = name
      end
      attr_reader :name
    end
    class Phrase < Node
      def initialize(left, conj, right)
        @left = left
        @conj = conj
        @right = right
      end
      attr_reader :left
      attr_reader :conj
      attr_reader :right
    end
  end
  def conj_node(op)
    AST::Conj.new(op)
  end
  def ctag_node(name)
    AST::Tag.new(name)
  end
  def phrase_node(left, conj, right)
    AST::Phrase.new(left, conj, right)
  end
  def setup_foreign_grammar; end

  # lp = "("
  def _lp
    _tmp = match_string("(")
    set_failed_rule :_lp unless _tmp
    return _tmp
  end

  # rp = ")"
  def _rp
    _tmp = match_string(")")
    set_failed_rule :_rp unless _tmp
    return _tmp
  end

  # space = /\s/
  def _space
    _tmp = scan(/\A(?-mix:\s)/)
    set_failed_rule :_space unless _tmp
    return _tmp
  end

  # term = < /\w+/ > {ctag_node(text)}
  def _term

    _save = self.pos
    while true # sequence
      _text_start = self.pos
      _tmp = scan(/\A(?-mix:\w+)/)
      if _tmp
        text = get_text(_text_start)
      end
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; ctag_node(text); end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_term unless _tmp
    return _tmp
  end

  # and = "and" {conj_node("and")}
  def _and

    _save = self.pos
    while true # sequence
      _tmp = match_string("and")
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; conj_node("and"); end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_and unless _tmp
    return _tmp
  end

  # or = "or" {conj_node("or")}
  def _or

    _save = self.pos
    while true # sequence
      _tmp = match_string("or")
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin; conj_node("or"); end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_or unless _tmp
    return _tmp
  end

  # conj = (and | or)
  def _conj

    _save = self.pos
    while true # choice
      _tmp = apply(:_and)
      break if _tmp
      self.pos = _save
      _tmp = apply(:_or)
      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_conj unless _tmp
    return _tmp
  end

  # phrase = (phrase:l space+ conj:c space+ phrase:r {phrase_node(l, c, r)} | lp phrase rp | term)
  def _phrase

    _save = self.pos
    while true # choice

      _save1 = self.pos
      while true # sequence
        _tmp = apply(:_phrase)
        l = @result
        unless _tmp
          self.pos = _save1
          break
        end
        _save2 = self.pos
        _tmp = apply(:_space)
        if _tmp
          while true
            _tmp = apply(:_space)
            break unless _tmp
          end
          _tmp = true
        else
          self.pos = _save2
        end
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:_conj)
        c = @result
        unless _tmp
          self.pos = _save1
          break
        end
        _save3 = self.pos
        _tmp = apply(:_space)
        if _tmp
          while true
            _tmp = apply(:_space)
            break unless _tmp
          end
          _tmp = true
        else
          self.pos = _save3
        end
        unless _tmp
          self.pos = _save1
          break
        end
        _tmp = apply(:_phrase)
        r = @result
        unless _tmp
          self.pos = _save1
          break
        end
        @result = begin; phrase_node(l, c, r); end
        _tmp = true
        unless _tmp
          self.pos = _save1
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save

      _save4 = self.pos
      while true # sequence
        _tmp = apply(:_lp)
        unless _tmp
          self.pos = _save4
          break
        end
        _tmp = apply(:_phrase)
        unless _tmp
          self.pos = _save4
          break
        end
        _tmp = apply(:_rp)
        unless _tmp
          self.pos = _save4
        end
        break
      end # end sequence

      break if _tmp
      self.pos = _save
      _tmp = apply(:_term)
      break if _tmp
      self.pos = _save
      break
    end # end choice

    set_failed_rule :_phrase unless _tmp
    return _tmp
  end

  # root = phrase:t { @ast = t }
  def _root

    _save = self.pos
    while true # sequence
      _tmp = apply(:_phrase)
      t = @result
      unless _tmp
        self.pos = _save
        break
      end
      @result = begin;  @ast = t ; end
      _tmp = true
      unless _tmp
        self.pos = _save
      end
      break
    end # end sequence

    set_failed_rule :_root unless _tmp
    return _tmp
  end

  Rules = {}
  Rules[:_lp] = rule_info("lp", "\"(\"")
  Rules[:_rp] = rule_info("rp", "\")\"")
  Rules[:_space] = rule_info("space", "/\\s/")
  Rules[:_term] = rule_info("term", "< /\\w+/ > {ctag_node(text)}")
  Rules[:_and] = rule_info("and", "\"and\" {conj_node(\"and\")}")
  Rules[:_or] = rule_info("or", "\"or\" {conj_node(\"or\")}")
  Rules[:_conj] = rule_info("conj", "(and | or)")
  Rules[:_phrase] = rule_info("phrase", "(phrase:l space+ conj:c space+ phrase:r {phrase_node(l, c, r)} | lp phrase rp | term)")
  Rules[:_root] = rule_info("root", "phrase:t { @ast = t }")
  # :startdoc:
end
