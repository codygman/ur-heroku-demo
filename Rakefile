require 'pg'

task "default" do
  puts "TODO HELP FIXME"
end

task "init-heroku-files" do

  puts "Creating Procfile..."
  File.open('Procfile','w') do |f|
    f.write('web: ./app.exe -t 1 -p $PORT\n')
  end

  puts "Creating Gemfile..."
  File.open('Gemfile','w') do |f|
    f.write("source :rubygems\n")
    f.write("gem 'pg', '0.11.0'\n")
  end

  `bundle install`
  `bundle show`

  puts
  puts "Done."
  puts
  puts "Make sure you modify Procfile to launch your own .exe."
  puts "You can test that by running:"
  puts
  puts "    $ foreman start"
  puts
  puts "Afterwords, be sure to commit your Gemfile, Gemfile.lock"
  puts "and your Procfile before pushing to Heroku"
  puts
end

task "get-urweb-pq-con" do
  puts "Looking for DATABASE_URL..."
  out = `heroku config -s`

  out.split(/\n/).each do |o|
    k,v = o.split(/=/,2)
    next unless k == "DATABASE_URL"

    res = v.scan(/postgres:\/\/(.*):(.*)@(.*)\/(.*)/)[0]
    if res == nil
      puts "Couldn't parse DATABASE_URL properly!"
      exit
    end

    user, pass, host, dbname = res
    puts "Done. Your URWEB_PQ_CON variable should be set with:"
    puts 
    puts "    $ heroku config:add URWEB_PQ_CON=\"dbname=#{dbname} user=#{user} password=#{pass} host=#{host}\""
    puts 

    break
  end
end

task "heroku-db-init", [:sqlfile] do |t, args|
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

  puts "Now dropping all old Ur/Web tables/sequences..."
  tabls = conn.exec("select tablename from pg_tables where tablename not like 'pg_%' and tablename not like 'sql_%' and tablename like 'uw_%';")
  tabls.each do |r|
    puts "Dropping table '#{r['tablename']}'"
    conn.exec("drop table #{r['tablename']};")
  end

  seqs  = conn.exec("select c.relname from pg_class c where c.relkind ='S' and c.relname like 'uw_%';")
  seqs.each do |r|
    puts "Dropping sequence '#{r['relname']}'"
    conn.exec("drop sequence #{r['relname']};")
  end

  puts "Now creating new schema..."
  conn.exec(schema)
end
