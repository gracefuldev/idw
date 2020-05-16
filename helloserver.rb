#!/usr/bin/env ruby
require "webrick"
server = WEBrick::HTTPServer.new(Port: 8080)
server.mount_proc("/") { |req, res| res.body = "Hello, world!" }
trap("INT") { server.shutdown }
server.start
