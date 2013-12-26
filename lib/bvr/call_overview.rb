require_relative 'call'
module Bvr
  class CallOverview
    API_COMMAND = 'CallOverview'
    # Valid Options:
    #  Variable  Value Option  Description
    #  command calloverview  Mandatory
    #  username  X..140  Mandatory the username of the reseller
    #  password  X..100  Mandatory the password of the reseller
    #  customer  X..140  Mandatory the username of the customer
    #  date  YYYY-MM-DD hh:nn:ss Optional  the datetime from which to start retrieving the history, current datetime is default
    #  callid  N..1000000  Optional  the callid from which to start retrieving the history, 0 is default
    #  recordcount 1 - 500 Optional  the maximum number of records returned, 10 is default, 500 is maximum
    #  direction forward / backward  Optional  the direction to search, backward is default
    VALID_OPTIONS = [:date, :callid, :recordcount, :direction]

    include ::HappyMapper

    tag 'Calls'
    has_many :calls, Bvr::Call
    attribute :count, Integer, tag: 'Count'


    def self.find(customer_id, options={})
      raise ArgumentError.new('Unknown Argument') unless self.valid_options?(options)

      params = {
        command: API_COMMAND,
        customer: customer_id
      }

      options.merge! params
      self.parse(self.result(options)).first #only one <Calls> tag
    end

  private

    def self.result(options)
      Bvr.connection.get(options)
    end

    def self.valid_options?(options)
      options.empty? ? true : options.keys.all? { |option| VALID_OPTIONS.include? option}
    end
  end
end
