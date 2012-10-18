
# line 1 "parser.rl"

# line 72 "parser.rl"


require File.expand_path('../ast', __FILE__)

module Imperator
  module Predicate
    class Parser
      def self.parse(predicate)
        new.tap do |parser|
          data = predicate.join(' ')
          buffer = ''
          eof = data.length
          stack = []

          
# line 21 "parser.rb"
begin
	p ||= 0
	pe ||= data.length
	cs = parser_start
	top = 0
	ts = nil
	te = nil
	act = 0
end

# line 87 "parser.rl"
          
# line 34 "parser.rb"
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_acts = _parser_from_state_actions[cs]
	_nacts = _parser_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _parser_actions[_acts - 1]
			when 14 then
# line 1 "NONE"
		begin
ts = p
		end
# line 68 "parser.rb"
		end # from state action switch
	end
	if _trigger_goto
		next
	end
	_keys = _parser_key_offsets[cs]
	_trans = _parser_index_offsets[cs]
	_klen = _parser_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _parser_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _parser_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _parser_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _parser_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _parser_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	end
	if _goto_level <= _eof_trans
	cs = _parser_trans_targs[_trans]
	if _parser_trans_actions[_trans] != 0
		_acts = _parser_trans_actions[_trans]
		_nacts = _parser_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _parser_actions[_acts - 1]
when 0 then
# line 21 "parser.rl"
		begin
 buffer << data[p].ord 		end
when 1 then
# line 22 "parser.rl"
		begin
 puts "q: #{buffer}"; buffer.clear 		end
when 3 then
# line 24 "parser.rl"
		begin
 puts "string: #{buffer}"; buffer.clear 		end
when 4 then
# line 25 "parser.rl"
		begin
 puts 'jump to criterion scanner'; 	begin
		stack[top] = cs
		top+= 1
		cs = 108
		_trigger_goto = true
		_goto_level = _again
		break
	end
 		end
when 5 then
# line 27 "parser.rl"
		begin
 puts "lt" 		end
when 6 then
# line 28 "parser.rl"
		begin
 puts "le" 		end
when 7 then
# line 29 "parser.rl"
		begin
 puts "eq" 		end
when 8 then
# line 30 "parser.rl"
		begin
 puts "ne" 		end
when 9 then
# line 31 "parser.rl"
		begin
 puts "ge" 		end
when 10 then
# line 32 "parser.rl"
		begin
 puts "gt" 		end
when 11 then
# line 33 "parser.rl"
		begin
 puts "ma" 		end
when 15 then
# line 1 "NONE"
		begin
te = p+1
		end
when 16 then
# line 51 "parser.rl"
		begin
act = 1;		end
when 17 then
# line 53 "parser.rl"
		begin
act = 3;		end
when 18 then
# line 54 "parser.rl"
		begin
act = 4;		end
when 19 then
# line 56 "parser.rl"
		begin
te = p+1
 begin  	begin
		top -= 1
		cs = stack[top]
		_trigger_goto = true
		_goto_level = _again
		break
	end
  end
		end
when 20 then
# line 51 "parser.rl"
		begin
te = p
p = p - 1; begin  puts 'string value'  end
		end
when 21 then
# line 52 "parser.rl"
		begin
te = p
p = p - 1; begin  puts 'integer value'  end
		end
when 22 then
# line 53 "parser.rl"
		begin
te = p
p = p - 1; begin  puts 'regexp'  end
		end
when 23 then
# line 54 "parser.rl"
		begin
te = p
p = p - 1; begin  puts 'answer reference'  end
		end
when 24 then
# line 55 "parser.rl"
		begin
te = p
p = p - 1; begin   end
		end
when 25 then
# line 1 "NONE"
		begin
	case act
	when 0 then
	begin	begin
		cs = 0
		_trigger_goto = true
		_goto_level = _again
		break
	end
end
	when 1 then
	begin begin p = ((te))-1; end
 puts 'string value' end
	when 3 then
	begin begin p = ((te))-1; end
 puts 'regexp' end
	when 4 then
	begin begin p = ((te))-1; end
 puts 'answer reference' end
end 
			end
# line 269 "parser.rb"
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	_acts = _parser_to_state_actions[cs]
	_nacts = _parser_actions[_acts]
	_acts += 1
	while _nacts > 0
		_nacts -= 1
		_acts += 1
		case _parser_actions[_acts - 1]
when 12 then
# line 1 "NONE"
		begin
ts = nil;		end
when 13 then
# line 1 "NONE"
		begin
act = 0
		end
# line 294 "parser.rb"
		end # to state action switch
	end
	if _trigger_goto
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	if p == eof
	if _parser_eof_trans[cs] > 0
		_trans = _parser_eof_trans[cs] - 1;
		_goto_level = _eof_trans
		next;
	end
	__acts = _parser_eof_actions[cs]
	__nacts =  _parser_actions[__acts]
	__acts += 1
	while __nacts > 0
		__nacts -= 1
		__acts += 1
		case _parser_actions[__acts - 1]
when 2 then
# line 23 "parser.rl"
		begin
 puts "a: #{buffer}"; buffer.clear 		end
# line 328 "parser.rb"
		end # eof action switch
	end
	if _trigger_goto
		next
	end
end
	end
	if _goto_level <= _out
		break
	end
	end
	end

# line 88 "parser.rl"
        end
      end

      
# line 347 "parser.rb"
class << self
	attr_accessor :_parser_actions
	private :_parser_actions, :_parser_actions=
end
self._parser_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	4, 1, 5, 1, 6, 1, 7, 1, 
	8, 1, 9, 1, 10, 1, 11, 1, 
	12, 1, 14, 1, 19, 1, 21, 1, 
	23, 1, 24, 1, 25, 2, 3, 20, 
	2, 3, 22, 2, 3, 23, 2, 12, 
	13, 3, 15, 0, 16, 3, 15, 0, 
	17, 3, 15, 0, 18
]

class << self
	attr_accessor :_parser_key_offsets
	private :_parser_key_offsets, :_parser_key_offsets=
end
self._parser_key_offsets = [
	0, 0, 5, 6, 9, 10, 14, 17, 
	19, 22, 25, 29, 32, 33, 39, 48, 
	53, 54, 57, 59, 60, 66, 70, 73, 
	75, 78, 81, 85, 88, 89, 90, 91, 
	92, 99, 100, 105, 110, 116, 121, 123, 
	128, 133, 139, 144, 148, 149, 150, 151, 
	152, 153, 154, 155, 156, 157, 158, 159, 
	160, 161, 162, 163, 164, 165, 168, 170, 
	172, 173, 174, 175, 176, 177, 178, 179, 
	180, 181, 182, 183, 184, 185, 186, 188, 
	189, 190, 191, 192, 193, 194, 195, 196, 
	198, 200, 201, 202, 203, 204, 205, 206, 
	207, 208, 209, 210, 211, 212, 213, 214, 
	216, 218, 218, 224, 226, 229, 232, 232, 
	234, 236, 238, 238, 240, 240
]

class << self
	attr_accessor :_parser_trans_keys
	private :_parser_trans_keys, :_parser_trans_keys=
end
self._parser_trans_keys = [
	33, 60, 61, 62, 113, 61, 32, 9, 
	13, 123, 32, 61, 9, 13, 32, 9, 
	13, 61, 126, 32, 9, 13, 32, 9, 
	13, 32, 61, 9, 13, 32, 9, 13, 
	95, 48, 57, 65, 90, 97, 122, 32, 
	9, 13, 48, 57, 65, 90, 97, 122, 
	33, 60, 61, 62, 99, 61, 32, 9, 
	13, 97, 123, 95, 48, 57, 65, 90, 
	97, 122, 32, 61, 9, 13, 32, 9, 
	13, 61, 126, 32, 9, 13, 32, 9, 
	13, 32, 61, 9, 13, 32, 9, 13, 
	111, 117, 110, 116, 32, 33, 60, 61, 
	62, 9, 13, 61, 32, 9, 13, 48, 
	57, 32, 9, 13, 48, 57, 32, 61, 
	9, 13, 48, 57, 32, 9, 13, 48, 
	57, 61, 126, 32, 9, 13, 48, 57, 
	32, 9, 13, 48, 57, 32, 61, 9, 
	13, 48, 57, 32, 9, 13, 48, 57, 
	97, 105, 114, 115, 110, 115, 119, 101, 
	114, 95, 114, 101, 102, 101, 114, 101, 
	110, 99, 101, 61, 62, 34, 48, 57, 
	34, 92, 34, 92, 110, 116, 101, 103, 
	101, 114, 95, 118, 97, 108, 117, 101, 
	61, 62, 48, 57, 101, 103, 101, 120, 
	112, 61, 62, 34, 34, 92, 34, 92, 
	116, 114, 105, 110, 103, 95, 118, 97, 
	108, 117, 101, 61, 62, 34, 34, 92, 
	34, 92, 48, 57, 65, 90, 97, 122, 
	48, 57, 44, 58, 125, 32, 9, 13, 
	34, 92, 48, 57, 48, 57, 34, 92, 
	34, 92, 0
]

class << self
	attr_accessor :_parser_single_lengths
	private :_parser_single_lengths, :_parser_single_lengths=
end
self._parser_single_lengths = [
	0, 5, 1, 1, 1, 2, 1, 2, 
	1, 1, 2, 1, 1, 0, 1, 5, 
	1, 1, 2, 1, 0, 2, 1, 2, 
	1, 1, 2, 1, 1, 1, 1, 1, 
	5, 1, 1, 1, 2, 1, 2, 1, 
	1, 2, 1, 4, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 0, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	2, 0, 0, 0, 3, 1, 0, 2, 
	0, 0, 0, 2, 0, 2
]

class << self
	attr_accessor :_parser_range_lengths
	private :_parser_range_lengths, :_parser_range_lengths=
end
self._parser_range_lengths = [
	0, 0, 0, 1, 0, 1, 1, 0, 
	1, 1, 1, 1, 0, 3, 4, 0, 
	0, 1, 0, 0, 3, 1, 1, 0, 
	1, 1, 1, 1, 0, 0, 0, 0, 
	1, 0, 2, 2, 2, 2, 0, 2, 
	2, 2, 2, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 3, 1, 0, 1, 0, 0, 
	1, 1, 0, 0, 0, 0
]

class << self
	attr_accessor :_parser_index_offsets
	private :_parser_index_offsets, :_parser_index_offsets=
end
self._parser_index_offsets = [
	0, 0, 6, 8, 11, 13, 17, 20, 
	23, 26, 29, 33, 36, 38, 42, 48, 
	54, 56, 59, 62, 64, 68, 72, 75, 
	78, 81, 84, 88, 91, 93, 95, 97, 
	99, 106, 108, 112, 116, 121, 125, 128, 
	132, 136, 141, 145, 150, 152, 154, 156, 
	158, 160, 162, 164, 166, 168, 170, 172, 
	174, 176, 178, 180, 182, 184, 187, 190, 
	193, 195, 197, 199, 201, 203, 205, 207, 
	209, 211, 213, 215, 217, 219, 221, 223, 
	225, 227, 229, 231, 233, 235, 237, 239, 
	242, 245, 247, 249, 251, 253, 255, 257, 
	259, 261, 263, 265, 267, 269, 271, 273, 
	276, 279, 280, 284, 286, 290, 293, 294, 
	297, 299, 301, 302, 305, 306
]

class << self
	attr_accessor :_parser_trans_targs
	private :_parser_trans_targs, :_parser_trans_targs=
end
self._parser_trans_targs = [
	2, 5, 7, 10, 12, 0, 3, 0, 
	4, 4, 0, 105, 0, 4, 6, 4, 
	0, 4, 4, 0, 8, 9, 0, 4, 
	4, 0, 4, 4, 0, 4, 11, 4, 
	0, 4, 4, 0, 13, 0, 14, 14, 
	14, 0, 15, 15, 14, 14, 14, 0, 
	16, 21, 23, 26, 28, 0, 17, 0, 
	18, 18, 0, 19, 105, 0, 20, 0, 
	106, 106, 106, 0, 18, 22, 18, 0, 
	18, 18, 0, 24, 25, 0, 18, 18, 
	0, 18, 18, 0, 18, 27, 18, 0, 
	18, 18, 0, 29, 0, 30, 0, 31, 
	0, 32, 0, 32, 33, 36, 38, 41, 
	32, 0, 34, 0, 35, 35, 107, 0, 
	35, 35, 107, 0, 35, 37, 35, 107, 
	0, 35, 35, 107, 0, 39, 40, 0, 
	35, 35, 107, 0, 35, 35, 107, 0, 
	35, 42, 35, 107, 0, 35, 35, 107, 
	0, 44, 64, 79, 89, 0, 45, 0, 
	46, 0, 47, 0, 48, 0, 49, 0, 
	50, 0, 51, 0, 52, 0, 53, 0, 
	54, 0, 55, 0, 56, 0, 57, 0, 
	58, 0, 59, 0, 60, 0, 61, 0, 
	62, 112, 0, 110, 63, 62, 111, 63, 
	62, 65, 0, 66, 0, 67, 0, 68, 
	0, 69, 0, 70, 0, 71, 0, 72, 
	0, 73, 0, 74, 0, 75, 0, 76, 
	0, 77, 0, 78, 0, 113, 0, 80, 
	0, 81, 0, 82, 0, 83, 0, 84, 
	0, 85, 0, 86, 0, 87, 0, 114, 
	88, 87, 115, 88, 87, 90, 0, 91, 
	0, 92, 0, 93, 0, 94, 0, 95, 
	0, 96, 0, 97, 0, 98, 0, 99, 
	0, 100, 0, 101, 0, 102, 0, 103, 
	0, 116, 104, 103, 117, 104, 103, 0, 
	106, 106, 106, 0, 107, 0, 109, 43, 
	108, 0, 109, 109, 108, 108, 110, 63, 
	62, 112, 108, 113, 108, 108, 114, 88, 
	87, 108, 116, 104, 103, 108, 108, 108, 
	108, 108, 108, 108, 108, 108, 108, 108, 
	108, 108, 108, 108, 0
]

class << self
	attr_accessor :_parser_trans_actions
	private :_parser_trans_actions, :_parser_trans_actions=
end
self._parser_trans_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	15, 15, 0, 7, 0, 9, 0, 9, 
	0, 11, 11, 0, 0, 0, 0, 13, 
	13, 0, 21, 21, 0, 19, 0, 19, 
	0, 17, 17, 0, 0, 0, 1, 1, 
	1, 0, 3, 3, 1, 1, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	15, 15, 0, 0, 7, 0, 0, 0, 
	1, 1, 1, 0, 9, 0, 9, 0, 
	11, 11, 0, 0, 0, 0, 13, 13, 
	0, 21, 21, 0, 19, 0, 19, 0, 
	17, 17, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 15, 15, 15, 0, 
	0, 0, 0, 0, 9, 0, 9, 9, 
	0, 11, 11, 11, 0, 0, 0, 0, 
	13, 13, 13, 0, 21, 21, 21, 0, 
	19, 0, 19, 19, 0, 17, 17, 17, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 1, 57, 1, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 1, 53, 1, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 49, 1, 1, 0, 
	1, 1, 1, 0, 0, 0, 0, 0, 
	27, 0, 0, 0, 33, 43, 0, 1, 
	1, 0, 31, 0, 29, 40, 0, 1, 
	1, 37, 0, 1, 1, 35, 35, 35, 
	35, 35, 35, 33, 43, 43, 31, 29, 
	40, 40, 37, 37, 0
]

class << self
	attr_accessor :_parser_to_state_actions
	private :_parser_to_state_actions, :_parser_to_state_actions=
end
self._parser_to_state_actions = [
	0, 23, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 23, 0, 0, 46, 0, 0, 0, 
	0, 0, 0, 0, 0, 0
]

class << self
	attr_accessor :_parser_from_state_actions
	private :_parser_from_state_actions, :_parser_from_state_actions=
end
self._parser_from_state_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 25, 0, 0, 0, 
	0, 0, 0, 0, 0, 0
]

class << self
	attr_accessor :_parser_eof_actions
	private :_parser_eof_actions, :_parser_eof_actions=
end
self._parser_eof_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 5, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0
]

class << self
	attr_accessor :_parser_eof_trans
	private :_parser_eof_trans, :_parser_eof_trans=
end
self._parser_eof_trans = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 315, 315, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 315, 
	315, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 315, 
	315, 0, 0, 0, 0, 316, 318, 318, 
	319, 320, 322, 322, 324, 324
]

class << self
	attr_accessor :parser_start
end
self.parser_start = 1;
class << self
	attr_accessor :parser_first_final
end
self.parser_first_final = 105;
class << self
	attr_accessor :parser_error
end
self.parser_error = 0;

class << self
	attr_accessor :parser_en_criterion
end
self.parser_en_criterion = 108;
class << self
	attr_accessor :parser_en_main
end
self.parser_en_main = 1;


# line 92 "parser.rl"
    end
  end
end
