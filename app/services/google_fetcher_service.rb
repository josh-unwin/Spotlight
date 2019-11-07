# rubocop:disable Metrics/LineLength

require 'open-uri'
require 'json'

class GoogleFetcherService
  def initialize(name)
    @name = name
  end

  def grab_place(restaurant_id) # rubocop:disable Metrics/MethodLength
    # 1st API call
    formatted_name = @name.strip.gsub(/\s/, "%20") # All whitespace must be converted into %20 for the API to respond
    parsed_id = open("#{ENV['GOOGLE_BASE_URL']}#{formatted_name}&inputtype=textquery&fields=place_id&key=#{ENV['GOOGLE_API_KEY']}").read
    returned_place_id = JSON.parse(parsed_id)["candidates"][0]["place_id"]

    # 2nd API call
    fields = "formatted_address,geometry,icon,name,place_id,type,website,rating,review,user_ratings_total,price_level"
    parsed_places = JSON.parse(open("#{ENV['GOOGLE_DETAILS_URL']}#{returned_place_id}&fields=#{fields}&key=#{ENV['GOOGLE_API_KEY']}").read)

    parsed_places["result"]["reviews"].each do |place|
      GoogleReview.create(reviewer_image: place["profile_photo_url"],
                          reviewer_username: place["author_name"],
                          reviewer_profile_url: place["author_url"],
                          review_text: place["text"],
                          rating: place["rating"],
                          review_time: place["time"],
                          restaurant_id: restaurant_id)
    end
  end
  
end

# rubocop:enable Metrics/LineLength