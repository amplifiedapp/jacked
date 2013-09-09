require 'spec_helper'

describe Jacked do
  context ".create" do
    context "with a valid audio(mp3) file" do
      let(:filename) { "#{File.expand_path('../', __FILE__)}/files/test.mp3" }
      subject { Jacked.create(file: filename) }

      it "creates a jacked instance" do
        expect(subject).to_not be_nil
      end
    end

    context "with nil parameter" do
      subject { Jacked.create }

      it "throws a Jacked::InvalidFile exception" do
        expect {
          subject
        }.to raise_error(Jacked::InvalidFile)
      end
    end

    context "with file that does not exist" do
      let(:filename) { "#{File.expand_path('../', __FILE__)}/files/unavailable.mp3" }
      subject { Jacked.create(file: filename) }

      it "throws a Jacked::InvalidFile exception" do
        expect {
          subject
        }.to raise_error(Jacked::InvalidFile)
      end
    end

    context "with invalid audio file" do
      let(:filename) { "#{File.expand_path('../', __FILE__)}/files/test.png" }
      subject { Jacked.create(file: filename) }

      it "throws a Jacked::InvalidFile exception" do
        expect {
          subject
        }.to raise_error(Jacked::InvalidFile)
      end
    end
  end
end
