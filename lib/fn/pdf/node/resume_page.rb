require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      def ResumePage(number)
        FN::Node::Base("resume_page", :pagenumber => number).extend(ResumePage)
      end
      
      module ResumePage 
        include FN::Node::Base
      
        def visit(struct, debug = false)
          struct.resume_page(attributes.to_h)
          visit_children(struct, debug)
          struct.suspend_page("")
        end
      end
    end
  end
end