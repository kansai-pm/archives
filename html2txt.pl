# html2txt.pl HTML形式データをテキストデータに
# 1997 Sey (sey@jkc.co.jp,SDI00577@niftyserve.or.jp)
# jperl html2txt.pl HTMLファイル…

# タグとそれに応じて出力する内容
%out = (
"H1",	"\n\n\n\n\n",
"H2",	"\n\n\n\n",
"H3",	"\n\n\n",
"H4",	"\n\n",
"/H1",	"\n\n",
"/H2",	"\n\n",
"/H3",	"\n\n",
"/H4",	"\n\n",
"P",	"\n\n",
"HR",	"\n\n",
"BLOCKQUOTE","\n\n",
"/BLOCKQUOTE","\n\n",
"BR",	"\n",
"CENTER","\n",
"/CENTER","\n",
"DIV","\n",
"/DIV","\n",
"/HTML","\n",
"UL",	"\n",
"OL",	"\n",
"/UL",	"\n\n",
"/OL",	"\n\n",
"LI",	"\no",
"/TABLE","\n",
"TR",	"\n",
"/TD",	"\t",
"/TH",	"\t"
);

# タグ間の文字列の出力を抑制するタグ
# 値：n … 抑制コンテナの開始 c … 〃終了  t … 次のタグまで抑制
%noout = (
"COMMENT","n",
"/COMMENT","c",
"HEAD",	"n",
"/HEAD","c",
"TABLE","t",
"TR",	"t",
"/TD",	"t",
"/TR",	"t",
);

# 出力バッファ
$outbuf = "";
# 出力時に連続する空行をまとめるためのカウンタ
$outnl = 0;

# <PRE>中のフラグ
$pre = 0;
# 出力抑制フラグ
$noout = 0;
# 次のタグまでの出力抑制フラグ
$noout1tag = 0;
# 状態
$status = "idle";
# 作業領域
$buf = "";
for(;;)
    {
    # タグ外の状態
    if( $status eq "idle" )
        {
        # < を検出
        if( $buf =~ /^([^<>]*)</ )
            # そこまでを出力し、< を検出した状態へ
            {
            $buf = $'; 
            out($1) if( !$noout && !$noout1tag ); 
            $status = "<"; 
            }
        # みつからない
        else
            # 次の行を読んでつなげる
            { last if( !&readline ); }
        }
    # < を検出した状態
    elsif( $status eq "<" )
        {
        # <!--
        if( $buf =~ /^!--/ )
            { $buf = $'; $status = "!--"; }
        # <PRE>
        elsif( $buf =~ /^PRE */i )
            { $buf = $'; out("\n"); $pre++; $status = "wait>"; }
        # </PRE>
        elsif( $buf =~ /^\/PRE */i )
            { $buf = $'; out("\n"); $pre--; $status = "wait>"; }
        # それ以外のタグ
        elsif( $buf =~ /^[\/\?!]?[a-zA-Z0-9]+/ )
            {
            $buf = $';
            $tagname = $&;
            $tagname =~ tr/a-z/A-Z/;
            # %outにあれば対応する内容を出力
            if( $out{$tagname} ne "" ) {
                out($out{$tagname}) 
            }
            # なにかタグが来たら$noout1tagはクリア
            $noout1tag = 0; 
            # %nooutにあれば出力抑制フラグをセット
            # 抑制を開始するタグ
            if( $noout{$tagname} eq "n" )
                { $noout++; }
            # 抑制を終了するタグ
            elsif( $noout{"$tagname"} eq "c" )
                { $noout--; }
            # 次のタグまで抑制するタグ
            elsif( $noout{$tagname} eq "t" )
                { $noout1tag = 1; }
            $status = "wait>";
            }
        # タグでないと思われる場合
        else
            { out("<"); $status = "idle"; }
        }
    # タグ中で > を待つ状態
    elsif( $status eq "wait>" )
        {
        # " " で囲まれた文字列
        if( $buf =~ /^[^<>\"]*\"[^\"]*\"/ )
            { $buf = $'; }
        # > が見つかった
        elsif( $buf =~ /^[^<>\"]*>/ )
            { $buf = $'; $status = "idle"; }
        # みつからない
        else
            # 次の行を読んでつなげる
            { last if( !&readline ); }
        }
    # 注釈状態
    elsif( $status eq "!--" )
        {
        # --> がみつかった
        if( $buf =~ /-->/ )
            { $buf = $'; $status = "idle"; }
        # みつからない
        else
            # 次の行を読んでつなげる
            { last if( !&readline ); }
        }
    }
# end

# 次の行を読んで$bufに連結
sub readline
    {
    if( $line = <> )
        {
        # 物理的改行はいったん\x01に変換しておく
        $line =~ s/\n/\x01/g;
        $buf .= $line;
        1;
        }
    # 終わりなら残りを出力して終了
    else
        {
        out($buf) if( $status eq "idle" );
        0;
        }
    }
# end readline

# 出力
sub out
    {
    local($string) = @_;
    
    # 特殊記号の変換
    $string =~ s/&lt;/</g;
    $string =~ s/&gt;/>/g;
    $string =~ s/&quot;/\"/g;
    $string =~ s/&amp;/&/g;
    # <PRE>～</PRE>中では物理的改行を復活してそのまま出力
    if( $pre )
        {
        $outbuf =~ s/\x01/\n/g;
        $string =~ s/\x01/\n/g;
        print $outbuf,$string;
        $outbuf = "";
        $outnl = 0;
        }
    else
        {
        # 物理的改行は除く
        $string =~ s/\x01//g;
        # 連続する空白はまとめる
        $string =~ s/ +/ /g;
        # 改行を含むときは改行までをバッファにつなげて出力
        if( $string =~ /^.*\n+/ )
            {
            $string = $outbuf . $&;
            $outbuf = $';
            # 行末の空白とタブは除く
            $string =~ s/[ \t]+\n/\n/;
            # 連続する改行はまとめる
            $string =~ s/\n{3,}/\n\n/;
            # 改行のみの時は前回の改行数を考慮する
            if( $string =~ /^\n+/ )
                {
                # すでに2回以上改行していればもう改行しない
                if( $outnl >= 2 )
                    { $string =~ s/^\n+//; }
                # 一回なら一回だけ
                elsif( $outnl == 1 )
                    { $string =~ s/^\n+/\n/; }
                # カウンタを増やす
                $outnl += $string =~ s/\n/\n/g;
                }
            else
                { $outnl = $string =~ s/\n/\n/g; }
            print $string;
            }
        # 改行を含まない時はバッファにためる
        else
            { $outbuf .= $string; }
        }
    }
# end out

# end html2txt.pl
