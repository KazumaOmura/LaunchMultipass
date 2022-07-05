# 環境構築

## ルートディレクトリ命名規則
サービスは`APP`，CMSは`CMS`のディレクトリ名で`LaunchMultipass`ディレクトリ階層に配置する

命名規則に則ってない場合，リモートサーバにマウントされないので注意

## multipassで環境構築
```
$ sh launch
```

## 実行例
※サービス名はキャメルケースのみ
```
任意のサービス名を入力してください >
...

サービス名「...」でインスタンスを作成しますか？ [y/n]:
y

--- インスタンス作成 ---

--> IPアドレス

--> hosts書き換え

--- Ansible実行 ---

--- mount設置 ---

```

## 動作確認
サービスは`[サービス名]-local.com`，CMSは`cms.[サービス名]-local.com`でブラウザからアクセスできる

リモートサーバの`/etc/hosts`に記載されているとおりに動作する

## 注意
これはMultipassの開発環境を作成するツールなのでステージングや本番環境にデプロイするものではない

デプロイは`rsync`を使う