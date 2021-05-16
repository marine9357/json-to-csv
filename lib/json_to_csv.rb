#!/usr/bin/env ruby
require 'json'
require 'csv'
require 'open-uri'

module JsonToCSV
  class Converter


    # Function that takes a json path or link and parses it
    private_class_method def self.parse_json(json_path)
      json_file = open(json_path) { |f| f.read }
      parsed_json = JSON.parse(json_file)
      unless parsed_json.is_a? Array
        raise TypeError.new "Input JSON must be an array of objects"
      end
      parsed_json
    end


    # Function that takes a json object and generates the list of this object's attribute names
    private_class_method def self.get_csv_header(json, parent=nil)
     json.each_with_object([]) do |(k,v), header|
       # get the "profiles.facebook.id" format style
       key_with_parent = parent ? "#{parent}.#{k}" : k
       if v.is_a? Hash
         header.concat(get_csv_header(v, key_with_parent))
       else
         header << key_with_parent
       end
     end
    end


    # Function that takes a json object and generates the list of this object's attribute values
    private_class_method def self.get_csv_row(json)
     json.each_with_object([]) do |(k,v), row|
       if v.is_a? Hash
         row.concat(get_csv_row(v))
       elsif v.is_a? Array
         row << v.join(',')
       else
         row << v
       end
     end
    end


    # Main function, takes an input json path (file or link) and generates an output csv file in the given path
    def self.json_to_csv(json_path, csv_path)
      CSV.open(csv_path, "w") do |csv|
        json = parse_json(json_path)
        header = ''
        json.each_with_index do |row, k|
          row_header = get_csv_header(row)

          # append the csv header from the first json object attributes
          if k == 0
            csv << row_header unless row_header.empty?
            header = row_header

          # test if object has extra/missing/different attributes
          elsif row_header != header
            raise JSON::ParserError.new "JSON objects must follow the same schema"
          end

          csv << get_csv_row(row) unless row.empty?
        end
      end
    end

  end
end
