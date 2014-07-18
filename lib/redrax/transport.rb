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

  # Hide the Faraday http request semantics behind this method
  # TODO: We're going to want to wrap errors here as well
  def make_request(method, path, params = {}, headers = {})
    if [:post, :put, :patch].include?(method) 
      send(method) do |r|
        r.headers.merge!(headers)
        r.url(path)
        r.body = params.to_json
      end
    else
      send(method, path, params, headers)
    end
  end
end
