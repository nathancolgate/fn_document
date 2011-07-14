require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      
      def SetParameter(key, value)
        FN::Node::Base("set_parameter", :key => key, :value => value).extend(SetParameter)
      end
      
      module SetParameter 
        include FN::Node::Base
      
        def visit(struct)
          has_no_children
          struct[self[:key]] = self[:value]
          struct.set_parameter(self[:key], self[:value])
        end
      end
    end
  end
end