require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      
      def BeginPageExt(width, height, number)
        FN::Node::Base("begin_page_ext", :width => width, :height => height, :number => number).extend(BeginPageExt)
      end
      
      module BeginPageExt 
        include FN::Node::Base
        
        def visit(struct, debug = false)
          struct.begin_page_ext(self[:width].to_i, self[:height].to_i, "")
          struct[CURRENT_PAGE_WIDTH]  = self[:width].to_i
          struct[CURRENT_PAGE_HEIGHT] = self[:height].to_i
          visit_children(struct, debug)
          struct.suspend_page("")
        end
      end
    end
  end
end