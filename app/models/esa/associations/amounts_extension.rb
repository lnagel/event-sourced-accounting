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
        total = BigDecimal.new('0')
        each do |amount_record|
          if amount_record.amount
            total += amount_record.amount
          else
            total = nil
          end
        end
        return total
      end
    end
  end
end