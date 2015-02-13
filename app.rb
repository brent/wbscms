require 'sinatra'

get '/' do
  all_paths = Dir.glob("posts/**/**")
  all_post_paths = all_paths.delete_if { |path| !path.include? ".md" }

  @posts = []
  all_post_paths.each do |path|
    @posts.push(
      { path: path.match(/posts\/(\d*\/\d*\/\d*\/.*)\..*/)[1],
        title: path.match(/\/(\w*)\./)[1] }
    )
  end

  erb :index, locals: { posts: @posts }
end

get '/:year/:month/:day/:title' do
  require 'redcarpet'
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

  @post = ""
  File.foreach("posts/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:title]}.md") do |line|
    @post << line
  end
  @parsed = markdown.render(@post)

  erb :post, locals: { post: @parsed }
end
