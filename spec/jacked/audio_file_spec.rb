require 'spec_helper'

describe Jacked::AudioFile do
  let(:mp3_filename) { "#{File.expand_path('../../', __FILE__)}/files/test.mp3" }
  let(:wav_filename) { "#{File.expand_path('../../', __FILE__)}/files/test.wav" }
  let(:aif_filename) { "#{File.expand_path('../../', __FILE__)}/files/test.aif" }
  let(:mp3_reduced_filename) { "#{File.expand_path('../../', __FILE__)}/files/test_mp3_reduced.mp3" }
  let(:mp3_reduced_from_wav_filename) { "#{File.expand_path('../../', __FILE__)}/files/test_wav_reduced.mp3" }
  let(:mp3_reduced_from_aif_filename) { "#{File.expand_path('../../', __FILE__)}/files/test_aif_reduced.mp3" }
  let(:content_string) { File.read(mp3_filename) }
  let(:mp3_jacked) { Jacked.create(file: mp3_filename) }
  let(:wav_jacked) { Jacked.create(file: wav_filename) }
  let(:aif_jacked) { Jacked.create(file: aif_filename) }
  let(:content_jacked) { Jacked.create(content: content_string) }
  let(:wav_jacked_waveform1) { JSON.parse(File.read(File.expand_path('../../',__FILE__) + "/files/test.wav.waveform.json")) }
  let(:wav_jacked_waveform140) { JSON.parse(File.read(File.expand_path('../../',__FILE__) + "/files/test.wav.waveform140.json")) }
  let(:mp3_jacked_waveform1) { JSON.parse(File.read(File.expand_path('../../',__FILE__) + "/files/test.mp3.waveform.json")) }
  let(:mp3_jacked_waveform140) { JSON.parse(File.read(File.expand_path('../../',__FILE__) + "/files/test.mp3.waveform140.json")) }
  let(:aif_jacked_waveform1) { JSON.parse(File.read(File.expand_path('../../', __FILE__) + "/files/test.aif.waveform.json")) }
  let(:aif_jacked_waveform140) { JSON.parse(File.read(File.expand_path('../../', __FILE__) + "/files/test.aif.waveform140.json")) }

  describe "#file_type" do
    context "with a mp3 file" do
      it "sets the file_type to audio" do
        expect(mp3_jacked.file_type).to eq "audio"
      end
    end

    context "with a wav file" do
      it "sets the file_type to audio" do
        expect(wav_jacked.file_type).to eq "audio"
      end
    end

    context "with an aif file" do
      it "sets the file_type to audio" do
        expect(aif_jacked.file_type).to eq "audio"
      end
    end

    context "with a content string" do
      it "sets the file_type to audio" do
        expect(content_jacked.file_type).to eq "audio"
      end
    end
  end

  describe "#file_format" do
    context "with a mp3 file" do
      it "sets the file_format to mp3" do
        expect(mp3_jacked.file_format).to eq :mp3
      end
    end

    context "with a wav file" do
      it "sets the file_format to wav" do
        expect(wav_jacked.file_format).to eq :wav
      end
    end

    context "with an aif file" do
      it "sets the file_format to aif" do
        expect(aif_jacked.file_format).to eq :aif
      end
    end

    context "with a content string" do
      it "sets the file_format to mp3" do
        expect(content_jacked.file_format).to eq :mp3
      end
    end
  end

  describe "#duration" do
    context "with a mp3 file" do
      it "sets the duration to 2 sec" do
        expect(mp3_jacked.duration).to eq 2
      end
    end

    context "with a wav file" do
      it "sets the duration to 1 sec" do
        expect(wav_jacked.duration).to eq 1
      end
    end

    context "with an aif file" do
      it "sets the duration to 2 sec" do
        expect(aif_jacked.duration).to eq 3
      end
    end

    context "with a content string" do
      it "sets the duration to 2 sec" do
        expect(content_jacked.duration).to eq 2
      end
    end
  end

  describe "#waveform" do
    context "with a mp3 file" do
      context "without a height parameter" do
        subject { JSON.parse(mp3_jacked.waveform) }

        it "returns a json object" do
          expect(subject).to_not be_nil
        end

        it "sets the width to 1800" do
          expect(subject["width"]).to eq 1800
        end

        it "sets the height to 140" do
          expect(subject["height"]).to eq 140
        end

        it "sets the data array" do
          expect(subject["data"]).to_not be_nil
          expect(subject["data"]).to eq mp3_jacked_waveform140
        end
      end

      context "with a height parameter" do
        subject { JSON.parse(mp3_jacked.waveform(1)) }

        it 'returns a json object' do
          expect(subject).to_not be nil
        end

        it 'sets the width to 1800' do
          expect(subject["width"]).to eq 1800
        end

        it 'sets the height to 1' do
          expect(subject["height"]).to eq 1
        end

        it 'sets the data array' do
          expect(subject["data"]).to_not be_nil
          expect(subject["data"]).to eq mp3_jacked_waveform1
        end
      end
    end

    context "with an aif file" do
      context "without a height parameter" do
        subject { JSON.parse(aif_jacked.waveform) }

        it "returns a json object" do
          expect(subject).to_not be_nil
        end

        it "sets the width to 1800" do
          expect(subject["width"]).to eq 1800
        end

        it "sets the height to 140" do
          expect(subject["height"]).to eq 140
        end

        it "sets the data array" do
          expect(subject["data"]).to_not be_nil
          expect(subject["data"]).to eq aif_jacked_waveform140
        end
      end

      context "with a height parameter" do
        subject { JSON.parse(aif_jacked.waveform(1)) }

        it 'returns a json object' do
          expect(subject).to_not be nil
        end

        it 'sets the width to 1800' do
          expect(subject["width"]).to eq 1800
        end

        it 'sets the height to 1' do
          expect(subject["height"]).to eq 1
        end

        it 'sets the data array' do
          expect(subject["data"]).to_not be_nil
          expect(subject["data"]).to eq aif_jacked_waveform1
        end
      end
    end

    context "with a wav file" do
      context "without a height parameter" do
        subject { JSON.parse(wav_jacked.waveform) }

        it "returns a json object" do
          expect(subject).to_not be_nil
        end

        it "sets the width to 1800" do
          expect(subject["width"]).to eq 1800
        end

        it "sets the height to 140" do
          expect(subject["height"]).to eq 140
        end

        it "sets the data array" do
          expect(subject["data"]).to_not be_nil
          expect(subject["data"]).to eq wav_jacked_waveform140
        end
      end

      context "with a height parameter" do
        subject { JSON.parse(wav_jacked.waveform(1)) }

        it 'returns a json object' do
          expect(subject).to_not be_nil
        end

        it 'sets the width to 1800' do
          expect(subject["width"]).to eq 1800
        end

        it 'sets the height to 1' do
          expect(subject["height"]).to eq 1
        end

        it 'sets the data array' do
          expect(subject["data"]).to_not be_nil
          expect(subject["data"]).to eq wav_jacked_waveform1
        end
      end
    end

    context "with a content string" do
      context 'without a height parameter' do
        subject { JSON.parse(content_jacked.waveform) }

        it "returns a json object" do
          expect(subject).to_not be_nil
        end

        it "sets the width to 1800" do
          expect(subject["width"]).to eq 1800
        end

        it "sets the height to 140" do
          expect(subject["height"]).to eq 140
        end

        it "sets the data array" do
          expect(subject["data"]).to_not be_nil
          expect(subject["data"]).to eq mp3_jacked_waveform140 # The content string is the mp3 file
        end
      end

      context 'with a heigth parameter' do
        subject { JSON.parse(content_jacked.waveform(1)) }

        it 'returns a json object' do
          expect(subject).to_not be_nil
        end

        it 'sets the width to 1800' do
          expect(subject["width"]).to eq 1800
        end

        it 'sets the height to 1' do
          expect(subject["height"]).to eq 1
        end

        it 'sets the data array' do
          expect(subject["data"]).to_not be_nil
          expect(subject["data"]).to eq mp3_jacked_waveform1
        end
      end
    end

    context 'calling it after content' do
      it 'returns the waveform data' do
        jacked = Jacked.create(content: content_string)
        jacked.content
        resp = JSON.parse(jacked.waveform)
        expect(resp["data"]).to_not be_nil
        expect(resp["data"]).to eq mp3_jacked_waveform140
      end
    end
  end

  describe "#content" do
    context "with a wav file" do
      subject { wav_jacked.content }

      it 'returns the content of the file' do
        expect(subject).to eq File.read(wav_filename)
      end
    end

    context "with an aif file" do
      subject { aif_jacked.content }

      it 'returns the content of the file' do
        expect(subject).to eq File.read(aif_filename)
      end
    end

    context "with a mp3 file" do
      subject { mp3_jacked.content }

      it 'returns the content of the file' do
        expect(subject).to eq File.read(mp3_filename)
      end
    end

    context "with a content string" do
      subject { content_jacked.content }

      it 'returns the content of the file' do
        expect(subject).to eq content_string
      end
    end
  end

  describe "#reduce" do
    context "with a wav file" do
      subject { wav_jacked.reduce }

      it 'returns a reduced jacked audio file' do
        file_content = File.read(mp3_reduced_from_wav_filename).encode('UTF-16', 'UTF-8', invalid: :replace)
        expect(subject.content.encode('UTF-16', 'UTF-8', invalid: :replace)).to eq file_content
      end
    end

    context 'with an aif file' do
      subject { aif_jacked.reduce }

      it 'returns a reduced jacked audio file' do
        file_content = File.read(mp3_reduced_from_aif_filename).encode('UTF-16', 'UTF-8', invalid: :replace)
        expect(subject.content.encode('UTF-16', 'UTF-8', invalid: :replace)).to eq file_content
      end
    end

    context "with a mp3 file" do
      subject { mp3_jacked.reduce }

      it 'returns a reduced jacked audio file' do
        file_content = File.read(mp3_reduced_filename).encode('UTF-16', 'UTF-8', invalid: :replace)
        expect(subject.content.encode('UTF-16', 'UTF-8', invalid: :replace)).to eq file_content
      end
    end

    context "with a content string" do
      subject { content_jacked.reduce }

      it 'returns a reduced jacked audio file' do
        file_content = File.read(mp3_reduced_filename).encode('UTF-16', 'UTF-8', invalid: :replace)
        expect(subject.content.encode('UTF-16', 'UTF-8', invalid: :replace)).to eq file_content
      end
    end
  end
end
