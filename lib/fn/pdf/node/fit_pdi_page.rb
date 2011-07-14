require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node
      def FitPdiPage(var)
        FN::Node::Base("fit_pdi_page", :page => var)
      end
      
      module FitPdiPage 
        include FN::Node::Base
        
        def visit(struct)
          @logger = Logger.new("#{RAILS_ROOT}/log/pdf_writer_logs/#{Time.now.strftime('pdf_writer_log_%Y_%m_%d')}.log")
          # @logger.info "HELP "*88 
          # @logger.info "self[:page] => #{self[:page]}" # yields {page}
          # @logger.info "struct[self[:page]] => #{struct[self[:page]]}" # yields -1
          # @logger.info "struct => #{struct.inspect}"
          has_no_children
          struct.fit_pdi_page(struct[self[:page]], 0, struct[CURRENT_PAGE_HEIGHT], "")
          
        end
      end
    end
  end
end