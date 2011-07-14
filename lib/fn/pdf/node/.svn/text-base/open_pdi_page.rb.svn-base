require File.dirname(__FILE__) + "/../../node/base"
require "PDFlib"
module FN
  module PDF
    module Node

      def OpenPdiPage(pdi_var, page_number, page_var)
        FN::Node::Base("open_pdi_page", :pdi => pdi_var, :number => page_number, :assigns => page_var).extend(OpenPdiPage)
      end
      
      module OpenPdiPage 
        include FN::Node::Base
      
        def visit(struct)
          @logger = Logger.new("#{RAILS_ROOT}/log/pdf_writer_logs/#{Time.now.strftime('pdf_writer_log_%Y_%m_%d')}.log")
          # @logger.info "DOGS "*88 
          # @logger.info "struct.inspect: #{struct.inspect}"
          # @logger.info "struct[self[:pdi]]: #{struct[self[:pdi]]}"
          # @logger.info "self[:number].to_i: #{self[:number].to_i}"
          pg = struct.open_pdi_page(struct[self[:pdi]], self[:number].to_i, "")
          # @logger.info "self.inspect: #{self.inspect}" 
          # @logger.info "pg.inspect: #{pg.inspect}"
          # @logger.info "CATS "*88 
          struct.assigns self, pg
          visit_children struct
          struct.close_pdi_page(pg)
        end
      end
    end
  end
end