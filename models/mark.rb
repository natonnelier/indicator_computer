# Columns:
# indicator_id: integer
# strategy_id: integer
# required: boolean
# created_at: datetime
# updated_at: datetime
# options: jsonb
# limits: jsonb, default: []
# fileset: string

require 'sinatra/activerecord'

class Mark < ActiveRecord::Base
  belongs_to :strategy
  belongs_to :indicator

  attribute :limits, :jsonb, default: []

  enum operation: { buy: 0, sell: 1 }

  DEFAULT_OPTIONS = { price_key: :close, volume_key: :volume }

  scope :required, -> { where(required: true) }
  scope :non_required, -> { where(required: false) }
  scope :buy, -> { where(operation: :buy) }
  scope :sell, -> { where(operation: :sell) }

  # limits are set in the following hash format: { name:"rsi", operation: ">", value: "40" }
  validate :limits_should_be_valid


  def filtered_options
    DEFAULT_OPTIONS.merge(options.slice(*indicator.accepted_params))
  end

  def limits_should_be_valid
    return if limits.empty?
    unless limits.all? { |l| indicator.response_keys.include? l[:name] }
      errors.add(:limits, "are not valid for indicator #{indicator.indicator_symbol}")
    end
  end

  def computed_results
    path = fileset || '/home/nicolas/Downloads/BTC-USD.csv'
    indicator.calculate(filtered_options, path)
  end

  def filter_computed
    computed_results.select do |r|
      limits.all? do |l|
        val = r.send(l.with_indifferent_access[:name])
        val.send(l.with_indifferent_access[:operation], l.with_indifferent_access[:value])
      end
    end
  end
end
