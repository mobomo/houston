require 'spec_helper'

describe Configuration::Feedback do
  describe '.configured?' do

    context 'without a url' do
      it 'returns false' do
        AppSettings.stub(:feedback_url).and_return(nil)
        expect(Configuration::Feedback.configured?).to eq false
      end
    end

    context 'with a url' do
      it 'returns true' do
        AppSettings.stub(:feedback_url)
          .and_return("http://example.com")

        expect(Configuration::Feedback.configured?).to eq true
      end
    end

  end
end