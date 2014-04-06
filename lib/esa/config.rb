module ESA
  module Config
    mattr_accessor :processor
    self.processor = ESA::BlockingProcessor

    mattr_accessor :context_checkers
    self.context_checkers = Set.new
    self.context_checkers << ESA::BalanceChecker
    self.context_checkers << ESA::SubcontextChecker

    mattr_accessor :context_providers
    self.context_providers = {
      'account'          => ESA::ContextProviders::AccountContextProvider,
      'accountable'      => ESA::ContextProviders::AccountableContextProvider,
      'accountable_type' => ESA::ContextProviders::AccountableTypeContextProvider,
      'monthly'          => [ESA::ContextProviders::DateContextProvider, {period: :month}],
      'daily'            => [ESA::ContextProviders::DateContextProvider, {period: :day}],
    }

    mattr_accessor :context_tree
    self.context_tree = {
      'account' => {
        'monthly' => {
          'daily' => {},
        },
      },
      'monthly' => {
        'account' => {
          'daily' => {},
        },
      },
      'daily' => {
        'account' => {},
      },
    }

    def self.walk_context_tree(path=[], tree=self.context_tree)
      if path.respond_to? :count and path.count == 0
        tree || {}
      elsif path.respond_to? :first and tree.is_a? Hash and path.first.in? tree
        walk_context_tree(path.drop(1), tree[path.first])
      else
        {}
      end
    end

    def self.context_providers_for_path(path=[])
      context_providers.slice(*walk_context_tree(path).keys)
    end
  end
end
