module ESA
  class ContextProvider
    def self.check_subcontexts(context, namespace, options = {})
      existing = existing_subcontexts(context, namespace)
      contained = contained_subcontexts(context, namespace, existing, options)

      created = contained - existing
      created.each do |sub|
        sub.save if sub.new_record? or sub.changed?
      end

      unregistered = contained - context.subcontexts
      context.subcontexts += unregistered

      removed = existing - contained
      context.subcontexts -= removed

      removed.each(&:destroy) if context.can_be_persisted?

      contained
    end

    def self.existing_subcontexts(context, namespace)
      context.subcontexts.where(namespace: namespace).all
    end

    def self.contained_subcontexts(context, namespace, existing, options = {})
      []
    end

    def self.affected_root_contexts(context)
      []
    end
  end
end
