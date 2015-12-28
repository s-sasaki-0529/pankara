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
  `id` INTEGER NULL AUTO_INCREMENT,
  `brand` VARCHAR(16) NOT NULL COMMENT 'JOYSOUND/DAM',
  `product` VARCHAR(16) NOT NULL COMMENT 'LiveDAM/PremiaDAM/f1など',
	`created_at` TIMESTAMP NOT NULL ,
  PRIMARY KEY (`id`)
) COMMENT 'カラオケ機種';

-- ---
-- Table 'score_type'
-- 採点モード
-- ---

DROP TABLE IF EXISTS `score_type`;

CREATE TABLE `score_type` (
  `id` INTEGER NULL AUTO_INCREMENT,
  `product` INTEGER NULL COMMENT '機種番号',
	`name` MEDIUMTEXT NULL COMMENT '採点モードの名前',
  `created_at` TIMESTAMP NOT NULL ,
  PRIMARY KEY (`id`)
) COMMENT '採点モード';

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
-- Table 'artist'
-- 個々の歌手を管理
-- ---

DROP TABLE IF EXISTS `artist`;

CREATE TABLE `artist` (
  `id` INTEGER NULL AUTO_INCREMENT,
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
  `id` INTEGER NULL AUTO_INCREMENT,
  `name` MEDIUMTEXT NOT NULL COMMENT '店名',
  `branch` MEDIUMTEXT NULL COMMENT '店舗名',
  `url` MEDIUMTEXT NULL COMMENT '店舗のURL',
  `memo` MEDIUMTEXT NULL COMMENT '備考',
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT '店舗情報';

-- ---
-- Table 'karaoke'
-- カラオケデータ
-- ---

DROP TABLE IF EXISTS `karaoke`;

CREATE TABLE `karaoke` (
  `id` INTEGER NULL AUTO_INCREMENT,
  `datetime` DATETIME NULL DEFAULT NULL COMMENT '入店日時',
  `plan` INTEGER NULL DEFAULT NULL COMMENT '滞在時間',
  `store` INTEGER NULL COMMENT '利用店舗',
  `product` INTEGER NULL COMMENT '機種',
  `memo` MEDIUMTEXT NULL COMMENT '備考',
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
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT '曲データ';

-- ---
-- Table 'history'
-- 歌唱履歴
-- ---

DROP TABLE IF EXISTS `history`;

CREATE TABLE `history` (
  `id` INTEGER NULL AUTO_INCREMENT,
  `user` INTEGER NOT NULL COMMENT 'ユーザ番号',
  `karaoke` INTEGER NOT NULL COMMENT 'カラオケ番号',
  `song` INTEGER NOT NULL COMMENT '曲番号',
  `key` INTEGER NULL DEFAULT 0 COMMENT 'キー設定',
  `score_type` INTEGER NULL COMMENT '採点モード',
  `score` INTEGER NULL DEFAULT NULL COMMENT '点数',
  `created_at` TIMESTAMP NOT NULL,
  PRIMARY KEY (`id`)
) COMMENT '歌唱履歴';

-- ---
-- Foreign Keys
-- ---

ALTER TABLE `score_type` ADD FOREIGN KEY (product) REFERENCES `product` (`id`);
ALTER TABLE `karaoke` ADD FOREIGN KEY (store) REFERENCES `store` (`id`);
ALTER TABLE `karaoke` ADD FOREIGN KEY (product) REFERENCES `product` (`id`);
ALTER TABLE `song` ADD FOREIGN KEY (artist) REFERENCES `artist` (`id`);
ALTER TABLE `history` ADD FOREIGN KEY (user) REFERENCES `user` (`id`);
ALTER TABLE `history` ADD FOREIGN KEY (karaoke) REFERENCES `karaoke` (`id`);
ALTER TABLE `history` ADD FOREIGN KEY (song) REFERENCES `song` (`id`);
ALTER TABLE `history` ADD FOREIGN KEY (score_type) REFERENCES `score_type` (`id`);
