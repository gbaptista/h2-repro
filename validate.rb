# frozen_string_literal: true

require 'sequel'
require 'json'
require 'ruby-progressbar'

connection = 'jdbc:h2:tcp://localhost:9092/the_database;CACHE_SIZE=65536'

DB = Sequel.connect(connection, user: 'sa', password: '')

puts "Valid Connection: #{DB.test_connection}"

puts ''

def self.count_lines(filename)
  raise 'File does not exist' unless File.exist?(filename)

  output = `wc -l #{filename}`
  output.split.first.to_i
rescue StandardError => e
  puts "An error occurred: #{e.message}"
  0
end

@result = { valid: 0, missing: 0, unexpected: 0 }

@missing = []

@progress = ProgressBar.create(
  format: '%a |%b%i| %p%% %t | %c of %C | %e',
  autofinish: false, total: count_lines('data/logs.jsonl') + 10
)

File.open('data/logs.jsonl', 'r') do |file|
  file.each_line do |raw|
    next if raw.strip.empty?

    log = JSON.parse(raw)
    if log['kind'] == 'success'
      sql = "SELECT * FROM the_kv WHERE the_key='#{log['key']}';"
      result = DB.fetch(sql).first
      if result && result[:the_value] == log['value']
        @result[:valid] += 1
      else
        @missing << log
        @result[:missing] += 1
      end
      @progress.increment
    end
  rescue StandardError => _e
    puts '-' * 20
    puts raw
    puts '-' * 20
    @result[:unexpected] += 1
  end
end

@progress.finish

puts ''

pp @result

if @missing.size.positive?
  puts ''
  pp @missing.sample
  puts ''
  pp @missing.sample
  puts ''
  pp @missing.sample
end
