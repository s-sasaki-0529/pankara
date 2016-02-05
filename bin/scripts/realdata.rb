require '~/March/app/models/util'
DB.connect
User.create('sa2knight' , 'zenra' , 'ないと')
User.create('tomotin' , 'zenra' , 'ともちん')
User.create('hetare' , 'zenra' , 'へたれ')
User.create('worry' , 'zenra' , 'ウォーリー')
Friend.add(1 , 2)
Friend.add(1 , 3)
Friend.add(2 , 1)
Friend.add(2 , 3)
Friend.add(3 , 1)
Friend.add(3 , 2)
Friend.add(3 , 4)
Friend.add(4 , 3)

# --2016-02-05 hetare
datetime = '2016-02-05 16:42:01'
name ='ヒトカラ専用ルーム'
plan = 1.5
store = {'name' => '快活CLUB' , 'branch' => '甚目寺店'}
product = {'brand' => 'DAM' , 'product' => 'LIVE DAM'}
register = Register.new(User.new('hetare'))
karaoke = register.create_karaoke(datetime , name , plan , store , product)
register.attend_karaoke(765 , 'クーラーあった')

register.create_history('カノン' , '宮野真守')
register.create_history('シュガーソングとビターステップ' , 'UNISON SQUARE GARDEN')
register.create_history('Innocent Graffiti' , 'Fo\'xTails')
register.create_history('青い春' , 'back number')
register.create_history('シャイン' , '宮野真守')
register.create_history('蒼ノ翼' , '宮野真守')
register.create_history('ハレ晴レユカイ' , '涼宮ハルヒ、朝比奈みくる、長門有希')
register.create_history('恋愛勇者' , 'Last Note.')
register.create_history('Clattanoia' , 'OxT')
register.create_history('One More Chance!!' , 'ALL OFF')
register.create_history('KINJITO' , 'UVERworld')
register.create_history('クオリア' , 'UVERworld')
register.create_history('Exterminate' , '水樹奈々')

# --2016-01-30 sa2knight / tomotin
datetime = '2016-01-30 14:00:00'
name ='2016年 3/24回目'
plan = 3
store = {'name' => '歌広場' , 'branch' => '亀戸店'}
product = {'brand' => 'JOYSOUND' , 'product' => 'CROSSO'}
score_type = {'brand' => 'JOYSOUND' , 'name' => '全国採点オンライン2'}

register = Register.new(User.new('sa2knight'))
karaoke = register.create_karaoke(datetime , name , plan , store , product)
register.attend_karaoke(860 , 'グロリアスレボリューションが楽しかった')

register.create_history('アゲハチョウ' , 'ポルノグラフィティ' , 0 , score_type , 88.812)
register.create_history('からくりピエロ' , '40mP' , 3 , score_type , 91.806)
register.create_history('タマシイレボリューション' , 'Superfly' , -5 , score_type , 85.913)
register.create_history('天ノ弱' , '164' , -3 , score_type , 87.061)
register.create_history('さよならのかわりに花束を' , '花束P' , 0 , score_type , 88.637)
register.create_history('ランプ' , 'BUMP OF CHICKEN' , 0 , score_type , 89.154)
register.create_history('サリシノハラ' , 'みきとP' , -4 , score_type , 89.404)
register.create_history('シュガーソングとビターステップ' , 'UNISON SQUARE GARDEN' , -3 , score_type , 88.217)
register.create_history('裏表ラバース' , 'wawoka' , 0 , score_type , 90.796)
register.create_history('dialogue' , 'KEI' , -3 , score_type , 90.010)
register.create_history('オンリーロンリーグローリー' , 'BUMP OF CHICKEN' , 0 , score_type , 88.395)
register.create_history('袖触れ合うも他生の縁' , '磯P' , -3 , score_type , 88.861)
register.create_history('歌に形はないけれど' , 'doriko' , -3 , score_type , 89.891)
register.create_history('吉原ラメント' , '亜紗' , -3 , score_type , 86.232)
register.create_history('ハウトゥー世界征服' , 'kemu' , 0 , score_type , 87.998)
register.create_history('グロリアスレボリューション' , 'BUMP OF CHICKEN' , 0 , score_type , 83.452)
register.create_history('ハッピーシンセサイザ' , 'Easy Pop' , -3 , score_type , 86.662)
register.create_history('嘘' , 'シド' , 0 , score_type , 90.901)
register.create_history('Independence' , '一ノ瀬トキヤ' , 0 , score_type , 88.028)
register.create_history('Ending' , 'BUMP OF CHICKEN' , 0 , score_type , 86.545)

register = Register.new(User.new('tomotin'))
register.karaoke = karaoke
register.attend_karaoke(860)

register.create_history('オーバーキルサイズ・ヘル' , '暁切歌' , 0 , score_type , 89.064) 
register.create_history('BAYONET CHARGE' , '風鳴翼、雪音クリス' , 0 , score_type , 86.642) 
register.create_history('恋だなう' , '千歳千里' , 3 , score_type , 85.796)
register.create_history('笑顔クエスト' , '一氏ユウジ' , 3 , score_type , 88.497)
register.create_history('たったひとつの日々' , '伊月俊' , 3 , score_type , 87.003)
register.create_history('Hikari' , '羽多野渉' , 2 , score_type , 85.321)
register.create_history('daze' , 'じん' , 0 , score_type , 87.608)
register.create_history('Get Sparks' , '財前光' , 4 , score_type , 86.063)
register.create_history('ORBITAL BEAT' , 'ツヴァイウィング' , 0 , score_type , 85.278)
register.create_history('殲琴・ダウルダブラ' , 'キャロル・マールス・ディーンハイム' , 0 , score_type , 87.971)
register.create_history('月の下、命は淡く雪のように(絶唱)' , '雪音クリス' , 0 , score_type , 84.701)
register.create_history('Rebirth-day' , '高垣彩陽' , 0 , score_type , 86.798)
register.create_history('魔弓・イチイバル' , '雪音クリス' , 0 , score_type , 86.424)
register.create_history('もんだいガール' , 'きゃりーぱみゅぱみゅ' , 0 , score_type , 87.177)
register.create_history('おきてがみ' , '暁切歌' , 0 , score_type , 84.363)
register.create_history('手紙' , '暁切歌' , 0 , score_type , 88.859)
register.create_history('繋いだ手だけが紡ぐもの' , '雪音クリス' , 0 , score_type , 88.400)
register.create_history('TRUST HART' , '雪音クリス' , 0 , score_type , 85.617)
register.create_history('tomorrow' , 'キャロル・マールス・ディーンハイム' , 0 , score_type , 87.292)
register.create_history('SENSE OF DISTANCE' , '月読調' , -2 , score_type , 86.597)

# ---2016-01-17 sa2knight / tomotin
datetime = '2016-01-17 14:50:00'
name = '2016年 2/24回目'
plan = 3
store = {'name' => '歌広場' , 'branch' => '亀戸店'}
product = {'brand' => 'JOYSOUND' , 'product' => 'CROSSO'}

register = Register.new(User.new('sa2knight'))
karaoke = register.create_karaoke(datetime , name , plan , store , product)
register.attend_karaoke(780 , 'エコー設定デフォルトにするとやっぱ気持ちいい')

register.create_history('世界に一つだけの花' , 'SMAP')
register.create_history('ドーナツホール' , 'ハチ')
register.create_history('1/3の純情な感情' , 'SIAM SHADE' , -2)
register.create_history('敗北の少年' , 'kemu')
register.create_history('月光' , '鬼束ちひろ' , 5)
register.create_history('independence' , '一ノ瀬トキヤ')
register.create_history('ワールドイズマイン' , 'supercell' , 5)
register.create_history('ロストワンの号哭' , 'Neru' , -2)
register.create_history('袖触れ合うも他生の縁' , '磯P' , -3)
register.create_history('カミサマネジマキ' , 'kemu' , -5)
register.create_history('home' , '木山裕策')
register.create_history('スノースマイル' , 'BUMP OF CHICKEN')
register.create_history('OVERLAP' , 'Kimeru')
register.create_history('Fire◎Flower' , 'absorb' , -2)
register.create_history('独りんぼエンヴィー' , '電ポルP')
register.create_history('from Y to Y' , 'ジミーサムP')
register.create_history('放課後ストライド' , 'Last Note.' , 5)
register.create_history('タマシイレボリューション' , 'Superfly' , -5)
register.create_history('セツナトリップ' , 'Last Note.' , -5)
register.create_history('Dear My Friend' , 'Ever Little Thing' , -2)
register.create_history('YUME日和' , '島谷ひとみ' , -4)
register.create_history('シュガーソングとビターステップ' , 'UNISON SQUARE GARDEN' , -2)
register.create_history('嘘' , 'シド')
register.create_history('地球最後の告白を' , 'kemu')
register.create_history('ワールズエンド・ダンスホール' , 'wawoka')
register.create_history('おちゃめ機能' , 'コジマジP' , -5)

register = Register.new(User.new('tomotin'))
register.karaoke = karaoke
register.attend_karaoke(860 , 'エコー良い')
register.create_history('daze' , 'じん')
register.create_history('ORBITAL BEAT' , 'ツヴァイウィング')
register.create_history('TRUST HART' , '雪音クリス')
register.create_history('銀腕・アガートラーム' , 'マリア・カデンツァヴナ・イヴ')
register.create_history('おきてがみ' , '暁切歌')
register.create_history('虹色のフリューゲル' , '立花響、風鳴翼、雪音クリス、マリア・カデンツァヴナ・イヴ、月読調、暁切歌、天羽奏')
register.create_history('believe yourself' , 'yozuka*')
register.create_history('はなまるぴっぴはよいこだけ' , 'A応P')
register.create_history('もんだいガール' , 'きゃりーぱみゅぱみゅ')
register.create_history('ASIAN STONE' , 'Dorothy Little Happy')
register.create_history('殲琴・ダウルダブラ' , 'キャロル・マールス・ディーンハイム')
register.create_history('Magenta Another Sky' , '原田ひとみ')
register.create_history('RADIANT FORCE' , '立花響、風鳴翼、雪音クリス')
register.create_history('Rebirth-day' , '高垣彩陽')
register.create_history('ジェノサイドソウ・ヘブン' , '月読調')
register.create_history('brave heart' , '宮崎歩')
register.create_history('Vitalization' , '水樹奈々')
register.create_history('繋いだ手だけが紡ぐもの' , '雪音クリス')
register.create_history('笑顔クエスト' , '一氏ユウジ')
register.create_history('恋だなう' , '千歳千里')
register.create_history('手紙' , '暁切歌')

# ---2016-01-08 hetare / worry
datetime = '2016-01-08 00:28:00'
name = '新年初カラオケ'
plan = 5
store = {'name' => 'JOYJOY', 'branch' => '甚目寺店'}
product = {'brand' => 'JOYSOUND' , 'product' => 'MAX'}

register = Register.new(User.new('hetare'))
karaoke = register.create_karaoke(datetime , name , plan , store , product)
register.attend_karaoke(1080)
register.create_history('オルフェ' , '宮野真守')
register.create_history('LLL' , 'MYTH & ROID')
register.create_history('ORIGINAL RESONANCE' , '聖川真斗、一ノ瀬トキヤ')
register.create_history('マジLOVEレボリューションズ' , 'ST☆RISH')
register.create_history('オリオンをなぞる' , 'UNISON SQUARE GARDEN')
register.create_history('女々しくて' , '	ゴールデンボンバー')
register.create_history('ウィーアー!' , 'きただにひろし')
register.create_history('home' , '木山裕策')
register.create_history('WOMAN' , 'アン・ルイス')
register.create_history('やさしさに包まれたなら' , '松任谷由実')
register.create_history('PIECE OF MY WISH' , '今井美樹')
register.create_history('モノクローム' , 'Every Little Thing')
register.create_history('ショットガン・ラヴァーズ' , '	のぼる↑')
register.create_history('ロストワンの号哭' , 'Neru')
register.create_history('地球最後の告白を' , 'kemu')
register.create_history('REVERSI' , 'UVERworld')
register.create_history('Dragon Night' , 'SEKAI NO OWARI')
register.create_history('天ノ弱' , '164')
register.create_history('勇者王誕生！' , '遠藤正明')
register.create_history('DREAM SOLISTER' , 'TRUE')
register.create_history('心響プロジェクター' , '高坂麗奈')
register.create_history('One More Chance!!' , 'ALL OFF')
register.create_history('SECRET LOVER' , '一ノ瀬トキヤ')

register = Register.new(User.new('worry'))
register.karaoke = karaoke
register.attend_karaoke(1380)
register.create_history('勇者王誕生！' , '遠藤正明')
register.create_history('サムライハート(Some Like It Hot!!)' , 'SPYAIR')
register.create_history('You have a dream' , '水樹奈々')
register.create_history('Hungry Spider' , '槇原敬之')
register.create_history('HOLLY LONELY LIGHT' , 'Fire Bomber')
register.create_history('Remember 16' , 'Fire Bomber')
register.create_history('夢であるように' , 'Deen')
register.create_history('Ash Like Snow' , 'the brilliant green')
register.create_history('Orchestral Fantasia' , '水樹奈々')
register.create_history('マダラ蝶' , 'UVERworld')
register.create_history('儚くも永久のカナシ' , 'UVERworld')
register.create_history('心color～a song for the wonderful year～' , '福山雅治')
register.create_history('ひとりぼっちじゃない' , 'coba＆宮沢和史')
register.create_history('THE HERO!!～怒れる拳に火をつけろ～' , 'JAM Project')
register.create_history('春夏秋冬' , 'Hilcrhyme')
register.create_history('ピエロ' , '上木彩矢')
register.create_history('セイラ～SARA～' , 'FENCE OF DEFENSE')
register.create_history('COLORS' , 'FLOW')
register.create_history('メリッサ' , 'ポルノグラフィティ')

# 2016-01-03
datetime = '2016-01-03 15:30:00'
name = '2016年 1/24回目'
plan = 3.5
store = {'name' => '歌広場', 'branch' => '亀戸店'}
product = {'brand' => 'DAM' , 'product' => 'Premier DAM'}
score_type = {'brand' => 'JOYSOUND' , 'name' => '分析採点2'} 
register = Register.new(User.new('sa2knight'))
karaoke = register.create_karaoke(datetime , name , plan , store , product)
register.attend_karaoke(1140)
register.create_history('オンリーロンリーグローリー' , 'BUMP OF CHICKEN' , 0 , score_type , 84)
register.create_history('天体観測' , 'BUMP OF CHICKEN' , 0 , score_type , 83)
register.create_history('HAPPY HARMONICS' , '野川 さくら' , 5 , score_type , 79)
register.create_history('TSUNAMI' , 'サザンオールスターズ' , 0 , score_type , 79)
register.create_history('PONPONPON' , 'きゃりーぱみゅぱみゅ' , -3 , score_type , 67)
register.create_history('輝く月のように' , 'Superfly' , 5 , score_type , 80)
register.create_history('はなまるぴっぴはよいこだけ' , 'A応P' , 0 , score_type , 77)
register.create_history('SIX SAME FACES' , 'イヤミ、おそ松、カラ松、チョロ松、一松、十四松、トド松' , 0 , score_type , 65)
register.create_history('シュガーソングとビターステップ' , 'UNISON SQUARE GARDEN' , -2 , score_type , 83)
register.create_history('ヨンジュウナナ' , 'りぶ' , 0 , score_type , 83)
register.create_history('YUME日和' , '島谷ひとみ' , -4 , score_type , 81)
register.create_history('セツナトリップ' , 'Last Note' , 5 , score_type , 77)
register.create_history('RPG' , 'SEKAI NO OWARI' , 0 , score_type , 82)
register.create_history('ヤンキーボーイ・ヤンキーガール' , 'トーマ' , 0 , score_type , 75)
register.create_history('ここにしか咲かない花' , 'コブクロ' , 0 , score_type , 78)
register.create_history('Independence' , '一ノ瀬トキヤ' , 0 , score_type , 79)
register.create_history('ワールドイズマイン' , 'Supercell' , 5 , score_type , 79)
register.create_history('ダイヤモンド' , 'BUMP OF CHICKEN' , 0 , score_type , 79)
register.create_history('嘘' , 'シド' , 0 , score_type , 80)
register.create_history('宙船(そらふね)' , 'TOKIO' , 0 , score_type , 76)
