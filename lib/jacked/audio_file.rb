require 'json'
require 'waveformjson'
require 'securerandom'
require 'tempfile'

module Jacked
  class InvalidFile < StandardError; end

  class AudioFile
    attr_reader :file_type, :file_format, :duration

    def initialize(options)
      begin
        if options[:content]
          @content = options[:content]
        else
          @content = File.read(options[:file])
        end

        raise InvalidFile.new("Missing file or content") unless @content

      rescue Exception
        raise InvalidFile.new("Invalid audio file")
      end

      parse_metadata
    end

    def waveform(height=140)
      begin
        internal_temp_wav = Tempfile.new("temp_wav")
        if "wav".eql? file_format
          internal_temp_wav.write(@content)
          internal_temp_wav.rewind
        else
          tmp_file = generate_temp_file
          `ffmpeg -v quiet -i #{tmp_file.path} -y -f wav #{internal_temp_wav.path}`
          tmp_file.close!
        end

        generate_waveform(internal_temp_wav.path, height)
      ensure
        internal_temp_wav.close!
      end
    end

    def content
      @content
    end

    def reduce
      internal_temp_reduced = Tempfile.new("temp_reduced")
      temp_file = generate_temp_file

      begin
        options = "-m j --quiet"
        options += " --mp3input" if @file_format.eql? "mp3"
        `lame #{options} #{temp_file.path} #{internal_temp_reduced.path}`
        internal_temp_reduced.rewind
        jacked = Jacked.create(content: internal_temp_reduced.read)
      ensure
        internal_temp_reduced.close!
        temp_file.close!
      end
    end

    private

    def generate_temp_file
      temp_file = Tempfile.new("temp_audio")
      temp_file.write(@content.force_encoding('UTF-8'))
      temp_file.rewind
      temp_file
    end

    def generate_waveform(filename, height)
      waveform = Waveformjson.generate(filename)
      waveform.map! {|elem| (elem * height).to_i } if height > 1
      json_waveform = {width: 1800, height: height, data: waveform }
      JSON.generate(json_waveform)
    end

    def parse_metadata
      tmp_file = generate_temp_file
      begin
        str_json = `ffprobe -v quiet -print_format json -show_streams #{tmp_file.path}`

        json = JSON.parse(str_json)

        @metadata = json['streams'][0]
        @file_type = @metadata['codec_type']

        raise InvalidFile.new("Not an audio file") if file_type != "audio"

        @file_format = _get_format(@metadata['codec_name'])
        @duration = @metadata['duration'].to_f.round
      rescue
        raise InvalidFile.new("Not an audio file")
      ensure
        tmp_file.close!
      end
    end

    def _get_format(codec_name)
      return "mp3" if "mp3".eql? codec_name
      return "wav" if "pcm_s16le".eql? codec_name
    end
  end
end
