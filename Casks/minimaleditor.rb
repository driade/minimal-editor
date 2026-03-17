cask "minimaleditor" do
  version "0.1.3"
  sha256 "c6e0443b2be8104c00608ec4d5609635922cc36ca7639bb96a4e1d91c914adf7"

  url "https://github.com/driade/minimal-editor/releases/download/v#{version}/MinimalEditor-macOS.zip"
  name "MinimalEditor"
  desc "Minimal native macOS plain-text editor with persistent colors"
  homepage "https://github.com/driade/minimal-editor"

  depends_on macos: ">= :sonoma"

  app "MinimalEditor.app"
end
