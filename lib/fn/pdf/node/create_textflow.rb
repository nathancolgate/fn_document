require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      def CreateTextflow(node)
        out = FN::Node::Base("create_textflow", :assigns => CreateTextflow.flow_name(node))
        out << XML::Node.new_cdata(CreateTextflow.format(node))
        out.extend(CreateTextflow)
      end
      
      module CreateTextflow 
        include FN::Node::Base
        NL = /\r|\n/
        SPACE = /\s+/
        
        BASE_FORMAT = {
          "face" => "Arial",
          "size" => "12",
          "blockindent" => "0",
          "indent" => "0",
          "leftmargin" => "0",
          "rightmargin" => "0",
          "leading" => "2",
          "color" => "#0000FF",
          "align" => "left",
          "bold" => false,
          "italic" => false,
          "underline" => false
        }
        
        def flow_name(node = nil)
          if node
            if node["id"]
              "flow-#{node["id"]}"
            else
              "flow-#{node["text"]}-#{node["index"]}"
            end
          else
            self["assigns"]
          end
        end
        
        def empty?
          inner_text.gsub(/<[^>]*>|\s+/, '').empty?
        end
        
        def inner_text
          child.to_s.gsub("<![CDATA[", "").gsub("]]>", "")
        end
      
        def visit(struct)
          tf = struct.create_textflow(inner_text, "")
          struct.assigns self, tf
        end
        
        def formatter(options)
          attrs = options.dup
          attrs["leftindent"] = (attrs["blockindent"].to_f + attrs["leftmargin"].to_f).to_i
          attrs["totalleading"] = (attrs["size"].to_f + attrs["leading"].to_f).to_i
          # logger.warn attrs.inspect
          attrs["formatted_color"] = format_color(attrs["color"])
          attrs["formatted_face"] = format_face(attrs)
          %(<encoding=unicode 
          embedding=true 
          adjustmethod=nofit 
          nofitlimit=100% 
          minspacing=100% 
          maxspacing=100% 
          kerning=true 
          charref=true
          fontname={#{attrs["formatted_face"]}} 
          fontsize=#{attrs['size']} 
          leftindent=#{attrs['leftindent']}
          rightindent=#{attrs['rightmargin']}
          leading=#{attrs["totalleading"]} 
          fillcolor={rgb #{attrs["formatted_color"]}}
          parindent=#{attrs["indent"]}
          underline=#{attrs['underline']}
          alignment=#{attrs["align"]}>).gsub(SPACE, ' ')
        end

        def format_face(attrs)
          # titlecase
          face = attrs["face"].split(SPACE).map{|s| s.capitalize }.join(" ")
          face += ",Bold" if attrs["bold"]
          face += ",Italic" if attrs["italic"]
          return face
        end

        def format_color(hex)
          hex.scan(/[\da-f]{2}/i).map{|s| s.to_i(16) / 255.0 }.join(" ")
        end
        
        def format(node, buffer = "<fontname=Arial encoding=#{Writer.encoding} fontsize=10>", options = BASE_FORMAT)
          return nil unless node
          
          options = options.dup
          if node.text?
            buffer << formatter(options)
            buffer << node.to_s.gsub(NL, '') 
          elsif node.element?
            case node.name.downcase
            when "br"; buffer << "<nextline>"
            when "b"; options["bold"] = true
            when "i"; options["italic"] = true
            when "u"; options["underline"] = true
            when "li"; buffer << "&bull;&nbsp;"
            when "p";  
              options["align"]  = node["ALIGN"] if node["ALIGN"]
            when "font";
              options["size"]   = node["size"]  if node["size"]
              options["face"]   = node["face"]  if node["face"]
              options["color"]  = node["color"] if node["color"]
              
              options["size"]   = node["SIZE"]  if node["SIZE"]
              options["face"]   = node["FACE"]  if node["FACE"]
              options["color"]  = node["COLOR"] if node["COLOR"]
            end
              
            node.children.each{|c| format(c, buffer, options)}
            
            case node.name.downcase
            when "p", "li"; 
              buffer << "<nextparagraph>"  
            end
          else
            raise "unhandled node type"
          end
          return buffer
        end
        
        extend self
      end
    end
  end
end