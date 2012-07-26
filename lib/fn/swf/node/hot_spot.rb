require File.dirname(__FILE__) + "/../../node/base"
module FN
  module SWF
    module Node
      def HotSpot(page)
        x, y, x2, y2 = page[:hotspot].gsub(/\s/, '').split(",").map{|s| s.to_i}
        w = x2 - x
        h = y2 - y
        FN::Node::Base("hot_spot", :x => x, :y => y, :w => w, :h => h, :n => page[:number]).extend(HotSpot)
      end
      
      module HotSpot 
        include FN::Node::Base
      
        def visit(struct, debug = false)
          has_no_children
          
          x = self[:x]
          y = self[:y]
          w = self[:w]
          h = self[:h]
          n = self[:n]
          
      	  struct << ".box btni#{n} width=#{w} height=#{h} color=red fill=white"

      	  struct.<< ".button btn#{n}" do
        	  struct.<< ".show btni#{n} as=area", :no_end_tag do
        	    struct.<< ".on_release:" do
        	      struct << "gotoAndStop(#{n});"
      	      end
            end
          end
          
          struct.<< ".action:" do
            struct << "_root.attachMovie('btn#{n}', 'btni#{n}', #{$depth+=1}, {_x:#{x}, _y:#{y}});"
          	struct << "_root['btni#{n}']._x = #{x};"
          	struct << "_root['btni#{n}']._y = #{y};"
          end
        end
      end
    end
  end
end