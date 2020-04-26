require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class AccessibilitySimulatorHelper
      def self.plist
        base_dir = Dir.home + "/Library/Developer/CoreSimulator/Devices/"
        self.list(
            base_dir: base_dir,
            file: "com.apple.UIKit.plist",
            key: "UIPreferredContentSizeCategoryName",
            value: "UICTContentSizeCategoryXXXL"
        )
        self.list(
            base_dir: base_dir,
            file: "com.apple.preferences-framework.plist",
            key: "largeTextUsesExtendedRange",
            value: true
        )
      end

      def self.list(options)
        Dir.entries(options[:base_dir]).select do |entry|
          unless entry[0] == '.'
            options[:simulator] = entry
            self.preferences(options)
          end
        end
      end

      def self.preferences(options)
        preference_file = File.join(options[:base_dir], [
            options[:simulator],
            "/data/Library/Preferences/",
            options[:file]
        ])

        if File.exist?(preference_file)
          options[:path] = preference_file
          self.read_plist(options)
        end
      end

      def self.read_plist(options)
        `plutil -convert xml1 #{options[:path]}`
        plist = Plist::parse_xml(options[:path])
        if plist[options[:key]] == options[:value]
          puts "#{options[:key]} is #{options[:value]} for #{options[:path]}"
        end
        # plist.save_plist(options[:path])

        `plutil -convert binary1 #{options[:path]}`
      end
    end
  end
end
