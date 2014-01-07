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
### Retreiving All the info and form, and manage a customer
`customer = Bvr::Customer.find('customer_id')`

`customer.phones`

`customer.phones.add( Bvr::Phone.new('+4412345678') )`

`customer.balance`

`customer.credit.add(10.20)`

`customer.credit.rm(1.20)`

`customer.block!`

`customer.unblock!`

`calls = customer.calls({recordcount: 100})`

`calls.count #=> 250`

`calls.size #=> 100`

`calls.next? # => true, 150 are left`

`Bvr::Customer.authenticate('customer_id', 'pass')`

A lot of class methods are available, just have a look at the specs


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


[![Analytics](https://ga-beacon.appspot.com/UA-34823890-2/bvr/readme?pixel)](https://github.com/gregory/bvr)

