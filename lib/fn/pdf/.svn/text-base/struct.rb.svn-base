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
      
      def method_missing(*args, &block)
        @logger = Logger.new("#{RAILS_ROOT}/log/pdf_writer_logs/#{Time.now.strftime('pdf_writer_log_%Y_%m_%d')}.log")
        # @logger.info("This is what args looks like when we first get it: #{a.inspect}")
        args.map! do |elem|
          case elem
          when Hash:
            elem.inject([]) {|m, (key, value)| 
              m << "#{key}={#{value}}"
            }.join(" ")
          else
            elem
          end
        end
        begin
          # @logger.info("Calling #{args.inspect}, this struct: #{self.inspect}")
          @pdf.send(*args, &block)
        rescue Exception => error
          # @logger.info("FAILURE FAILURE FAILURE FAILURE FAILURE FAILURE")
          # @logger.info("Exception: #{error}")
          raise error
        end
      end
    end
  end
end