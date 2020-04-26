describe Fastlane::Actions::AccessibilitySimulatorAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The accessibility_simulator plugin is working!")

      Fastlane::Actions::AccessibilitySimulatorAction.run(nil)
    end
  end
end
