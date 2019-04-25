# This is a template for a Ruby scraper on morph.io (https://morph.io)
# including some code snippets below that you should find helpful

 require 'scraperwiki'
 require 'mechanize'
 require 'open-uri'
require 'nokogiri'
require 'json'
#
# agent = Mechanize.new
#
# # Read in a page
# page = agent.get("https://www.eventmieter.de")
#
# # Find somehing on the page using css selectors
# p page.at('[@id="con"]/div[3]/div[1]/div/div[2]/span[1]/a')
#
# # Write out to the sqlite database using scraperwiki library
 #ScraperWiki.save_sqlite(["name"], {"name" => "susan", "occupation" => "software developer"})
#
# # An arbitrary query against the database
 #ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries.
# You can use whatever gems you want: https://morph.io/documentation/ruby
# All that matters is that your final data is written to an SQLite database
# called "data.sqlite" in the current working directory which has at least a table
# called "data".

url = 'https://bridgereports.com/city/wichita-kansas/'
html = open(url)

doc = Nokogiri::HTML(html)
bridges = []
table = doc.at('table')


table.search('tr').each do |tr|
  cells = tr.search('th, td')
  links = {}
  cells[0].css('a').each do |a|
    links[a.text] = a['href']
  end

  got_coords = false

  if links['NBI report']
    nbi = links['NBI report']
    report = "https://bridgereports.com" + nbi
    report_html = open(report)
    sleep 1 until report_html
    r = Nokogiri::HTML(report_html)

    lat = r.css('span.latitude').text.strip.to_f
    long = r.css('span.longitude').text.strip.to_f
    puts lat, long
    got_coords = true
  else
    got_coords = true
  end

  sleep 1 until got_coords == true

  bridges.push(
    links: links,
    latitude: lat,
    longitude: long,
    carries: cells[1].text,
    crosses: cells[2].text,
    location: cells[3].text,
    design: cells[4].text,
    status: cells[5].text,
    year_build: cells[6].text.to_i,
    year_recon: cells[7].text,
    span_length: cells[8].text.to_f,
    total_length: cells[9].text.to_f,
    condition: cells[10].text,
    suff_rating: cells[11].text.to_f,
    id: cells[12].text.to_i
  )
  puts bridges
end
