require File.dirname(__FILE__) + "/../../node/base"
module FN
  module SWF
    module Node
      def Image(name, file)
        FN::Node::Base("image", :name => name, :file => file).extend(Image)
      end
      
      module Image 
        include FN::Node::Base
      
        def visit(struct, debug = false)
          has_no_children
          struct << %[.jpeg #{self[:name]} "#{self[:file]}"]
        end
      end
    end
  end
end