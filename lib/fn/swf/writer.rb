Dir[File.dirname(__FILE__) + "/**/*.rb"].each do |f|
  require f.sub(/\.rb$/, '')
end

module FN
  module SWF
    class Writer
      include FN::SWF::Node
      
      def initialize
      end
      
      def image_dimensions(image)
        img = `identify "#{image}"`.scan(/ JPEG (\d+)x(\d+)/).flatten.map{|a|a.to_i}
      end
      
      def write(doc, options = {})
        write_xml translate(doc, options), options[:save_as]
      end
      
      def write_xml(xml, file)
        xml.root.extend(FN::Node::Root)
        File.open("#{file}.txt", "w") {|f| f.puts xml.root.visit(FN::SWF::Struct.new).buffer }        
        cmd = %[swfc -o #{file} #{file}.txt]
        system(cmd) ? file : raise("couldn't write swf")
      end
            
      def translate(doc, options = {})
        raise "Not an FN Document" unless doc.is_a?(FN::Document)
        
        file          = options[:save_as] or raise "must provide :save_as"
        root          = options[:resource_root]
        
        context = FN::Node::Context.new       
        $depth = 500
        
        page = doc.pages.first
        context << Flash(page[:width], page[:height])
        
        # sorta no-op-ish
        # doc.fonts.each do |font|
        #   context.add Font.load_all_variants(font.key, font.path_from(root))
        # end
        
        global_texts = doc.textflows.inject({}) do |memo, node|
          memo[node["id"]] = node.children.to_s
          memo
        end
        
        context.add Break()
        
        image_dims = {}
        
        doc.images.each do |img|
          if img.complete?
            path = img.path_from(root)
            context.add Image(img.key, path)
            image_dims[img.key] = image_dimensions(path)
          end
        end
        
        context.add Break()
        
        doc.pages.each do |page|
          context.retain_after do
            context.pre HotSpot(page)
            context << Page(page[:number], page[:background])
            
            doc.text_blocks_by(page["number"]).each do |block|
              context.add Text(block, global_texts[block["text"]])
            end
            
            context.add Break()
            
            i = 0
            doc.photo_blocks_by(page["number"]).each do |block|
              i += 1
              context.add PhotoBlock(block, image_dims)
            end
            
            context.add Break()
          end
        end
        
        return context.doc
      end
    end
  end
end