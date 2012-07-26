require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      
      def EndPageExt(number)
        FN::Node::Base("end_page_ext", :pagenumber => number).extend(EndPageExt)
      end
      
      module EndPageExt 
        include FN::Node::Base
      
        def visit(struct, debug = false)
          has_no_children
          struct.resume_page(attributes.to_h)
          struct.end_page_ext("")
        end
      end
    end
  end
end