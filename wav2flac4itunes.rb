#!/usr/bin/env ruby
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

  TAGS = {
    title:  'Name',
    album:  'Album',
    track:  'Track Number',
    artist: 'Artist',
    genre:  'Genre',
    year:   'Year'
  }.freeze

  REPLACE_TARGET = %r{[\\\/:*?\"<>\|]}

  def initialize
    Encoding.default_external = 'UTF-8'
    @tracks = Plist.parse_xml(XML_PATH)['Tracks'].values
    @progress = ProgressBar.create(
      starting_at: 0,
      total: @tracks.size,
      format: '%t: |%B| %c/%u',
      output: $stderr
    )
  end

  def execute
    @tracks.each do |track|
      @progress.increment

      # CGI.unescape により + が半角スペースに変換されるのを回避
      fname = CGI.unescape(track['Location'].gsub('+', '//plus//'))
                 .gsub('//plus//', '+').match(%r{.*\/iTunes\/(.*)}).to_a[1]

      next unless File.extname(fname) == '.wav'

      input = File.join(ITUNES_DIR, fname)
      output = File.join(
        FLAC_DIR,
        if track['Album Artist'].nil?
          'Compilations'
        else
          track['Album Artist'].strip.gsub(REPLACE_TARGET, '_')
        end,
        track['Album'].strip.gsub(REPLACE_TARGET, '_'),
        "#{track['Track Number']} #{track['Name'].strip}.flac"
          .gsub(REPLACE_TARGET, '_')
      )

      convert(input, output)

      add_tag(output, track) if File.exist?(output)
    end
  end

  private

  def add_tag(output, track)
    TagLib::FLAC::File.open(output) do |flac|
      tag = flac.xiph_comment

      cond = TAGS.map.any? do |k, v|
        unless tag.send(k) == track[v]
          tag.send("#{k}=", track[v])
          true
        end
      end

      if cond
        flac.save
        puts "Updating tag of #{output} is completed."
      end
    end
  end

  def convert(input, output)
    return if File.exist?(output)

    unless Dir.exist?(File.dirname(output))
      FileUtils.mkdir_p(File.dirname(output))
    end

    puts "flac -V #{input.shellescape} -o #{output.shellescape}"
    system("flac -V #{input.shellescape} -o #{output.shellescape}")
  end
end

Wav2Flac4ITunes.new.execute
