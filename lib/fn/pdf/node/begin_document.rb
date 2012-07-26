require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      
      def BeginDocument(file, compatibility)
        FN::Node::Base("begin_document", :file => file, :compatibility => compatibility).extend(BeginDocument)
      end
      
      module BeginDocument 
        include FN::Node::Base
      
        def visit(struct, debug = false)
          struct.begin_document(self[:file], :compatibility => self[:compatibility])
          visit_children(struct, debug )
          struct.end_document("")
        end
      end
    end
  end
end