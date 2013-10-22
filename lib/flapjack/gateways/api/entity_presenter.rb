#!/usr/bin/env ruby

# Formats entity data for presentation by the API methods in Flapjack::Gateways::API.
# Currently this just aggregates all of the check data for an entity, leaving
# clients to make any further calculations for themselves.

require 'sinatra/base'

require 'flapjack/data/check'

require 'flapjack/gateways/api/entity_check_presenter'

module Flapjack

  module Gateways

    class API < Sinatra::Base

      class EntityPresenter

        def initialize(entity, options = {})
          @entity = entity
        end

        def status
          checks.collect {|c| {:entity => @entity.name, :check => c.name,
                               :status => check_presenter(c).status } }
        end

        def outages(start_time, end_time)
          checks.collect {|c|
            {:entity => @entity.name, :check => c.name, :outages => check_presenter(c).outages(start_time, end_time)}
          }
        end

        def unscheduled_maintenances(start_time, end_time)
          checks.collect {|c|
            {:entity => @entity.name, :check => c.name, :unscheduled_maintenances =>
              check_presenter(c).unscheduled_maintenances(start_time, end_time)}
          }
        end

        def scheduled_maintenances(start_time, end_time)
          checks.collect {|c|
            {:entity => @entity.name, :check => c.name, :scheduled_maintenances =>
              check_presenter(c).scheduled_maintenances(start_time, end_time)}
          }
        end

        def downtime(start_time, end_time)
          checks.collect {|c|
            {:entity => @entity.name, :check => c.name, :downtime =>
              check_presenter(c).downtime(start_time, end_time)}
          }
        end

      private

        def checks
          @check_list ||= @entity.checks.all.sort_by(&:name)
        end

        def check_presenter(entity_check)
          return if entity_check.nil?
          presenter = Flapjack::Gateways::API::EntityCheckPresenter.new(entity_check)
        end

      end

    end

  end

end
