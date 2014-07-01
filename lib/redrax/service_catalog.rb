module Redrax
  class ServiceCatalog
    def initialize(json)
      @services = json['access']['serviceCatalog']
    end

    def [](service)
      @services.find { |s| s['name'] == service }
    end

    def services
      @service_names ||= @services.map { |s| s['name'] }
    end
  end
end
