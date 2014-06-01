require 'json'
require 'waveformjson'
require 'securerandom'
require 'tempfile'

module Jacked
  class InvalidFile < StandardError; end

  class AudioFile
    attr_reader :file_type, :file_format, :duration

    SILENCE_REGEXP = /(silence_end: \d+.\d+) | (silence_start: \d+.\d+)/
    CONVERTER = 'avconv'
    PROBE = 'avprobe'

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
        case file_format
        when :wav
          internal_temp_wav.write(@content)
          internal_temp_wav.rewind
        else
          tmp_file = generate_temp_file
          `#{CONVERTER} -v quiet -i #{tmp_file.path} -y -f wav #{internal_temp_wav.path}`
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
        options += " --mp3input" if @file_format.eql? :mp3
        `lame #{options} #{temp_file.path} #{internal_temp_reduced.path}`
        internal_temp_reduced.rewind
        jacked = Jacked.create(content: internal_temp_reduced.read)
      ensure
        internal_temp_reduced.close!
        temp_file.close!
      end
    end

    def split(ranges)
      temp_file = generate_temp_file
      files = []
      begin
        ranges.each do |range|
          internal_temp_splitted = Tempfile.new("temp_splitted")
          start = range[:start]
          duration = range[:end] - start
          input_options = "-ss #{start} "
          input_options += " -f mp3" if @file_format.eql? :mp3
          input_options += " -i #{temp_file.path}"
          output_options = " -t #{duration} -f mp3 -y "
          output_options += " #{internal_temp_splitted.path}"
          begin
            `#{CONVERTER} -v quiet #{input_options} #{output_options}`
            internal_temp_splitted.rewind
            files << Jacked.create(content: internal_temp_splitted.read)
          ensure
            internal_temp_splitted.close!
          end
        end
      ensure
        temp_file.close!
      end
      files
    end

    # def find_silences
    #   temp_file = generate_temp_file
    #   silences = []
    #   begin
    #     options = " -af silencedetect=n=-25dB:d=1 -v info -f null - 2>&1 | grep silencedetect"
    #     output = `#{CONVERTER} -i #{temp_file.path} #{options}`
    #     hash_silence = {}
    #     output.each_line do |line|
    #       silence_line = SILENCE_REGEXP.match(line)
    #       silence = silence_line[0].split(':')
    #
    #       hash_silence[silence[0].strip] = silence[1].strip
    #       if hash_silence.size == 2
    #         # Has both start and end
    #         silences << hash_silence
    #         hash_silence = {}
    #       end
    #     end
    #   ensure
    #     temp_file.close!
    #   end
    #   silences
    # end

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
        str = `#{PROBE} -v quiet -show_streams #{tmp_file.path}`

        metadata = {}
        str.split.each do |element|
          key_value = element.split("=")
          next if key_value.size < 1
          metadata[key_value[0]] = key_value[1]
        end

        @file_type = metadata['codec_type']

        raise InvalidFile.new("Not an audio file - #{PROBE} was: #{str}") if file_type != "audio"

        @file_format = _get_format(metadata['codec_name'])
        @duration = metadata['duration'].to_f.round
      rescue
        raise InvalidFile.new("Not an audio file - #{PROBE} was: #{str}")
      ensure
        tmp_file.close!
      end
    end

    def _get_format(codec_name)
      return :mp3 if "mp3".eql? codec_name
      return :wav if "pcm_s16le".eql? codec_name
      return :aif if "pcm_s16be".eql? codec_name
    end
  end
end
