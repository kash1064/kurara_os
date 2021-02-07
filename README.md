# kurara_os x86_64
- 32bit 自作OS
- 4GB の USB をブートメディアに利用


## Environment
1. Windows環境に、OS実行用のQemuをインストールして、PATHを通す
    - C:\Program Files\qemu
    - \kurara_os\intel_386\env
    
2. OSコンパイル用のDockerイメージを作成
    - sudo /etc/init.d/docker start
    - docker build -t kurara_os_x86_64 .
    - docker run --rm -it --user ubuntu -v $PWD:/kurara_os kurara_os_x86_64 bash

3. VSCodeに拡張機能[microsoft/vscode-hexeditor: VS Code Hex Editor](https://github.com/microsoft/vscode-hexeditor)をインストール


## Reference
### Book
- [30日でできる! OS自作入門 | 川合 秀実 | 工学 | Kindleストア | Amazon](https://amzn.to/2Og95Yr)

- [作って理解するOS x86系コンピュータを動かす理論と実装 | 林 高勲, 川合 秀実 | 工学 | Kindleストア | Amazon](https://amzn.to/2OiqcsJ)

- [自作エミュレータで学ぶx86アーキテクチャ　コンピュータが動く仕組みを徹底理解！ | 内田 公太, 上川 大介 | 工学 | Kindleストア | Amazon](https://amzn.to/36OW3aP)

### Web
- [tools/nask - hrb-wiki](http://hrb.osask.jp/wiki/index.php?tools%2Fnask)

### Blog
- [【Ubuntu/NASMで】『30日でできる！OS自作入門』を10日目まで進めたのでポイントをまとめてみた｜かえるのほんだな](https://yukituna.com/2785/)

- [30日OSのブートイメージをQemuのCUIで動かすnographicオプションの使い方｜かえるのほんだな](https://yukituna.com/2940/)


### Licence
この OS は、以下の素晴らしい書籍のサンプルをベースに作成しております。

- [30日でできる! OS自作入門 | 川合 秀実 | 工学 | Kindleストア | Amazon](https://amzn.to/2Og95Yr)
- [作って理解するOS x86系コンピュータを動かす理論と実装 | 林 高勲, 川合 秀実 | 工学 | Kindleストア | Amazon](https://amzn.to/2OiqcsJ)

いずれの著者の方も、サンプルプログラムの改造・再配布を認めていただいておりますので、本プログラムもそれに倣ってライセンスフリーで公開いたします。