require_relative 'phone'
module Bvr
  class Call
    include HappyMapper

    tag 'Call'
    attribute :id, String, tag: 'CallId'
    attribute :calltype, String, tag: 'CallType'
    attribute :start_time, Time, tag: 'StartTime'
    attribute :dest, Phone, tag: 'Destination', parser: :phone_number_parser
    attribute :duration, String, tag: 'Duration'
    attribute :charge, String, tag: 'Charge' #? currency

    def relative_duration
      Time.parse(self.duration, start_time)
    end
  end
end
