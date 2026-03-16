cask "minimaleditor" do
  version "0.1.0"
  sha256 "c664d663599c37c851dbeba1e81d4d066de693ba031f044bf32838a983a9f27d"

  url "https://github.com/driade/minimal-editor/releases/download/v#{version}/MinimalEditor-macOS.zip"
  name "MinimalEditor"
  desc "Minimal native macOS plain-text editor with persistent colors"
  homepage "https://github.com/driade/minimal-editor"

  depends_on macos: ">= :sonoma"

  app "MinimalEditor.app"
end
