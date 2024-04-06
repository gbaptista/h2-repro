# frozen_string_literal: true

require 'sequel'
require 'securerandom'
require 'time'
require 'json'

@log = File.open('data/logs.jsonl', 'a')

def get_precise_time
  Process.clock_gettime(Process::CLOCK_REALTIME, :nanosecond)
end

def nano_to_time(nano_time)
  sec, nsec = nano_time.divmod(1_000_000_000)
  Time.at(sec, nsec, :nsec)
end

def time_to_iso(time_obj)
  time_obj.iso8601(9) # 9 digits for nanoseconds
end

def log!(data)
  data[:duration] = {
    nano: data[:finished] - data[:started],
    micro: (data[:finished] - data[:started]) / 1000.0,
    milli: (data[:finished] - data[:started]) / 1_000_000.0
  }

  data[:started] = time_to_iso(nano_to_time(data[:started]))
  data[:finished] = time_to_iso(nano_to_time(data[:finished]))

  @log.puts data.to_json
end

connection = 'jdbc:h2:tcp://localhost:9092/the_database;CACHE_SIZE=65536'

DB = Sequel.connect(connection, user: 'sa', password: '')

puts "Valid Connection: #{DB.test_connection}"

create_table_sql = <<-SQL
  CREATE TABLE IF NOT EXISTS the_kv (
    the_key VARCHAR(255) PRIMARY KEY,
    the_value VARCHAR(255)
  );
SQL

DB.run(create_table_sql)

def create_and_insert_value!
  key = SecureRandom.uuid
  value = SecureRandom.uuid

  begin
    insert_row_sql = "INSERT INTO the_kv (the_key, the_value) VALUES ('#{key}', '#{value}');"
    started = get_precise_time
    DB.run(insert_row_sql)
    finished = get_precise_time

    log!({ started:, finished:, kind: 'success', key:, value:, sql: insert_row_sql })

    true
  rescue StandardError => e
    finished = get_precise_time
    log!({ started:, finished:, kind: 'error', message: e.message, key:, value:,
           sql: insert_row_sql })
    false
  end
end

@errors = 0

loop do
  @errors += 1 unless create_and_insert_value!
  break if @errors > 100
end
