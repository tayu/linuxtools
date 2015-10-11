#! /bin/bash

# CTRL+C is pressed, or other signals
trap "_atexit;  exit 1" HUP INT QUIT USR1 USR2

# env(export)
set -a
# use http proxy for wget
http_proxy="http://127.0.0.1:3128/"
set +a

# default download directory
default_dir="Downloads"
download_dir="$HOME/${default_dir}"

# 変数
authtoken=""
stname=""
retry_limit="1"

# version
VERSION=3.0.0.01

# 認証関係ファイル/urlの保存先
keydir="$HOME/.radiko"
tempdir="/tmp"
keyfile="${keydir}/authkey.jpg"
playerfile="${keydir}/player.swf"
auth1_fms="${tempdir}/auth1_fms_$$"
auth2_fms="${tempdir}/auth2_fms_$$"
playerurl="http://radiko.jp/player/swf/player_${VERSION}.swf"
# 余白
filler="60"

# ページ表示
if [ ! -z "$PAGER" ]; then
    pager="$PAGER"
else
    pager="/bin/more"
fi

# mplayer: --quiet or --really-quiet
mpopt="--quiet"


# 使い方
function usage() {
    cat <<EOF
Usage: $COMMAND [-a] [-o output_path] [-t recording_seconds] station_ID
  -a  エリア情報を出力して終了 (ex:'JP13, tokyo Japan')
  -d  出力ディレクトリ名 (デフォルトは \$HOME/${default_dir})
  -f  出力ファイル名 (デフォルトは STATION_YYYYMMDD-hhmm.flv)
  -h  時刻指定(ファイル名に設定)
  -l  番組リスト(radiko は JP13)
  -n  番組名(ファイル名に設定)
  -r  リトライ回数
  -t  録音時間 (秒または HMS) (デフォルトは 30秒)
  -w  開始時に（少し）待つ(秒)
EOF
}

# リスト
function show_list() {
    cat | ${pager} <<EOF
放送局一覧
  FM
    INT     InterFM
    BAYFM78 bayfm78
    NACK5   NACK5
    FMT     TOKYO FM
    FMJ     J-WAVE
    YFM     ＦＭヨコハマ
  AM
    TBS     TBS
    QRR     文化放送
    LFR     ニッポン放送
    JORF    ラジオ日本
  短波
    RN1     ラジオNIKKEI第1
    RN2     ラジオNIKKEI第2
  その他
    HOUSOU-DAIGAKU 放送大学
  NHK
    NHK-FM  ＮＨＫ－ＦＭ
    NHK-R1  ＮＨＫ第一放送
    NHK-R2  ＮＨＫ第二放送
  サイマルラジオ
    sankakuyama         三角山放送局［札幌市西区］
    jaga                FM JAGA［帯広市］
    fmwing              FM WING［帯広市］
x   dramacity           RadioD FM dramacity［札幌市厚別区］ NG 映像らしい
    FmKushiro           FMくしろ［釧路市］
    fmwappy             FMわっぴ～［稚内市］
    fm-riviere          FMりべーる［旭川市］
    radioniseko         ラジオニセコ［ニセコ町］
    fmiruka             FMいるか［函館市］
    radiokaros          ラジオカロスサッポロ［札幌市］
    fmapple             FMアップル［札幌市豊平区］
    e-niwa              e-niwaFM［恵庭市］
    radiomorioka        ラヂオもりおか［盛岡市］
    radio3              RADIO3［仙台市青葉区］
    fmmotcom            エフエム モットコム［本宮市］
    fm-iwaki            FMいわき［いわき市］
    fmaizu              エフエム会津［会津若松市］
    yutopia             FMゆーとぴあ［湯沢市］
    fmyokote            横手かまくらエフエム［横手市］
    miyakofm            みやこハーバーラジオ［宮古市］
    RadioIshinomaki     ラジオ石巻［石巻市］
    bay-wave            BAY WAVE［塩釜市］
    fmIzumi             fmいずみ［仙台市泉区］
    RingoFM             りんごFM［山元町］
    Natoraji            なとらじ［名取市］
    MinamisomaFM        南相馬ひばりエフエム［南相馬市］
    kocofm              郡山コミュニティ放送［郡山市］
    onagawafm           女川さいがいFM［女川町］
    kesennumaFM         けせんぬまさいがいエフエム［気仙沼市］
    rikuzentakataFM     陸前高田災害FM［陸前高田市］
    OdagaisamaFM        富岡臨時災害FM局（おだがいさまFM）［富岡町］
    aozora              亘理臨時災害FM局（FMあおぞら）［亘理町］
    ofunato             FMねまらいん［大船渡市］
    otsuchi             おおつちさいがいエフエム［大槌町］
    kamaishi            釜石災害FM［釜石市］
    fmasmo              FMあすも［一関市］
    befm                BeFM［八戸市］
    kiritampo           鹿角きりたんぽFM［鹿角市］
    fmkento             FM Kento［新潟市中央区］
    fmkaruizawa         FM軽井沢［軽井沢町］
    fmsakudaira         FMさくだいら［佐久市］
    azuminofm           あづみ野FM［安曇野市］
    fmpalulun           FMぱるるん［水戸市］
    flower              フラワーラジオ［鴻巣市］
    smile               すまいるFM［朝霞市］
    shonanbeachfma      湘南ビーチFM［逗子市・葉山町］
    radioshonan         レディオ湘南［藤沢市］
    fmodawara           FMおだわら［小田原市］
    redswave            REDS WAVE［さいたま市］
    tsukuba             ラヂオつくば［つくば市］
    fm-tachikawa        エフエムたちかわ［立川市］
    kawasakifm          かわさきFM［川崎市］
    fmkiryu             FM 桐生［桐生市］
    fmyamato            FMやまと［大和市］
    fm-totsuka          FM戸塚［横浜市］
    fm-salus            FMサルース［横浜市］
    chofu-fm            調布FM［調布市］
    maebashi            まえばしCITYエフエム［前橋市］
    katsushika          かつしかFM［葛飾区］
    fmsagami            エフエムさがみ［相模原市］
    rainbowtown         レインボータウンFM［江東区］
    fmkaon              FM kaon［海老名市］
    chuo_fm             中央エフエム［中央区］
    takahagi            たかはぎFM［ 高萩市］
    kawaguchi           FM Kawaguchi［川口市］
    fmuu                FM-UU［牛久市］
    p-wave              PORT WAVE［四日市市］
    ciao                Ciao!［熱海市］
    midfm761            MID-FM［名古屋市中区］
    fmokazaki           FMおかざき［岡崎市］
    pitch               Pitch FM［刈谷市］
    loveat              RADIO LOVEAT［豊田市］
    suzuka              Suzuka Voice FM［鈴鹿市］
    izunokuni           FMいずのくに［伊豆の国市］
    fmn1                FM-N1［野々市市］
    harbor779           ハーバーステーション［敦賀市］
    radiomyu            ラジオ・ミュー［黒部市］
    fm-tanba            FM丹波［福知山市］
    senri-fm            FM 千里［豊中市］
    fmyy                エフエムわいわい［神戸市］
    fmhanako            FM HANAKO［守口市］
    fm-miki             エフエム　みっきぃ［三木市］
    hirakata            FMひらかた［枚方市］
    fmgenki             FM GENKI［姫路市］
    fm-tanabe           FM TANABE［田辺市］
    jungle              FMジャングル［豊岡市］
    banban              BAN-BANラジオ［加古川市］
    takarazuka          FM宝塚［宝塚市］
    beach_station       ビーチステーション［白浜町］
    minoh               みのおエフエム［箕面市］
    yesfm               YES-fm［大阪市中央区］
    KyotoLivingFM       京都リビングエフエム［京都市伏見区］
    sakura-fm           さくらFM［西宮市］
    fmaiai              エフエムあまがさき［尼崎市］
    fmkusatsu           えふえむ草津［草津市］
    hasimoto            FMはしもと［橋本市］
    radiocafe           京都三条ラジオカフェ［京都市中京区］
    tanbacom            たんばしさいがいFM［丹波市］
    fm-tango            FMたんご［京丹後市］
    fm-moov             FM MOOV KOBE［神戸市］
    chupea              FMちゅーピー［広島市］
    darazfm             DARAZ FM［米子市］
    takamatsu           FM高松［高松市］
    bfm                 FMびざん［徳島市］
    fmsun               FM SUN［坂出市］
    fmnakatsu           NOAS FM［中津市］
    sunfm               サンシャイン エフエム［宮崎市］
    AmamiFM             あまみFM［奄美市］
    shimabara           FMしまばら［島原市］
    fm-kitaq            FM KITAQ［北九州市小倉北区］
    starcornfm          スターコーンFM［築上郡築上町］
    comiten             コミュニティラジオ天神［福岡市］
    hibiki              AIR STATION HIBIKI［北九州市］
    fmnobeoka           FMのべおか［延岡市］
    fm-nirai            エフエム ニライ［北谷町］
    fmishigaki          FMいしがき［石垣市］
    fm-uruma            FMうるま［うるま市］
    fm21                FM21［浦添市］
    fmlequio            FMレキオ［那覇市］
    fm-toyomi           FMとよみ［豊見城市］
    okiradi             オキラジ［沖縄市］
    fm-nanjo            FMなんじょう［南城市］
    motob               FMもとぶ［本部町］
    fmkumejima          FMくめじま［久米島］
EOF
}


# at exit
function _atexit() {
    [ -e ${auth1_fms} ] && rm -f ${auth1_fms}
    [ -e ${auth2_fms} ] && rm -f ${auth2_fms}
}


# 放送局名
function get_station_name() {
    stname=`echo $1 | awk '
    BEGIN {
        station[ "INT" ]      = "インターＦＭ";
        station[ "BAYFM78" ]  = "ｂａｙ－ｆｍ";
        station[ "NACK5" ]    = "ＮＡＣＫ５";
        station[ "FMT" ]      = "ＴＯＫＹＯ－ＦＭ";
        station[ "FMJ" ]      = "Ｊ－ＷＡＶＥ";
        station[ "YFM" ]      = "ｆｍ　ｙｏｋｏｈａｍａ";
        station[ "TBS" ]      = "ＴＢＳラジオ";
        station[ "QRR" ]      = "文化放送(NCB) ";
        station[ "LFR" ]      = "ニッポン放送";
        station[ "JORF" ]     = "ラジオ日本";
        station[ "NHK-FM" ]   = "ＮＨＫ－ＦＭ";
        station[ "NHK-R1" ]   = "ＮＨＫ第一放送";
        station[ "NHK-R2" ]   = "ＮＨＫ第二放送";
        station[ "RN1" ]      = "ラジオNIKKEI第1";
        station[ "RN2" ]      = "ラジオNIKKEI第2";
        station[ "HOUSOU-DAIGAKU" ] = "放送大学";
    }
    {
        name = station[ $1 ]
        if ( 0 == length( name ) ) {
            printf( "%s", $1 );
        } else {
            printf( "%s", name );
        }
    }
'`
}


# 放送局名：サイマル
declare -A SIMUL_ST
function set_simul_station() {
    SIMUL_ST[ "sankakuyama" ]="http://wm.sankakuyama.co.jp/asx/sankaku_24k.asx"
    SIMUL_ST[ "jaga" ]="http://www.simulradio.info/asx/fmjaga.asx"
    SIMUL_ST[ "fmwing" ]="http://www.simulradio.info/asx/fmwing.asx"
    SIMUL_ST[ "dramacity" ]="http://dramacity.jp/fmdorama_24k.asx"
    SIMUL_ST[ "FmKushiro" ]="http://www.simulradio.info/asx/FmKushiro.asx"
    SIMUL_ST[ "fmwappy" ]="http://wappy761.jp/fmwappy.asx"
    SIMUL_ST[ "fm-riviere" ]="http://www.simulradio.info/asx/fm837.asx"
    SIMUL_ST[ "radioniseko" ]="http://www.radioniseko.jp/asx/radioniseko_24k.asx"
    SIMUL_ST[ "fmiruka" ]="http://www.simulradio.info/asx/iruka.asx"
    SIMUL_ST[ "radiokaros" ]="http://www.simulradio.info/asx/radiokaros.asx"
    SIMUL_ST[ "fmapple" ]="http://www.simulradio.info/asx/fmapple.asx"
    SIMUL_ST[ "e-niwa" ]="http://www.simulradio.info/asx/eniwa.asx"
    SIMUL_ST[ "radiomorioka" ]="http://www.simulradio.info/asx/radiomorioka.asx"
    SIMUL_ST[ "radio3" ]="http://www.simulradio.info/asx/radio3.asx"
    SIMUL_ST[ "fmmotcom" ]="http://www.simulradio.info/asx/fmmotcom.asx"
    SIMUL_ST[ "fm-iwaki" ]="http://www.simulradio.info/asx/fm-iwaki.asx"
    SIMUL_ST[ "fmaizu" ]="http://www.simulradio.info/asx/aizu.asx"
    SIMUL_ST[ "yutopia" ]="http://www.simulradio.info/asx/FmYutopia.asx"
    SIMUL_ST[ "fmyokote" ]="http://www.simulradio.info/asx/yokote.asx"
    SIMUL_ST[ "miyakofm" ]="http://www.simulradio.info/asx/FmMiyako.asx"
    SIMUL_ST[ "RadioIshinomaki" ]="http://www.simulradio.info/asx/RadioIshinomaki.asx"
    SIMUL_ST[ "bay-wave" ]="http://www.simulradio.info/asx/BAYWAVE.asx"
    SIMUL_ST[ "fmIzumi" ]="http://www.simulradio.info/asx/fmIzumi.asx"
    SIMUL_ST[ "RingoFM" ]="http://www.simulradio.info/asx/RingoFM.asx"
    SIMUL_ST[ "Natoraji" ]="http://www.simulradio.info/asx/Natoraji.asx"
    SIMUL_ST[ "MinamisomaFM" ]="http://www.simulradio.info/asx/MinamisomaFM.asx"
    SIMUL_ST[ "kocofm" ]="http://www.simulradio.info/asx/kocofm.asx"
    SIMUL_ST[ "onagawafm" ]="http://www.simulradio.info/asx/OnagawaFM.asx"
    SIMUL_ST[ "kesennumaFM" ]="http://www.simulradio.info/asx/kesennumaFM.asx"
    SIMUL_ST[ "rikuzentakataFM" ]="http://www.simulradio.info/asx/rikuzentakataFM.asx"
    SIMUL_ST[ "OdagaisamaFM" ]="http://www.simulradio.info/asx/OdagaisamaFM.asx"
    SIMUL_ST[ "aozora" ]="http://www.simulradio.info/asx/aozora.asx"
    SIMUL_ST[ "ofunato" ]="mms://hdv.nkansai.tv/ofunato"
    SIMUL_ST[ "otsuchi" ]="http://www.simulradio.info/asx/otsuchi.asx"
    SIMUL_ST[ "kamaishi" ]="http://www.simulradio.info/asx/kamaishi.asx"
    SIMUL_ST[ "fmasmo" ]="http://fmasmo.fmplapla.com/player/"
    SIMUL_ST[ "befm" ]="http://www.simulradio.info/asx/befm.asx"
    SIMUL_ST[ "kiritampo" ]="http://www.simulradio.info/asx/kiritampo.asx"
    SIMUL_ST[ "fmkento" ]="http://www.simulradio.info/asx/fmkento.asx"
    SIMUL_ST[ "fmkaruizawa" ]="http://www.simulradio.info/asx/fmkaruizawa.asx"
    SIMUL_ST[ "fmsakudaira" ]="http://www.simulradio.info/asx/sakudaira.asx"
    SIMUL_ST[ "azuminofm" ]="http://www.simulradio.info/asx/azumino.asx"
    SIMUL_ST[ "fmpalulun" ]="http://www.simulradio.info/asx/fmpalulun.asx"
    SIMUL_ST[ "flower" ]="http://www.fm767.com/flower_64k.asx"
    SIMUL_ST[ "smile" ]="http://www.simulradio.info/asx/smile.asx"
    SIMUL_ST[ "shonanbeachfma" ]="http://www.simulradio.info/asx/shonanbeachfma.asx"
    SIMUL_ST[ "radioshonan" ]="http://www.simulradio.info/asx/radioshonan.asx"
    SIMUL_ST[ "fmodawara" ]="http://www.simulradio.info/asx/fmodawara.asx"
    SIMUL_ST[ "redswave" ]="http://redswave.com/simul.asx"
    SIMUL_ST[ "tsukuba" ]="http://www.simulradio.info/asx/tsukuba.asx"
    SIMUL_ST[ "fm-tachikawa" ]="http://www.simulradio.info/asx/fm-tachikawa.asx"
    SIMUL_ST[ "kawasakifm" ]="http://www.simulradio.info/asx/kawasaki.asx"
    SIMUL_ST[ "fmkiryu" ]="http://www.simulradio.info/asx/kiryufm.asx"
    SIMUL_ST[ "fmyamato" ]="http://www.simulradio.info/asx/FmYamato.asx"
    SIMUL_ST[ "fm-totsuka" ]="http://www.simulradio.info/asx/totsuka.asx"
    SIMUL_ST[ "fm-salus" ]="http://www.simulradio.info/asx/FmSalus.asx"
    SIMUL_ST[ "chofu-fm" ]="http://www.simulradio.info/asx/chofu_fm.asx"
    SIMUL_ST[ "maebashi" ]="http://radio.maebashi.fm:8080/mwave"
    SIMUL_ST[ "katsushika" ]="http://www.simulradio.info/asx/katsushika.asx"
    SIMUL_ST[ "fmsagami" ]="http://www.fmsagami.co.jp/asx/fmsagami.asx"
    SIMUL_ST[ "rainbowtown" ]="http://www.simulradio.info/asx/rainbowtown.asx"
    SIMUL_ST[ "fmkaon" ]="mms://hdv.nkansai.tv/kaon"
    SIMUL_ST[ "chuo_fm" ]="http://www.simulradio.info/asx/chuo_fm.asx"
    SIMUL_ST[ "takahagi" ]="http://www.simulradio.info/asx/takahagi.asx"
    SIMUL_ST[ "kawaguchi" ]="http://www.simulradio.info/asx/kawaguchi.asx"
    SIMUL_ST[ "fmuu" ]="http://www.simulradio.info/asx/fmuu.asx"
    SIMUL_ST[ "p-wave" ]="http://www.simulradio.info/asx/portwavefm.asx"
    SIMUL_ST[ "ciao" ]="http://www.simulradio.info/asx/ciao.asx"
    SIMUL_ST[ "midfm761" ]="http://www.simulradio.info/asx/mid-fm761.asx"
    SIMUL_ST[ "fmokazaki" ]="http://www.simulradio.info/asx/FmOkazaki.asx"
    SIMUL_ST[ "pitch" ]="http://www.simulradio.info/asx/pitch.asx"
    SIMUL_ST[ "loveat" ]="http://www.simulradio.info/asx/toyota.asx"
    SIMUL_ST[ "suzuka" ]="http://www.simulradio.info/asx/suzuka.asx"
    SIMUL_ST[ "izunokuni" ]="http://www.simulradio.info/asx/izunokuni.asx"
    SIMUL_ST[ "fmn1" ]="http://android.fmn1.jp/live/"
    SIMUL_ST[ "harbor779" ]="http://www.web-services.jp/harbor779/"
    SIMUL_ST[ "radiomyu" ]="http://www.simulradio.info/asx/radiomyu.asx"
    SIMUL_ST[ "fm-tanba" ]="http://fukuchiyama.fm-tanba.jp/simul.asx"
    SIMUL_ST[ "senri-fm" ]="http://www.simulradio.info/asx/fmsenri.asx"
    SIMUL_ST[ "fmyy" ]="http://www.simulradio.info/asx/fmyy.asx"
    SIMUL_ST[ "fmhanako" ]="http://fmhanako.jp/radio/824.asx"
    SIMUL_ST[ "fm-miki" ]="http://www.simulradio.info/asx/fm-miki.asx"
    SIMUL_ST[ "hirakata" ]="http://www.simulradio.info/asx/hirakata.asx"
    SIMUL_ST[ "fmgenki" ]="http://www.simulradio.info/asx/fm-genki.asx"
    SIMUL_ST[ "fm-tanabe" ]="http://www.simulradio.info/asx/fm-tanabe.asx"
    SIMUL_ST[ "jungle" ]="http://www.simulradio.info/asx/jungle.asx"
    SIMUL_ST[ "banban" ]="http://www.simulradio.info/asx/banban.asx"
    SIMUL_ST[ "takarazuka" ]="http://www.simulradio.info/asx/takarazuka.asx"
    SIMUL_ST[ "beach_station" ]="http://www.simulradio.info/asx/beach_station.asx"
    SIMUL_ST[ "minoh" ]="http://fm.minoh.net/minohfm.asx"
    SIMUL_ST[ "yesfm" ]="http://www.simulradio.info/asx/yes-fm.asx"
    SIMUL_ST[ "KyotoLivingFM" ]="http://www.simulradio.info/asx/KyotoLivingFM.asx"
    SIMUL_ST[ "sakura-fm" ]="http://www.simulradio.info/asx/sakura.asx"
    SIMUL_ST[ "fmaiai" ]="http://www.simulradio.info/asx/aiai.asx"
    SIMUL_ST[ "fmkusatsu" ]="http://www.simulradio.info/asx/rockets785.asx"
    SIMUL_ST[ "hasimoto" ]="http://www.simulradio.info/asx/hasimoto.asx"
    SIMUL_ST[ "radiocafe" ]="http://www.simulradio.info/asx/radiocafe.asx"
    SIMUL_ST[ "tanbacom" ]="http://www.simulradio.info/asx/tanbacom.asx"
    SIMUL_ST[ "fm-tango" ]="http://www.simulradio.info/asx/tango.asx"
    SIMUL_ST[ "fm-moov" ]="http://www.simulradio.info/asx/fmmoov.asx"
    SIMUL_ST[ "chupea" ]="http://www.simulradio.info/asx/fm-chupea.asx"
    SIMUL_ST[ "darazfm" ]="http://www.darazfm.com/streaming.asx"
    SIMUL_ST[ "takamatsu" ]="http://www.simulradio.info/asx/fm815.asx"
    SIMUL_ST[ "bfm" ]="http://www.simulradio.info/asx/b-fm791.asx"
    SIMUL_ST[ "fmsun" ]="http://www.simulradio.info/asx/fmsun.asx"
    SIMUL_ST[ "fmnakatsu" ]="http://www.simulradio.info/asx/fmnakatsu.asx"
    SIMUL_ST[ "sunfm" ]="http://www.simulradio.info/asx/sunshinefm.asx"
    SIMUL_ST[ "AmamiFM" ]="http://www.npo-d.org/simul/AmamiFM.asx"
    SIMUL_ST[ "shimabara" ]="http://www.shimabara.fm/st/fm-shimabara-live.asx"
    SIMUL_ST[ "fm-kitaq" ]="http://www.shimabara.fm/st/fm-kitaq-live.asx"
    SIMUL_ST[ "starcornfm" ]="mms://hdv.nkansai.tv/starcorn"
    SIMUL_ST[ "comiten" ]="http://comiten.jp/live.asx"
    SIMUL_ST[ "hibiki" ]="http://www.simulradio.info/asx/hibiki.asx"
    SIMUL_ST[ "fmnobeoka" ]="http://www.simulradio.info/asx/nobeoka.asx"
    SIMUL_ST[ "fm-nirai" ]="http://www.simulradio.info/asx/fm-nirai.asx"
    SIMUL_ST[ "fmishigaki" ]="http://118.21.140.45/Push1"
    SIMUL_ST[ "fm-uruma" ]="http://www.simulradio.info/asx/uruma.asx"
    SIMUL_ST[ "fm21" ]="http://www.simulradio.info/asx/fm21.asx"
    SIMUL_ST[ "fmlequio" ]="http://www.simulradio.info/asx/lequio.asx"
    SIMUL_ST[ "fm-toyomi" ]="http://www.simulradio.info/asx/toyomi.asx"
    SIMUL_ST[ "okiradi" ]="http://www.simulradio.info/asx/okiradi.asx"
    SIMUL_ST[ "fm-nanjo" ]="http://www.simulradio.info/asx/nanjo.asx"
    SIMUL_ST[ "motob" ]="http://www.simulradio.info/asx/motob.asx"
    SIMUL_ST[ "fmkumejima" ]="http://www.simulradio.info/asx/fmkumejima.asx"
}


# HMS を 秒に変換: 1h30m --> 5400
function hms2second() {
    local tm=$1
    local sec
    sec=`echo $tm | awk '
{
    t = 0;
    tm = 0;
    for ( i = 0; i <= length( $0 ); ++i ) {
        c = toupper( substr( $0, i, 1 ) );
        if ( "0" <= c && c <= "9") {
            t = t * 10 + c;
        } else if ( "H" == c ) {
            tm = tm + t * 3600;
            t = 0;
        } else if ( "M" == c ) {
            tm = tm + t * 60
            t = 0;
        } else if ( "S" == c ) {
            tm = tm + t
            t = 0;
            break;
        }
    }
    tm = tm + t
    printf( "%d", tm );
}
'`
    echo "$sec"
}



# 認証
function radiko_authorize() {
    local offset length partialkey areaid rc

    echo "==== authorize ===="

    # ディレクトリ：認証キー他ファイル置き場
    if [ ! -d "${keydir}" ]; then
        if ! mkdir -p ${keydir}; then
            echo "Cannot make directory: ${keydir}"
            exit 1
        fi
    fi
    #
    # get player
    #
    if [ ! -f $playerfile ]; then
        echo "$playerfile downloading..."
        wget -O $playerfile $playerurl
        if [ $? -ne 0 ]; then
            echo "failed get player"
            [ -f $playerfile ] && rm $playerfile
            exit 1
        fi
    fi

    #
    # get keydata (need swftool)
    #
    if [ ! -f $keyfile ]; then
        echo $keyfile extracting...
        swfextract -b 14 $playerfile -o $keyfile
        if [ ! -f $keyfile ]; then
            echo "failed get keydata"
            exit 1
        fi
    fi

    #
    # access auth1_fms
    #
    wget -q \
        --header="pragma: no-cache" \
        --header="X-Radiko-App: pc_1" \
        --header="X-Radiko-App-Version: $VERSION" \
        --header="X-Radiko-User: test-stream" \
        --header="X-Radiko-Device: pc" \
        --post-data='\r\n' \
        --no-check-certificate \
        --save-headers \
        https://radiko.jp/v2/api/auth1_fms -O ${auth1_fms}

    if [ $? -ne 0 ]; then
        echo "failed auth1 process"
        _atexit
        exit 1
    fi

    #
    # get partial key
    #
    authtoken=`perl -ne 'print $1 if(/x-radiko-authtoken: ([\w-]+)/i)' \
        ${auth1_fms}`
    offset=`perl -ne 'print $1 if(/x-radiko-keyoffset: (\d+)/i)' ${auth1_fms}`
    length=`perl -ne 'print $1 if(/x-radiko-keylength: (\d+)/i)' ${auth1_fms}`
    partialkey=`dd if=$keyfile bs=1 skip=${offset} count=${length} \
        2>/dev/null \
        | base64`

    #
    # access auth2_fms
    #
    wget -q \
        --header="pragma: no-cache" \
        --header="X-Radiko-App: pc_1" \
        --header="X-Radiko-App-Version: $VERSION" \
        --header="X-Radiko-User: test-stream" \
        --header="X-Radiko-Device: pc" \
        --header="X-Radiko-Authtoken: ${authtoken}" \
        --header="X-Radiko-Partialkey: ${partialkey}" \
        --post-data='\r\n' \
        --no-check-certificate \
        https://radiko.jp/v2/api/auth2_fms -O ${auth2_fms}
    rc=$?
    if [ $? -ne 0 -o ! -f ${auth2_fms} ]; then
        echo "failed auth2 process"
        _atexit
        exit 1
    fi

    echo "==== authentication success ===="

    areaid=`perl -ne 'print $1 if(/^([^,]+),/i)' ${auth2_fms}`
    echo "areaid: $areaid"

    return $rc
}


# 録音: radiko
function radiko_record() {
    local URLLINE RMTP APP PLAYPATH rc

    echo "==== recording ===="
    #
    # get stream-url & get authtoken
    #
    URLLINE=($(wget -q \
        "http://radiko.jp/v2/station/stream/${channel}.xml" -O - \
        | xpath -q -e '//url/item[1]/text()' \
        | perl -pe 's!^(.*)://(.*?)/(.*)/(.*?)$/!$1://$2/ $3 $4!'))
    RMTP="${URLLINE[0]}"
    APP="${URLLINE[1]}"
    PLAYPATH="${URLLINE[2]}"
    #
    # rtmpdump
    #
    # WARNING が出る
    echo "save to '$output'"
    rtmpdump \
        --rtmp ${RMTP} \
        --app ${APP} \
        --playpath ${PLAYPATH} \
        -C S:"" -C S:"" -C S:"" -C S:${authtoken} \
        -W $playerurl \
        --live \
        --stop "${rectime}" \
        --flv "${output}"
    rc=$?
    if [ ! -z "${oname}" ]; then
        mv ${output} "`dirname ${output}`/${oname}"
    fi
    return $rc
}


# 録音: NHK
# WARNING が 2 個出る
# mplayer のみでも可能らしい: https://gist.github.com/matchy2/5310409
function radiko_nhk() {
    local PLAYPATH ID rc

    PLAYPATH="$1"
    ID="${channel##*-}"
    ID="${ID,,}" # 小文字にしておく

    echo "==== recording ===="
    echo "save as '$output'"

    rtmpdump --rtmp "rtmpe://netradio-${ID}-flash.nhk.jp" \
        --playpath "${PLAYPATH}" \
        --app "live" \
        -W http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf \
        --live \
        --stop "${rectime}" \
        -o "${output}"
    rc=$?

    if [ ! -z "${oname}" ]; then
        mv ${output} "`dirname ${output}`/${oname}"
    fi

    return $rc
}


# 録音: simul radio
function sumul_record() {
    local url svfile outfile rc pid st ed interval opt mms
    url="$1"
    interval=10

    svfile="${output%%.flv}.wma"
    opt="$mpopt -dumpstream -dumpfile ${svfile}"
    if [ "mms://" = "${url:0:6}" ]; then
	opt="$opt ${url}"
    elif [ ".asx" = "${url:${#url}-4:4}" ]; then
	mms=($( \
	    wget -q "${url}" -O - \
	      | grep 'mms://' \
	      | perl -pe 's!^(.*)"(.*)"(.*)$!$2!' \
	      ))
	if [ ! -z "${mms}" ]; then
	    opt="$opt ${mms}"
	else
	    opt="$opt -playlist ${url}"
	fi
    else
	opt="$opt ${url}"
    fi
    st="`date +%s`"
    ed="`expr $st + ${rectime}`"
    mplayer $opt &
    pid=$!
    while [ $st -lt $ed ]; do
	sleep ${interval}
	if [ -z "`ps --no-headers -o pid $pid`" ]; then
	    # abend
	    rc=1
	    break
	fi
	st="`date +%s`"
    done
    if [ -z "$rc" ]; then
	# normal end
	kill $pid
	wait $pid
	rc=0
    fi

    if [ ! -z "${oname}" ]; then
	outfile="${oname%%.flv}.wma"
        mv ${svfile} "`dirname ${svfile}`/${outfile}"
    fi

    return $rc
}


#
# -- main -----------------------------------------------------------
#

# 引数解析
COMMAND=`basename $0`
while getopts ad:f:h:ln:r:t:w: OPTION; do
    case $OPTION in
        a )
            OPTION_a="TRUE"
            ;;
        d )
            OPTION_d="TRUE"
            VALUE_d="$OPTARG"
            ;;
        f )
            OPTION_f="TRUE"
            VALUE_f="$OPTARG"
            ;;
        h )
            OPTION_h="TRUE"
            VALUE_h="$OPTARG"
            ;;
        l )
            OPTION_l="TRUE"
            ;;
        n )
            OPTION_n="TRUE"
            VALUE_n="$OPTARG"
            ;;
        r )
            OPTION_r="TRUE"
            VALUE_r="$OPTARG"
            ;;
        t )
            OPTION_t="TRUE"
            VALUE_t="$OPTARG"
            ;;
        w )
            OPTION_w="TRUE"
            VALUE_w="$OPTARG"
            ;;
        * )
            usage
            exit 1
            ;;
    esac
done

shift $(($OPTIND - 1))  # 残りの非オプションな引数のみが、$@に設定される

# 残りのオプションはチャンネルのみ
channel=$1



# オプション処理: 指定できる放送局一覧
if [ "TRUE" = "$OPTION_l" ]; then
    show_list
    exit 1
fi

# オプション処理: エリアチェック
if [ "TRUE" = "$OPTION_a" ]; then
    radiko_authorize && cat ${auth2_fms} | grep -e '^\w\+'
    _atexit
    exit 0
fi

# 引数チェック: 放送局指定が無い
if [ -z "$channel" ]; then
    usage
    exit 1
fi

# オプション処理: ディレクトリ名
if [ "$OPTION_d" = "TRUE" ]; then
    wdir="${VALUE_d}"
else
    wdir=${download_dir}
fi

# オプション処理: ファイル名
if [ "$OPTION_f" = "TRUE" ]; then
    oname=`basename $VALUE_f`
fi
fname="${channel}_`date +%Y%m%d-%H%M`.flv"

# オプション処理: 番組名, 時刻表記　-f を上書き
if [ "$OPTION_n" = "TRUE" -a "$OPTION_h" = "TRUE" ]; then
    get_station_name $channel
    datetime="`date +%y%m%d`"
    oname="${VALUE_n}_${stname}_${datetime}${VALUE_h}.flv"
fi

# オプション処理: リトライ回数
if [ "$OPTION_r" = "TRUE" ]; then
    retry_limit="${VALUE_r}"
fi

# オプション処理: 開始時待ち
if [ "$OPTION_w" = "TRUE" ]; then
    waits="${VALUE_w}"
else
    waits=0
fi

# オプション処理: 録音時間
if [ "$OPTION_t" = "TRUE" ]; then
    rectime="`hms2second $VALUE_t`"
    rectime=`expr ${rectime} + ${filler} - ${waits}`
else
    rectime=30
fi

# 引数解析：終了

# 開始時ウエイト
sleep ${waits}

# ディレクトリ：出力先
if [ ! -d "${wdir}" ]; then
    if ! mkdir -p ${wdir}; then
        echo "Cannot make directory: ${wdir}"
    fi
fi

# 出力ファイル名: 第一回
output="${wdir}/${fname}"

# メイン
retry_count=0
st="`date +%s`"
ed="`expr $st + $rectime`"
set_simul_station
while [ $st -lt $ed ]; do
    case ${channel} in
        NHK-R1)  # ラジオ第1
            radiko_nhk "NetRadio_R1_flash@63346"
            ;;
        NHK-R2)  # ラジオ第2
            radiko_nhk "NetRadio_R2_flash@63342"
            ;;
        NHK-FM)  # NHK-FM
            radiko_nhk "NetRadio_FM_flash@63343"
            ;;
        * )
	    url=${SIMUL_ST[ ${channel} ]}
	    if [ ! -z "${url}" ]; then
		sumul_record ${url}
	    else
		radiko_authorize && radiko_record
	    fi
            ;;
    esac
    if [ 0 -eq $? ]; then
        break
    fi

    retry_prev=${retry_count}
    retry_count="`expr ${retry_count} + 1`"
    if [ $retry_count -gt $retry_limit ]; then
        echo "== abort: retry count reached to limit =="
        break
    fi
    if [ 0 -eq $retry_prev ]; then
        output="${output/.flv/(1).flv}"
        oname="${oname/.flv/(1).flv}"
    else
        output="${output/(${retry_prev}).flv/(${retry_count}).flv}"
        oname="${oname/(${retry_prev}).flv/(${retry_count}).flv}"
    fi

    st="`date +%s`"
    rectime="`expr $ed - $st`"
    echo "== retry(${retry_count}): rest time is $rectime =="
done


# 後始末
_atexit
