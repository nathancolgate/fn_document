module FN
  module Block
    def page_number
      find_first("ancestor::page")["number"].to_i
    end
    
    def content?
      content && !content.empty?
    end
    
    def text
      self["text"]
    end
    
    def src
      self["src"]
    end
    
    def index
      self["index"] && self["index"].to_i
    end
    
    def sort_key
      "#{text}-#{index}"
    end
  end
end