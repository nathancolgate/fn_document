require File.dirname(__FILE__) + '/util'
require File.dirname(__FILE__) + '/resource'
require File.dirname(__FILE__) + '/block'
require File.dirname(__FILE__) + '/pdf/writer'
require File.dirname(__FILE__) + '/swf/writer'

XML.default_keep_blanks = false

module FN
  class ItemNotFoundError < RuntimeError; end
  class Document
    module ClassMethods
      include Util
      
      # Creates a new FN::Document from an XML object that is in the old-
      # school (original) style
      def migrate_from(xml)
        raise_unless_xml_doc xml
        @xslt ||= XSLT::Stylesheet.new(
                  XML::Document.file(
                  File.dirname(__FILE__) + "/migrate.xslt"
                ))
        return FN::Document.new(@xslt.apply(xml))
      end
      
      # Reads XML from a file, and returns the FN::Document
      def file(file, options = {})
        new(XML::Document.file(file), options)
      end
      
      # Reads XML from a string, and returns the FN::Document
      def string(string, options = {})
        new(XML::Document.string(string), options)
      end
    end    
    extend ClassMethods
    
    include Util
    
    SPACE = /\s+/
    
    attr_accessor :resource_root
    attr_reader :xml
    
    def initialize(xml, options = {})
      raise_unless_xml_doc xml
      @xml = xml
      update_resources options
      # validate!
    end
    
    def update_resources(options = {})
      @resource_root = options[:resource_root]      if options[:resource_root]
      mapping = string_keys(options[:resources])    or return
      resources.each do |resource|
        path = mapping[resource.key.to_s]
        resource.path = path                        if path
      end
    end
    
    def menu_item(path)
      xpath = "//" + path.
                      split("/").
                      map{|label| "item[@label='#{label}']"}.
                      join("/")
      @xml.find_first(xpath) or raise ItemNotFoundError.new(xpath + "\n\n" + @xml.to_s)
    end
    
    def edit_menu_items
      @xml.find("//item[@label='Edit']/item")
    end
    
    def string_keys(hash)
      return nil unless hash
      hash.inject({}) do |m, (k, v)|
        m[k.to_s] = v
        m
      end
    end
    
    def remove_menu_items(*args)
      args.flatten.each do |arg|
        remove_menu_item arg
      end
    end
    
    def remove_menu_item(name)
      node = @xml.find_first("//item[@label='#{name}']")
      node.remove! unless node.nil?
      #@xml.find("//item[@label='#{name}']").each do |node|
      #  node.remove! # mongrels keep dying -> bug caused by finding two items named "Download"
      #end
    end
    
    def to_pdf(options = {})
      update_resources(options)
      @pdf ||= PDF::Writer.new
      @pdf.write(self, options)      
    end
        
    def to_swf(options = {})
      update_resources(options)
      @swf ||= SWF::Writer.new
      @swf.write(self, options)      
    end
    
    def blocks
      extend_block @xml.find("//block")
    end
    
    def text_blocks
      extend_block(@xml.find("//block[@type='text']")).sort_by{|b| b.sort_key }
    end
    
    def text_blocks_by(page)
      typed_blocks_by(page, "text")
    end
    
    def photo_blocks_by(page)
      typed_blocks_by(page, "photo")
    end
    
    def typed_blocks_by(page, type)
      query = "//page[@number='#{page}']//block[@type='#{type}']
              |//block[@type='#{type}' and @multipage='yes']".gsub(SPACE, '')
      extend_block(@xml.find(query)).sort_by{|b| b.sort_key }
    end
    
    def photo_blocks
      extend_block @xml.find("//block[@type='photo']")
    end
    
    def extend_block(blox)
      blox.map do |blk|
        blk.extend(FN::Block)
        blk
      end
    end
    
    def textflows
      @xml.find("//text")
    end
    
    def pages
      @xml.find("//page")
    end
    
    def dependencies?
      resources.all?{|r| r.complete? }
    end
    
    def printable?
      dependencies? && @resource_root
    end
    
    def resource_hash
      @resources ||= @xml.find("//resource").inject({}) {|memo, r|
        res = Resource.new(r)
        memo[res.key].delete      if memo[res.key]
        memo[res.key] = res
        memo
      }
    end
    
    def images
      photos + backgrounds
    end
    
    def photos
      resources.select{|r| r.type == "photo"}
    end
    
    def backgrounds
      resources.select{|r| r.type == "bkg"}
    end
    alias_method :bkgs, :backgrounds
    
    def fonts
     resources.select{|r| r.type == "font"}
    end
    
    def resources
      resource_hash.values.sort_by {|x| x.key }
    end
    
    def resource(key)
      resource_hash[key] || Resource.new(LibXML::XML::Node.new("anon", key))
    end
    
    # Raise unless this document matches an internal schema
    def validate!
      @schema ||= XML::RelaxNG.document(
                   XML::Document.file(
                   File.dirname(__FILE__) + "/validation.rng"
                 ))
      @xml.validate_relaxng(@schema)
    end
    
    # String representation of the internal XML document
    def xml_to_s
      @xml.to_s
    end
  end
end