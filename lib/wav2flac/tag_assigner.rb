# frozen_string_literal: true

require 'taglib'

module Wav2Flac
  class TagAssigner
    TAGS = { title:  'Name',
             album:  'Album',
             track:  'Track Number',
             artist: 'Artist',
             genre:  'Genre',
             year:   'Year' }.freeze

    def self.update_tag(output, track)
      TagLib::FLAC::File.open(output) do |flac|
        tag = flac.xiph_comment
        TAGS.each { |k, v| tag.send("#{k}=", track[v]) }

        if flac.save
          puts "Updating tag of #{output} is completed."
        else
          puts "Failed to update tag of #{output} ."
        end
      end
    end
  end
end
