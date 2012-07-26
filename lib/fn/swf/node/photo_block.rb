require File.dirname(__FILE__) + "/../../node/base"
module FN
  module SWF
    module Node
      
      def PhotoBlock(node, image_dims = {})
        dims = image_dims[node[:src]]
        FN::Node::Base("photo_block", node.attributes.to_h.update(
          :orig_width => dims[0],
          :orig_height => dims[1]
        )).extend(PhotoBlock)
      end
      
      module PhotoBlock 
        include FN::Node::Base
      
        # <block type="photo" src="logo" width="162" boxX="30" boxY="40" 
        # boxWidth="185" boxHeight="99" align="middlecenter"/>
        def visit(struct, debug = false)
          has_no_children
          
          src   = self[:src]
          bx    = self[:boxX].to_i
          by    = self[:boxY].to_i
          bw    = self[:boxWidth].to_i
          bh    = self[:boxHeight].to_i
          w     = self[:width].to_i
          ow    = self[:orig_width].to_i
          oh    = self[:orig_height].to_i
          align = self[:align]
          
          scale   = w.to_f / ow
          percent = "#{scale * 100}%"
          h       = ow * scale
          
          x = case align
          when /center/: bx + (bw - w) / 2.0;
          when /right/:  bx + (bw - w)
          else;          bx
          end
          
          y = case align
          when /middle/: by + (bh - h) / 2.0;
          when /bottom/: by + (bh - h)
          else;          by
          end
            
          struct << ".put #{src} x=#{x} y=#{y} scalex=#{percent} scaley=#{percent}"
        end
      end
    end
  end
end