#simplest ruby program to read from PIC USBserial,
#using the SerialPort gem
#(http://rubygems.org/gems/serialport)

require "serialport"
require "pry"
#require "eventmachine"

# params for serial port
# usaly in the form of /dev/tty.usbmodem*
#port_str = "/dev/ttyACM0"
port_str = "/dev/ttyACM1"  #may be different for you
baud_rate = 57600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
a = Array.new #test array
(0..10).each {|data| a[data] = (data).chr}


def packetize_data sp, data
  data_to_send = Array.new
  data_to_send[0] = 0x62.chr
  data_to_send[11] = 0x65.chr
  (1..10).each { |i| data_to_send[i] = data[i-1] }
  send_and_get_data sp, data_to_send
end

def send_data sp, data
  puts "Sending '#{data}'..."
  data.each { |c| sp.putc c }
  puts "Data sent :'#{data}'"
end

def get_data sp#, times=nil
  # this first version just gets data forever
  puts "Getting getting data..."
 #"{ if (times)
  #  times.times { puts sp.getc }
  #else}"
    loop { puts sp.getc }
  #end
end

def send_and_get_data sp, data
  send_data sp, data
  get_data sp#, data.size
end


binding.pry

sp.close
