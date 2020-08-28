require './lib/helper'
require "technical-analysis"
require 'sinatra/activerecord'
require 'byebug'
require_relative "mark"

class Indicator < ActiveRecord::Base

  has_many :marks
  has_many :strategies, through: :marks


  def valid_options
    library_class.valid_options
  end

  def calculate(opts = {}, path = '/home/nicolas/Downloads/BTC-USD.csv')
    TechnicalAnalysis::Indicator.calculate(
      indicator_symbol, data(path), :technicals, opts.slice(*valid_options)
    )
  end

  def data(path)
    Helper.get_csv_data(path, :date_time, :high, :low, :close, :volume)
  end

  def accepted_params
    library_class.valid_options
  end

  private
    def library_class
      Kernel.const_get("TechnicalAnalysis::" + indicator_symbol.camelcase)
    end

end
