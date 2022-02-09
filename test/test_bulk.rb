require_relative '../brawndo'

config = {}
config['public_key'] = 'bce5d3e8dff43743d6a1a241694e247a33dc35cf23fb3e36d727a0fa62179b4b'
config['private_key'] = '6cc3fcf4b4db7b7550fc53414d4d1c15afe5ab0e65c7c6d1afcfce39c501861c'
config['api_url'] = 'http://localhost:9094/v1'
config['host'] = 'http://localhost:9094'

duration = 5

brawndo = Brawndo.new(config)
info_data = brawndo.info()
bulk_data = brawndo.bulk()
bulk_data.create(info_data, './shortest copy.csv')