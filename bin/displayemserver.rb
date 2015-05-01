require_relative '../lib/display'

require 'eventmachine'

module DIDV
  module DisplayEMServer

    def post_init
      @display = Display.new
    end

    def receive_data

    end

  end

end

EventMachine.run do
  EventMachine.start_server '127.0.0.1',9002,DIDV::DisplayEMServer

end