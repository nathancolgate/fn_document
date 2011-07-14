require File.dirname(__FILE__) + "/../../node/base"
module FN
  module SWF
    module Node
      def Flash(width, height)
        FN::Node::Base("flash", :width => width, :height => height).extend(Flash)
      end
      
      module Flash 
        include FN::Node::Base
      
        def visit(struct)
          w = self[:width]
          h = self[:height]
          size = "#{w}x#{h}"
          struct.<< %[.flash bbox="#{size}" compress version=6] do
            struct.<< %[.box bkg width=#{w} height=#{h} color=white fill]
            visit_children struct
          end
        end
      end
    end
  end
end