require "open-uri"
require "nokogiri"
require 'csv'


def scrape_medium_profile(username)
  # TODO: return an array of Antiques found of Craiglist for this `city`.
  doc = Nokogiri::HTML(open("https://medium.com/@#{username}/latest").read)

  output = {}
  doc.search('.graf--h3').each_with_index do |element, index|
    title = element.text.strip.to_s
    output["Blog Post #{index + 1}"] = {}
    output["Blog Post #{index + 1}"][:title] = title
  end

  doc.search('.postArticle-readMore a').each_with_index do |element, index|
    href = element[:href]
    output["Blog Post #{index + 1}"][:href] = href
    new_doc = Nokogiri::HTML(open(href).read)
    description = new_doc.search('.graf-after--h3').text.strip.to_s
    output["Blog Post #{index + 1}"][:description] = description
    time = new_doc.search('.js-testPostMetaInlineSupplemental').text.strip.to_s
    output["Blog Post #{index + 1}"][:timestamp] = time
  end
  return output
end

def update_csv(blog_data, csv)
  csv_options = { col_sep: ",", force_quotes: true, quote_char: '"' }
  CSV.open(csv, 'w', csv_options) do |csv|
    csv << ["title", "href", "description", "timestamp"]
    blog_data.each do |hash|
      csv << [hash[1][:title], hash[1][:href], hash[1][:description], hash[1][:timestamp]]
    end
  end
end

blog_data = scrape_medium_profile("jamieduj")

update_csv(blog_data,'blog-posts.csv')

# test = {"hi" => 1, "i" => 1, "h" => 1}

# test.each do |element|
#   p element[1]
# end
