require File.dirname(__FILE__) + "/../../node/base"
module FN
  module SWF
    module Node
      def Break
        FN::Node::Base("break").extend(Break)
      end
      
      module Break 
        include FN::Node::Base
        
        def visit(struct, debug = false)
          has_no_children
          struct.break
        end
      end
    end
  end
end