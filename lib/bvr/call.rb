module Bvr
  class Call
    attr_accessor :id, :calltype, :start_time, :dest, :raw_duration, :charge

    def duration
      Time.parse(self.raw_duration, start_time)
    end

    def self.new_from_response(h)
      self.new do |call|
        call.id           = h['CallId']
        call.calltype     = h['CallType']
        call.start_time   = h['StartTime']
        call.dest         = h['Destination']
        call.raw_duration = h['Duration']
        call.charge       = h['Charge']
      end
    end
  end
end
