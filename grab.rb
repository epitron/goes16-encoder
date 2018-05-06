#!/usr/bin/env ruby
require 'epitools'
require 'nokogiri'

class Curler
  def initialize(cookies: true)
    @ua      = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Safari/537.36"
    @cookies = "cookies.txt" if cookies
  end

  def run(*cmd)
    IO.popen(cmd) do |io|
      io.read
    end
  end

  def get(url, save: false, save_to: nil, resume: true, referer: nil, details: false)
    puts
    puts "Getting: #{url}"
    # uri = URI.parse(url)
    url = url.to_s unless url.is_a? String

    cmd = ["curl"]
    cmd << "--progress-bar" unless details
    cmd += ["--cookie-jar", @cookies, "--cookie", @cookies] if @cookies 
    cmd += ["--user-agent", @ua] 
    cmd += ["--referer", referer] if referer 

    if save or save_to
      cmd << "--xattr"
      cmd += ["--continue-at", "-"] if resume

      if save_to
        cmd += ["--output", save_to]
      else
        cmd << "-O"
      end

      system(*cmd, url)
    else
      html = run(*cmd, url)
      Nokogiri::HTML(html)
    end
  end
end

baseurl = "https://cdn.star.nesdis.noaa.gov/GOES16/ABI/FD/GEOCOLOR/"
curl    = Curler.new
page    = curl.get(baseurl)
pics    = page.search("a").map {|a| a["href"]}.select { |url| url =~ /-1808x1808/ }

Path.mkdir("pics") unless Path["pics"].dir?

Path.cd("pics") do
  pics.each do |pic|
    if Path[pic].exists?
       puts "Skipping #{pic}..."
    else
      uri = URI.join(baseurl, pic)
      curl.get(uri, save: true)
    end 
  end
end

