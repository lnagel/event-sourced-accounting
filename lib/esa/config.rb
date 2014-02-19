require 'esa/blocking_processor'

module ESA
  module Config
    mattr_accessor :processor

    self.processor = ESA::BlockingProcessor
  end
end
