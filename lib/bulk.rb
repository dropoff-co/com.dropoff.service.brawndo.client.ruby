require 'net/http'
require 'json'

require_relative 'signing'

class Bulk
  def initialize(params)
    @public_key   = params['public_key']
    @private_key  = params['private_key']
    @hasher_url   = params['hasher_url']
    @host         = params['host']
    @api_url      = params['api_url']
  end

  def create(params)
    bulk_uri = URI(@api_url + '/bulkupload')
    qry = {}
    qry['company_id'] = params['data']['client']['id']
    qry['customer_id'] = params['data']['user']['id']
    bulk_uri.query = URI.encode_www_form(qry)
    request = Net::HTTP::Post.new(bulk_uri)
    request.set_form(
      [
        ['file', File.open('./shortest copy.csv'), content_type: 'text/csv']
      ],
      'multipart/form-data'
    )

    signing_params = Signing.generate_signing_params(request, 'POST', 'bulk', bulk_uri, @private_key, @public_key)
    Signing.sign(signing_params)
    response = Net::HTTP.start(bulk_uri.hostname, bulk_uri.port, :use_ssl => (bulk_uri.port == 443)) {|http|
      http.request(request)
  }
  JSON.parse(response.body)


  end

end
