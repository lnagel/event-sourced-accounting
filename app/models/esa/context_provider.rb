module ESA
  class ContextProvider
    def self.check_subcontexts(context, namespace, options = {})
      existing = existing_subcontexts(context, namespace)
      contained = contained_subcontexts(context, namespace, existing, options)

      created = contained - existing
      created.each do |sub|
        sub.save if sub.new_record? or sub.changed?
      end

      removed = existing - contained
      removed.each(&:destroy) unless :remove.in? options and not options[:remove]

      if :freshness.in? options and options[:freshness]
        contained.each(&:check_freshness)
      end

      contained
    end

    def self.existing_subcontexts(context, namespace)
      if context.persisted?
        context.subcontexts.where(namespace: namespace).all
      else
        ESA::Context.where(parent_id: context.id, namespace: namespace).all
      end
    end

    def self.contained_subcontexts(context, namespace, existing, options = {})
      []
    end

    def self.affected_root_contexts(context)
      []
    end
  end
end
