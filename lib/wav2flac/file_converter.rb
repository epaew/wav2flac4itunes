# frozen_string_literal: true

require 'cgi'
require 'fileutils'
require 'shellwords'

module Wav2Flac
  class FileConverter
    REPLACE_TARGET_CHAR = %r{[\\\/:*?\"<>\|]}

    def initialize(track)
      @track = track
      @relative_path = CGI.unescape(track['Location'].gsub('+', '//plus//'))
                         .gsub('//plus//', '+')
                         .match(%r{.*\/iTunes\/(.*)}).to_a[1]
    end

    def convert
      return unless File.extname(input_fullpath) == '.wav'
      return if File.exist?(output_fullpath)

      parent = File.dirname(output_fullpath)
      FileUtils.mkdir_p(parent) unless Dir.exist?(parent)

      command = "flac -V #{input_fullpath.shellescape}" \
        " -o #{output_fullpath.shellescape}"
      puts command
      system(command)
    end

    def input_fullpath
      File.join(Config.itunes_path, @relative_path)
    end

    def output_fullpath
      File.join(Config.output_path,
                album_artist_name,
                album_name,
                output_file_name)
    end

    private

    def album_artist_name
      if @track['Album Artist'].nil?
        'Compilations'
      else
        @track['Album Artist'].strip.gsub(REPLACE_TARGET_CHAR, '_')
      end
    end

    def album_name
      @track['Album'].strip.gsub(REPLACE_TARGET_CHAR, '_')
    end

    def output_file_name
      "#{format('%03d', @track['Track Number'])}-#{@track['Name'].strip}.flac"
        .gsub(REPLACE_TARGET_CHAR, '_')
    end
  end
end
