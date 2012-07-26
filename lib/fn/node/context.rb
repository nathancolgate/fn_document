require "PDFlib"
Dir[File.dirname(__FILE__) + "/node/*.rb"].each do |f|
  require f.sub(/\.rb$/, '')
end
module FN
  module Node
    class Context
      attr_reader :doc
      attr_accessor :current
      
      def initialize
        @doc = XML::Document.new
        @doc.root = @current = FN::Node::Root()
      end
      
      def <<(node)
        add node
        @current = node
      end
      
      def root
        doc.root
      end
      
      def root?
        current == root
      end
      
      def add(node)
        @current << node
      end
      
      def retain_after
        old = @current
        yield self
        @current = old
      end
      
      def visit(struct, debug = false)
        root.visit(struct,debug)
        struct
      end
      
      def pre(item)
        if @current.first? 
          @current.first.prev = item
        else
          @current << item
        end
      end
      
      def inject_at_head(item)
        head = @doc.find_first("//begin_document")
        if head.first? 
          head.first.prev = item
        else
          head << item
        end
      end
      
      def inject_at_page(number)
        old = @current
        @current = @doc.find_first("//begin_page_ext[@number='#{number}']") or 
                   raise "page not found: #{number}.  Pages: #{@doc.find('//begin_page_ext').map{|n|n.to_s}.inspect}"
        yield self
        @current = old
      end
    end
  end
end