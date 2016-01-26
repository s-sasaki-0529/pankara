require '~/March/app/models/util'
DB.connect
datetime = '2016-01-17 14:50:00'
name = '2016年 2/24回目'
plan = 3
store = {'name' => '歌広場' , 'branch' => '亀戸店'}
product = {'brand' => 'JOYSOUND' , 'product' => 'CROSSO'}

User.create('sa2knight' , 'zenra' , 'ないと')
User.create('tomotin' , 'zenra' , 'ともちん')
User.create('hetare' , 'zenra' , 'へたれ')
User.create('worry' , 'zenra' , 'ウォーリー')

register = Register.new(User.new('sa2knight'))
karaoke = register.create_karaoke(datetime , name , plan , store , product)
register.attend_karaoke(780 , 'エコー設定デフォルトにするとやっぱ気持ちいい')

register.create_history('SMAP' , '世界に一つだけの花')
register.create_history('ハチ' , 'ドーナツホール')
register.create_history('SIAM SHADE' , '1/3の純情な感情' , -2)
register.create_history('kemu' , '敗北の少年')
register.create_history('鬼束ちひろ' , '月光' , 5)
register.create_history('一ノ瀬トキヤ' , 'independence')
register.create_history('supercell' , 'ワールドイズマイン' , 5)
register.create_history('Neru' , 'ロストワンの号哭' , -2)
register.create_history('磯P' , '袖触れ合うも他生の縁' , -3)
register.create_history('kemu' , 'カミサマネジマキ' , -5)
register.create_history('木山裕策' , 'home')
register.create_history('BUMP OF CHICKEN' , 'スノースマイル')
register.create_history('Kimeru' , 'OVERLAP')
register.create_history('absorb' , 'Fire◎Flower' , -2)
register.create_history('電ポルP' , '独りんぼエンヴィー')
register.create_history('ジミーサムP' , 'from Y to Y')
register.create_history('Last Note.' , '放課後ストライド' , 5)
register.create_history('Superfly' , 'タマシイレボリューション' , -5)
register.create_history('Last Note.' , 'セツナトリップ' , -5)
register.create_history('Ever Little Thing' , 'Dear My Friend' , -2)
register.create_history('島谷ひとみ' , 'YUME日和' , -4)
register.create_history('UNISON SQUARE GARDEN' , 'シュガーソングとビターステップ' , -2)
register.create_history('シド' , '嘘')
register.create_history('kemu' , '地球最後の告白を')
register.create_history('wawoka' , 'ワールズエンド・ダンスホール')
register.create_history('コジマジP' , 'おちゃめ機能' , -5)
register.create_history('BUMP OF CHICKEN' , 'Stage of the ground')

register = Register.new(User.new('tomotin'))
register.karaoke = karaoke
register.attend_karaoke(860 , '妙にハイテンション')
register.create_history('暁切歌' , 'オーバーキルサイズ・ヘル')
register.create_history('キャロル・マールス・ディーンハイム' , 'tomorrow')
register.create_history('じん' , 'daze')
register.create_history('ツヴァイウィング' , 'ORBITAL BEAT')
register.create_history('雪音クリス' , 'TRUST HART')
register.create_history('マリア・カデンツァヴナ・イヴ' , '銀腕・アガートラーム')
register.create_history('暁切歌' , 'おきてがみ')
register.create_history('立花響、風鳴翼、雪音クリス、マリア・カデンツァヴナ・イヴ、月読調、暁切歌、天羽奏' , '虹色のフリューゲル')
register.create_history('yozuka*' , 'believe yourself')
register.create_history('A応P' , 'はなまるぴっぴはよいこだけ')
register.create_history('きゃりーぱみゅぱみゅ' , 'もんだいガール')
register.create_history('Dorothy Little Happy' , 'ASIAN STONE')
register.create_history('キャロル・マールス・ディーンハイム' , '殲琴・ダウルダブラ')
register.create_history('原田ひとみ' , 'Magenta Another Sky')
register.create_history('立花響、風鳴翼、雪音クリス' , 'RADIANT FORCE')
register.create_history('高垣彩陽' , 'Rebirth-day')
register.create_history('月読調' , 'ジェノサイドソウ・ヘブン')
register.create_history('宮崎歩' , 'brave heart')
register.create_history('水樹奈々' , 'Vitalization')
register.create_history('雪音クリス' , '繋いだ手だけが紡ぐもの')
register.create_history('一氏ユウジ' , '笑顔クエスト')
register.create_history('千歳千里' , '恋だなう')
register.create_history('暁切歌' , '手紙')
register.create_history('雪音クリス' , '魔弓・イチイバル')

datetime = '2016-01-08 00:28:00'
name = '新年初カラオケ'
plan = 5
store = {'name' => 'JOYJOY', 'branch' => '甚目寺店'}
product = {'brand' => 'JOYSOUND' , 'product' => 'MAX'}

register = Register.new(User.new('hetare'))
karaoke = register.create_karaoke(datetime , name , plan , store , product)
register.attend_karaoke(1080)

register.create_history('宮野真守' , 'オルフェ')
register.create_history('MYTH & ROID' , 'LLL')
register.create_history('聖川真斗、一ノ瀬トキヤ' , 'ORIGINAL RESONANCE')
register.create_history('ST☆RISH' , 'マジLOVEレボリューションズ')
register.create_history('UNISON SQUARE GARDEN' , 'オリオンをなぞる')
register.create_history('	ゴールデンボンバー'	, '女々しくて')
register.create_history('きただにひろし' , 'ウィーアー!')
register.create_history('木山裕策' , 'home')
register.create_history('アン・ルイス','WOMAN')
register.create_history('松任谷由実','やさしさに包まれたなら')
register.create_history('今井美樹',	'PIECE OF MY WISH')
register.create_history('Every Little Thing',	'モノクローム')
register.create_history('	のぼる↑'	,'ショットガン・ラヴァーズ')
register.create_history('Neru'	,'ロストワンの号哭')
register.create_history('kemu','地球最後の告白を')
register.create_history('UVERworld'	,'REVERSI')
register.create_history('SEKAI NO OWARI',	'Dragon Night')
register.create_history('164',	'天ノ弱')
register.create_history('遠藤正明'	,'勇者王誕生！')
register.create_history('TRUE',	'DREAM SOLISTER')
register.create_history('高坂麗奈','心響プロジェクター')
register.create_history('ALL OFF',	'One More Chance!!')
register.create_history('一ノ瀬トキヤ',	'SECRET LOVER')
register.create_history('UVERworld',	'クオリア')

register = Register.new(User.new('worry'))
register.karaoke = karaoke
register.attend_karaoke(1230)

register.create_history('遠藤正明','勇者王誕生！')
register.create_history('SPYAIR',	'サムライハート(Some Like It Hot!!)')
register.create_history('水樹奈々',	'You have a dream')
register.create_history('槇原敬之',	'Hungry Spider')
register.create_history('Fire Bomber',	'HOLLY LONELY LIGHT')
register.create_history('Fire Bomber',	'Remember 16')
register.create_history('Deen',	'夢であるように')
register.create_history('the brilliant green'	,'Ash Like Snow')
register.create_history('水樹奈々',	'Orchestral Fantasia')
register.create_history('UVERworld',	'マダラ蝶')
register.create_history('UVERworld',	'儚くも永久のカナシ')
register.create_history('福山雅治',	'心color～a song for the wonderful year～')
register.create_history('coba＆宮沢和史',	'ひとりぼっちじゃない')
register.create_history('JAM Project'	,'THE HERO!!～怒れる拳に火をつけろ～')
register.create_history('Hilcrhyme',	'春夏秋冬')
register.create_history('上木彩矢',	'ピエロ')
register.create_history('FENCE OF DEFENSE',	'セイラ～SARA～')
register.create_history('FLOW'	,'COLORS')
register.create_history('ポルノグラフィティ',	'メリッサ')
register.create_history('WANDS',	'世界が終わるまでは・・・')

datetime = '2016-01-03 15:30:00'
name = '2016年 1/24回目'
plan = 3.5
store = {'name' => '歌広場', 'branch' => '亀戸店'}
product = {'brand' => 'DAM' , 'product' => 'Premier DAM'}
score = {'brand' => 'JOYSOUND' , 'name' => '分析採点2'} 

register = Register.new(User.new('sa2knight'))
karaoke = register.create_karaoke(datetime , name , plan , store , product)
register.attend_karaoke(1140)

register.create_history('BUMP OF CHICKEN',	'オンリーロンリーグローリー',0,score,84)
register.create_history('BUMP OF CHICKEN',	'天体観測',0,score,83)
register.create_history('野川 さくら',	'HAPPY HARMONICS',5,score,79)
register.create_history('サザンオールスターズ' , 'TSUNAMI',0,score,79)
register.create_history('きゃりーぱみゅぱみゅ',	'PONPONPON',-3,score,67)
register.create_history('Superfly',	'輝く月のように',5,score,80)
register.create_history('A応P',	'はなまるぴっぴはよいこだけ',0,score,77)
register.create_history('イヤミ、おそ松、カラ松、チョロ松、一松、十四松、トド松' , 'SIX SAME FACES',0,score,65)
register.create_history('UNISON SQUARE GARDEN',	'シュガーソングとビターステップ',-2,score,83)
register.create_history('りぶ'	,'ヨンジュウナナ',0,score,83)
register.create_history('島谷ひとみ',	'YUME日和',-4,score,81)
register.create_history('Last Note',	'セツナトリップ',5,score,77)
register.create_history('SEKAI NO OWARI',	'RPG',0,score,82)
register.create_history('トーマ',	'ヤンキーボーイ・ヤンキーガール',0,score,75)
register.create_history('コブクロ',	'ここにしか咲かない花',0,score,78)
register.create_history('一ノ瀬トキヤ',	'Independence',0,score,79)
register.create_history('Supercell',	'ワールドイズマイン',5,score,79)
register.create_history('BUMP OF CHICKEN',	'ダイヤモンド',0,score,79)
register.create_history('シド',	'嘘',0,score,80)
register.create_history('TOKIO',	'宙船(そらふね)',0,score,76)
register.create_history('A応P','はなまるぴっぴはよいこだけ',0,score,74)
