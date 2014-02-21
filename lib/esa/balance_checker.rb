module ESA
  class BalanceChecker
    def self.check_freshness(context)
      if not context.freshness.nil?
        context.event_count = context.events.with_time_lt(context.freshness).count
        context.flag_count = context.flags.with_time_lt(context.freshness).count
        context.transaction_count = context.transactions.with_time_lt(context.freshness).count
        context.amount_count = context.amounts.with_time_lt(context.freshness).count

        context.debits_total = context.amounts.debits.with_time_lt(context.freshness).total
        context.credits_total = context.amounts.credits.with_time_lt(context.freshness).total
        context.opening_balance = context.opening_context.amounts.with_time_lt(context.freshness).balance
        context.closing_balance = context.closing_context.amounts.with_time_lt(context.freshness).balance
      end
    end
  end
end
