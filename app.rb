require 'sinatra'
require "sinatra/json"
require 'sinatra/activerecord'
require 'json'
require './lib/helper'
require './models/indicator'
require './models/user'
require 'byebug'

set :database_file, 'config/database.yml'

class App < Sinatra::Base
  get '/' do
    'Hello world!'
  end

  get '/:indicator' do
    options = { price_key: :close, volume_key: :volume }.merge(params.slice(*accepted_params))
    indicator = Indicator.find_by(indicator_symbol: params[:indicator])
    options = options.transform_keys!(&:to_sym)
    results = indicator.calculate(options, '/home/nicolas/Downloads/daily_IBM.csv')
    array_results = results.map { |r| r.to_hash }
    json array_results
  end

  def accepted_params
    Kernel.const_get("TechnicalAnalysis::" + params[:indicator].camelize).valid_options
  end
end
