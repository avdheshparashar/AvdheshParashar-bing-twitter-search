class CombController < ApplicationController
  def search

  	require 'net/http'
    require 'twitter'


    if params[:name] && params[:keywords]		#Checking if it is GET or POST request or not

		    client = Twitter::REST::Client.new do  |config|
		      config.consumer_key = 'huKNTYl5LVS91jbNrDmg'
		      config.consumer_secret =  'rpwDF5qDbTSh75MYX8zGZbRLmYfEqWtwCeAWL1dQlA'
		    end
    
    
		    @twitter_array = Array.new		     
		    qury = params[:name] + " "+ "OR" + " "+ params[:keywords]		# Looking for name or keyword or both

		    client.search(qury, :result_type => "recent").take(25).each do |twitter_result|
		      @twitter_array.push(twitter_result.to_h())
		    end

#		Removing leading and trailing White Spaces
		    if params[:name]
		      person = params[:name].rstrip.lstrip.downcase
		    end
		    
		    if params[:keywords]
		      keywords = params[:keywords].rstrip.lstrip.downcase
		    end
=begin

#		Using google's freebase API to fetch name of spouse, but does not seem to be fully functional yet

		    
		    free_base_key = 'AIzaSyCD7Bi4JqQwy7FrWIuw-BcLkfRUcaywpBU'
		    query = person.gsub(' ','').split( /  */ ).join('+')
		    service_url = 'https://www.googleapis.com/freebase/v1/search'+'?'+'query='+query+'&key='+free_base_key+'&filter=%28any+type%3A%2Fpeople%2Fperson%29&%2Fpeople%2Fmarriage%2Fspouse&limit=1'

		    service_uri = URI(service_url)

			      requst = Net::HTTP::Get.new(service_uri.request_uri)

			      respnse = Net::HTTP.start(service_uri.hostname, service_uri.port, :use_ssl => service_uri.scheme == 'https'){|http|
			        http.request(requst)
			      }
			      bdy = JSON.parse(respnse.body)
			      puts bdy
=end

		    @name = person
		    @keyword = keywords
		    id = Comb.where(:name => person).and(:keyword =>keywords)

		    if params[:new]
		    	@bing = Comb.find(id)

		    	person_name = person.gsub(' ','').split( /  */ ).join('+')
			      key_word = keywords.gsub(' ','').split( /  */ ).join('+')

			      accountKey = 'i5oS4/TmJ13knMCx+vQCNg0sb2HpQyK1dKD4VduT51s'

			      url = 'https://api.datamarket.azure.com/Bing/Search/Web?$format=json&Query=%27'+person_name+'+'+key_word+'%27&$top=50'
			      uri = URI(url)

			      req = Net::HTTP::Get.new(uri.request_uri)
			      req.basic_auth( accountKey, accountKey)

			      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https'){|http|
			        http.request(req)
			      }
			      body = JSON.parse(res.body)
			      @bing.update_attributes(name: person, keyword: keywords, bing_result:body)
			      @result_set = body
			      @cache = false

			      return @result_set



		    end
		    
		    if(@bing = Comb.find(id))
		        
		        @bing = Comb.find(id)
		        @result_set = @bing.bing_result
		        @cache = true

		    else
		      person_name = person.gsub(' ','').split( /  */ ).join('+')
		      key_word = keywords.gsub(' ','').split( /  */ ).join('+')

		      accountKey = 'i5oS4/TmJ13knMCx+vQCNg0sb2HpQyK1dKD4VduT51s'

		      url = 'https://api.datamarket.azure.com/Bing/Search/Web?$format=json&Query=%27'+person_name+'+'+key_word+'%27&$top=50'
		      uri = URI(url)

		      req = Net::HTTP::Get.new(uri.request_uri)
		      req.basic_auth( accountKey, accountKey)

		      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https'){|http|
		        http.request(req)
		      }
		      body = JSON.parse(res.body)
		      new_record = Comb.new(name: person, keyword: keywords, bing_result:body)
		      new_record.save
		      @result_set = body
		      @cache = false

		      return @result_set
			end
    end

  end




end
