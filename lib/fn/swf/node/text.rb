require File.dirname(__FILE__) + "/../../node/base"
module FN
  module SWF
    module Node
      def Text(node, alt_text)
        out = FN::Node::Base("text", node.attributes.to_h)
        out.extend(Text)
        out.text = node.children.to_s
        out.text = alt_text                  if out.text.empty?
        out
      end
      
      module Text 
        include FN::Node::Base
        SPACE = /\s+/
                
        def text
          (child && child.content).to_s
        end
        
        def text=(s)
          self.children.map{|c| c.remove! }
          self << XML::Node.new_cdata(s)
        end
        
        def escaped_text
          text.gsub("\\", "\\\\").gsub("\"", "\\\"").gsub(SPACE, " ")
        end
              
        def visit(struct, debug = false)
          has_no_children
          name = "#{self[:text]}_#{self[:index]}"
          x = self[:x]
          y = self[:y]
          w = self[:width]
          h = self[:height].to_i + 20 # Fudge
           
          struct.<< ".action:" do
    			  struct << "this.createTextField('#{name}', #{$depth+=1}, #{x}, #{y}, #{w}, #{h});"
      			struct << "id = this['#{name}'];"
      			struct << "id.html=true;"
      			struct << "id.multiline=true;"
      			struct << "id.wordWrap=true;"
      			struct << "id.htmlText = \"#{escaped_text}\";"
      			struct << "id.selectable = false;"
    			end
        end
      end
    end
  end
end