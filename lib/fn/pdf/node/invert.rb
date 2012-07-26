# if block['flip'] == "yes"
#   @pdf.save
#   @pdf.translate block["x"].to_f + block["x2"].to_f, block["y"].to_f + block["y2"].to_f
#   @pdf.rotate 180
#   @pdf.fit_textflow flow, block["x"].to_f, block["y"].to_f, block["x2"].to_f, block["y2"].to_f, ""
#   @pdf.restore
# else

require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      def Invert(block)
        FN::Node::Base("invert", 
              :x  => block["x"], 
              :y  => block["y"],
              :x2 => block["x"].to_f + block["width"].to_f,
              :y2 => block["y"].to_f + block["height"].to_f
            ).extend(Invert)
      end
      
      module Invert 
        include FN::Node::Base
      
        def visit(struct, debug = false)
          struct.save
          struct.translate self["x"].to_f + self["x2"].to_f, self["y"].to_f + self["y2"].to_f
          struct.rotate 180
          visit_children(struct, debug)
          struct.restore
        end
      end
    end
  end
end