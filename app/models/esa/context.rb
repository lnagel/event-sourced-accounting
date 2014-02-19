module ESA
  class Context < ActiveRecord::Base
    attr_accessible :chart, :parent, :type, :name
    attr_readonly   :chart, :parent

    belongs_to :chart
    has_many :accounts, :through => :chart
    has_many :rulesets, :through => :chart

    has_many :unscoped_events, :through => :rulesets, :source => :events, :uniq => true
    has_many :unscoped_flags, :through => :rulesets, :source => :flags, :uniq => true
    has_many :unscoped_transactions, :through => :accounts, :source => :transactions, :uniq => true
    has_many :unscoped_amounts, :through => :accounts, :source => :amounts, :uniq => true, :extend => Associations::AmountsExtension

    belongs_to :parent, :class_name => "Context"
    has_many :subcontexts, :class_name => "Context", :foreign_key => "parent_id"

    after_initialize :default_values, :initialize_filters
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
      if self.parent.present? and self.parent.respond_to? :apply
        relation = self.parent.apply(relation)
      end

      @filters.
        select{|f| f.is_a? Proc}.
        inject(relation){|r,filter| filter.(r)}
    end

    def check_freshness
      if self.respond_to? :check_subcontexts
        self.check_subcontexts
      end
    end

    protected

    def validate_parent
      if self.parent == self
        errors[:parent] = "cannot self-reference, that would create a loop"
      end
    end

    def default_values
      self.chart ||= self.parent.chart if self.chart_id.nil? and not self.parent_id.nil?
      self.name ||= self.create_name if self.name.nil?
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
  end
end
