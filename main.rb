require 'nokogiri'
require 'open-uri'
require 'pry'
require 'logger'

require './alien'
require './alien_collection'
require './alien_scraper'

@timestamp = Time.now.to_i
@log = Logger.new("log/#{@timestamp}_aliens.log")

begin
  collection = AlienCollection.new
  scraper = AlienScraper.new(@log, collection)
  scraper.scrape_aliens_at("https://www.aonsrd.com/Aliens.aspx?Letter=All")
rescue Interrupt

ensure
  File.open("./out/#{@timestamp}_aliens.csv", "w") { |f| f.write(collection.to_csv) }
end