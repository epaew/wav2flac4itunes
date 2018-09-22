# frozen_string_literal: true

require 'plist'
require 'ruby-progressbar'

module Wav2Flac
  class Command
    def initialize
      @tracks = Plist.parse_xml(Config.xml_path)['Tracks'].values
      @progress = ProgressBar.create(
        starting_at: 0,
        total: @tracks.size,
        format: '%t: |%B| %c/%u',
        output: $stderr
      )
    end

    def convert_all
      @tracks.each do |track|
        @progress.increment

        converter = FileConverter.new(track)
        converter.convert
        TagAssigner.update_tag(converter.output_fullpath, track)
      end
    end
  end
end
