require File.dirname(__FILE__) + "/../../node/base"
module FN
  module SWF
    module Node
      def Frame(name, file)
        FN::Node::Base("frame", :name => name, :file => file).extend(Frame)
      end
      
      module Frame 
        include FN::Node::Base
        
        def visit(struct)
          has_no_children
          struct << %[.font #{self[:name]} "#{self[:file]}"]
        end
      end
    end
  end
end