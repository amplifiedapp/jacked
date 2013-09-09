require "jacked/version"
require "jacked/audio_file"

module Jacked
  extend self

  def create(options={})
    Jacked::AudioFile.new(options)
  end
end
