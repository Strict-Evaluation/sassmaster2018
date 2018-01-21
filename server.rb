require 'sinatra'
require 'socket'
require 'json'

$client = TCPSocket.new 'localhost', 12345

post '/sarc' do
  data = JSON.parse(request.body.read.to_s)
  $client.puts data["text"]
  if response == 'quit' then exit end
  response = $client.gets
  puts "Response: #{response}"
  response
end
