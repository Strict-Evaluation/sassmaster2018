require 'sinatra'
require 'socket'
require 'json'
require 'sinatra/cross_origin'

configure do
  enable :cross_origin
end

$client = TCPSocket.new 'localhost', 12345

post '/sarc' do
  data = JSON.parse(request.body.read.to_s)
  $client.puts data["text"]
  response = $client.gets
  if response == 'quit' then exit end
  puts "Response: #{response}"
  response
end

get '/sarc_query/:text' do
  data = params[:text].gsub '+', ' '
  $client.puts data
  response = $client.gets
  if response == 'quit' then exit end
  puts "Response: #{response}"
  r = JSON.parse(response)
  "
<html>
  <head>
  </head>
  <body>
    <p>
      Sarcasm: #{response}
    </p>
    <div>
      #{data} --> verdict:
      <b>
        #{case r["prediction"] when 'sarc' then 'SARCASTIC' when 'notsarc' then 'NOT SARCASTIC' else 'AMBIGUOUS' end}
      </b>
    </div>
  </body>
</html>
"
end
