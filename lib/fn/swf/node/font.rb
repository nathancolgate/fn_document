require File.dirname(__FILE__) + "/../../node/base"
module FN
  module SWF
    module Node
      
      def Font(name, file)
        FN::Node::Base("font", :name => name, :file => file).extend(Font)
      end
      
      module Font 
        include FN::Node::Base
        
        def self.load_all_variants(key, path)
          # no-op, since at present, we aren't using custom fonts?!
        end
      
        def visit(struct, debug = false)
          has_no_children
          struct << %[.font #{self[:name]} "#{self[:file]}"]
        end
      end
    end
  end
end