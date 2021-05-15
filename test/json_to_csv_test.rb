#!/usr/bin/env ruby

require "test/unit"
require 'open-uri'
require_relative '../lib/json_to_csv'

class JsonToCsvTest < Test::Unit::TestCase
  include JsonToCSV

  FILE_LINKS = {'json' => "https://gist.githubusercontent.com/romsssss/6b8bc16cfd015e2587ef6b4c5ee0f232/raw/f74728a6ac05875dafb882ae1ec1deaae4d0ed4b/users.json",
                'csv' => "https://gist.githubusercontent.com/romsssss/2efc2ace305b98be85d0fe617a10ac8b/raw/a43cffb5dc2170294e9635207f18bacba2b68001/users.csv"}

  GENERATED_CSV_PATH = "../csv/generated_users.csv"
  INPUT_JSON_PATH = "../json/users.json"

  # Test with json and csv examples from the task description
  def test_json_to_csv
    JsonToCSV::Converter.json_to_csv(FILE_LINKS['json'], GENERATED_CSV_PATH)
    generated_csv = open(GENERATED_CSV_PATH) { |f| f.read }
    gold_csv  = open(FILE_LINKS['csv']) {|f| f.read }
    assert_equal generated_csv, gold_csv

    JsonToCSV::Converter.json_to_csv(INPUT_JSON_PATH, GENERATED_CSV_PATH)
    generated_csv = open(GENERATED_CSV_PATH) { |f| f.read }
    assert_equal generated_csv, gold_csv
  end

  # Test with misshaped or empty or invalid json input
  def test_misshaped_json
    assert_raise JSON::ParserError do
      JsonToCSV::Converter.json_to_csv("../json/misshaped.json", GENERATED_CSV_PATH)
    end
    assert_raise JSON::ParserError do
      JsonToCSV::Converter.json_to_csv("../json/empty.json", GENERATED_CSV_PATH)
    end
    assert_raise JSON::ParserError do
      JsonToCSV::Converter.json_to_csv("https://www.google.fr", GENERATED_CSV_PATH)
    end
    assert_raise TypeError do
      JsonToCSV::Converter.json_to_csv("../json/not_a_list.json", GENERATED_CSV_PATH)
    end
  end
end

