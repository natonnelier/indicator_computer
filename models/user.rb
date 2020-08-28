require 'sinatra/activerecord'

class User < ActiveRecord::Base
  
  has_many :strategies

end