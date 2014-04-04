module ESA
  class Context < ActiveRecord::Base
    attr_accessible :chart, :chart_id, :parent, :parent_id, :type, :name, :namespace, :position
    attr_accessible :chart, :chart_id, :parent, :parent_id, :type, :name, :namespace, :position, :start_date, :end_date, :as => :admin
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
    before_validation :update_name, :update_position
    validates_presence_of :chart, :name
    validate :validate_parent
    before_save :enforce_persistence_rule

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
      self.effective_contexts.inject(relation) do |r,context|
        context.inject_filters(r)
      end
    end

    def last_transaction_time
      if defined? @last_transaction_time
        @last_transaction_time
      else
        @last_transaction_time = self.transactions.maximum(:created_at)
      end
    end

    def check_freshness(depth=0)
      if self.is_update_needed?
        self.update!
      end

      if depth > 0 and self.last_transaction_time.present?
        self.subcontexts.each do |sub|
          if sub.freshness.nil? or sub.freshness <= self.last_transaction_time
            sub.check_freshness(depth - 1)
          end
        end
      end
    end

    def is_update_needed?
      if self.freshness.present?
        if self.last_transaction_time.present?
          self.freshness <= self.last_transaction_time
        else
          false
        end
      else
        true
      end
    end

    def update!
      self.freshness = Time.zone.now

      Config.context_checkers.each do |checker|
        if checker.respond_to? :check
          checker.check(self)
        end
      end

      self.update_name
      self.save if self.can_be_persisted?
    end

    def subcontext_namespaces
      self.subcontexts.pluck(:namespace).compact.uniq
    end

    def effective_contexts
      self.parents_and_self
    end

    def effective_path
      self.effective_contexts.map{|ctx| ctx.namespace || ""}
    end

    def effective_start_date
      self.effective_contexts.map(&:start_date).compact.max
    end

    def effective_end_date
      self.effective_contexts.map(&:end_date).compact.min
    end

    def opening_context
      if self.effective_start_date.present?
        end_date = self.effective_start_date - 1.day
        Contexts::OpenCloseContext.new(chart: self.chart, parent: self, end_date: end_date, namespace: 'opening')
      else
        Contexts::EmptyContext.new(chart: self.chart, parent: self, namespace: 'opening')
      end
    end

    def closing_context
      if self.effective_end_date.present?
        Contexts::OpenCloseContext.new(chart: self.chart, parent: self, end_date: self.effective_end_date, namespace: 'closing')
      else
        Contexts::OpenCloseContext.new(chart: self.chart, parent: self, namespace: 'closing')
      end
    end

    def change_total
      if self.debits_total.present? and self.credits_total.present?
        self.debits_total - self.credits_total
      else
        nil
      end
    end

    def can_be_persisted?
      self.type.present?
    end

    protected

    def validate_parent
      if self.parent == self
        errors[:parent] = "cannot self-reference, that would create a loop"
      end
    end

    def default_values
      self.chart ||= self.parent.chart if self.chart_id.nil? and not self.parent_id.nil?
      self.namespace ||= self.class.name.demodulize.underscore.gsub(/_context$/, '')
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

    def update_position
      self.position = self.create_position
    end

    def create_position
      nil
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

    def enforce_persistence_rule
      if not self.can_be_persisted?
        raise "#{self.class.name} objects are not intended to be persisted"
      end
    end
  end
end
