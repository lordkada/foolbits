class CryptoController < ApplicationController

  def index
  end

  def setup
    render "_setup", layout: false
  end

  def vault
    render "_vault", layout: false
  end

  def set_vault
    p "set_vault"
    p params
    current_user.vault = params["vault"]
    current_user.save!
    render json: { status: "ok" }
  end

  def keypair
    current_user.public_key = params["public_key"]
    current_user.private_key = params["private_key"]

    current_user.save!
    render json: { status: "ok" }
  end

end
