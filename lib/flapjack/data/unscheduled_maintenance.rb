#!/usr/bin/env ruby

require 'zermelo/records/redis_record'

require 'flapjack/data/validators/id_validator'

module Flapjack
  module Data
    class UnscheduledMaintenance

      include Zermelo::Records::RedisRecord
      include ActiveModel::Serializers::JSON
      self.include_root_in_json = false

      define_attributes :start_time => :timestamp,
                        :end_time   => :timestamp,
                        :summary    => :string

      belongs_to :check_by_start, :class_name => 'Flapjack::Data::Check',
        :inverse_of => :unscheduled_maintenances_by_start

      belongs_to :check_by_end, :class_name => 'Flapjack::Data::Check',
        :inverse_of => :unscheduled_maintenances_by_end

      before_validation :ensure_start_time

      validates :start_time, :presence => true
      validates :end_time, :presence => true

      validates_with Flapjack::Data::Validators::IdValidator

      def duration
        self.end_time - self.start_time
      end

      def check
        self.check_by_start
      end

      def check=(c)
        self.check_by_start = c
        self.check_by_end   = c
      end

      def self.jsonapi_attributes
        [:start_time, :end_time, :summary]
      end

      def self.jsonapi_singular_associations
        [{:check_by_start => :check, :check_by_end => :check}]
      end

      def self.jsonapi_multiple_associations
        []
      end

      private

      def ensure_start_time
        self.start_time ||= Time.now
      end

    end
  end
end
