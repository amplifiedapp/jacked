require 'json'
require 'waveformjson'
require 'securerandom'

module Jacked
  class InvalidFile < StandardError; end

  class AudioFile
    attr_reader :file_type, :file_format, :duration

    def initialize(options)
      begin
        if options[:content]
          tmp_filename = _generate_temp_file(options[:content])
          options[:file] = tmp_filename
        end

        raise InvalidFile.new("Missing filename") unless options[:file]

        @filename = options[:file]
        File.open(@filename)
      rescue Exception
        raise InvalidFile.new("Invalid audio file")
      end

      _parse_metadata(options[:file])
    end

    def waveform
      if "wav".eql? file_format
        filename = @filename
      else
        filename = _get_temp_wav_file(@filename)
      end

      _generate_waveform(filename)
    end

    private

    def _generate_temp_file(content)
      temp_file = "/tmp/#{SecureRandom.hex}.mp3"
      f = File.new(temp_file, "w")
      f.write(content)
      f.close()
      temp_file
    end

    def _get_temp_wav_file(filename)
      temp_wav = "/tmp/#{SecureRandom.hex}.wav"
      command = <<-end_command
        ffmpeg -v quiet -i #{filename} #{temp_wav}
      end_command
      IO.popen(command) {}
      temp_wav
    end

    def _generate_waveform(filename)
      waveform = Waveformjson.generate(filename)
      json_waveform = {width: 1800, height: 140, data: waveform }
      JSON.generate(json_waveform)
    end

    def _parse_metadata(filename)
      command = <<-end_command
        ffprobe -v quiet -print_format json -show_streams #{filename}
      end_command

      str_json = ""
      IO.popen(command) do |io|
          str_json = io.read
      end

      json = JSON.parse(str_json)

      @metadata = json['streams'][0]
      @file_type = @metadata['codec_type']

      raise InvalidFile.new("Not an audio file") if file_type != "audio"

      @file_format = _get_format(@metadata['codec_name'])
      @duration = @metadata['duration'].to_f.round
    end

    def _get_format(codec_name)
      return "mp3" if "mp3".eql? codec_name
      return "wav" if "pcm_s16le".eql? codec_name
    end
  end
end
