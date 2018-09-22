# WAV2FLAC (for iTunes)
iTunesで取り込んだwavファイルをflacに変換します。  
その際、iTunesで保存されたメタ情報をflacファイルに埋め込みます。  

## Requirement
### 動作環境
動作確認はUbuntu 18.04 on VirtualBox on Windows10 にて行っています。  

```
$ uname -a
Linux ubuntu1804 4.15.0-20-generic #21-Ubuntu SMP Tue Apr 24 06:16:15 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
$ ruby -v
ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-linux]
$ dpkg -l | grep libtag1-dev
ii  libtag1-dev:amd64                     1.11.1+dfsg.1-0.2build2             amd64        audio meta-data library - development files
```

## How to use
`config/local.yml`ファイル内の定数を利用する環境に合わせ修正してください。  
```
vim config/local.yml
bin/wav_to_flac
```

## License
[MIT](LICENSE)
