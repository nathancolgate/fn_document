require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      def LoadImage(file, var)
        FN::Node::Base("load_image", :file => file, :assigns => var).extend(LoadImage)
      end
      
      module LoadImage 
        include FN::Node::Base
        
        def visit(struct)
          has_no_children
          img = struct.load_image("auto", self[:file], "")
          struct.assigns self, img
        end
      end
    end
  end
end