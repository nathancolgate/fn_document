require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      
      def Watermark(text)
        FN::Node::Base("watermark", :text => text).extend(Watermark)
      end
      
      module Watermark
        include FN::Node::Base
      
        def visit(struct)
          has_no_children
          w = struct[CURRENT_PAGE_WIDTH]
          h = struct[CURRENT_PAGE_HEIGHT]
          font = struct.load_font("Arial,Bold", "unicode", "")
          struct.fit_textline(self["text"], 0, h, "font #{font} fontsize 30 boxsize {#{w} #{h}} fitmethod meet rotate 0 textrendering 1 position {0 50}")
        end
      end
    end
  end
end