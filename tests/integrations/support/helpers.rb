# frozen_string_literal: true

# Helper methods for Cucumber steps
module HelperMethods
   # TEST_TMP_ROOT = Pathname.new(Dir.mktmpdir('bouncer_test_')).expand_path.freeze
   # TEST_TMP_LOG  = (TEST_TMP_ROOT / 'log').expand_path.freeze

   # Data conversion helpers for Cucumber steps
   module Conversion
      def extract_list(list_string)
         (list_string || '').split(',').map(&:strip)
      end

      def symrow(table)
         table.symbolic_hashes.first
      end

      def symtable(table)
         table.map_headers do |header|
            header.tr(' ', '_').downcase.to_sym
         end
      end

      def parse_bool(string)
         !(string =~ /t|y/i).nil?
      end

      def parse_phone(string)
         string.to_s.split(/:\s+/)
      end

      def parse_duration(string)
         scalar, unit = string.split(/\s/)

         return nil if unit.nil? || unit.empty?

         unit = "#{ unit }s" unless unit.end_with?('s')

         unit_map = {
               years:   365.25 * 86400,
               months:  30 * 86400,
               weeks:   7 * 86400,
               days:    86400,
               hours:   3600,
               minutes: 60,
               seconds: 1
         }

         scalar.to_i * unit_map[unit.downcase.to_sym]
      end
   end
end

# Inject the HelperMethods into the Cucumber test context
World(HelperMethods, HelperMethods::Conversion)
