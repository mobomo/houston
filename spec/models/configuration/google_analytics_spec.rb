require 'spec_helper'

describe Configuration::GoogleAnalytics do
  describe '.configured?' do

    context 'without tracker' do
      it 'returns false' do
        AppSettings.stub(:google_analytics_tracker).and_return(nil)
        expect(Configuration::GoogleAnalytics.configured?).to eq false
      end
    end

    context 'with a tracker' do
      it 'returns true' do
        AppSettings.stub(:google_analytics_tracker)
          .and_return("tracker_id")

        expect(Configuration::GoogleAnalytics.configured?).to eq true
      end
    end
  end

  describe '.tracker' do
    it 'returns a proc' do
      Configuration::GoogleAnalytics.tracker.should respond_to(:call)
    end
  end
end