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
          tmp_filename = _generate_temp_file(options[:content])
          options[:file] = tmp_filename
        end

        raise InvalidFile.new("Missing filename") unless options[:file]

        @filename = options[:file]
        File.open(@filename)
      rescue Exception
        raise InvalidFile.new("Invalid audio file")
      end

      _parse_metadata
    end

    def waveform(height=140)
      filename = if "wav".eql? file_format
                   @filename
                 else
                   wav_content(@filename).path
                 end

      generate_waveform(filename, height)
    end

    def content
      File.read(@filename)
    end

    def reduce
      internal_temp_reduced = Tempfile.new("temp_reduced")

      begin
        options = "-m j --quiet"
        options += " --mp3input" if @file_format.eql? "mp3"
        `lame #{options} #{@filename} #{internal_temp_reduced.path}`
        internal_temp_reduced.rewind
        jacked = Jacked.create(content: internal_temp_reduced.read)
      ensure
        internal_temp_reduced.close
        internal_temp_reduced.unlink
      end
    end

    private

    def _generate_temp_file(content)
      temp_file = Tempfile.new("temp_audio")
      temp_file.write(content)
      temp_file.rewind
      temp_file.path
    end

    def wav_content(mp3_filename)
      internal_temp_wav = Tempfile.open("temp_wav")
      internal_temp_wav.close
      `ffmpeg -v quiet -i #{mp3_filename} -y -f wav #{internal_temp_wav.path}`
      internal_temp_wav.open
      internal_temp_wav
    end

    def generate_waveform(filename, height)
      waveform = Waveformjson.generate(filename)
      waveform.map! {|elem| (elem * height).to_i } if height > 1
      json_waveform = {width: 1800, height: height, data: waveform }
      JSON.generate(json_waveform)
    end

    def _parse_metadata
      str_json = `ffprobe -v quiet -print_format json -show_streams #{@filename}`

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
