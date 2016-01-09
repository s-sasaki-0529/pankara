use march;
INSERT INTO product ( brand , product ) VALUES
('JOYSOUND' , 'WAVE') ,
('JOYSOUND' , 'CROSSO') ,
('JOYSOUND' , 'f1') ,
('JOYSOUND' , 'MAX') ,
('DAM' , 'Premier DAM') ,
('DAM' , 'LIVE DAM');

insert into store ( name , branch , url , memo ) VALUES
('歌広場' , '亀戸店' , 'http://www.utahiro.com/store/storelist/storeinfo/tabid/64/pdid/0105/Default.aspx' , '壁がめっちゃうすい');

insert into artist ( name ) VALUES
('BUMP OF CHICKEN') ,
('野川 さくら') ,
('サザンオールスターズ') ,
('きゃりーぱみゅぱみゅ') ,
('Superfly') ,
('A応P') ,
('イヤミ(鈴村健一) feat.おそ松(櫻井孝宏)×カラ松(中村悠一)×チョロ松(神谷浩史)×一松(福山潤)×十四松(小野大輔)×トド松(入野自由)') ,
('UNISON SQUARE GARDEN') ,
('りぶ') ,
('島谷ひとみ') ,
('Last Note') ,
('SEKAI NO OWARI') ,
('トーマ') ,
('コブクロ') ,
('一ノ瀬トキヤ(宮野真守)') ,
('Supercell') ,
('シド') ,
('TOKIO');

INSERT INTO user ( username , password , screenname ) VALUES
('sa2knight' , 'zenra' , 'ないと');

INSERT INTO song ( artist , name , url ) VALUES
(1 , 'オンリーロンリーグローリー' , 'https://www.youtube.com/watch?v=ZpAn8moiAOM') ,
(1 , '天体観測' , 'https://www.youtube.com/watch?v=j7CDb610Bg0') ,
(2 , 'HAPPY HARMONICS' , 'https://www.youtube.com/watch?v=iPVL2eYEDDQ') ,
(3 , 'TSUNAMI' , 'https://www.youtube.com/watch?v=HgDGFrMITOo') ,
(4 , 'PONPONPON' , 'https://www.youtube.com/watch?v=yzC4hFK5P3g') ,
(5 , '輝く月のように' , 'https://www.youtube.com/watch?v=gG7evVU0OdA') ,
(6 , 'はなまるぴっぴはよいこだけ' , 'https://www.youtube.com/watch?v=-AawjV4eJPA') ,
(7 , 'SIX SAME FACES' , 'https://www.youtube.com/watch?v=RVB6E03-9m8') ,
(8 , 'シュガーソングとビターステップ' , 'https://www.youtube.com/watch?v=3exsRhw3xt8') ,
(9 , 'ヨンジュウナナ' , 'https://www.youtube.com/watch?v=YICM_U1EwLM') ,
(10 , 'YUME日和' , 'https://www.youtube.com/watch?v=LuNmfDmeCTc') ,
(11 , 'セツナトリップ' , 'https://www.youtube.com/watch?v=EXxW1GWSdps') ,
(12 , 'RPG' , 'https://www.youtube.com/watch?v=Mi9uNu35Gmk') ,
(13 , 'ヤンキーボーイ・ヤンキーガール' , 'https://www.youtube.com/watch?v=v5S1kdPc8LA') ,
(14 , 'ここにしか咲かない花' , 'https://www.youtube.com/watch?v=aa8iVP-9M5w') ,
(15 , 'Independence' , 'https://www.youtube.com/watch?v=QPmoTAmcVGk') ,
(16 , 'ワールドイズマイン' , 'https://www.youtube.com/watch?v=YGYaOLTVDR8') ,
(1 , 'ダイヤモンド' , 'https://www.youtube.com/watch?v=zATrOuOUu3E') ,
(17 , '嘘' , 'https://www.youtube.com/watch?v=LbZXvmXvNQQ') ,
(18 , '宙船(そらふね)' , 'https://www.youtube.com/watch?v=UpcDdLQgVVE');

INSERT INTO karaoke ( datetime , name , plan , store , product , price , memo) VALUES
('2016-01-03 15:30:00' , 'ともちんとないとのフタカラ' ,  3.5 , 1 , 5 , 1015 , '新年一発目');

INSERT INTO attendance ( user , karaoke ) VALUES
(1 , 1);

INSERT INTO history ( attendance , song , songkey , score_type , score) VALUES
(1 ,1 , 0 , 'DAM 精密採点2' , 84 ) ,
(1 ,2 , 0 , 'DAM 精密採点2' , 83 ) ,
(1 ,3 , 5 , 'DAM 精密採点2' , 79 ) ,
(1 ,4 , 0 , 'DAM 精密採点2' , 79 ) ,
(1 ,5 , -3 , 'DAM 精密採点2' , 67 ) ,
(1 ,6 , 5 , 'DAM 精密採点2' , 80 ) ,
(1 ,7 , 0 , 'DAM 精密採点2' , 77 ) ,
(1 ,8 , 0 , 'DAM 精密採点2' , 65 ) ,
(1 ,9 , -2 , 'DAM 精密採点2' , 83 ) ,
(1 ,10 , 0 , 'DAM 精密採点2' , 83 ) ,
(1 ,11 , -4 , 'DAM ランキングバトル' , 81.416) ,
(1 ,12 , 5 , 'DAM 精密採点2' , 77 ) ,
(1 ,13 , 0 , 'DAM 精密採点2' , 82 ) ,
(1 ,14 , 0 , 'DAM 精密採点2' , 75 ) ,
(1 ,15 , 0 , 'DAM 精密採点2' , 78 ) ,
(1 ,16 , 0 , 'DAM 精密採点2' , 79 ) ,
(1 ,17 , 5 , 'DAM 精密採点2' , 79 ) ,
(1 ,18 , 0 , 'DAM 精密採点2' , 80 ) ,
(1 ,19 , 0 , 'DAM 精密採点2' , 76 ) ,
(1 ,20 , 0 , 'DAM 精密採点2' , 81 ) ,
(1 ,6 , 0 , 'DAM 精密採点2' , 74 );
