require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class AccessibilitySimulatorHelper
      def self.plist
        base_dir = Dir.home + "/Library/Developer/CoreSimulator/Devices/"

        has_correct_category = self.list(
            base_dir: base_dir,
            file: "com.apple.UIKit.plist",
            key: "UIPreferredContentSizeCategoryName",
            value: "UICTContentSizeCategoryXXXL"
        )

        has_toggle_on = self.list(
            base_dir: base_dir,
            file: "com.apple.preferences-framework.plist",
            key: "largeTextUsesExtendedRange",
            value: true
        )

        has_both_correct = has_correct_category & has_toggle_on

        puts has_both_correct
      end

      def self.list(options)
        udids = []
        Dir.entries(options[:base_dir]).select do |entry|
          unless entry[0] == '.'
            options[:simulator] = entry
            udid = self.preferences(options).to_s.strip
            unless udid.empty?
              udids.push(udid)
            end
          end
        end
        return udids
      end

      def self.preferences(options)
        preference_file = File.join(options[:base_dir], [
            options[:simulator],
            "/data/Library/Preferences/",
            options[:file]
        ])

        if File.exist?(preference_file)
          options[:path] = preference_file
          return self.read_plist(options)
        end
      end

      def self.read_plist(options)
        `plutil -convert xml1 #{options[:path]}`
        plist = Plist::parse_xml(options[:path])
        if plist[options[:key]] == options[:value]
          puts "#{options[:key]} is #{options[:value]} for #{options[:path]}"
          return options[:simulator]
        end
        # plist.save_plist(options[:path])

        `plutil -convert binary1 #{options[:path]}`
      end
    end
  end
end
