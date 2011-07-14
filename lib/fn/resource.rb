require File.dirname(__FILE__) + "/util"

class String
  def starts_with?(other)
    head = self[0, other.length]
    head == other
  end
end

module FN
  class Resource
    include Util
    attr_reader :node
    
    def initialize(node)
      raise_unless_xml_node node
      @node = node
    end
    
    def complete?
      !@node.children.empty?
    end
    
    def manual?
      !!@node["manual"]
    end
    
    def path=(p)
      @node.children.each{|c| c.remove! }
      @node << p.to_s
    end
    
    def path
      @node.first? && @node.first.to_s
    end
    
    def path_from(root)
      File.expand_path("#{root}#{path}")
    end
     
    def key
      @node["id"]
    end
    
    def type
      @node["type"]
    end
    
    def delete
      @node.remove!
    end
  end
end