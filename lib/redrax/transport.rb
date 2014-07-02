require 'delegate'

class Transport < SimpleDelegator
  US_SERVER = 'https://identity.api.rackspacecloud.com'

  def initialize(service, region, service_catalog)
    unless service && region && service_catalog
      fail ArgumentError, "Must provide service, region, and service_catalog"
    end

    service_entry = service_catalog[service]
    region_endpoint = service_entry['endpoints'].find { |e| e['region'] == region }
    url = region_endpoint['publicURL']
    
    __setobj__(Faraday.new(:url => url))
  end 
end
