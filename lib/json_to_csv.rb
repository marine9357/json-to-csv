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

    private_class_method def self.get_all_keys(json, parent=nil)
      json.each_with_object([]) do |(k,v),keys|
        v_is_hash = v.is_a? Hash
        key_with_parent = parent ? "#{parent}.#{k}" : k
        if v_is_hash
          keys.concat(get_all_keys(v, key_with_parent))
        else
          keys << key_with_parent
        end
      end
    end

    def self.json_to_csv(json_path, csv_dir)
      CSV.open(csv_dir, "w") do |csv|
        users_json = parse_json(json_path)
        users_json.each do |row|
          if row['id'] == 0
            csv << get_all_keys(row)
          end
          profiles = row['profiles']
          facebook_profile = profiles['facebook']
          twitter_profile = profiles['twitter']
          csv << [row['id'], row['email'], row['tags'].join(","), facebook_profile['id'], facebook_profile['picture'],
                  twitter_profile['id'], twitter_profile['picture']]
        end
      end
    end

  end
end
