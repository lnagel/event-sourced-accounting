module ESA
  class Context < ActiveRecord::Base
    attr_accessible :chart, :parent, :type, :name, :namespace
    attr_accessible :chart, :chart_id, :parent, :parent_id, :type, :name, :start_date, :end_date, :as => :admin
    attr_readonly   :chart, :parent

    belongs_to :chart
    has_many :accounts, :through => :chart
    has_many :rulesets, :through => :chart

    has_many :unscoped_events, :through => :rulesets, :source => :events, :uniq => true
    has_many :unscoped_flags, :through => :rulesets, :source => :flags, :uniq => true
    has_many :unscoped_transactions, :through => :accounts, :source => :transactions, :uniq => true
    has_many :unscoped_amounts, :through => :accounts, :source => :amounts, :uniq => true, :extend => Associations::AmountsExtension

    belongs_to :parent, :class_name => "Context"
    has_many :subcontexts, :class_name => "Context", :foreign_key => "parent_id", :dependent => :destroy

    after_initialize :default_values, :initialize_filters
    before_validation :update_name
    validates_presence_of :chart, :name
    validate :validate_parent

    scope :roots, lambda { where(parent_id: nil) }
    scope :subs,  lambda { where("esa_contexts.parent_id is not null") }

    def is_root?
      self.parent_id.nil?
    end

    def is_subcontext?
      self.parent_id.present?
    end

    def events
      self.apply(self.unscoped_events)
    end

    def flags
      self.apply(self.unscoped_flags)
    end

    def transactions
      self.apply(self.unscoped_transactions)
    end

    def amounts
      self.apply(self.unscoped_amounts)
    end

    def apply(relation)
      self.parents_and_self.inject(relation) do |r,context|
        context.inject_filters(r)
      end
    end

    def check_freshness
      Config.context_checkers.each do |checker|
        if checker.respond_to? :check_freshness
          checker.check_freshness(self)
        end
      end

      self.update_name
      self.save if self.changed?
    end

    def subcontext_namespaces
      self.subcontexts.pluck(:namespace).compact.uniq
    end

    def parents_and_self
      contexts = [self]
      while contexts.last.parent_id.present? and 
            not contexts.last.parent_id.in? contexts.map(&:id) and
            contexts.count < 16 do
        # found a valid parent
        contexts << contexts.last.parent
      end
      contexts.reverse
    end

    def effective_start_date
      self.parents_and_self.map(&:start_date).compact.max
    end

    def effective_end_date
      self.parents_and_self.map(&:end_date).compact.min
    end

    protected

    def validate_parent
      if self.parent == self
        errors[:parent] = "cannot self-reference, that would create a loop"
      end
    end

    def default_values
      self.chart ||= self.parent.chart if self.chart_id.nil? and not self.parent_id.nil?
    end

    def update_name
      self.name = self.create_name
    end

    def create_name
      if self.type.nil?
        self.chart.name unless self.chart.nil?
      else
        "#{self.type.demodulize} \##{self.id}"
      end
    end

    def initialize_filters
      @filters = []
    end

    def inject_filters(relation)
      @filters.select{|f| f.is_a? Proc}.
      inject(relation) do |r,filter|
        filter.call(r)
      end
    end
  end
end
