require_relative '../lib/display'

require 'eventmachine'

module DIDV
  class Display_EM_server < EventMachine::Connection

  attr_accessor :display

    def post_init
      @display = Display.new
    end

    def receive_data

    end

  end

end

EventMachine.run do
  EventMachine.start_server '127.0.0.1',9001,DIDV::display_EM_server
end