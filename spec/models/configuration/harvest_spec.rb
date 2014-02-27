require 'spec_helper'

describe Configuration::Harvest do

  subject(:harvest) { Configuration::Harvest }

  describe '.configured?' do
    context 'when there is an identifier and a secret' do
      before {
        harvest.stub(:identifier).and_return(:id)
        harvest.stub(:secret).and_return(:secret)
      }

      it { expect(harvest.configured?).to be(true) }
    end

    context 'when there is an identifier but no secret' do
      before { harvest.stub(:identifier).and_return(:id) }

      it { expect(harvest.configured?).to be(false) }
    end

    context 'when there is a secret but no identifer' do
      before { harvest.stub(:secret).and_return(:secret) }

      it { expect(harvest.configured?).to be(false) }
    end

    context 'when there is no identifer and no secret' do
      it { expect(harvest.configured?).to be(false) }
    end
  end

end
