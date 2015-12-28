use march

-- product
INSERT INTO product ( brand , product ) VALUES
('JOYSOUND' , 'WAVE') ,
('JOYSOUND' , 'CROSSO') ,
('JOYSOUND' , 'f1') ,
('JOYSOUND' , 'MAX') ,
('DAM' , 'Premier DAM') ,
('DAM' , 'LIVE DAM');

-- store
INSERT INTO store ( name , branch , url , memo ) VALUES
('カラオケ館' , '千葉中央店' , 'http://karaokekan.jp/shop/kanto_chiba/04030005.html' , '良い店') ,
('カラオケ館' , '川崎店' , 'http://karaokekan.jp/shop/kanto_kanagawa/04020005.html' , '悪い店') ,
('カラオケマック' , '仙台フォーラス店' , 'http://www.k-mac.jp/shop/shop28.html' , '広い店') ,
('カラオケマック' , '仙台広瀬通店' , 'http://www.k-mac.jp/shop/shop18.html' , '狭い店');

-- artist
INSERT INTO artist ( name ) VALUES
('BUMP OF CHICKEN') ,
('コブクロ') ,
('Whiteberry');

-- song
INSERT INTO song ( artist , name ) VALUES
(1 , '天体観測') ,
(1 , 'ゼロ') ,
(2 , 'ここにしか咲かない花') ,
(2 , '蕾') ,
(3 , '桜並木道') ,
(3 , '夏祭り');

-- user
INSERT INTO user ( username , password , screenname ) VALUES
('Sa2Knight' , 'hogehoge' , 'ないと') ,
('unagipai' , 'fugafuga' , 'ちゃら') ,
('hidakasan' , 'foo' , 'へたれ') ,
('tomotin' , 'bar' , 'さっちゃん');

-- score_type
INSERT INTO score_type ( product , name ) VALUES
(4 , '全国採点オンライン2') ,
(6 , '精密採点DX');

-- karaoke
INSERT INTO karaoke ( datetime , plan , store , product , price , memo ) VALUES
('2015-12-01 13:00:00' , 4 , 1 , 4 , 1200 , 'with ちゃら、へたれ ワンドリンク') ,
('2015-11-13 10:30:00' , 7 , 3 , 3 , 1500 , 'with さっちゃん ドリンクバー付き');

-- attend
INSERT INTO attend ( user , karaoke) VALUES
(1 , 1) ,
(1 , 2) ,
(2 , 1) ,
(3 , 1) ,
(4 , 2);

-- history
INSERT INTO history ( attend , song , songkey , score_type , score ) VALUES
(1 , 1 , 0 , 1 , 88) ,
(1 , 2 , -2 , 1 , 90) ,
(1 , 3 , -2 , 1 , 84) ,
(1 , 4 , -3 , 1 , 87) ,
(1 , 5 , 5 , 1 , 90) ,
(1 , 6 , 4 , 1 , 99);
