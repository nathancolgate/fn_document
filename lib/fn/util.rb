require 'rubygems'
# gem "libxml-ruby", "=1.1.3"
# gem "libxslt-ruby", "=0.9.2"
gem "libxml-ruby"
gem "libxslt-ruby"
require 'libxml'
require 'libxslt'
include LibXML
include LibXSLT

module FN
  class XMLTypeError < TypeError; end
  
  module Util
    
    def raise_unless_xml_doc(xml)
      
      if !xml.is_a?(XML::Document)
        raise XMLTypeError.new("Not a LibXML doc")
      end
    end
    
    def raise_unless_xml_node(xml)
      if !xml.is_a?(XML::Node)
        raise XMLTypeError.new("Not a LibXML node")
      end
    end
  end
end