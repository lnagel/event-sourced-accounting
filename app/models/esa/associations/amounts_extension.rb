module ESA
  module Associations
    # Association extension for has_many :amounts relations. Internal.
    module AmountsExtension
      # Returns a total sum of the referenced Amount objects
      def total
        sums = group('esa_amounts.amount is null').
               sum(:amount)

        checked = sums.map do |s|
          amount_is_nil, amount = s.flatten
          amount
        end

        if checked.all?
          return checked.inject(BigDecimal(0)){|x,y| x + y}
        else
          return nil
        end
      end

      # Returns a sum of the referenced Amount objects.
      def balance
        sums = group('esa_amounts.amount is null').
               group('esa_amounts.type').
               sum(:amount)

        signed = sums.map do |s|
          amount_is_nil, amount_type, amount = s.flatten
          amount_type = amount_type.demodulize.downcase

          if amount_type == "debit"
            amount
          elsif amount_type == "credit"
            - amount
          else
            nil
          end
        end

        if signed.all?
          return signed.inject(BigDecimal(0)){|x,y| x + y}
        else
          return nil
        end
      end

      # Returns a sum of the referenced Amount objects.
      def iterated_total
        amounts = map(&:amount)

        if amounts.all?
          amounts.inject(BigDecimal(0)){|x,y| x + y}
        else
          return nil
        end
      end

      # Returns a sum of the referenced Amount objects.
      def iterated_balance
        amounts = map do |a|
          if a.is_debit?
            a.amount
          elsif a.is_credit? and not a.amount.nil?
            - a.amount
          else
            nil
          end
        end
        
        if amounts.all?
          amounts.inject(BigDecimal(0)){|x,y| x + y}
        else
          return nil
        end
      end
    end
  end
end