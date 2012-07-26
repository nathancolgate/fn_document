require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      def FitImage(image, x, y, opts = {})
        FN::Node::Base("fit_image", opts.merge(:image => image, :x => x, :y => y)).extend(FitImage)
      end
      
      module FitImage 
        include FN::Node::Base
      
        def visit(struct, debug = false)
          has_no_children
          h = attributes.to_h
          img = struct[h.delete("image")]
          x = h.delete("x").to_i
          y = h.delete("y").to_i
          h["scale"] = 0.99 # if h["scale"] == "1.0"
            
          struct.fit_image(img, x, y, h)
        end
      end
    end
  end
end