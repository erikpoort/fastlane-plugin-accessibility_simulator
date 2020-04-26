require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class AccessibilitySimulatorHelper
      def self.plist
        base_dir = Dir.home + "/Library/Developer/CoreSimulator/Devices/"

        preferred_content_size_category = "UICTContentSizeCategoryAccessibilityXXXL"
        has_correct_category = self.list(
            base_dir: base_dir,
            file: "com.apple.UIKit.plist",
            key: "UIPreferredContentSizeCategoryName",
            value: preferred_content_size_category
        )

        if has_correct_category.empty?
          `xcrun simctl list devices | grep "(Booted)" | grep -E -o -i "([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12})"`

          new_udid = `xcrun simctl create AccessibilityPhone "iPhone X"`.to_s.strip
          puts new_udid

          `xcrun simctl boot #{new_udid}`

          wait_for_uikit = File.join(base_dir, [
              new_udid,
              "/data/Library/Preferences/",
              "com.apple.UIKit.plist"
          ])
          until File.exist?(wait_for_uikit)
            sleep 1
          end
          `xcrun simctl shutdown #{new_udid}`
          self.write_plist(
              path: File.join(base_dir, [
                  new_udid,
                  "/data/Library/Preferences/",
                  "com.apple.UIKit.plist"
              ]),
              key: "UIPreferredContentSizeCategoryName",
              value: preferred_content_size_category
          )
          `xcrun simctl boot #{new_udid}`
        end
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
          return options[:simulator]
        end
        `plutil -convert binary1 #{options[:path]}`
      end

      def self.write_plist(options)
        `plutil -convert xml1 #{options[:path]}`
        plist = Plist::parse_xml(options[:path])
        plist[options[:key]] = options[:value]
        plist.save_plist(options[:path])
        `plutil -convert binary1 #{options[:path]}`
      end
    end
  end
end
