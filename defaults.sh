# Finderで隠しファイルを表示する
defaults write com.apple.finder AppleShowAllFiles true
# Finderにステータスバーを表示
defaults write com.apple.finder ShowStatusBar -bool true
# Finderにパスバーを表示
defaults write com.apple.finder ShowPathbar -bool true
# Finderにタブバーを表示
defaults write com.apple.finder ShowTabView -bool true
# Finderで全ての拡張子を表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# ライブ変換をOFF
defaults write com.apple.TextInputSource "AppleTextInputSourceLiveConversionEnabled" -bool false
# IME切り替えインジゲーターを非表示
defaults write kCFPreferencesAnyApplication TSMLanguageIndicatorEnabled 0
# キーのリピート速度を最速に設定
defaults write NSGlobalDomain KeyRepeat -int 1
# リピート入力認識までの時間を最短に設定
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# キャプチャ時に余白が入らないようにする
defaults write com.apple.screencapture disable-shadow -boolean true

# Dockを右に配置
defaults write com.apple.dock orientation -string "right"
# Dockのアプリを全て削除
defaults delete com.apple.dock persistent-apps
# Dockを自動で隠す
defaults write com.apple.dock autohide -bool true
# Dockのアイコンサイズを変更
defaults write com.apple.dock tilesize -int 32

# 再起動
killall Dock
killall SystemUIServer
