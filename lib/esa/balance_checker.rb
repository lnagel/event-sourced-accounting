module ESA
  class BalanceChecker
    def self.check(context)
      if not context.freshness.nil?
        #context.event_count = context.events.created_before(context.freshness).count
        #context.flag_count = context.flags.created_before(context.freshness).count
        context.transaction_count = context.transactions.created_before(context.freshness).count
        context.amount_count = context.amounts.created_before(context.freshness).count

        context.debits_total = context.amounts.debits.created_before(context.freshness).total
        context.credits_total = context.amounts.credits.created_before(context.freshness).total
        context.opening_balance = context.opening_context.amounts.created_before(context.freshness).balance
        context.closing_balance = context.closing_context.amounts.created_before(context.freshness).balance
      end
    end
  end
end
