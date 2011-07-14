require File.dirname(__FILE__) + "/../../node/base"
module FN
  module SWF
    module Node
      
      def Page(number, bkg)
        FN::Node::Base("page", :number => number, :bkg => bkg).extend(Page)
      end
      
      module Page 
        include FN::Node::Base
        
        def visit(struct)
          n = self[:number] 
          bkg = self[:bkg]
          struct << ".frame #{n}"
          struct.<< ".sprite page#{n}" do
            struct << ".put bkg 0 0"
            struct << ".put #{bkg} x=0 y=0"
            visit_children(struct)
          end
          struct << ".put page#{n} 0 00"
          struct.<< ".action:" do
            struct << "stop();"
          end
        end
      end
    end
  end
end