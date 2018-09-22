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

    def self.update_tag(output, track_info)
      TagLib::FLAC::File.open(output) do |flac|
        tags = flac.xiph_comment
        update_results = TAGS.map do |k, v|
          next if tags.public_send(k) == track_info[v]

          # tags.public_send("#{k}=") always return nil.
          tags.public_send("#{k}=", track_info[v])
          true
        end

        if update_results.any?
          if flac.save
            puts "Updating tag of #{output} is completed."
          else
            puts "Failed to update tag of #{output} ."
          end
        end
      end
    end
  end
end
