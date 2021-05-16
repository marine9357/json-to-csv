# json-to-csv

This lib allows you to convert JSON files composed of arrays of objects (all following the same schema) to a CSV file where one line equals one object.
It has been developped with **Ruby 2.6**.

## Getting started

    $ gem build json_to_csv.gemspec
    $ gem install json_to_csv-0.0.0.gem

## Use it in your Ruby code

    require 'json-to-csv'

    JsonToCsv::Converter.json_to_csv(<json file path or url>, <csv output file path>)

