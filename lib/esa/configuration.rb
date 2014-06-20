module ESA
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :base_classes
    attr_accessor :extension_namespace
    attr_accessor :processor
    attr_accessor :context_checkers
    attr_accessor :context_freshness_threshold
    attr_accessor :context_providers
    attr_accessor :context_tree
    attr_accessor :context_walk_ignore

    def initialize
      @base_classes = [ESA::Ruleset, ESA::Event, ESA::Flag, ESA::Transaction].freeze

      @extension_namespace = "Accounting"

      @processor = ESA::BlockingProcessor

      @context_checkers = Set.new
      @context_checkers << ESA::BalanceChecker
      @context_checkers << ESA::SubcontextChecker

      @context_freshness_threshold = 15.minutes

      @context_providers = {
        'account'          => ESA::ContextProviders::AccountContextProvider,
        'accountable'      => ESA::ContextProviders::AccountableContextProvider,
        'accountable_type' => ESA::ContextProviders::AccountableTypeContextProvider,
        'month'            => [ESA::ContextProviders::DateContextProvider, {all: true, period: :month}],
        'date'             => [ESA::ContextProviders::DateContextProvider, {all: true, period: :date}],
      }

      @context_tree = {
        'account' => {
          'month'   => {
            'date' => {},
          },
        },
        'period' => {
          'account' => {
            'date' => {},
          },
        },
        'year' => {
          'account' => {
            'date' => {},
          },
        },
        'month'   => {
          'account' => {
            'date' => {},
          },
        },
        'date' => {
          'account' => {},
        },
      }

      @context_walk_ignore = ['filter']
    end

    def register(accountable, short_name=nil)
      accountable_name = accountable.to_s
      extension_name = short_name || accountable_name.demodulize

      @base_classes.each do |klass|
        klass.register_extension(accountable_name, self.extension_class(klass.name.demodulize, extension_name))
      end
    end

    def extension_class(extension_type, extension_name)
      [
        @extension_namespace.presence,
        "#{extension_type}s",
        "#{extension_name}#{extension_type}"
      ].compact.join('::')
    end

    def walk_context_tree(path=[], tree=@context_tree)
      if path.respond_to? :count and path.count == 0
        tree || {}
      elsif path.respond_to? :first and tree.is_a? Hash and path.first.in? tree
        self.walk_context_tree(path.drop(1), tree[path.first])
      else
        {}
      end
    end

    def context_providers_for_path(path=[])
      clean_path = path - context_walk_ignore
      @context_providers.slice(*self.walk_context_tree(clean_path).keys)
    end
  end
end
