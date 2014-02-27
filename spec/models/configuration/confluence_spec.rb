require 'spec_helper'

describe Configuration::Confluence do
  describe '.configured?' do

    context 'without se' do
      it 'returns false' do
        Configuration::Confluence.client = nil

        expect(Configuration::Confluence.configured?).to eq false
      end
    end

    context 'with a client' do
      context 'and without settings' do
        it 'returns false' do
          AppSettings.stub(:confluence).and_return(nil)

          expect(Configuration::Confluence.configured?).to eq false
        end
      end

      context 'and with settings' do
        it 'returns true' do
          AppSettings.stub(:confluence)
            .and_return({
                          test: {
                            space: 'TEST',
                            user: 'test',
                            password: 'test',
                            faq_parent: 123
                          }
                        })

          expect(Configuration::Confluence.configured?).to eq false
        end
      end
    end

  end
end
