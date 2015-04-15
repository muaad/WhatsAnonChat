class Amazon
	def self.request
		request = Vacuum.new
		request.configure(
		    aws_access_key_id: Rails.application.secrets.aws_access_key_id
		    aws_secret_access_key: Rails.application.secrets.aws_secret_access_key
		    associate_tag: Rails.application.secrets.associate_tag
		)
	end

	def self.search keywords, search_index
		response = request.item_search(
		  query: {
		    'Keywords' => keywords,
		    'SearchIndex' => search_index
		  }
		)
	end
end