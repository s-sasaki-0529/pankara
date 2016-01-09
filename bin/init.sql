-- ---
-- Database 'march'
-- カラオケ統合情報管理サービス
-- ---

DROP DATABASE IF EXISTS march;
CREATE DATABASE march CHARACTER SET utf8;
use march;

-- ---
-- Table 'product'
-- カラオケ機種
-- ---

DROP TABLE IF EXISTS `product`;

CREATE TABLE `product` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `brand` VARCHAR(16) NOT NULL COMMENT 'JOYSOUND/DAM',
  `product` VARCHAR(16) NOT NULL COMMENT 'LiveDAM/PremiaDAM/f1など',
  `created_at` TIMESTAMP NOT NULL COMMENT '備考',
  PRIMARY KEY (`id`)
) COMMENT 'カラオケ機種';

-- ---
-- Table 'user'
-- ユーザ
-- ---

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(16) NOT NULL COMMENT 'ログイン用ユーザID',
  `password` VARCHAR(16) NOT NULL COMMENT 'ログイン用パスワード',
  `screenname` VARCHAR(16) NOT NULL COMMENT '画面表示用ユーザ名',
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT 'ユーザ';

-- ---
-- Table 'friend'
-- 友達関係を管理
-- ---

DROP TABLE IF EXISTS `friend`;

CREATE TABLE `friend` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `user_from` INTEGER NOT NULL COMMENT '申請側userid',
  `user_to` INTEGER NOT NULL COMMENT '受信側userid',
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT '友達関係を管理';

-- ---
-- Table 'artist'
-- 個々の歌手を管理
-- ---

DROP TABLE IF EXISTS `artist`;

CREATE TABLE `artist` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `name` MEDIUMTEXT NOT NULL COMMENT '歌手名',
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT '個々の歌手を管理';

-- ---
-- Table 'store'
-- 店舗情報
-- ---

DROP TABLE IF EXISTS `store`;

CREATE TABLE `store` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `name` MEDIUMTEXT NOT NULL COMMENT '店名',
  `branch` MEDIUMTEXT NULL DEFAULT NULL COMMENT '店舗名',
  `url` MEDIUMTEXT NULL DEFAULT NULL COMMENT '店舗のURL',
  `memo` MEDIUMTEXT NULL DEFAULT NULL COMMENT '備考',
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT '店舗情報';

-- ---
-- Table 'karaoke'
-- カラオケデータ
-- ---

DROP TABLE IF EXISTS `karaoke`;

CREATE TABLE `karaoke` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `name` MEDIUMTEXT NULL COMMENT '名前',
  `datetime` DATETIME NULL DEFAULT NULL COMMENT '入店日時',
  `plan` FLOAT NULL DEFAULT NULL COMMENT '滞在時間',
  `store` INTEGER NOT NULL COMMENT '利用店舗',
  `product` INTEGER NOT NULL COMMENT '機種',
  `price` INTEGER NULL DEFAULT 0 COMMENT '一人あたりの料金',
  `memo` MEDIUMTEXT NULL DEFAULT NULL COMMENT '備考',
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT 'カラオケデータ';

-- ---
-- Table 'song'
-- 曲データ
-- ---

DROP TABLE IF EXISTS `song`;

CREATE TABLE `song` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `artist` INTEGER NOT NULL COMMENT '歌手番号',
  `name` MEDIUMTEXT NOT NULL COMMENT '曲名',
  `url` MEDIUMTEXT NULL COMMENT '動画URL',
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT '曲データ';

-- ---
-- Table 'history'
-- 歌唱履歴
-- ---

DROP TABLE IF EXISTS `history`;

CREATE TABLE `history` (
  `id` INTEGER NULL AUTO_INCREMENT DEFAULT NULL,
  `attendance` INTEGER NOT NULL COMMENT '参加番号',
  `song` INTEGER NOT NULL COMMENT '曲番号',
  `songkey` INTEGER NULL DEFAULT 0 COMMENT 'キー設定',
  `score_type` MEDIUMTEXT NULL DEFAULT NULL COMMENT '採点モード',
  `score` FLOAT NULL DEFAULT NULL COMMENT '点数',
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT '歌唱履歴';

-- ---
-- Table 'attendance'
-- カラオケへの参加記録
-- ---

DROP TABLE IF EXISTS `attendance`;

CREATE TABLE `attendance` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `user` INTEGER NOT NULL COMMENT '参加ユーザのID',
  `karaoke` INTEGER NOT NULL COMMENT '参加したカラオケ',
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT 'カラオケへの参加記録';

-- ---
-- Foreign Keys
-- ---

ALTER TABLE `karaoke` ADD FOREIGN KEY (store) REFERENCES `store` (`id`);
ALTER TABLE `karaoke` ADD FOREIGN KEY (product) REFERENCES `product` (`id`);
ALTER TABLE `song` ADD FOREIGN KEY (artist) REFERENCES `artist` (`id`);
ALTER TABLE `history` ADD FOREIGN KEY (attendance) REFERENCES `attendance` (`id`);
ALTER TABLE `history` ADD FOREIGN KEY (song) REFERENCES `song` (`id`);
ALTER TABLE `attendance` ADD FOREIGN KEY (user) REFERENCES `user` (`id`);
ALTER TABLE `attendance` ADD FOREIGN KEY (karaoke) REFERENCES `karaoke` (`id`);
ALTER TABLE `friend` ADD FOREIGN KEY (user_from) REFERENCES `user` (`id`);
ALTER TABLE `friend` ADD FOREIGN KEY (user_to) REFERENCES `user` (`id`);
