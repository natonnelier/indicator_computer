require "technical-analysis"
require_relative "../models/indicator"

TechnicalAnalysis::Indicator.roster.each do |indicator|
  value_klass = Kernel.const_get(indicator.to_s + "Value") rescue nil
  if value_klass.nil?
    name = indicator.to_s.split("::").last
    value_klass = Kernel.const_get(indicator.to_s + "::" + name + "Value")
  end
  response_keys = value_klass.new.instance_variables.map { |v| v.to_s.remove("@") }
  new_indicator = Indicator.create(
    indicator_name: indicator.indicator_name,
    indicator_symbol: indicator.indicator_symbol,
    response_keys: response_keys,
    min_data_size: indicator.min_data_size
  )
  puts "Indicator Created: #{new_indicator.indicator_name} -> #{new_indicator.indicator_symbol}"
end
