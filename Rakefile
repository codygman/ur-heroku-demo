require 'pg'

task "db-reinit", [:sqlfile] do |t, args|
  puts "Reading #{args.sqlfile}"
  schema = IO.read(args.sqlfile)

  dbcon = ENV['URWEB_PQ_CON']
  res = dbcon.scan(/.*dbname=([^\s]*).*$/)[0]
  if res == nil
    puts "No dbname found in URWEB_PQ_CON, aborting!"
    exit
  end
  dbname = res[0]
  if res == nil
    puts "No dbname found in URWEB_PQ_CON, aborting!"
    exit
  end

  puts "Connecting to database '#{dbname}' specified by URWEB_PQ_CON (value is '#{dbcon}')"
  conn = PGconn.connect(dbcon)
  
  puts "Now dropping old database schema and its data..."
  conn.exec("DROP SCHEMA IF EXISTS public CASCADE;")
  conn.exec("CREATE SCHEMA public;")
  puts "Now creating schema..."
  conn.exec(schema)
end
