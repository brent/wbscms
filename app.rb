require 'sinatra'

get '/' do
  all_posts = Dir.glob("public/posts/*/*/*/*")

  @posts = []
  all_posts.each do |path|
    path['public/posts/'] = ''

    if File.directory? path
      @posts.push(
        { path: path,
          title: File.basename(path) }
      )
    else
      @posts.push(
        { path: path.split('.')[0],
          title: File.basename(path, File.extname(path)) }
      )
    end
  end

  @posts.each { |post| puts "XXX: #{post}" }
  erb :index, locals: { posts: @posts }
end

get '/:year/:month/:day/:title' do
  if File.directory? "public/posts/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:title]}"
    # send_file "public/posts/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:title]}/index.html"
    redirect "posts/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:title]}/index.html"
  else
    require 'redcarpet'
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

    @post = ""
    File.foreach("public/posts/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:title]}.md") do |line|
      @post << line
    end
    @parsed = markdown.render(@post)

    erb :post, locals: { post: @parsed }
  end
end
