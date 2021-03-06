require "rubygems"
require "PDFlib"
require "RMagick"
require "tempfile" # Built into ruby
require "open-uri" # So we can download remote files
Dir[File.dirname(__FILE__) + "/node/*.rb"].each do |f|
  require f.sub(/\.rb$/, '')
end
module FN
  module PDF
    class WriterError < RuntimeError; end
    class Writer
      
      include Node
      SPACE = /[\s_]+/
      
      def self.encoding=(e)
        @encoding = e
      end
      
      def self.encoding
        @encoding
      end
      
      def write(doc, options = {}, debug = false)
        options[:save_as] ||= (tmp = Tempfile.new("pdf"); tmp.close; tmp.path)
        write_xml translate(doc, options), options[:save_as], debug
      end
      
      def write_xml(xml, file, debug = false)
        xml.root.extend(FN::Node::Root)
        xml.root.visit(FN::PDF::Struct.new(debug),debug)
        return file
      end
      
      def titlecase(str)
        face = str.split(SPACE).map{|s| s.capitalize }.join("")
      end
      
      def translate(doc, options = {})
        raise "Not an FN Document" unless doc.is_a?(FN::Document)
        
        file                    = options[:save_as]
        bkg                     = options[:background]
        pdf_version             = options[:pdf_version] || 1.5
        license                 = options[:license]
        resource_file           = options[:font_list] || File.join(File.dirname(__FILE__), "pdflib.upr")
        self.class.encoding     = options[:encoding] || "unicode"
        textformat              = options[:textformat] || "utf8"
        root                    = options[:resource_root] || ""
        watermark               = options[:watermark]
        
        context = FN::Node::Context.new
        
        context.add SetParameter("license", license)
        context.add SetParameter("resourcefile", resource_file)
        context.add SetParameter("hypertextencoding", self.class.encoding)
        context.add SetParameter("textformat", textformat)
        
        context << OpenPdi(bkg, assigns = "pdi")      if bkg
        context << BeginDocument(file, pdf_version)
        context.add SetParameter("topdown", true)
        
        doc.fonts do |name|
          LoadFont.add_all_variants_to context, name
        end
        
        flows_by_name = {}
        doc.textflows.each do |flow|
          ctf = CreateTextflow(flow)
          flows_by_name[ctf.flow_name] = ctf
          context.add ctf
        end
        
        doc.pages.each do |page|
          context.retain_after do
            context << BeginPageExt(page["width"], page["height"], page["number"])
            if bkg
              context <<  OpenPdiPage("{pdi}", page["number"], assigns = "page" )
              context.add FitPdiPage("{page}")
            elsif page["background"]
              bkg_image = doc.resource(page["background"]).path_from(root)
              context.add LoadImage(bkg_image, "tmp")
              context.add FitImage("{tmp}", 0, page["height"], 
                                       :fitmethod => :meet, 
                                       :boxsize => [page["width"], page["height"]])
            end
            context.add(Watermark(watermark)) if watermark
          end
        end
        
        doc.text_blocks.each do |block|
          flow = CreateTextflow(block)
          
          context.retain_after do
            key = "flow-#{block.text}"
            if flow.empty?
              flow = flows_by_name[key]
            else
              flows_by_name.delete(key)
              context.add(flow)
            end
            
            if flow
              context << ResumePage(block.page_number)
              context << Invert(block) if block["flip"] == "yes"
              context.add FitTextflow(flow, block)
            end
          end
        end
        
        doc.photo_blocks.each do |block|
          image = nil
          begin
            context.inject_at_page(block.page_number) do 
              # image = doc.resource(block.src).path_from(root)
              # tmp = Magick::Image::read(image).first
              # http://stackoverflow.com/questions/7264895/rmagick-can-not-read-remote-image
              image = open(doc.resource(block.src).path_from(root))
              tmp = Magick::Image::from_blob(image.read).first
              dims = [tmp.columns.to_f, tmp.rows.to_f]
              x, y, width, height = calculate(block, dims)
              context.add LoadImage(image, "tmp")
              context.add FitImage("{tmp}", x, y, :fitmethod => "meet",
                                       :boxsize => [width, height])
            end
          rescue Magick::ImageMagickError => e
            $stderr.puts e.message
            $stderr.puts e.backtrace.join("\n")
            raise WriterError.new("Couldn't load remote photo '#{block.src}', given by #{doc.resource(block.src).node}")
          end
        end
        
        doc.pages.each do |page|
          context.add EndPageExt(page["number"])
        end
        
        return context.doc
      end
      
      
      def calculate(block, dims)
        x = bx = block["boxX"].to_i
        y = by = block["boxY"].to_i
        bw = block["boxWidth"].to_i
        bh = block["boxHeight"].to_i
        aw = block["width"].to_i
        iw, ih = dims
        ah =  aw * ih / iw
        case block["align"]
        when /right/
          x = bx + bw - aw
        when /center/
          x = bx + (bw - aw) / 2
        else
          x = bx
        end
        
        case block["align"]
        when /bottom/
          y = by + bh 
        when /middle/
          y = by + bh / 2
        else
          y = by
        end
        
        return [x, y, aw, ah]
      end
      
    end
  end
end