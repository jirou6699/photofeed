# PhotoFeed

写真を投稿してTwitter/Xにツイートできるアプリケーションです。

## セットアップ手順
```bash
# リポジトリをクローン
git clone https://github.com/jirou6699/photofeed.git

# 環境変数の設定
touch .env
# .envファイルを編集して必要な環境変数を設定してください

# Dockerコンテナのビルド
docker compose build

# データベースの作成とマイグレーション
docker compose run --rm app rails db:create
docker compose run --rm app rails db:migrate

# コンテナの起動
docker compose up

# アプリケーションにアクセス
# http://localhost:3000 をブラウザで開く
```

## テストの実行
```bash
# 全てのテストを実行
docker compose run --rm -e "RAILS_ENV=test" app bundle exec rspec

# 特定のファイルのテストを実行
docker compose run --rm -e "RAILS_ENV=test" app bundle exec rspec ./spec/requests/sessions_request_spec.rb
```
## ユーザー登録
```ruby
docker compose run --rm app bin/rails c
User.create(email:"user@gmail.com", password:"password")
```

## 機能
- ログイン
- 写真のアップロード
- MYTWEET OAuth連携
- ツイート作成

## DB設計

### USERS
| カラム名 | 型 | 説明 |
|---------|-----|------|
| id | bigint | 主キー |
| email | string | メールアドレス |
| password_digest | string | パスワード（暗号化） |
| session_digest | string | セッション（暗号化） |
| created_at | datetime | 作成日時 |
| updated_at | datetime | 更新日時 |

### PHOTOS
| カラム名 | 型 | 説明 |
|---------|-----|------|
| id | bigint | 主キー |
| user_id | bigint | 外部キー（USERS） |
| title | string | タイトル |
| created_at | datetime | 作成日時 |
| updated_at | datetime | 更新日時 |

### ACTIVE_STORAGE_BLOBS
| カラム名 | 型 | 説明 |
|---------|-----|------|
| id | bigint | 主キー |
| key | string | キー |
| filename | string | ファイル名 |
| content_type | string | コンテンツタイプ |
| metadata | text | メタデータ |
| byte_size | bigint | ファイルサイズ |
| checksum | string | チェックサム |
| created_at | datetime | 作成日時 |

### ACTIVE_STORAGE_ATTACHMENTS
| カラム名 | 型 | 説明 |
|---------|-----|------|
| id | bigint | 主キー |
| name | string | 名前 |
| record_type | string | レコードタイプ |
| record_id | bigint | レコードID |
| blob_id | bigint | 外部キー（ACTIVE_STORAGE_BLOBS） |
| created_at | datetime | 作成日時 |

### ACTIVE_STORAGE_VARIANT_RECORDS
| カラム名 | 型 | 説明 |
|---------|-----|------|
| id | bigint | 主キー |
| blob_id | bigint | 外部キー（ACTIVE_STORAGE_BLOBS） |
| variation_digest | string | バリエーションダイジェスト |
| created_at | datetime | 作成日時 |

### リレーション
- USERS 1 : N PHOTOS
- PHOTOS 1 : N ACTIVE_STORAGE_ATTACHMENTS
- ACTIVE_STORAGE_BLOBS 1 : N ACTIVE_STORAGE_ATTACHMENTS
- ACTIVE_STORAGE_BLOBS 1 : N ACTIVE_STORAGE_VARIANT_RECORDS
