require 'spec_helper'

describe Configuration::Mailer do

  subject(:mailer) { Configuration::Mailer }

  describe '.configured?' do

    before {
      mailer.stub(:from).and_return(:from)
      mailer.stub(:scheduler_email).and_return(:scheduler_email)
      mailer.stub(:host).and_return(:host)
      mailer.stub(:port).and_return(:port)
      mailer.stub(:user_name).and_return(:user_name)
      mailer.stub(:password).and_return(:password)
    }

    context 'when all fields are set' do
      it { expect(mailer.configured?).to be(true) }
    end

    context 'when from not set' do
      before { mailer.stub(:from).and_return(nil) }

      it { expect(mailer.configured?).to be(false) }
    end

    context 'when scheduler_email not set' do
      before { mailer.stub(:scheduler_email).and_return(nil) }

      it { expect(mailer.configured?).to be(false) }
    end

    context 'when host not set' do
      before { mailer.stub(:host).and_return(nil) }

      it { expect(mailer.configured?).to be(false) }
    end

    context 'when port not set' do
      before { mailer.stub(:port).and_return(nil) }

      it { expect(mailer.configured?).to be(false) }
    end

    context 'when user_name not set' do
      before { mailer.stub(:user_name).and_return(nil) }

      it { expect(mailer.configured?).to be(false) }
    end

    context 'when password not set' do
      before { mailer.stub(:password).and_return(nil) }

      it { expect(mailer.configured?).to be(false) }
    end

  end

end
