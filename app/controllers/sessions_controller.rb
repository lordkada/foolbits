class SessionsController < ApplicationController

  def create
    auth_hash = request.env['omniauth.auth']
    case auth_hash.provider
        when 'facebook'
            user = User.find_by_facebook_id auth_hash.uid
            user = User.new if user.nil?

            info = auth_hash.info
            
            user.first_name = info.first_name if user.first_name.nil?
            user.last_name = info.last_name if user.last_name.nil?
            user.email = info.email if user.email.nil?
            user.picture_url = info.image if user.picture_url.nil?

            user.facebook_id = auth_hash.uid if user.facebook_id.nil?
            user.facebook_access_token = auth_hash.credentials.token if auth_hash.credentials.token != user.facebook_access_token

            user.save! if user.changed?
            sign_in user 
    end
    redirect_to '/'
  end

  def destroy
    sign_out
    redirect_to '/'
  end

  def get
    render json: current_user
  end

  protected

  def auth_hash
    
  end
end