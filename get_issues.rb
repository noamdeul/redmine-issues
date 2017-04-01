require 'httparty'
require 'json'

@config = JSON.load(File.read('config.json'))

def get_issues(project_id, type, key)
  query = project_id ? { project_id: project_id } : {}
  headers = {
    'X-Redmine-API-Key' => @config['redmine_api_key']
  }

  response = HTTParty.get(
    "http://#{@config['redmine_url']}/#{type}",
    :query => query,
    :headers => headers
  )

  if response.code == 200
    response[key]
  else
    []
  end

end

def get_weather
  url = "http://api.wunderground.com/api/#{@config['weather_api_key']}/conditions/q/Hod_Hasharon.json"
  response = HTTParty.get(url)

  if response.code == 200
    response["current_observation"]
  else
    {}
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

weather = get_weather

# open and write to a file with ruby
open('issues.json', 'w') { |f|
  f.puts "data = '" + issues.to_json + "';\nmessages = '" + messages.to_json + "';\nweather = '" + weather.to_json + "';"
}
