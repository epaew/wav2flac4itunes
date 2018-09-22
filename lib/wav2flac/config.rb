# frozen_string_literal: true

require 'deep_merge'
require 'yaml'

module Wav2Flac
  class Config
    CONFIG_DIR = File.expand_path('../../config', __dir__).freeze
    XML_FILENAME = '/iTunes Music Library.xml'

    class << self
      def itunes_path
        File.expand_path(config[:directories][:itunes_root])
      end

      def output_path
        File.expand_path(config[:directories][:output_root])
      end

      def xml_path
        File.join(itunes_path, XML_FILENAME)
      end

      private

      def config
        @config ||= load_config
      end

      def load_config
        %i[defaults local].each_with_object({}) do |file, hash|
          path = File.join(CONFIG_DIR, "#{file}.yml")
          next hash unless File.exist?(path)

          hash.deep_merge!(YAML.safe_load(IO.read(path), symbolize_names: true))
        end
      end
    end
  end
end
