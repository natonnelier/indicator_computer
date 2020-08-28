require 'csv'

class Helper

  FLOAT_KEYS = [:open, :high, :low, :close].freeze
  INTEGER_KEYS = [:volume].freeze

  def self.get_csv_data(file_path, *columns, date_time_key: :date_time)
    @data = CSV.read(file_path, headers: true)
    columns = columns.map(&:to_sym)
    output = []
    @data.each do |v|
      col_hash = { date_time_key => v["date_time"] }
      columns.each do |col|
        value = v[col.to_s]
        value = value.to_f if FLOAT_KEYS.include?(col)
        value = value.to_i if INTEGER_KEYS.include?(col)
        col_hash[col] = value
      end
      output << col_hash
    end
    output
  end

end