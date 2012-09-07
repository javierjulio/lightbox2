require 'sinatra'

set :public_folder, Dir.getwd

get '/' do
  redirect to("index.html")
end