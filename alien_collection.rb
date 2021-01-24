require 'csv'

class AlienCollection
  include Enumerable

  attr_reader :aliens

  def initialize(aliens = [])
    @aliens = aliens
  end

  def each(&block)
    aliens.each(&block)
  end

  def add(alien)
    aliens.push(alien)
  end

  def to_csv
    CSV.generate do |csv|
      csv << Alien::ATTRIBUTE_KEYS
      each do |alien|
        csv << alien.to_csv_row
      end
    end
  end
end