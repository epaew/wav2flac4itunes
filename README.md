# WAV2FLAC4iTunes
ソフト名のままです。  
iTunesで取り込んだwavファイルをflacに変換します。  
その際、iTunesで保存されたメタ情報をflacファイルに埋め込みます。  

# Requirement
## 動作環境
動作確認はUbuntu 16.04 on VirtualBox on Windows10 にて行っています。  
私がMacBookを買ったらそれ用に修正する予定です。  

```
$ uname -a
Linux xubuntu1604 4.10.0-37-generic #41~16.04.1-Ubuntu SMP Fri Oct 6 22:42:59 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
$ ruby -v
ruby 2.3.1p112 (2016-04-26) [x86_64-linux-gnu]
```

## 必要なパッケージ
* ruby
* flac
* libtag1-dev
* gems
  * plist
  * taglib-ruby
  * ruby-progressbar

足りないの思い出したら追記します。

# How to use
`wav2flac4itunes.rb`ファイル内の`ITUNES_DIR` `FLAC_DIR`定数を利用する環境に合わせ修正してください。  
あとは以下のとおりターミナルに入力すれば動きます。
```
$ ruby path/to/wav2flac4itunes.rb
```
