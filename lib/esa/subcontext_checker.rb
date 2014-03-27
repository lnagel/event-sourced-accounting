module ESA
  class SubcontextChecker
    def self.check_freshness(context)
      ESA::Config.context_providers_for_path(context.effective_path).each do |namespace,provider|
        if provider.is_a? Class and provider.respond_to? :check_subcontexts
          provider.check_subcontexts(context, namespace)
        elsif provider.respond_to? :count and provider.count == 2 and 
              provider[0].is_a? Class and provider[0].respond_to? :check_subcontexts and provider[1].is_a? Hash
          klass, options = provider
          klass.check_subcontexts(context, namespace, options)
        end
      end
    end
  end
end
