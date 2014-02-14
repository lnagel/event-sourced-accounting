module ESA
  class Context < ActiveRecord::Base
    attr_accessible :chart, :parent, :type
    attr_readonly   :chart, :parent

    belongs_to :chart
    has_many :accounts, :through => :chart
    has_many :rulesets, :through => :chart

    has_many :unscoped_events, :through => :rulesets, :source => :events
    has_many :unscoped_flags, :through => :rulesets, :source => :flags
    has_many :unscoped_transactions, :through => :accounts, :source => :transactions
    has_many :unscoped_amounts, :through => :accounts, :source => :amounts

    belongs_to :parent, :class_name => "Context"
    has_many :subcontexts, :class_name => "Context", :foreign_key => "parent_id"

    # has_many :planets, :conditions => Planet.life_supporting.where_values,
    # :order => Planet.life_supporting.order_values
    after_initialize :default_values
    validates_presence_of :chart
    validate :validate_parent

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

      @filters.inject(relation){|r,filter| filter.(r)}
    end

    protected

    def validate_parent
      if self.parent == self
        errors[:parent] = "cannot self-reference, that would create a loop"
      end
    end

    def default_values
      @filters = []
    end
  end
end
