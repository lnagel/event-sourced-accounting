require 'esa/blocking_processor'
require 'esa/balance_checker'

module ESA
  module Config
    mattr_accessor :processor
    self.processor = ESA::BlockingProcessor

    mattr_accessor :context_checkers
    self.context_checkers = Set.new
    self.context_checkers << ESA::BalanceChecker
  end
end
