cask "minimaleditor" do
  version "0.1.6"
  sha256 "ec3d4197900bb743739f0160a41b2c05206bf802c7505bce637ac2980c388f42"

  url "https://github.com/driade/minimal-editor/releases/download/v#{version}/MinimalEditor-macOS.zip"
  name "MinimalEditor"
  desc "Minimal native macOS plain-text editor with persistent colors"
  homepage "https://github.com/driade/minimal-editor"

  depends_on macos: ">= :sonoma"

  app "MinimalEditor.app"
end
