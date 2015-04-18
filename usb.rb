#simplest ruby program to read from PIC USBserial,
#using the SerialPort gem
#(http://rubygems.org/gems/serialport)

require "serialport"
require "pry"

module DIDV
  class Serial_communication

    attr_accessor :sp
    def initialize(baud_rate=57600, data_bits=8, stop_bits=1, parity=SerialPort::NONE)
      port_str = "/dev/ttyACM1"  #may be different for you
      @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    end

    def packetize_data data
      data_to_send = Array.new
      data_to_send[0] = 0x62.chr
      data_to_send[11] = 0x65.chr
      (1..10).each { |i| data_to_send[i] = data[i-1] }
      send_and_get_data data_to_send
    end

    def send_data data
      puts "Sending '#{data}'..."
      data.each { |c| sp.putc c }
      puts "Data sent :'#{data}'"
    end

    def get_data times=nil
      # this first version just gets data forever
      puts "Getting getting data..."
      if (times)
        times.times { puts sp.getc }
      else
        #TODO pensar na recepção
        loop { foward_received_data(sp.gets) }
      end
    end

    def send_and_get_data data
      send_data data
      get_data data.size
    end

    def foward_received_data data
      puts "#{data}" #modify to send data to somewhere that it makes sense
    end

  end
  serial = Serial_communication.new
  a = Array.new #test array
  (0..10).each {|data| a[data] = (data).chr}
  serial.packetize_data a
  binding.pry


end
