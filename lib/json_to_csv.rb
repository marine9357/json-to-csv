#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'csv'
require 'open-uri'

module JsonToCSV
  class Converter

    private_class_method def self.parse_json(json_path)
                            json_file = open(json_path) { |f| f.read }
                            parsed_json = JSON.parse(json_file)
                            unless parsed_json.is_a? Array
                              raise TypeError.new "Input JSON must be an array of objects"
                            end
                            parsed_json
                         end


    private_class_method def self.get_csv_header(json, parent=nil)
                           json.each_with_object([]) do |(k,v), header|
                             v_is_hash = v.is_a? Hash
                             key_with_parent = parent ? "#{parent}.#{k}" : k
                             if v_is_hash
                               header.concat(get_csv_header(v, key_with_parent))
                             else
                               header << key_with_parent
                             end
                           end
                         end


    private_class_method def self.get_csv_row(json)
                           json.each_with_object([]) do |(k,v), row|
                             v_is_hash = v.is_a? Hash
                             if v_is_hash
                               row.concat(get_csv_row(v))
                             elsif v.is_a? Array
                               row << v.join(',')
                             else
                               row << v
                             end
                           end
                         end

    def self.json_to_csv(json_path, csv_path)
      CSV.open(csv_path, "w") do |csv|
        users_json = parse_json(json_path)
        users_json.each do |row|
          if row['id'] == 0
            csv << get_csv_header(row)
          end
          csv << get_csv_row(row)
        end
      end
    end

  end
end
