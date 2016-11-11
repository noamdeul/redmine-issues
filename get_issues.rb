require 'httparty'
require 'json'


def get_issues(project_id, type, key)
  query = project_id ? { project_id: project_id } : {}
  headers = {
    'X-Redmine-API-Key' => '1bf27c0e69064e411e64a162850b9b101da6621f'
  }

  response = HTTParty.get(
    "http://46.101.169.41/#{type}",
    :query => query,
    :headers => headers
  )

  if response.code == 200
    response[key]
  else
    []
  end

end

messages = get_issues(5, 'issues.json', 'issues').map do |r|
  {
    "title" => r["subject"],
    "description" => r["description"].tr("\n","  ").tr("\r","  "),
    "date" => r["start_date"]
  }
end

issues = get_issues(1, "issues.json", "issues").map do |r|
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
  f.puts "data = '" + issues.to_json + "';\nmessages = '" + messages.to_json + "';"
}
