require 'fastlane/action'
require_relative '../helper/accessibility_simulator_helper'

module Fastlane
  module Actions
    class AccessibilitySimulatorAction < Action
      def self.run(params)
        UI.message("The accessibility_simulator plugin is working!")
      end

      def self.description
        "Create and run on simulators with accessibility settings"
      end

      def self.authors
        ["Erik Poort"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "This plugin will run your tests on a simulator created with specific accessibility settings. It will first search for any existing simulators."
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "ACCESSIBILITY_SIMULATOR_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
