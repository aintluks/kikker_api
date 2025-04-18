require 'net/http'
require 'uri'
require 'json'
require 'ffaker'

# Configuration
NUM_USERS = 100
NUM_POSTS = 200_000
NUM_IPS = 50
RATING_PERCENTAGE = 0.75

# Helper method to make API requests
def api_request(method, endpoint, params = {})
  uri = URI("http://localhost:3000/api/v1/#{endpoint}")

  case method
  when :get
    uri.query = URI.encode_www_form(params)
    request = Net::HTTP::Get.new(uri)
  when :post
    request = Net::HTTP::Post.new(uri)
    request.body = params.to_json
  end

  request['Accept'] = 'application/json'
  request['Content-Type'] = 'application/json'

  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end

  JSON.parse(response.body) if response.body.present?
rescue => e
  puts "Error making #{method} request to #{endpoint}: #{e.message}"
  nil
end

def batch_create_ratings(posts_to_rate, users)
  ratings_to_create = []
  ratings_count = 0

  posts_to_rate.each do |post|
    num_raters = rand(1..5)
    raters = users.sample(num_raters)

    raters.each do |rater|
      ratings_to_create << {
        post_id: post[:id],
        user_id: rater[:id],
        value: rand(1..5)
      }
    end

    ratings_count += raters.size
    puts "Created #{ratings_count} ratings"
  end

  Rating.insert_all(ratings_to_create)
  ratings_count
end

# Generate unique IPs
ips = []
NUM_IPS.times do
  ips << FFaker::Internet.unique.ip_v4_address
end

# Generate users
puts "Generating #{NUM_USERS} users..."
users = []
NUM_USERS.times do |i|
  login = FFaker::Internet.unique.user_name
  users << { id: i + 1, login: login }

  api_request(:post, "posts", { login: login })

  if (i + 1) % 10 == 0
    puts "Created #{i + 1} users"
  end
end

# Generate posts
puts "Generating #{NUM_POSTS} posts..."
posts = []
NUM_POSTS.times do |i|
  user = users.sample
  ip = ips.sample

  response = api_request(:post, "posts", {
    login: user[:login],
    title: FFaker::Lorem.sentence,
    body: FFaker::Lorem.paragraph,
    ip: ip
  })

  if response
    posts << { id: response["id"], user_id: user[:id] }
  end

  if (i + 1) % 1000 == 0
    puts "Created #{i + 1} posts"
  end
end

# Generate ratings for posts
puts "Generating ratings for posts..."
posts_to_rate = posts.sample((NUM_POSTS * RATING_PERCENTAGE).to_i)
puts "Posts to rate: #{posts_to_rate}"

ratings_count = batch_create_ratings(posts_to_rate, users)

puts "Seed completed!"
puts "Created #{users.size} users"
puts "Created #{posts.size} posts"
puts "Created #{ratings_count} ratings"
