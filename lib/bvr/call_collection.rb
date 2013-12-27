module Bvr
  class CallCollection
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
    VALID_OPTIONS = [:date, :callid, :recordcount, :direction, :customer, :command]
    API_COMMANDS= {
      find_by_customer_id: 'calloverview'
    }

    attr_reader :query_params
    attr_accessor :raw_count, :raw_more_data, :collection

    def self.find_by_customer_id(customer_id, options={})
      raise ArgumentError.new('Unknown Argument') unless self.valid_options?(options)

      @query_params = options

      params = {
        command: API_COMMANDS[:find_by_customer_id],
        customer: customer_id
      }

      response = Bvr.connection.get(@query_params.merge(params))

      response['Calls'].nil? ? nil : self.new_from_response(response)
    end

    def self.new_from_response(h)
      self.new.tap do |calls_collection|
        calls_collection.raw_more_data  = h['MoreData'][0]
        calls_collection.raw_count = h['Calls'][0]['Count']
        calls_collection.collection = h['Calls'][0]['Call'].each_with_object([]) do |callH, array|
          array << Call.new_from_response(callH)
        end
      end
    end

    def count
      Integer(self.raw_count)
    end

    def next?
      self.raw_more_data == 'True'
    end

  private

    def self.valid_options?(options)
      options.empty? ? true : options.keys.all? { |option| VALID_OPTIONS.include? option }
    end
  end
end
