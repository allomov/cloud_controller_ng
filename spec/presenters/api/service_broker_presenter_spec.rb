require 'spec_helper'
require 'presenters/api/service_broker_presenter'

module VCAP::CloudController
  describe ServiceBrokerPresenter do
    let(:broker) { ServiceBroker.make }

    subject(:presenter) { ServiceBrokerPresenter.new(broker) }

    describe '#to_hash' do
      describe '[:metadata]' do
        subject(:metadata) { presenter.to_hash.fetch(:metadata) }

        it 'includes the guid' do
          expect(metadata.fetch(:guid)).to eq(broker.guid)
        end

        it 'includes the CC resource url' do
          expect(metadata.fetch(:url)).to eq("/v2/service_brokers/#{broker.guid}")
        end
      end

      describe '[:entity]' do
        subject(:entity) { presenter.to_hash.fetch(:entity) }

        it 'does not include the token' do
          expect(entity).to_not have_key(:token)
        end

        it 'includes the name' do
          expect(entity.fetch(:name)).to eq(broker.name)
        end

        it 'includes the endpoint url' do
          expect(entity.fetch(:broker_url)).to eq(broker.broker_url)
        end
      end
    end
  end
end
