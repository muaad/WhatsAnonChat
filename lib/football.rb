class Football
	def self.get league, type, matchday
		HTTParty.get("http://api.football-data.org/alpha/soccerseasons/#{league}/#{type}?matchday=#{matchday}", {headers: {'X-Auth-Token' => ENV['FOOTBALL_TOKEN']}})
	end
	def table league=354
		# 354 - Premier League
		tbl = HTTParty.get("http://api.football-data.org/alpha/soccerseasons/#{league}/leagueTable", {headers: {'X-Auth-Token' => ENV['FOOTBALL_TOKEN']}})
		{ league: tbl[:leagueCaption], matchday: tbl[:matchday], table: tbl[:standing]}
	end

	def fixtures
		HTTParty.get("http://api.football-data.org/alpha/fixtures?timeFrame=n1", {headers: {'X-Auth-Token' => ENV['FOOTBALL_TOKEN']}})
	end
end