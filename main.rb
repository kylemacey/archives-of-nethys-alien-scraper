require 'nokogiri'
require 'open-uri'
require 'pry'
require 'logger'

require './alien'
require './alien_collection'
require './alien_scraper'

@log = Logger.new("log/#{Time.now.to_i}_aliens.log")

begin
  collection = AlienCollection.new
  scraper = AlienScraper.new(@log, collection)
  scraper.scrape_aliens_at("https://www.aonsrd.com/Aliens.aspx?Letter=All")
rescue Interrupt

ensure
  File.open("./out/#{Time.now.to_i}_aliens.csv", "w") { |f| f.write(collection.to_csv) }
end