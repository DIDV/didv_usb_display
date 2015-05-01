require_relative '../lib/display'

require 'eventmachine'

module DIDV

  module DisplayDaemon

    def post_init
      @display = Display.new
    end

    def receive_data(input)
      @display.send_hex input if @display.valid? input
    end

  end
end

EventMachine.run do
  EventMachine.start_server '127.0.0.1',9002,DIDV::DisplayDaemon
end