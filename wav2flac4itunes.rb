#!/usr/bin/env ruby
# -*- coding:UTF-8 -*-

require 'plist'
require 'taglib'
require 'ruby-progressbar'

require 'pp'
require 'cgi'
require 'fileutils'
require 'shellwords'

class Wav2Flac4ITunes

  ITUNES_DIR = '/media/sf_music/iTunes'.freeze
  FLAC_DIR = '/media/sf_music/flac'.freeze
  XML_PATH = File.join(ITUNES_DIR, '/iTunes Music Library.xml').freeze

  TAG_MAP = {
   title:  "Name",
   album:  "Album",
   track:  "Track Number",
   artist: "Artist",
   genre:  "Genre",
   year:   "Year",
  }.freeze

  def initialize
    Encoding.default_external = 'UTF-8'
    @tracks = Plist.parse_xml(XML_PATH)["Tracks"].values
    @progress = ProgressBar.create(
      starting_at: 0,
      total: @tracks.size,
      format: "%t: |%B| %c/%u",
      output: $stderr
    )
  end

  def convert(input, output)
    unless File.exist?(output)
      unless Dir.exist?(File.dirname(output))
        FileUtils.mkdir_p(File.dirname(output))
      end

      puts "flac -V #{input.shellescape} -o #{output.shellescape}"
      system("flac -V #{input.shellescape} -o #{output.shellescape}")
    end
  end

  def add_tag(output, track)
    TagLib::FLAC::File.open(output) do |flac|
      flag = false
      tag = flac.xiph_comment

      TAG_MAP.each do |k, v|
        unless tag.send(k) == track[v]
          tag.send("#{k}=".to_sym, track[v])
          flag = true
        end
      end

      if flag
        flac.save
        puts "Updating tag of #{output} is completed."
      end
    end
  end

  def execute
    @tracks.each do |track|
      @progress.increment

      # CGI.unescape により + が半角スペースに変換されるのを回避
      fname = CGI.unescape(track["Location"].gsub('+', '//plus//'))
        .gsub('//plus//', '+').match(/.*\/iTunes\/(.*)/).to_a[1]

      next unless File.extname(fname) == ".wav"

      input = File.join(ITUNES_DIR, fname)
      output = File.join(
        FLAC_DIR,
        unless track["Album Artist"].nil?
          track["Album Artist"].strip.gsub(/[\\\/:*?\"<>\|]/, '_')
        else
          "Compilations"
        end,
        track["Album"].strip.gsub(/[\\\/:*?\"<>\|]/, '_'),
        "#{track["Track Number"]} #{track["Name"].strip}.flac"
          .gsub(/[\\\/:*?\"<>\|]/, '_')
      )

      convert(input, output)

      add_tag(output, track) if File.exist?(output)
    end
  end
end

Wav2Flac4ITunes.new.execute
