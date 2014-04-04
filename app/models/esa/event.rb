module ESA
  # The Event class represents an event of significance to accounting,
  # which triggers the creation of Flags, which in turn create Transactions.
  #
  # @author Lenno Nagel
  class Event < ActiveRecord::Base
    include Traits::Extendable
    extend ::Enumerize

    attr_accessible :time, :nature, :accountable, :ruleset
    attr_readonly   :time, :nature, :accountable, :ruleset

    belongs_to :accountable, :polymorphic => true
    belongs_to :ruleset
    has_many   :flags
    has_many   :transactions, :through => :flags
    has_many   :amounts, :through => :transactions, :extend => Associations::AmountsExtension

    enumerize :nature, in: [:unknown, :adjustment]

    after_initialize :default_values
    validates_presence_of :time, :nature, :accountable, :ruleset
    validates_inclusion_of :processed, :in => [true, false]

    private

    def default_values
      self.time ||= Time.zone.now if self.time.nil?
      self.ruleset ||= Ruleset.extension_instance(self.accountable) if self.ruleset_id.nil? and not self.accountable_id.nil?
      self.processed ||= false
    end
  end
end
