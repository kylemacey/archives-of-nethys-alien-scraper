class Alien
  ATTRIBUTE_KEYS = %i[
    url name cr xp le init senses perception hp eac kac
    fort ref will dr immunities sr speed str dex con int wis cha
  ]
  attr_accessor *ATTRIBUTE_KEYS

  def self.num_attr(*keys)
    keys.each do |key|
      define_method("#{key}=") do |val|
        if val.is_a?(String)
          instance_variable_set("@#{key}", val.to_i)
        end
      end
    end
  end

  def self.array_attr(*keys)
    keys.each do |key|
      define_method("#{key}=") do |val|
        if val.is_a?(String)
          instance_variable_set("@#{key}", val.split(", ").map(&:strip))
        end
      end
    end
  end

  num_attr *%[cr init perception hp eac kac fort ref will sr str dex con int wis cha]

  array_attr :senses, :immunities

  def url=(val)
    @url = Addressable::URI.encode(val)
  end

  # convert "XP 1,200" to 1200
  def xp=(val)
    if val.is_a?(String)
      val = val.scan(/\d/).join.to_i
    end

    @xp = val
  end

  def le=(val)
    if val.is_a?(String)
      val = val.match(/LE (.+)/)[1]
    end

    @le = val
  end

  def to_csv_row
    ATTRIBUTE_KEYS.map do |key|
      val = self.send(key)
      if val.is_a?(Array)
        val.join(", ")
      else
        val
      end
    end
  end
end