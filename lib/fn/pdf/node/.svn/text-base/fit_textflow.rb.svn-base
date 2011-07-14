require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      def FitTextflow(flow, block)
        FN::Node::Base("fit_textflow", :flow => "{#{flow && flow.flow_name}}", 
              :x  => block["x"], 
              :y  => block["y"],
              :x2 => block["x"].to_f + block["width"].to_f,
              :y2 => block["y"].to_f + block["height"].to_f
            ).extend(FitTextflow)
      end
      
      module FitTextflow 
        include FN::Node::Base
      
        def visit(struct)
          has_no_children
          struct.fit_textflow struct[self["flow"]], 
              self["x"].to_f,  self["y"].to_f, 
              self["x2"].to_f, self["y2"].to_f, ""
        end
      end
    end
  end
end