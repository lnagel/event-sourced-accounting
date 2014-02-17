module ESA
  # The Chart class represents an organized set of accounts in the system.
  #
  # @author Lenno Nagel
  class Chart < ActiveRecord::Base
    include Traits::Extendable

    attr_accessible :name

    has_many :accounts
    has_many :rulesets

    has_many :events, :through => :rulesets
    has_many :flags, :through => :rulesets
    has_many :transactions, :through => :accounts
    has_many :amounts, :through => :accounts, :extend => Associations::AmountsExtension

    after_initialize :default_values

    validates_presence_of :name
    validates_uniqueness_of :name

    private

    def default_values
      self.name ||= "Chart of Accounts"
    end
  end
end
