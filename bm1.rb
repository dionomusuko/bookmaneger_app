require 'webrick'
require 'dbi'
require 'erb'
require 'sqlite3'

config = {
    :Port => 8080,
    :DocumentRoot => '.'
}

server = WEBrick::HTTPServer.new(config)

server.mount_proc "/" do |req, res|
    names = []
    dbh = DBI.connect('DBI:SQLite3:names.db')
        dbh.select_all("select * from namet") do |row|
        names << {id: row["id"], name: row["name"]}
        end
    dbh.disconnect
   res.body = ERB.new(File.read('bm1.erb')).result(binding)

   server.mount_proc "/bookinfo" do |req, res|
    dbh = DBI.connect('DBI:SQLite3:names.db')
    dbh.do("insert into namet (name) values  ('#{req.query["name"]}')")
    dbh.disconnect
    res.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, '/')
end

trap(:INT) do 
    server.shutdown
end
server.start


