require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      def OpenPdi(file, var)
        FN::Node::Base("open_pdi", :file => file, :assigns => var).extend(OpenPdi)
      end
      
      module OpenPdi 
        include FN::Node::Base
      
        def visit(struct)
          pdi = struct.open_pdi(self[:file], "", 0)
          struct.assigns(self, pdi)
          visit_children struct
          struct.close_pdi(pdi)
        end
      end
    end
  end
end