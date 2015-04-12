root_dir = File.dirname(File.expand_path(__FILE__))
app_file = File.join(root_dir, 'app.rb')
require app_file

set :environment, ENV['RACK_ENV'].to_sym
set :root,        root_dir
set :app_file,    app_file

set :public_folder, "public"
set :posts, "#{settings.public_folder}/posts"
set :asset_types, %w{css img js}

disable :run

run Sinatra::Application
