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

            user.save! if user.changed?
            sign_in user 
    end

    redirect_to '/'

  end

  protected

  def auth_hash
    
  end
end