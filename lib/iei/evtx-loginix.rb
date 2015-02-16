#-define HDR_TYP :type=>"class"
#-define HDR_GNM :name=>"IEI - Eventrix : Loginix"
#-define HDR_GDC :dc=>"22/06/2012"
#-define HDR_GDM :dm=>"22/06/2012"
#-define HDR_GAUT :author=>"IceDragon"
#-define HDR_VER :version=>"1.0"
#-inject gen_script_header HDR_TYP,HDR_GNM,HDR_GAUT,HDR_GDC,HDR_GDM,HDR_VER
($imported||={})['IEI::Eventrix::Loginix'] = 0x10000
#-inject gen_module_header 'Eventrix'
module Eventrix
  module Loginix
    class << self
      def And a,b
        a and b ? true : false
      end
      def Or a,b
        a or b ? true : false
      end
      def Buffer a
        !!a
      end
      def Invert a
        !a
      end
      def NAnd a,b
        a and b ? false : true
      end
      def NOr a,b
        a or b ? false : true
      end
      def XOr a,b
        a or b and not a and b ? true : false
      end
      def XNOr a,b
        a and b or !a and !b ? true : false
      end

      def switch_bool operand,sid
        bool = $game.switches[sid]
        case operand.upcase
        when 'INVERT', '!'
          bool = !bool
        when 'BUFFER', '@'
          bool = !!bool
        end
        bool
      end
      #@mapping = {
      #  and: method 'And',
      #  or: method 'Or',
      #  buffer: method 'Buffer',
      #  invert: method 'Invert',
      #  nand: method 'NAnd',
      #  nor: method 'NOr',
      #  xor: method 'XOr',
      #  xnor: method 'XNOr'
      #}
      #attr_reader :mapping
    end
  end
  # // Behaves like a Conditional Branch
  # // Place above a conditional branch, this overrides the original branching.
  # // DO NOT PLACE ANYTHING BETWEEN THE LOGINIX AND THE CONDITIONAL BRANCH
  # // EG:
  # //   LGNIX: AND @1 @2
  # //   your regular conditional branch
  gates = '(AND|OR|NAND|NOR|XOR|XNOR)'
  param = '(?:(BUFFER|\@|INVERT|\!):?)?(\d+)'
  add_command mk_uniq_code,/\A(?:LOGINIX|LGNIX)\:\s#{gates}\s#{param}\s#{param}/i,[:drop_next] do
    exparams = @params.first
    loginix = Eventrix::Loginix
    param1 = loginix.switch_bool exparams[2], exparams[3].to_i
    param2 = loginix.switch_bool exparams[4], exparams[5].to_i
    result = case exparams[1].upcase # // Logic
      when 'AND' ; loginix.And param1, param2
      when 'OR'  ; loginix.Or param1, param2
      when 'NAND'; loginix.NAnd param1, param2
      when 'NOR' ; loginix.NOr param1, param2
      when 'XOR' ; loginix.XOr param1, param2
      when 'XNOR'; loginix.XNOr param1, param2
    end
    @branch[@indent] = result
    command_skip if !@branch[@indent]
  end
end
