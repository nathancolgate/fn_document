require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node

      def OpenPdiPage(pdi_var, page_number, page_var)
        FN::Node::Base("open_pdi_page", :pdi => pdi_var, :number => page_number, :assigns => page_var).extend(OpenPdiPage)
      end
      
      module OpenPdiPage 
        include FN::Node::Base
      
        def visit(struct)
          pg = struct.open_pdi_page(struct[self[:pdi]], self[:number].to_i, "")
          struct.assigns self, pg
          visit_children struct
          struct.close_pdi_page(pg)
        end
      end
    end
  end
end