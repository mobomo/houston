require 'spec_helper'

describe Configuration::GoogleOmniauth do
  describe '.configured?' do

    context 'without client id' do
      it 'returns false' do
        AppSettings.stub(:google_client_id).and_return(nil)
        expect(Configuration::GoogleOmniauth.configured?).to eq false
      end
    end

    context 'without client id' do
      it 'returns false' do
        AppSettings.stub(:google_client_secret).and_return(nil)
        expect(Configuration::GoogleOmniauth.configured?).to eq false
      end
    end

    context 'with a client id and secret' do
      it 'returns true' do
        AppSettings.stub(:google_client_id)
          .and_return("client_id")
        AppSettings.stub(:google_client_secret)
          .and_return("client_secret")

        expect(Configuration::GoogleOmniauth.configured?).to eq true
      end
    end
  end

  describe '.setup_proc' do
    it 'returns a proc' do
      Configuration::GoogleOmniauth.setup_proc.should respond_to(:call)
    end
  end
end