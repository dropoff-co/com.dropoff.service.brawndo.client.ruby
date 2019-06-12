require_relative '../brawndo'

config = {}
config['public_key'] = ''
config['private_key'] = ''
config['api_url'] = 'https://sandbox-brawndo.dropoff.com/v1'
config['host'] = 'sandbox-brawndo.dropoff.com'

duration = 5

brawndo = Brawndo.new(config)

info_data = brawndo.info()

p info_data

# property_data = brawndo.order.properties({});

# p property_data

driver_action_params = {}
driver_action_params['company_id'] = ''
driver_actions_meta_data = brawndo.order.driver_actions_meta(driver_action_params)

p driver_actions_meta_data

item_data = brawndo.order.items({});

p item_data

sig_params = {}
# sig_params['order_id'] = ''
sig_data = brawndo.order.signature('')

p sig_data

pu_sig_params = {}
pu_sig_params['order_id'] = ''
pu_sig_params['company_id'] = ''
pu_sig_data = brawndo.order.pickup_signature(pu_sig_params)

p pu_sig_data

if true
  raise('poop');
end

p '(1.) Reading first page of orders'

order_data = brawndo.order.read({})

p order_data
sleep(duration)

last_key_params = {}
last_key_params['last_key'] = order_data['last_key']

p '(2.) Reading subsequent page of orders'

order_data = brawndo.order.read(last_key_params)

p order_data
sleep(duration)

order_id_params = {}
order_id_params['order_id'] = order_data['data'][0]['details']['order_id']

p "(3.) Reading specific order #{order_id_params['order_id']}"

order_data = brawndo.order.read(order_id_params)

p order_data
sleep(duration)

no_order_id_params = {}
no_order_id_params['order_id'] = ''

p '(4.) Reading order that DNE'

order_data = brawndo.order.read(no_order_id_params)

p order_data

origin = {
  'address_line_1' => '117 San Jacinto Blvd',  # required
  'company_name' => 'Dropoff Ruby Origin',     # required
  'first_name' => 'Napoleon',                  # required
  'last_name' => 'Bonner',                     # required
  'phone' => '5125555555',                     # required
  'email' => 'noreply+origin@dropoff.com',     # required
  'city' => 'Austin',                          # required
  'state' => 'TX',                             # required
  'zip' => '78701',                            # required
  'lat' => '30.263706',                        # required
  'lng' => '-97.741703',                       # required
  'remarks' => 'Be nice to napoleon',          # optional
  'driver_actions' => '1100,1300'              # optional
}

destination = {
  'address_line_1' => '1601 S MoPac Expy',      # required
  'address_line_2' => 'C301',                   # optional
  'company_name' => 'Dropoff Ruby Destination', # required
  'first_name' => 'Del',                        # required
  'last_name' => 'Fitzgitibit',                 # required
  'phone' => '5125555555',                      # required
  'email' => 'noreply+destination@dropoff.com', # required
  'city' => 'Austin',                           # required
  'state' => 'TX',                              # required
  'zip' => '78746',                             # required
  'lat' => '30.260228',                         # required
  'lng' => '-97.793359',                        # required
  'driver_actions' => '2300'                    # optional
}

in_two_hours = Time.now.to_i + 7200

details = {
  'quantity' => 1,                   # required
  'weight' => 5,                     # required
  'eta' => '449.8',                  # required
  'distance' => '0.62',              # required
  'price' => '0.01',                 # required
  'ready_date' => in_two_hours,      # required
  'type' => 'two_hr'                 # required
}

estimate_params = {};
estimate_params['origin'] = '117 San Jacinto Blvd, Austin, TX 78701'
estimate_params['destination'] = '1601 S MoPac Expy, Austin, TX 78746'
estimate_params['utc_offset'] = Time.now.utc_offset

p '(5.) Estimating order'
estimate_data = brawndo.order.estimate(estimate_params)

p estimate_data
sleep(duration)

details['eta'] = estimate_data['data']['ETA'];
details['distance'] = estimate_data['data']['Distance'];
details['price'] = estimate_data['data']['asap']['Price'];
details['type'] = 'asap';

p details

items = [
  {
    'sku' => '128UV9',
    'quantity' => 3,
    'weight' => 10,
    'height' => 1.4,
    'width' => 1.2,
    'depth' => 2.3,
    'unit' => 'ft',
    'container' => brawndo.order.containers[:BOX],
    'description' => 'Box of t-shirts',
    'price' => 59.99,
    'temperature' => brawndo.order.temperatures[:NA],
    'person_name' => 'T. Shirt'
  },
  {
    'sku' => '128UV8',
    'height' => 9.4,
    'width' => 6.2,
    'depth' => 3.3,
    'unit' => 'in',
    'container' => brawndo.order.containers[:BOX],
    'description' => 'Box of socks',
    'price' => 9.99,
    'temperature' => brawndo.order.temperatures[:NA],
    'person_name' => 'Jim'
  }
]

order_data = {
  'origin' => origin,
  'destination' => destination,
  'details' => details,
  'items' => items
}

# p '(6.1) Creating new order'
# p order_data

# order_response_data = brawndo.order.create(order_data)

# p order_response_data

# order_id = order_response_data['data']['order_id']

# p "(6.2) Created #{order_id}"
# sleep(duration)

# tip_params = {
#   'order_id' => order_id,
#   'amount' => 5.55
# }

# p "(6.3) Creating order tip #{order_id}"
# tip_data = brawndo.order.tip.create(tip_params)

# p tip_data
# p "(6.4) Created order tip #{order_id}"
# sleep(duration)


# p "(6.5) Getting order tip #{order_id}"
# tip_data = brawndo.order.tip.read(order_id)

# p tip_data
# sleep(duration)



# p "(6.6) Deleting order tip #{order_id}"
# tip_data = brawndo.order.tip.delete(order_id)

# p tip_data
# sleep(duration)


# p "(6.7) Cancelling #{order_id}"
# cancel_data = brawndo.order.cancel(order_id)

# p cancel_data
