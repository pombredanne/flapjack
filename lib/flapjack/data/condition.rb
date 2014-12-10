#!/usr/bin/env ruby

require 'sandstorm/records/redis_record'

module Flapjack
  module Data
    class Condition

      # class methods rather than constants, as these may come from config
      # data in the future; name => priority
      def self.healthy
        {
          'ok' => 1
        }
      end

      def self.unhealthy
        {
          'critical' => 3,
          'warning'  => 2,
          'unknown'  => 1
        }
      end

      # NB: not actually persisted; we probably want a non-persisted record type
      # for this case
      include Sandstorm::Records::RedisRecord

      define_attributes :name      => :string,
                        :priority  => :integer

      validates :name, :presence => true,
        :inclusion => { :in => Flapjack::Data::Condition.healthy.keys +
                               Flapjack::Data::Condition.unhealthy.keys }

      validates :priority, :presence => true,
        :numericality => {:greater_than => 0, :only_integer => true},
        :inclusion => { :in => Flapjack::Data::Condition.healthy.values |
                               Flapjack::Data::Condition.unhealthy.values }

      before_create :save_allowed?
      before_update :save_allowed?
      def save_allowed?
        false
      end

      def self.healthy?(c)
        self.healthy.keys.include?(c)
      end

      def self.for_name(n)
        c = Flapjack::Data::Condition.new(:name => n,
          :priority => self.healthy[n.to_s] || self.unhealthy[n.to_s] )
        c.valid? ? c : nil
      end

    end
  end
end