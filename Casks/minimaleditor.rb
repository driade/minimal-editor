cask "minimaleditor" do
  version "0.1.4"
  sha256 "b607a6265afd20ef0f58af7297d10bbfe5f2c3fbfe6516aba7879a3e49481ded"

  url "https://github.com/driade/minimal-editor/releases/download/v#{version}/MinimalEditor-macOS.zip"
  name "MinimalEditor"
  desc "Minimal native macOS plain-text editor with persistent colors"
  homepage "https://github.com/driade/minimal-editor"

  depends_on macos: ">= :sonoma"

  app "MinimalEditor.app"
end
