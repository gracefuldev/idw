#!/usr/bin/env ruby
require "webrick"
server = WEBrick::HTTPServer.new(BindAddress: "0.0.0.0", Port: 8080)
server.mount_proc("/") { |req, res| res.body = "Hello, world!" }
trap("INT") { server.shutdown }
server.start
