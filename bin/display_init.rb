require 'daemons'

script = "#{File.dirname(__FILE__)}/display_daemon.rb"
options = {
  app_name: "display_daemon",
  log_dir: "/home/didv",
  log_output: true
}

Daemons.run(script, options)
