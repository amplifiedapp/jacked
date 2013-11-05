require 'spec_helper'

describe Jacked::AudioFile do
  let(:mp3_filename) { "#{File.expand_path('../../', __FILE__)}/files/test.mp3" }
  let(:wav_filename) { "#{File.expand_path('../../', __FILE__)}/files/test.wav" }
  let(:content_string) { File.open(mp3_filename).read() }
  let(:mp3_jacked) { Jacked.create(file: mp3_filename) }
  let(:wav_jacked) { Jacked.create(file: wav_filename) }
  let(:content_jacked) { Jacked.create(content: content_string) }
  let(:wav_jacked_waveform1) { JSON.parse(File.read(File.expand_path('../../',__FILE__) + "/files/test.wav.waveform.json")) }
  let(:wav_jacked_waveform140) { JSON.parse(File.read(File.expand_path('../../',__FILE__) + "/files/test.wav.waveform140.json")) }
  let(:mp3_jacked_waveform1) { JSON.parse(File.read(File.expand_path('../../',__FILE__) + "/files/test.mp3.waveform.json")) }
  let(:mp3_jacked_waveform140) { JSON.parse(File.read(File.expand_path('../../',__FILE__) + "/files/test.mp3.waveform140.json")) }

  context "#file_type" do
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

    context "with a content string" do
      it "sets the file_type to audio" do
        expect(content_jacked.file_type).to eq "audio"
      end
    end
  end

  context "#file_format" do
    context "with a mp3 file" do
      it "sets the file_format to mp3" do
        expect(mp3_jacked.file_format).to eq "mp3"
      end
    end

    context "with a wav file" do
      it "sets the file_format to wav" do
        expect(wav_jacked.file_format).to eq "wav"
      end
    end

    context "with a content string" do
      it "sets the file_format to mp3" do
        expect(content_jacked.file_format).to eq "mp3"
      end
    end
  end

  context "#duration" do
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

    context "with a content string" do
      it "sets the duration to 2 sec" do
        expect(content_jacked.duration).to eq 2
      end
    end
  end

  context "#waveform" do
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
  end
end
