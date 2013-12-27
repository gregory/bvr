# Bvr

The BestVoipReselling Ruby Gem

## Installation

Add this line to your application's Gemfile:

    gem 'bvr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bvr

## Usage

### Configuration
`
Bvr.configure do |config|
  config.username, config.password = ['username', 'password']
end
`
### Retreiving Call Overview
`
Bvr::CallOverview.find('a customer id')
`


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
