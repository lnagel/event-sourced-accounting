require 'esa/blocking_processor'

module ESA
  module Config
    mattr_accessor :processor
    self.processor = ESA::BlockingProcessor

    mattr_accessor :context_checkers
    self.context_checkers = Set.new
  end
end
