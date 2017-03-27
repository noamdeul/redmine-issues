require 'httparty'
require 'json'


def get_issues(project_id, type, key)
  query = project_id ? { project_id: project_id } : {}
  headers = {
    'X-Redmine-API-Key' => 'f28af2b9b33e5d626da5e96aa3f5b500b0c4a417'
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
    "title" => r["subject"].tr("'"," "),
    "description" => r["description"].tr("\n","  ").tr("\r","  ").tr("'"," "),
    "date" => r["start_date"]
  }
end

issues = get_issues(1, "issues.json", "issues").map do |r|
  {
    'id' => r['id'] ,
    "subject" => r["subject"].tr("'"," "),
    "status" => r["status"]["name"],
    "created_on" => Time.parse(r["created_on"]).strftime("%d-%m-%Y"),#.to_date,
    "days_open" => "#{(Time.now.to_date - Time.parse(r["created_on"]).to_date).round}" #r["created_on"]
  }
end
# open and write to a file with ruby
open('issues.json', 'w') { |f|
  f.puts "data = '" + issues.to_json + "';\nmessages = '" + messages.to_json + "';"
}
