# Columns:
# name: string
# user_id: integer
# min_buy_required: integer, default: 1
# min_sell_required: integer, default: 1
# created_at: datetime
# updated_at: datetime

require './lib/helper'
require 'technical-analysis'
require 'sinatra/activerecord'
require_relative 'mark'

class Strategy < ActiveRecord::Base
  attr_accessor :name

  belongs_to :user
  has_many :marks
  has_many :indicators, through: :marks

  def filter
    # how many times a value should be present in non-required indicators 
    # in order to be selected
    required_dif = min_buy_required - marks.required.count

    if required_dif < 1
      required_dates
    else
      dates_filtered(required_dif)
    end
  end

  def computed_required
    marks.required.map { |m| m.filter_computed }.flatten
  end

  def computed_non_required
    marks.non_required.map { |m| m.filter_computed }.flatten
  end

  # returns Array of dates
  def required_dates
    required_dates_count.keys.select { |d| required_dates_count[d] == marks.required.count }.uniq
  end

  # returns Array of dates matching counts and required
  def dates_filtered(dif)
    if marks.required.present?
      required_dates.select { |date| non_required_dates_count[date].present? && non_required_dates_count[date] >= dif }
    else
      non_required_dates_count.select { |key, val| val >= dif }.keys
    end
  end

  # returns a hash { "some-date" => number-of-presences }
  def required_dates_count
    dates = computed_required.map(&:date_time)
    counts = Hash.new(0)
    dates.each { |date| counts[date] += 1 }
    counts
  end

  # returns a hash { "some-date" => number-of-presences }
  def non_required_dates_count
    dates = computed_non_required.map(&:date_time)
    counts = Hash.new(0)
    dates.each { |date| counts[date] += 1 }
    counts
  end
end
