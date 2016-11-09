require 'httparty'
require 'json'


def get_issues
  query = { project_id: 1 }
  headers = {
    'X-Redmine-API-Key' => '1bf27c0e69064e411e64a162850b9b101da6621f'
  }

  response = HTTParty.get(
    "http://46.101.169.41/issues.json",
    :query => query,
    :headers => headers
  )

  if response.code == 200
    response["issues"]
  else
    []
  end

end

#puts get_issues

issues = get_issues.map do |r|
  {
    'id' => r['id'] ,
    "subject" => r["subject"],
    "status" => r["status"]["name"],
    "created_on" => Time.parse(r["created_on"]).strftime("%d-%m-%Y"),#.to_date,
    "days_open" => "#{(Time.now.to_date - Time.parse(r["created_on"]).to_date).round}" #r["created_on"]
  }
end
# open and write to a file with ruby
open('issues.json', 'w') { |f|
  f.puts "data = '" + issues.to_json + "';"
}
