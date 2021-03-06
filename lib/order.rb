require 'net/http'
require 'json'

require_relative 'signing'
require_relative 'tip'

class Order
  def tip
    @tip
  end

  def temperatures
    {
      'NA': 0,
      'AMBIENT': 100,
      'REFRIGERATED': 200,
      'FROZEN': 300
    }
  end
  
  def containers
    {
      'NA': 0,
      'BAG': 100,
      'BOX': 200,
      'TRAY': 300,
      'PALLET': 400,
      'BARREL': 500,
      'BASKET': 600,
      'BUCKET': 700,
      'CARTON': 800,
      'CASE': 900,
      'COOLER': 1000,
      'CRATE': 1100,
      'TOTE': 1200
    }
  end

  def initialize(params)
    @public_key   = params['public_key']
    @private_key  = params['private_key']
    @hasher_url   = params['hasher_url']
    @host         = params['host']
    @api_url      = params['api_url']
    @tip          = Tip.new(params)
  end

  def create(params)
    order_uri = URI(@api_url + '/order')

    request = Net::HTTP::Post.new(order_uri)
    request['Content-Type'] = 'application/json'

    if params['company_id']
      qry = {}
      qry['company_id'] = params['company_id']
      order_uri.query = URI.encode_www_form(qry)
      params.delete('company_id')
    end

    request.body = params.to_json

    signing_params = Signing.generate_signing_params(request,
                                                     'POST',
                                                     'order',
                                                     order_uri,
                                                     @private_key,
                                                     @public_key)
    Signing.sign(signing_params)

    response = Net::HTTP.start(order_uri.hostname, order_uri.port, :use_ssl => (order_uri.port == 443)) {|http|
      http.request(request)
    }

    JSON.parse(response.body)
  end

  def read(params)
    order_read_uri = nil

    # Get one order
    if params['order_id']
      order_read_uri = URI(@api_url + '/order/' + params['order_id'])
      if params['company_id']
        qry = {}
        qry['company_id'] = params['company_id']
        order_read_uri.query = URI.encode_www_form(qry)
      end
    # Get a page of orders starting at last_key
    elsif params['last_key']
      order_read_uri = URI(@api_url + '/order')
      qry = {}
      qry['last_key'] = params['last_key']
      if params['company_id']
        qry['company_id'] = params['company_id']
      end
      order_read_uri.query = URI.encode_www_form(qry)
    # Get the first page of orders
    else
      order_read_uri = URI(@api_url + '/order')
      if params['company_id']
        qry = {}
        qry['company_id'] = params['company_id']
        order_read_uri.query = URI.encode_www_form(qry)
      end
    end

    request = Net::HTTP::Get.new(order_read_uri)

    signing_params = Signing.generate_signing_params(request,
                                                     'GET',
                                                     'order',
                                                     order_read_uri,
                                                     @private_key,
                                                     @public_key)
    Signing.sign(signing_params)

    response = Net::HTTP.start(order_read_uri.hostname, order_read_uri.port, :use_ssl => (order_read_uri.port == 443)) {|http|
      http.request(request)
    }

    JSON.parse(response.body)
  end

  def estimate(params)
    params['origin'] || raise('Missing origin paramter')
    params['destination'] || raise('Missing destination paramter')

    estimate_uri = URI(@api_url + '/estimate')
    estimate_uri.query = URI.encode_www_form(params)

    request = Net::HTTP::Get.new(estimate_uri)

    signing_params = Signing.generate_signing_params(request,
                                                     'GET',
                                                     'estimate',
                                                     estimate_uri,
                                                     @private_key,
                                                     @public_key)

    Signing.sign(signing_params)

    response = Net::HTTP.start(estimate_uri.hostname, estimate_uri.port, :use_ssl => (estimate_uri.port == 443)) {|http|
      http.request(request)
    }

    JSON.parse(response.body)
  end

  def cancel(params)
    order_id = nil
    company_id = nil

    if params.instance_of? String
      order_id = params
    end

    if params.instance_of? Hash
      order_id = params['order_id']
      company_id = params['company_id']
    end

    order_id || raise('Missing order_id to cancel')

    cancel_uri = URI(@api_url + '/order/' + order_id + '/cancel')

    if company_id
      qry = {}
      qry['company_id'] = company_id
      cancel_uri.query = URI.encode_www_form(qry)
    end

    request = Net::HTTP::Post.new(cancel_uri)

    signing_params = Signing.generate_signing_params(request,
                                                     'POST',
                                                     'order',
                                                     cancel_uri,
                                                     @private_key,
                                                     @public_key)

    Signing.sign(signing_params)

    response = Net::HTTP.start(cancel_uri.hostname, cancel_uri.port, :use_ssl => (cancel_uri.port == 443)) {|http|
      http.request(request)
    }

    JSON.parse(response.body)
  end

  def items(params)
    company_id = nil

    if params.instance_of? Hash
      company_id = params['company_id']
    end

    items_uri = URI(@api_url + '/order/items')

    if company_id
      qry = {}
      qry['company_id'] = company_id
      properties_uri.query = URI.encode_www_form(qry)
    end

    request = Net::HTTP::Get.new(items_uri)

    signing_params = Signing.generate_signing_params(request,
                                                     'GET',
                                                     'order',
                                                     items_uri,
                                                     @private_key,
                                                     @public_key)

    Signing.sign(signing_params)

    response = Net::HTTP.start(items_uri.hostname, items_uri.port, :use_ssl => (items_uri.port == 443)) {|http|
      http.request(request)
    }

    JSON.parse(response.body)
  end

  def properties(params)
    company_id = nil

    if params.instance_of? Hash
      company_id = params['company_id']
    end

    properties_uri = URI(@api_url + '/order/properties')

    if company_id
      qry = {}
      qry['company_id'] = company_id
      properties_uri.query = URI.encode_www_form(qry)
    end

    request = Net::HTTP::Get.new(properties_uri)

    signing_params = Signing.generate_signing_params(request,
                                                     'GET',
                                                     'order',
                                                     properties_uri,
                                                     @private_key,
                                                     @public_key)

    Signing.sign(signing_params)

    response = Net::HTTP.start(properties_uri.hostname, properties_uri.port, :use_ssl => (properties_uri.port == 443)) {|http|
      http.request(request)
    }

    JSON.parse(response.body)
  end

  def driver_actions_meta(params)
    driver_actions_meta_uri = URI(@api_url + '/order/driver_actions_meta')

    request = Net::HTTP::Get.new(driver_actions_meta_uri)

    signing_params = Signing.generate_signing_params(request,
                                                     'GET',
                                                     'order',
                                                     driver_actions_meta_uri,
                                                     @private_key,
                                                     @public_key)

    Signing.sign(signing_params)

    response = Net::HTTP.start(driver_actions_meta_uri.hostname, driver_actions_meta_uri.port, :use_ssl => (driver_actions_meta_uri.port == 443)) {|http|
      http.request(request)
    }

    JSON.parse(response.body)
  end

  def signature(params)
    order_id = nil
    company_id = nil

    if params.instance_of? String
      order_id = params
    end

    if params.instance_of? Hash
      order_id = params['order_id']
      company_id = params['company_id']
    end

    order_id || raise('Missing order_id to fetch signature')

    signature_uri = URI(@api_url + '/order/signature/' + order_id)

    if company_id
      qry = {}
      qry['company_id'] = company_id
      signature_uri.query = URI.encode_www_form(qry)
    end

    request = Net::HTTP::Get.new(signature_uri)

    signing_params = Signing.generate_signing_params(request,
                                                     'GET',
                                                     'order',
                                                     signature_uri,
                                                     @private_key,
                                                     @public_key)

    Signing.sign(signing_params)

    response = Net::HTTP.start(signature_uri.hostname, signature_uri.port, :use_ssl => (signature_uri.port == 443)) {|http|
      http.request(request)
    }

    JSON.parse(response.body)
  end

  def pickup_signature(params)
    order_id = nil
    company_id = nil

    if params.instance_of? String
      order_id = params
    end

    if params.instance_of? Hash
      order_id = params['order_id']
      company_id = params['company_id']
    end

    order_id || raise('Missing order_id to fetch pickup_signature')

    signature_uri = URI(@api_url + '/order/pickup_signature/' + order_id)

    if company_id
      qry = {}
      qry['company_id'] = company_id
      signature_uri.query = URI.encode_www_form(qry)
    end

    request = Net::HTTP::Get.new(signature_uri)

    signing_params = Signing.generate_signing_params(request,
                                                     'GET',
                                                     'order',
                                                     signature_uri,
                                                     @private_key,
                                                     @public_key)

    Signing.sign(signing_params)

    response = Net::HTTP.start(signature_uri.hostname, signature_uri.port, :use_ssl => (signature_uri.port == 443)) {|http|
      http.request(request)
    }

    JSON.parse(response.body)
  end

  def simulate(params)
    market = nil
    order_id = nil
    simulation_uri = nil
    company_id = nil

    if params && params['market']
      market = params['market']
    end

    if params && params['order_id']
      order_id = params['order_id']
    end

    if params && params['company_id']
      company_id = params['company_id']
    end

    market || order_id || raise('Missing market or order_id parameter')

    if market
      simulation_uri = URI(@api_url + '/order/simulate/' + market)
    elsif order_id
      simulation_uri = URI(@api_url + '/order/simulate/order/' + order_id)
    end

    if company_id
      qry = {}
      qry['company_id'] = company_id
      simulation_uri.query = URI.encode_www_form(qry)
    end

    p simulation_uri

    request = Net::HTTP::Get.new(simulation_uri)

    signing_params = Signing.generate_signing_params(request,
                                                     'GET',
                                                     'order',
                                                     simulation_uri,
                                                     @private_key,
                                                     @public_key)

    Signing.sign(signing_params)

    response = Net::HTTP.start(simulation_uri.hostname, simulation_uri.port, :use_ssl => (simulation_uri.port == 443)) {|http|
      http.request(request)
    }

    JSON.parse(response.body)
  end
end