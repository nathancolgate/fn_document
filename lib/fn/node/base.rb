require File.dirname(__FILE__) + "/../util"
module FN
  module Node
    def self.Base(name, attributes = {})
      n = XML::Node.new(name)
      attributes.each {|k, v| n[k.to_s] = Base.value(v) }
      n.extend(Base)
      return n
    end
    
    module Base
      
      CURRENT_PAGE_WIDTH  = "__current_page_width"
      CURRENT_PAGE_HEIGHT = "__current_page_height"
    
      def visit(struct)
        visit_children(struct)
      end
      
      def has_no_children
        raise "should have no children" if children.any?{|c| !c.cdata?}
      end
      
      def visit_children(struct)
        children.each do |c| 
          if c.element?
            mixin(c)
            c.visit(struct)
          end
        end
        return struct
      end
      
      def mixin(node)
        name = classify(node.name)
        mod = FN::SWF::Node.const_get(name) rescue 
              FN::PDF::Node.const_get(name)
        node.extend(mod)
      end
      
      def classify(name)
        name.split("_").map{|s| s.capitalize}.join("")
      end
      
      def with_attributes_like(node)
        node.attributes.each do |attr|
          self[attr.name] = attr.value
        end
        self
      end
      
      def value(v)
        case v
        when Array: v.map{|e| value(e)}.join(" ")
        else
          v.to_s
        end
      end
      
      extend self
    end
  end
end