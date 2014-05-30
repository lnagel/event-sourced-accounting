module ESA
  class SubcontextChecker
    def self.providers(context, options = {})
      if :namespace.in? options
        if options[:namespace].respond_to? :each
          ESA.configuration.context_providers.slice(*options[:namespace])
        else
          ESA.configuration.context_providers.slice("#{options[:namespace]}")
        end
      else
        ESA.configuration.context_providers_for_path(context.effective_path)
      end
    end

    def self.check(context, options = {})
      providers(context, options).each do |namespace,provider|
        if provider.is_a? Class and provider.respond_to? :check_subcontexts
          provider.check_subcontexts(context, namespace)
        elsif provider.respond_to? :count and provider.count == 2 and
              provider[0].is_a? Class and provider[0].respond_to? :check_subcontexts and provider[1].is_a? Hash
          provider_klass, provider_options = provider
          provider_klass.check_subcontexts(context, namespace, provider_options)
        end
      end
    end
  end
end
