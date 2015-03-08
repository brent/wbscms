require 'sinatra'
require 'sinatra/reloader' if development?
require 'redcarpet'
require 'date'
require 'data_mapper'

configure do
  set :root, File.dirname(File.expand_path(__FILE__))
  set :posts, "public/posts"
  set :asset_types, %w{css img js}

  DataMapper.setup(:default, "sqlite://#{settings.root}/db/wbscms.db")

  class Admin
    include DataMapper::Resource

    property :id,        Serial
    property :username,  String, key: true, default: "admin"
    property :password,  String, default: "password"
    property :firstname, String
    property :lastname,  String
  end

  DataMapper.finalize
  DataMapper.auto_migrate!
  DataMapper.auto_upgrade!

  Admin.create()
end

helpers do
  def is_logged_in?(user)
  end
end

enable :sessions

get '/' do
  all_posts = Dir.glob("#{settings.posts}/*/*/*/*")
  all_posts.reverse!

  @posts = []
  all_posts.each do |path|
    path['public/posts/'] = ''
    parts = path.match(/^(\d*)\/(\d*)\/(\d*)/)
    @date = "#{parts[2]}/#{parts[3]}/#{parts[1]}"
    # @date = Date.parse(@date)
    # @date.strftime('%b %e, %Y')

    if File.directory? path
      @posts.push({ path: path, title: File.basename(path), date: @date })
    else
      @title = File.basename(path, File.extname(path))
      @title.gsub!(/-/, " ")
      @title.split.each { |word| word.capitalize! }.join(" ")
      # why doens't above work?
      @posts.push({ path: path.split('.')[0], title: @title, date: @date })
    end
  end

  erb :index, locals: { posts: @posts }
end

get '/:year/:month/:day/:title' do
  post_dir = "#{settings.posts}/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:title]}"

  if File.directory? post_dir
    @post = ""
    File.foreach("#{post_dir}/index.html") do |line|
      if line.match("href=|src=")
        pieces = line.match(/(.*href=")(.*)(".*)/)
        line = pieces[1] + "#{params[:title]}/#{pieces[2]}" + pieces[3]
      end
      @post << line
    end

    erb :html_post, locals: { post: @post }, layout: false
  else
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

    @post = ""
    File.foreach("#{post_dir}.md") do |line|
      @post << line
    end
    @post = markdown.render(@post)

    erb :text_post, locals: { post: @post, type: :text_post }
  end
end

get '/:year/:month/:day/:title/:asset/:file' do
  if settings.asset_types.include? params[:asset]
    send_file "#{settings.posts}/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:title]}/#{params[:asset]}/#{params[:file]}"
  end
end

get '/admin' do
  erb :admin
end

post '/admin/login' do
  @user = Admin.first(username: params[:username])
  puts "---#{@user.username}/#{@user.password}---"
  erb :admin
end
