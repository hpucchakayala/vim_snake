get '/' do
  @leaders = User.order("topscore DESC").limit(10)
  erb :index
end

post '/newtop' do
  current_user.update_attributes(topscore: params[:score]) if params[:score]%125 == 0
end

get '/signin' do
  rt = request_token
  session[:request_token] = rt
  redirect rt.authorize_url
end

get '/signout' do
  session[:request_token] = nil
  session[:user_id] = nil
  redirect '/'
end

get '/oauth/callback' do
  rt = session[:request_token]
  @access_token = rt.get_access_token(:oauth_token => params[:oauth_token], :oauth_verifier => params[:oauth_verifier])
  handle = @access_token.params[:screen_name]
  user = User.find_or_initialize_by(handle: handle)
  user.update_attributes(:token => @access_token.token, :secret => @access_token.secret)
  session[:request_token] = nil
  session[:user_id] = user.id
  redirect '/'
end


