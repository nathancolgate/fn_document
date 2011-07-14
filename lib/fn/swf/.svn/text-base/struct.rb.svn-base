module FN
  module SWF
    class Struct < Hash
      TAB = "  "
      
      attr_reader :buffer 
      
      def initialize
        @buffer = ""
        @indent_level = 0
      end
      
      def break
        self << ""
      end
      
      def <<(s, omit_end_tag = false, &b)
        @buffer << "#{tabs}#{s}\n"
        if block_given?
          indent(&b)
          @buffer << "#{tabs}.end\n"      unless omit_end_tag
        end
      end
      
      def tabs
        TAB * @indent_level
      end
      
      def indent
        @indent_level += 1
        if block_given?
          yield
          @indent_level -= 1
        end
      end
      
      def undent
        @indent_level -= 1
        raise "can't indent < 0"          if @indent_level < 0
      end
    end
  end
end