module ESA
  class Flag < ActiveRecord::Base
    include Extendable
    extend ::Enumerize

    attr_accessible :nature, :set, :event, :time, :accountable, :type, :ruleset

    belongs_to :accountable, :polymorphic => true
    belongs_to :event
    belongs_to :ruleset
    has_many   :transactions

    enumerize :nature, in: [:unknown]

    validates_presence_of :nature, :event, :time, :accountable, :ruleset
    validates_inclusion_of :set, :in => [true, false]

    after_initialize :default_values
    after_create :create_transactions

    def create_transactions
      if Settings.accounting[:create_transactions]
        self.save_produced_transactions
      end
    end

    def self.valid_flag?(flag_sym)
      enums_for(:flag).has_key?(flag_sym)
    end

    def self.valid_state?(state)
      state != nil and [true, false].include?(state)
    end

    def self.flag_sym_to_int(flag_sym)
      enums = enums_for(:flag)
      enums[flag_sym] if enums.present?
    end

    def self.get_state(flag_list, flag_sym, time = Time.zone.now)
      if valid_flag?(flag_sym)
        most_recent = flag_list.
              where('flag = ?', flag_sym_to_int(flag_sym)).
              where('time <= ?', time).
              order('time DESC, created_at DESC').first

        if most_recent != nil
          most_recent.set # return the set bit of this flag
        else
          nil
        end
      else
        nil
      end
    end

    def self.set_state!(flag_list, flag_sym, new_state, event = nil, time = Time.zone.now)
      if valid_flag?(flag_sym) and valid_state?(new_state)
        new_flag = flag_list.new({:flag => flag_sym, :set => new_state, :event => event, :time => time})
        new_flag.save
        new_flag # return the ptr
      else
        false
      end
    end

    def self.is_set?(flag_list, flag_sym, time = Time.zone.now)
      get_state(flag_list, flag_sym, time).present?
    end

    def self.would_change?(flag_list, flag_sym, new_state, time = Time.zone.now)
      if valid_flag?(flag_sym) and valid_state?(new_state)
        if new_state != is_set?(flag_list, flag_sym, time)
          true
        else
          false
        end
      else
        false
      end
    end

    def self.change_state!(flag_list, flag_sym, new_state, event = nil, time = Time.zone.now)
      if would_change?(flag_list, flag_sym, new_state, time)
        set_state!(flag_list, flag_sym, new_state, event, time)
      end
    end

    # changes = {:flag => true, :flag2 => false, ...}
    def self.state_diff(flag_list, changes, time = Time.zone.now)
      Hash[changes.select{ |flag,state| would_change?(flag_list, flag, state, time) }]
    end

    # gives you back the new flags, unsaved
    def self.produce_flags(flag_list, event, changes)
      state_diff(flag_list, changes, event.time).map do |flag,state|
        flag_list.new(:flag => flag, :set => state, :event => event, :time => event.time)
      end
    end

    def produce_transactions
      if self.ruleset.present?
        transactions = self.ruleset.flag_transactions(self)

        transactions.map do |tx|
          Transaction.extension_class(self).new(tx)
        end
      end
    end

    def save_produced_transactions
      transactions = self.produce_transactions
      transactions.map(&:save).reduce(true){|a,b| a and b}
    end

    private

    def default_values
      self.time ||= Time.zone.now
      self.ruleset ||= Ruleset.extension_instance(self)
    end
  end
end
