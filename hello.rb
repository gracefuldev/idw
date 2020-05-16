def hello
  puts "Hello, world"
end

TracePoint.new { }.enable
hello
