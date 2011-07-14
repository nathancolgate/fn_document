require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      def FitPdiPage(var)
        FN::Node::Base("fit_pdi_page", :page => var)
      end
      
      module FitPdiPage 
        include FN::Node::Base
        
        def visit(struct)
          has_no_children
          struct.fit_pdi_page(struct[self[:page]], 0, struct[CURRENT_PAGE_HEIGHT], "")
        end
      end
    end
  end
end