#! /usr/bin/env python
# -*- coding: UTF-8 -*-

import os
import sys
import re



# サイマルラジオ局一覧
LST = [
[ \
"sankakuyama", \
"data/1.jpg", \
"http://wm.sankakuyama.co.jp/asx/sankaku_24k.asx", \
"http://www.sankakuyama.co.jp/", \
"三角山放送局", \
"札幌市西区", \
], \


[ \
"jaga", \
"data/2.jpg", \
"http://www.simulradio.info/asx/fmjaga.asx", \
"http://www.jaga.fm/", \
"FM JAGA", \
"帯広市", \
], \


[ \
"fmwing", \
"data/3.jpg", \
"http://www.simulradio.info/asx/fmwing.asx", \
"http://www.fmwing.com/index.html", \
"FM WING", \
"帯広市", \
], \


[ \
"dramacity", \
"data/4.jpg", \
"http://dramacity.jp/fmdorama_24k.asx", \
"http://www.dramacity.jp/", \
"RadioD FM dramacity", \
"札幌市厚別区", \
], \


[ \
"FmKushiro", \
"data/57.jpg", \
"http://www.simulradio.info/asx/FmKushiro.asx", \
"http://www.fm946.com", \
"FMくしろ", \
"釧路市", \
], \


[ \
"fmwappy", \
"data/58.jpg", \
"http://wappy761.jp/fmwappy.asx", \
"http://wappy761.jp", \
"FMわっぴ～", \
"稚内市", \
], \


[ \
"fm-riviere", \
"data/5.jpg", \
"http://www.simulradio.info/asx/fm837.asx", \
"http://www.fm837.com/", \
"FMりべーる", \
"旭川市", \
], \


[ \
"radioniseko", \
"data/92.jpg", \
"http://www.radioniseko.jp/asx/radioniseko_24k.asx", \
"http://www.facebook.com/radioniseko", \
"ラジオニセコ", \
"ニセコ町", \
], \


[ \
"fmiruka", \
"data/104.jpg", \
"http://www.simulradio.info/asx/iruka.asx", \
"http://www.fmiruka.co.jp/", \
"FMいるか", \
"函館市", \
], \


[ \
"radiokaros", \
"data/112.jpg", \
"http://www.simulradio.info/asx/radiokaros.asx", \
"http://www.radiokaros.com/", \
"ラジオカロスサッポロ", \
"札幌市", \
], \


[ \
"fmapple", \
"data/123.jpg", \
"http://www.simulradio.info/asx/fmapple.asx", \
"http://765fm.com/", \
"FMアップル", \
"札幌市豊平区", \
], \


[ \
"e-niwa", \
"data/129.jpg", \
"http://www.simulradio.info/asx/eniwa.asx", \
"http://www.e-niwa.tv/", \
"e-niwaFM", \
"恵庭市", \
], \


[ \
"radiomorioka", \
"data/6.jpg", \
"http://www.simulradio.info/asx/radiomorioka.asx", \
"http://www.radiomorioka.co.jp/index_pc.html", \
"ラヂオもりおか", \
"盛岡市", \
], \


[ \
"radio3", \
"data/7.jpg", \
"http://www.simulradio.info/asx/radio3.asx", \
"http://www.radio3.jp/", \
"RADIO3", \
"仙台市青葉区", \
], \


[ \
"fmmotcom", \
"data/8.jpg", \
"http://www.simulradio.info/asx/fmmotcom.asx", \
"http://www.fm-mot.com/", \
"エフエム モットコム", \
"本宮市", \
], \


[ \
"fm-iwaki", \
"data/34.jpg", \
"http://www.simulradio.info/asx/fm-iwaki.asx", \
"http://www.fm-iwaki.co.jp/cgi-bin/WebObjects/1201dac04a1.woa/", \
"FMいわき", \
"いわき市", \
], \


[ \
"fmaizu", \
"data/52.jpg", \
"http://www.simulradio.info/asx/aizu.asx", \
"http://www.fmaizu.com/index.shtm", \
"エフエム会津", \
"会津若松市", \
], \



[ \
"yutopia", \
"data/53.jpg", \
"http://www.simulradio.info/asx/FmYutopia.asx", \
"http://www.yutopia.or.jp/~fm763/", \
"FMゆーとぴあ", \
"湯沢市", \
], \


[ \
"fmyokote", \
"data/54.jpg", \
"http://www.simulradio.info/asx/yokote.asx", \
"http://www.fmyokote.com/", \
"横手かまくらエフエム", \
"横手市", \
], \


[ \
"miyakofm", \
"data/64.jpg", \
"http://www.simulradio.info/asx/FmMiyako.asx", \
"http://miyakofm.com", \
"みやこハーバーラジオ", \
"宮古市", \
], \


[ \
"RadioIshinomaki", \
"data/68.jpg", \
"http://www.simulradio.info/asx/RadioIshinomaki.asx", \
"http://www.fm764.jp", \
"ラジオ石巻", \
"石巻市", \
], \


[ \
"bay-wave", \
"data/66.jpg", \
"http://www.simulradio.info/asx/BAYWAVE.asx", \
"http://www.bay-wave.co.jp ", \
"BAY WAVE", \
"塩釜市", \
], \


[ \
"fmIzumi", \
"data/67.jpg", \
"http://www.simulradio.info/asx/fmIzumi.asx", \
"http://www.fm797.co.jp/", \
"fmいずみ", \
"仙台市泉区", \
], \


[ \
"RingoFM", \
"data/71.jpg", \
"http://www.simulradio.info/asx/RingoFM.asx", \
"http://ringo-radio.cocolog-nifty.com/", \
"りんごFM", \
"山元町", \
], \


[ \
"Natoraji", \
"data/72.jpg", \
"http://www.simulradio.info/asx/Natoraji.asx", \
"http://www.natori801.jp", \
"なとらじ", \
"名取市", \
], \


[ \
"MinamisomaFM", \
"data/74.jpg", \
"http://www.simulradio.info/asx/MinamisomaFM.asx", \
"http://minamisomasaigaifm.hostei.com/index.html", \
"南相馬ひばりエフエム", \
"南相馬市", \
], \


[ \
"kocofm", \
"data/75.jpg", \
"http://www.simulradio.info/asx/kocofm.asx", \
"http://www.kocofm.jp/", \
"郡山コミュニティ放送", \
"郡山市", \
], \


[ \
"onagawafm", \
"data/80.jpg", \
"http://www.simulradio.info/asx/OnagawaFM.asx", \
"http://onagawafm.jp/", \
"女川さいがいFM", \
"女川町", \
], \


[ \
"kesennumaFM", \
"data/88.jpg", \
"http://www.simulradio.info/asx/kesennumaFM.asx", \
"http://km-saigaifm.com", \
"けせんぬまさいがいエフエム", \
"気仙沼市", \
], \


[ \
"rikuzentakataFM", \
"data/89.jpg", \
"http://www.simulradio.info/asx/rikuzentakataFM.asx", \
"http://rikuzentakata-fm.blogspot.com/", \
"陸前高田災害FM", \
"陸前高田市", \
], \


[ \
"OdagaisamaFM", \
"data/91.jpg", \
"http://www.simulradio.info/asx/OdagaisamaFM.asx", \
"http://www.gurutto-koriyama.com/detail/index_213.html", \
"富岡臨時災害FM局（おだがいさまFM）", \
"富岡町", \
], \


[ \
"aozora", \
"data/94.jpg", \
"http://www.simulradio.info/asx/aozora.asx", \
"http://www.town.watari.miyagi.jp/index.cfm/22,21308,126,html", \
"亘理臨時災害FM局（FMあおぞら）", \
"亘理町", \
], \


[ \
"ofunato", \
"data/98.jpg", \
"mms://hdv.nkansai.tv/ofunato", \
"http://www.facebook.com/Radioofunato", \
"FMねまらいん", \
"大船渡市", \
], \


[ \
"otsuchi", \
"data/100.jpg", \
"http://www.simulradio.info/asx/otsuchi.asx", \
"http://www.town.otsuchi.iwate.jp/", \
"おおつちさいがいエフエム", \
"大槌町", \
], \


[ \
"kamaishi", \
"data/107.jpg", \
"http://www.simulradio.info/asx/kamaishi.asx", \
"http://www.city.kamaishi.iwate.jp/index.cfm/12,18557,121,html", \
"釜石災害FM", \
"釜石市", \
], \


[ \
"fmasmo", \
"data/115.jpg", \
"http://fmasmo.fmplapla.com/player/", \
"http://emus.jimdo.com/", \
"FMあすも", \
"一関市", \
], \


[ \
"befm", \
"data/119.jpg", \
"http://www.simulradio.info/asx/befm.asx", \
"http://www.befm765.jpn.org/oz/", \
"BeFM", \
"八戸市", \
], \


[ \
"kiritampo", \
"data/120.jpg", \
"http://www.simulradio.info/asx/kiritampo.asx", \
"http://fm791.net/", \
"鹿角きりたんぽFM", \
"鹿角市", \
], \


[ \
"fmkento", \
"data/9.jpg", \
"http://www.simulradio.info/asx/fmkento.asx", \
"http://www.fmkento.com/pc/", \
"FM Kento", \
"新潟市中央区", \
], \


[ \
"fmkaruizawa", \
"data/10.jpg", \
"http://www.simulradio.info/asx/fmkaruizawa.asx", \
"http://www.fm-karuizawa.co.jp/", \
"FM軽井沢", \
"軽井沢町", \
], \


[ \
"fmsakudaira", \
"data/101.jpg", \
"http://www.simulradio.info/asx/sakudaira.asx", \
"http://www.fmsakudaira.co.jp/", \
"FMさくだいら", \
"佐久市", \
], \


[ \
"azuminofm", \
"data/106.jpg", \
"http://www.simulradio.info/asx/azumino.asx", \
"http://www.azuminofm.co.jp/", \
"あづみ野FM", \
"安曇野市", \
], \


[ \
"fmpalulun", \
"data/11.jpg", \
"http://www.simulradio.info/asx/fmpalulun.asx", \
"http://www.fmpalulun.co.jp/", \
"FMぱるるん", \
"水戸市", \
# 映像http://219.117.222.12:80/Push316
], \

[ \
"flower", \
"data/12.jpg", \
"http://www.fm767.com/flower_64k.asx", \
"http://www.fm767.com/top.html", \
"フラワーラジオ", \
"鴻巣市", \
], \


[ \
"smile", \
"data/13.jpg", \
"http://www.simulradio.info/asx/smile.asx", \
"http://fm767.net/main/", \
"すまいるFM", \
"朝霞市", \
], \


[ \
"shonanbeachfma", \
"data/14.jpg", \
"http://www.simulradio.info/asx/shonanbeachfma.asx", \
"http://www.beachfm.co.jp/", \
"湘南ビーチFM", \
"逗子市・葉山町", \
# 映像http://www.simulradio.info/asx/shonanbeachfm.asx
], \


[ \
"radioshonan", \
"data/15.jpg", \
"http://www.simulradio.info/asx/radioshonan.asx", \
"http://www.radioshonan.co.jp/", \
"レディオ湘南", \
"藤沢市", \
], \


[ \
"fmodawara", \
"data/16.jpg", \
"http://www.simulradio.info/asx/fmodawara.asx", \
"http://fm-odawara.com/", \
"FMおだわら", \
"小田原市", \
], \


[ \
"redswave", \
"data/31.jpg", \
"http://redswave.com/simul.asx", \
"http://redswave.com", \
"REDS WAVE", \
"さいたま市", \
], \


[ \
"tsukuba", \
"data/32.jpg", \
# "mms://ir298.com/IRTsukuba/radiotsukuba.asx", \
"http://www.simulradio.info/asx/tsukuba.asx", \
"http://radio-tsukuba.net", \
"ラヂオつくば", \
"つくば市", \
], \


[ \
"fm-tachikawa", \
"data/38.jpg", \
"http://www.simulradio.info/asx/fm-tachikawa.asx", \
"http://www.fm844.co.jp/", \
"エフエムたちかわ", \
"立川市", \
], \


[ \
"kawasakifm", \
"data/41.jpg", \
"http://www.simulradio.info/asx/kawasaki.asx", \
"http://www.kawasakifm.co.jp/", \
"かわさきFM", \
"川崎市", \
], \


[ \
"fmkiryu", \
"data/42.jpg", \
"http://www.simulradio.info/asx/kiryufm.asx", \
"http://www.fmkiryu.jp", \
"FM 桐生", \
"桐生市", \
], \


[ \
"fmyamato", \
"data/44.jpg", \
"http://www.simulradio.info/asx/FmYamato.asx", \
"http://fmyamato.co.jp/", \
"FMやまと", \
"大和市", \
], \


[ \
"fm-totsuka", \
"data/47.jpg", \
"http://www.simulradio.info/asx/totsuka.asx", \
"http://www.fm-totsuka.com/", \
"FM戸塚", \
"横浜市", \
], \


[ \
"fm-salus", \
"data/56.jpg", \
"http://www.simulradio.info/asx/FmSalus.asx", \
"http://www.fm-salus.jp/", \
"FMサルース", \
"横浜市", \
], \


[ \
"chofu-fm", \
"data/62.jpg", \
"http://www.simulradio.info/asx/chofu_fm.asx", \
"http://www.chofu-fm.com/", \
"調布FM", \
"調布市", \
], \


[ \
"maebashi", \
"data/69.jpg", \
"http://radio.maebashi.fm:8080/mwave", \
"http://www.maebashi.fm/", \
"まえばしCITYエフエム", \
"前橋市", \
], \


[ \
"katsushika", \
"data/76.jpg", \
"http://www.simulradio.info/asx/katsushika.asx", \
"http://www.kfm789.co.jp/", \
"かつしかFM", \
"葛飾区", \
], \



[ \
"fmsagami", \
"data/77.jpg", \
"http://www.fmsagami.co.jp/asx/fmsagami.asx", \
"http://www.fmsagami.co.jp/", \
"エフエムさがみ", \
"相模原市", \
], \


[ \
"rainbowtown", \
"data/81.jpg", \
"http://www.simulradio.info/asx/rainbowtown.asx", \
"http://www.792fm.com/", \
"レインボータウンFM", \
"江東区", \
], \


[ \
"fmkaon", \
"data/97.jpg", \
"mms://hdv.nkansai.tv/kaon", \
"http://www.fmkaon.com/", \
"FM kaon", \
"海老名市", \
], \


[ \
"chuo_fm", \
"data/99.jpg", \
"http://www.simulradio.info/asx/chuo_fm.asx", \
"http://fm840.jp/", \
"中央エフエム", \
"中央区", \
], \


[ \
"takahagi", \
"data/121.jpg", \
"http://www.simulradio.info/asx/takahagi.asx", \
"", \
" たかはぎFM", \
" 高萩市", \
], \

[ \
"kawaguchi", \
"data/133.jpg", \
"http://www.simulradio.info/asx/kawaguchi.asx", \
"http://www.fm856.co.jp/", \
"FM Kawaguchi", \
"川口市", \
], \


[ \
"fmuu", \
"data/134.jpg", \
"http://www.simulradio.info/asx/fmuu.asx", \
"http://fmuu.jp/", \
"FM-UU", \
"牛久市", \
], \


[ \
"p-wave", \
"data/17.jpg", \
"http://www.simulradio.info/asx/portwavefm.asx", \
"http://www.p-wave.ne.jp/", \
"PORT WAVE", \
"四日市市", \
], \


[ \
"ciao", \
"data/18.jpg", \
"http://www.simulradio.info/asx/ciao.asx", \
"http://www.ciao796.com/", \
"Ciao!", \
"熱海市", \
], \


[ \
"midfm761", \
"data/19.jpg", \
"http://www.simulradio.info/asx/mid-fm761.asx", \
"http://midfm761.com/", \
"MID-FM", \
"名古屋市中区", \
], \


[ \
"fmokazaki", \
"data/83.jpg", \
"http://www.simulradio.info/asx/FmOkazaki.asx", \
"http://www.fmokazaki.jp/", \
"FMおかざき", \
"岡崎市", \
], \


[ \
"pitch", \
"data/105.jpg", \
"http://www.simulradio.info/asx/pitch.asx", \
"http://www.838.fm/", \
"Pitch FM", \
"刈谷市", \
], \


[ \
"loveat", \
"data/118.jpg", \
"http://www.simulradio.info/asx/toyota.asx", \
"http://www.loveat.co.jp/", \
"RADIO LOVEAT", \
"豊田市", \
], \


[ \
"suzuka", \
"data/125.jpg", \
"http://www.simulradio.info/asx/suzuka.asx", \
"http://www.suzuka-voice.fm/", \
"Suzuka Voice FM", \
"鈴鹿市", \
], \


[ \
"izunokuni", \
"data/127.jpg", \
"http://www.simulradio.info/asx/izunokuni.asx", \
"http://www.fmizunokuni.jp/", \
"FMいずのくに", \
"伊豆の国市", \
], \


[ \
"fmn1", \
"data/20.jpg", \
"http://android.fmn1.jp/live/", \
"http://fmn1.jp/", \
"FM-N1", \
"野々市市", \
# 映像 http://fmn1.jp/netradio.html
], \


[ \
"harbor779", \
"data/61.jpg", \
"http://www.web-services.jp/harbor779/", \
"http://harbor779.com", \
"ハーバーステーション", \
"敦賀市", \
], \


[ \
"radiomyu", \
"data/132.jpg", \
"http://www.simulradio.info/asx/radiomyu.asx", \
"http://www.fm761.co.jp/", \
"ラジオ・ミュー", \
"黒部市", \
], \



[ \
"fm-tanba", \
"data/21.jpg", \
"http://fukuchiyama.fm-tanba.jp/simul.asx", \
"http://fukuchiyama.fm-tanba.jp/", \
"FM丹波", \
"福知山市", \
], \


[ \
"senri-fm", \
"data/22.jpg", \
"http://www.simulradio.info/asx/fmsenri.asx", \
"http://www.senri-fm.jp/", \
"FM 千里", \
"豊中市", \
], \


[ \
"fmyy", \
"data/23.jpg", \
"http://www.simulradio.info/asx/fmyy.asx", \
"http://www.tcc117.org/fmyy/", \
"エフエムわいわい", \
"神戸市", \
], \


[ \
"fmhanako", \
"data/24.jpg", \
"http://fmhanako.jp/radio/824.asx", \
"http://fmhanako.jp/", \
"FM HANAKO", \
"守口市", \
], \


[ \
"fm-miki", \
"data/25.jpg", \
"http://www.simulradio.info/asx/fm-miki.asx", \
"http://www.fm-miki.jp/", \
"エフエム　みっきぃ", \
"三木市", \
], \


[ \
"hirakata", \
"data/33.jpg", \
"http://www.simulradio.info/asx/hirakata.asx", \
"http://www.kiku-fm779.com/", \
"FMひらかた", \
"枚方市", \
#映像 http://www.media-gather.jp/_mg_standard/deliverer2.php?p=IaxEXCgTuKI%3D
], \


[ \
"fmgenki", \
"data/37.jpg", \
"http://www.simulradio.info/asx/fm-genki.asx", \
"http://fmgenki.jp", \
"FM GENKI", \
"姫路市", \
], \


[ \
"fm-tanabe", \
"data/35.jpg", \
"http://www.simulradio.info/asx/fm-tanabe.asx", \
"http://www.fm885.jp/", \
"FM TANABE", \
"田辺市", \
], \


[ \
"jungle", \
"data/39.jpg", \
"http://www.simulradio.info/asx/jungle.asx", \
"http://www.764.fm/", \
"FMジャングル", \
"豊岡市", \
], \


[ \
"banban", \
"data/46.jpg", \
"http://www.simulradio.info/asx/banban.asx", \
"http://www.banban.jp/radio/", \
"BAN-BANラジオ", \
"加古川市", \
], \


[ \
"takarazuka", \
"data/59.jpg", \
"http://www.simulradio.info/asx/takarazuka.asx", \
"http://835.jp", \
"FM宝塚", \
"宝塚市", \
], \


[ \
"beach_station", \
"data/82.jpg", \
"http://www.simulradio.info/asx/beach_station.asx", \
"http://www.fm764.com/", \
"ビーチステーション", \
"白浜町", \
], \


[ \
"minoh", \
"data/85.jpg", \
"http://fm.minoh.net/minohfm.asx", \
"http://fm.minoh.net/", \
"みのおエフエム", \
"箕面市", \
], \


[ \
"yesfm", \
"data/87.jpg", \
"http://www.simulradio.info/asx/yes-fm.asx", \
"http://www.yesfm.jp/index.php", \
"YES-fm", \
"大阪市中央区", \
], \


[ \
"KyotoLivingFM", \
"data/90.jpg", \
"http://www.simulradio.info/asx/KyotoLivingFM.asx", \
"http://www.fm-845.com/", \
"京都リビングエフエム", \
"京都市伏見区", \
], \


[ \
"sakura-fm", \
"data/102.jpg", \
"http://www.simulradio.info/asx/sakura.asx", \
"http://sakura-fm.co.jp/", \
"さくらFM", \
"西宮市", \
], \


[ \
"fmaiai", \
"data/109.jpg", \
"http://www.simulradio.info/asx/aiai.asx", \
"http://www.fmaiai.com/top5.html", \
"エフエムあまがさき", \
"尼崎市", \
], \


[ \
"fmkusatsu", \
"data/110.jpg", \
"http://www.simulradio.info/asx/rockets785.asx", \
"http://www.fm785.jp/", \
"えふえむ草津", \
"草津市", \
], \


[ \
"hasimoto", \
"data/114.jpg", \
"http://www.simulradio.info/asx/hasimoto.asx", \
"http://816.fm/", \
"FMはしもと", \
"橋本市", \
], \


[ \
"radiocafe", \
"data/122.jpg", \
"http://www.simulradio.info/asx/radiocafe.asx", \
"http://radiocafe.jp/", \
"京都三条ラジオカフェ", \
"京都市中京区", \
], \


[ \
"tanbacom", \
"data/128.jpg", \
"http://www.simulradio.info/asx/tanbacom.asx", \
"http://www.tanba.info/category/%E4%B8%B9%E6%B3%A2%E5%B8%82%E7%81%BD%E5%AE%B3%EF%BD%86%EF%BD%8D/", \
"たんばしさいがいFM", \
"丹波市", \
], \


[ \
"fm-tango", \
"data/130.jpg", \
"http://www.simulradio.info/asx/tango.asx", \
"http://fm-tango.jp/", \
"FMたんご", \
"京丹後市", \
], \



[ \
"fm-moov", \
"data/131.jpg", \
"http://www.simulradio.info/asx/fmmoov.asx", \
"http://www.fm-moov.com/", \
"FM MOOV KOBE", \
"神戸市", \
], \


[ \
"chupea", \
"data/36.jpg", \
"http://www.simulradio.info/asx/fm-chupea.asx", \
"http://chupea.fm/", \
"FMちゅーピー", \
"広島市", \
], \


[ \
"darazfm", \
"data/51.jpg", \
"http://www.darazfm.com/streaming.asx", \
"http://www.darazfm.com/", \
"DARAZ FM", \
"米子市", \
], \


[ \
"takamatsu", \
"data/29.jpg", \
"http://www.simulradio.info/asx/fm815.asx", \
"http://www.fm815.com/", \
"FM高松", \
"高松市", \
], \


[ \
"bfm", \
"data/43.jpg", \
"http://www.simulradio.info/asx/b-fm791.asx", \
"http://www.bfm.jp/", \
"FMびざん", \
"徳島市", \
], \


[ \
"fmsun", \
"data/126.jpg", \
"http://www.simulradio.info/asx/fmsun.asx", \
"http://www.kbn.ne.jp/fm/", \
"FM SUN", \
"坂出市", \
], \


[ \
"fmnakatsu", \
"data/26.jpg", \
"http://www.simulradio.info/asx/fmnakatsu.asx", \
"http://www.789.fm/", \
"NOAS FM", \
"中津市", \
], \


[ \
"sunfm", \
"data/27.jpg", \
"http://www.simulradio.info/asx/sunshinefm.asx", \
"http://www.sunfm.co.jp/", \
"サンシャイン エフエム", \
"宮崎市", \
], \


[ \
"AmamiFM", \
"data/65.jpg", \
"http://www.npo-d.org/simul/AmamiFM.asx", \
"http://www.npo-d.org", \
"あまみFM", \
"奄美市", \
], \


[ \
"shimabara", \
"data/78.jpg", \
"http://www.shimabara.fm/st/fm-shimabara-live.asx", \
"http://www.shimabara.fm/", \
"FMしまばら", \
"島原市", \
], \


[ \
"fm-kitaq", \
"data/86.jpg", \
"http://www.shimabara.fm/st/fm-kitaq-live.asx", \
"http://www.fm-kitaq.com/", \
"FM KITAQ", \
"北九州市小倉北区", \
], \


[ \
"starcornfm", \
"data/95.jpg", \
"mms://hdv.nkansai.tv/starcorn", \
"http://www.starcornfm.com/", \
"スターコーンFM", \
"築上郡築上町", \
], \


[ \
"comiten", \
"data/108.jpg", \
"http://comiten.jp/live.asx", \
"http://comiten.jp/", \
"コミュニティラジオ天神", \
"福岡市", \
], \


[ \
"hibiki", \
"data/116.jpg", \
"http://www.simulradio.info/asx/hibiki.asx", \
"http://www.hibiki882.jp/", \
"AIR STATION HIBIKI", \
"北九州市", \
], \


[ \
"fmnobeoka", \
"data/124.jpg", \
"http://www.simulradio.info/asx/nobeoka.asx", \
"http://fmnobeoka.jp/", \
"FMのべおか", \
"延岡市", \
], \


[ \
"fm-nirai", \
"data/28.jpg", \
"http://www.simulradio.info/asx/fm-nirai.asx", \
"http://www.fm-nirai.jp/", \
"エフエム ニライ", \
"北谷町", \
], \


[ \
"fmishigaki", \
"data/30.jpg", \
"http://118.21.140.45/Push1", \
"http://www.fmishigaki.jp/", \
"FMいしがき", \
"石垣市", \
], \


[ \
"fm-uruma", \
"data/48.jpg", \
"http://www.simulradio.info/asx/uruma.asx", \
"http://www.fm-uruma.com/", \
"FMうるま", \
"うるま市", \
], \


[ \
"fm21", \
"data/49.jpg", \
"http://www.simulradio.info/asx/fm21.asx", \
"http://www.fm21.net/", \
"FM21", \
"浦添市", \
], \


[ \
"fmlequio", \
"data/50.jpg", \
"http://www.simulradio.info/asx/lequio.asx", \
"http://www.fmlequio.com/", \
"FMレキオ", \
"那覇市", \
], \


[ \
"fm-toyomi", \
"data/73.jpg", \
"http://www.simulradio.info/asx/toyomi.asx", \
"http://www.fm-toyomi.com/", \
"FMとよみ", \
"豊見城市", \
], \


[ \
"okiradi", \
"data/103.jpg", \
"http://www.simulradio.info/asx/okiradi.asx", \
"http://www.fm854.com/", \
"オキラジ", \
"沖縄市", \
], \


[ \
"fm-nanjo", \
"data/111.jpg", \
"http://www.simulradio.info/asx/nanjo.asx", \
"http://www.fm-nanjo.net/", \
"FMなんじょう", \
"南城市", \
], \


[ \
"motob", \
"data/113.jpg", \
"http://www.simulradio.info/asx/motob.asx", \
"http://www.motob.net/", \
"FMもとぶ", \
"本部町", \
], \


[ \
"fmkumejima", \
"data/117.jpg", \
"http://www.simulradio.info/asx/fmkumejima.asx", \
"http://fmkumejima.com/", \
"FMくめじま", \
"久米島", \
], \
]


def make_xml():
    GRAPHURLBASE = "http://www.simulradio.info/"
    GRAPHBASE = "./"

    print '<?xml version="1.0" encoding="UTF-8" ?>'
    print "<stations>"
    for st in LST:
        print "  <station>"
        print "    <id>" + st[ 0 ] + "</id>"
        print "    <name>" + st[ 4 ] + "</name>"
        print "    <href>" + st[ 3 ] + "</href>"
        print "    <banner>" + GRAPHBASE + st[ 1 ] + "</banner>"
        print "    <place>" + st[ 5 ] + "</place>"
        print "    <playlist>" + st[ 2 ] + "</playlist>"
        print "  </station>"
    print "</stations>"


def make_bash_array():
    for st in LST:
        print "    SIMUL_ST[ \"" + st[ 0 ] +  "\" ]=\"" + st[ 2 ] + "\""

# make list for usage
def main_list():
    for st in LST:
        print "   " + st[ 0 ] + "\t" + st[ 4 ] + "［" + st[ 5 ] + "］"






def main():
    make_bash_array()



if __name__ == "__main__":
    main()

