class CryptoController < ApplicationController
  def index
  end

  def setup
    render "_setup", layout: false
  end

end