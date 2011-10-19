require "PDFlib"
module FN
  module PDF
    class Struct < Hash
      attr_reader :pdf
      
      def initialize(debug = false)
        @pdf = PDFlib.new
        @debug = debug
      end  
      
      def assigns(node, value)
        self["{#{node[:assigns]}}"] = value
      end
      
      def method_missing(*a, &b)
        a.map! do |elem|
          case elem
          when Hash:
            elem.inject([]) {|m, (k, v)| 
              m << "#{k}={#{v}}"
            }.join(" ")
          else
            elem
          end
        end
        begin
          # puts "command: #{a.inspect}"        if @debug
          @pdf.send(*a, &b)
        rescue Exception => e
          $stderr.puts("tried calling #{a.shift} with args: #{a.inspect}, state: #{inspect}")
          raise e
        end
      end
    end
  end
end