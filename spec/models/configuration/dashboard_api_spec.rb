require 'spec_helper'

describe Configuration::DashboardAPI do
  describe '.configured?' do

    context 'without api key' do
      it 'returns false' do
        AppSettings.stub(:dashboard_api_key).and_return(nil)
        expect(Configuration::DashboardAPI.configured?).to eq false
      end
    end

    context 'with a tracker' do
      it 'returns true' do
        AppSettings.stub(:dashboard_api_key)
          .and_return("api_key")

        expect(Configuration::DashboardAPI.configured?).to eq true
      end
    end
  end

  describe '.key' do
    it 'returns a proc' do
      Configuration::DashboardAPI.key.should respond_to(:call)
    end
  end
end