require 'sinatra'
require 'socket'
require 'json'

$client = TCPSocket.new 'localhost', 12345

post '/sarc' do
  data = JSON.parse(request.body.read.to_s)
  $client.puts data["text"]
  response = $client.gets
  puts "Response: #{response}"
  response
end
