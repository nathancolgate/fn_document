require "rubygems"
require "PDFlib"
require "RMagick"
require "tempfile"
Dir[File.dirname(__FILE__) + "/node/*.rb"].each do |f|
  require_dependency f.sub(/\.rb$/, '')
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
      
      def write(doc, options = {})
        options[:save_as] ||= (tmp = Tempfile.new("pdf"); tmp.close; tmp.path)
        write_xml translate(doc, options), options[:save_as]
      end
      
      def write_xml(xml, file)
        xml.root.extend(FN::Node::Root)
        xml.root.visit(FN::PDF::Struct.new)
        return file
      end
      
      def titlecase(str)
        face = str.split(SPACE).map{|s| s.capitalize }.join("")
      end
      
      def translate(doc, options = {})
        raise "Not an FN Document" unless doc.is_a?(FN::Document)
        @logger = Logger.new("#{RAILS_ROOT}/log/pdf_writer_logs/#{Time.now.strftime('pdf_writer_log_%Y_%m_%d')}.log")
        
        
        debug         = options[:debug]
        file          = options[:save_as]
        bkg           = options[:background]
        pdf_version   = options[:pdf_version] ||
                        1.5
        license       = options[:license]
        resource_file = options[:font_list] ||
                        File.join(File.dirname(__FILE__), "pdflib.upr")
        self.class.encoding      = options[:encoding] || 
                        "unicode"
        textformat    = options[:textformat] || "utf8"
        root          = options[:resource_root] ||
                        ""
        watermark     = options[:watermark]
        
        context = FN::Node::Context.new
        
        # @logger.info "===== Setting Parameters ====="
        context.add SetParameter("license", license)
        context.add SetParameter("resourcefile", resource_file)
        context.add SetParameter("hypertextencoding", self.class.encoding)
        context.add SetParameter("textformat", textformat)
        
        if bkg
          # @logger.info "===== This Document Has a Background ====="
          context << OpenPdi(bkg, assigns = "pdi")      
        end
        
        # @logger.info "===== Uh... Begin Document ====="
        context << BeginDocument(file, pdf_version)
        
        # @logger.info "===== Setting A Forgotten Parameter ====="
        context.add SetParameter("topdown", true)
        
        # @logger.info "===== Adding #{doc.fonts.length} Fonts ====="
        doc.fonts do |name|
          LoadFont.add_all_variants_to context, name
        end
        
        # @logger.info "===== Adding #{doc.textflows.length} Text Flows ====="
        flows_by_name = {}
        doc.textflows.each do |flow|
          ctf = CreateTextflow(flow)
          flows_by_name[ctf.flow_name] = ctf
          context.add ctf
        end
        
        
        # @logger.info "===== Adding #{doc.pages.length} Pages ====="
        doc.pages.each_with_index do |page,index|
          context.retain_after do
            # @logger.info "Page #{index+1}:"
            # @logger.info "BeginPageExt(:width => #{page["width"]}, :height => #{page["height"]}, :number => #{page["number"]})"
            context << BeginPageExt(page["width"], page["height"], page["number"])
            if bkg
              # @logger.info "This Document Has Background"
              # @logger.info "OpenPdiPage(:pdi_var => \"{pdi}\", :page_number => #{page["number"]}, :page_var => \"page\")"
              context <<  OpenPdiPage("{pdi}", page["number"], assigns = "page" )
              # @logger.info "FitPdiPage(:var => \"{page}\")"
              context.add FitPdiPage("{page}")
            elsif page["background"]
              # @logger.info "Page #{index+1}: This Document does NOT have a Background, but the page does"
              bkg_image = doc.resource(page["background"]).path_from(root)
              context.add LoadImage(bkg_image, "tmp")
              context.add FitImage("{tmp}", 0, page["height"], 
                                       :fitmethod => :meet, 
                                       :boxsize => [page["width"], page["height"]])
            else
              # @logger.info "Page #{index+1}: Does not have a background at all"
            end
            context.add(Watermark(watermark)) if watermark
          end
        end
        
        # @logger.info "===== Adding #{doc.text_blocks.length} Text Blocks ====="
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
        
        # @logger.info "===== Adding #{doc.photo_blocks.length} Photo Blocks ====="
        doc.photo_blocks.each do |block|
          # require "ruby-debug"
          # debugger
          image = nil
          begin
            context.inject_at_page(block.page_number) do 
              image = doc.resource(block.src).path_from(root)
              tmp = Magick::Image::read(image).first
              dims = [tmp.columns.to_f, tmp.rows.to_f]
              x, y, width, height = calculate(block, dims)
              fi = FitImage("{tmp}", x, y, :fitmethod => "meet", :boxsize => [width, height], :inverted => block["flip"] == "yes")
              context.add LoadImage(image, "tmp")
              context.add(fi)
            end
          rescue Magick::ImageMagickError => e
            STDERR.puts e.message
            STDERR.puts e.backtrace.join("\n")
            raise WriterError.new("Couldn't load '#{block.src}', given by #{doc.resource(block.src).node}")
          end
        end
        
        # @logger.info "===== Closing #{doc.pages.length} Pages ====="
        doc.pages.each do |page|
          context.add EndPageExt(page["number"])
        end
        
        
        # @logger.info "====================================================================="
        # @logger.info "===== Somewhere after this point, the major churning begins     ====="
        # @logger.info "===== And starts looping through all the context things we just ====="
        # @logger.info "===== added and tries to execute them all                       ====="
        # @logger.info "====================================================================="
        
        # @logger.info "================================== doc.xml_to_s ================================="
        # @logger.info doc.xml_to_s
        # @logger.info "================================== context.doc.to_s ============================="
        # @logger.info context.doc.to_s
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
        when /right/:   x = bx + bw - aw
        when /center/:  x = bx + (bw - aw) / 2
        else            x = bx
        end
        
        case block["align"]
        when /bottom/:  y = by + bh 
        when /middle/:  y = by + bh / 2
        else            y = by
        end
        
        return [x, y, aw, ah]
      end
      
    end
  end
end