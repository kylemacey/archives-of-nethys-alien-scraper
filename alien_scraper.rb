class AlienScraper
  attr_reader :collection

  def initialize(log, collection)
    @log = log
    @collection = collection
  end

  # Find all the aliens on https://www.aonsrd.com/Aliens.aspx?Letter=All
  def scrape_aliens_at(url)
    doc = Nokogiri::HTML(URI.open(url))
    doc.css("#ctl00_MainContent_GridViewAliens tr").flat_map do |row|
      row.search("td[1] a").map do |link|
        if alien = scrape_alien(File.join("https://www.aonsrd.com/", link["href"]))
          collection.add(alien)
        end
      rescue => e
        puts "INDEX_ERROR: #{e.message}"
        next
      end
    end.compact
  end

  def scrape_alien(url)
    doc = Nokogiri::HTML(URI.open(url))

    table = doc.at_xpath(%{//*[@id="ctl00_MainContent_DataListTalentsAll_ctl00_LabelName"]})

    alien = Alien.new
    alien.url = url
    alien.name = table.at_css("h1.title a").content
    alien.cr = table.at_css("h2.title").content.match(/CR (\d+)\z/)[1] rescue nil
    alien.xp = table.css("b").detect do |elem|
      elem.content.match(/^XP/)
    end.content
    alien.le = match_text(table, /^LE/)

    easy_attrs = {
      init: "Init",
      senses: "Senses",
      perception: "Perception",
      hp: "HP",
      eac: "EAC",
      kac: "KAC",
      fort: "Fort",
      ref: "Ref",
      will: "Will",
      dr: "DR",
      immunities: "Immunities",
      sr: "SR",
      speed: "Speed",
      str: "STR",
      dex: "DEX",
      con: "CON",
      int: "INT",
      wis: "WIS",
      cha: "CHA",
    }

    easy_attrs.each do |attr, label|
      set_attr(attr, label, alien, table)
    end

    alien
  rescue => e
    @log.error("Alien Error at #{url}")
    @log.error(e)
    nil
  end

  def match_text(root, regex)
    root.xpath("text()").detect do |elem|
      elem.content.match(regex)
    end&.content
  end

  def neighbor(root, elem, iter = 1)
    i = root.children.index(elem)
    root.children[i + iter]
  end

  def set_attr(attr, label, alien, table)
    attr_e = table.css("b").detect do |elem|
      elem.content == label
    end

    if attr_e
      content = neighbor(table, attr_e).content.strip
      content.gsub!(";", "")
      alien.send("#{attr}=", content)
    end
  end
end