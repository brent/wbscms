require 'sinatra'

set :posts, "public/posts"
set :asset_types, %w{css img js}

get '/' do
  all_posts = Dir.glob("#{settings.posts}/*/*/*/*")
  all_posts.reverse!

  @posts = []
  all_posts.each do |path|
    path['public/posts/'] = ''

    if File.directory? path
      @posts.push({ path: path, title: File.basename(path) })
    else
      @posts.push({ path: path.split('.')[0], title: File.basename(path, File.extname(path)) })
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
  else
    require 'redcarpet'
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

    @post = ""
    File.foreach("#{post_dir}.md") do |line|
      @post << line
    end
    @post = markdown.render(@post)
  end

  erb :post, locals: { post: @post }
end

get '/:year/:month/:day/:title/:asset/:file' do
  if settings.asset_types.include? params[:asset]
    send_file "#{settings.posts}/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:title]}/#{params[:asset]}/#{params[:file]}"
  end
end
