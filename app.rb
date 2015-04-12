require 'sinatra'
require 'sinatra/reloader' if development?
require 'redcarpet'
require 'date'

configure do
  set :public_folder, "public"
  set :posts, "#{settings.public_folder}/posts"
  set :asset_types, %w{css img js}
end

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
      @posts.push({ path: path.split('.')[0], title: File.basename(path, File.extname(path)).gsub(/-/, ' '), date: @date })
    end
  end

  erb :index, locals: { posts: @posts }
end

get '/:year/:month/:day/:title' do
  post_dir = "#{settings.posts}/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:title]}"

  if File.directory? post_dir
    @post = ""
    File.foreach("#{post_dir}/index.html") do |line|
      if line.match("href=|src=") && !line.match("href=\"http|href=\"www|src=\"http|src=\"www")
        pieces = line.match(/(.*[href=|src=]")(.*)(".*)/)
        unless pieces.nil?
          puts "\n\n#{pieces}\n#{pieces.length}\n"
          line = pieces[1] + "#{params[:title]}/#{pieces[2]}" + pieces[3]
        end
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

get %r{(\d{4})\/(\d{2})\/(\d{2})\/(.*)\/(\w*)\/(\w*)\.(\w*)} do
  if settings.asset_types.include? params[:captures][4]
    send_file "#{settings.posts}/#{params[:captures][0]}/#{params[:captures][1]}/#{params[:captures][2]}/#{params[:captures][3]}/#{params[:captures][4]}/#{params[:captures][5]}.#{params[:captures][6]}"
  end
end
