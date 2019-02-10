# KPML3.cgi
# 2002 <nakajima@netstock.co.jp>
use Win32::GuiTest qw(FindWindowLike SetForegroundWindow SendKeys);
use Win32::OLE;
use CGI;
use strict;

$| = 1;
main(CGI->new);

sub main {
	my($cgi) = @_;
	my $job = $cgi->param('job');
	if( $job eq 'capture' ) {
		do_capture($cgi);
	} elsif( $job eq 'printout' ) {
		do_printout($cgi);
	} else {
		result($cgi, 'Shift_JIS', 'エラー', 
			"unknown job: $job", undef, 'back()');
	}
}
	
sub do_capture {
	my($cgi) = @_;
	my $url = $cgi->url;
	my $imgname = $cgi->param('imgname');
	my $imgfile = "$imgname.jpg";
	if( capture($imgfile) ) {
		my $imgurl = $url;
		$imgurl =~ s/[^\/]+$/$imgfile/;
		result($cgi, 'Shift_JIS', '撮影結果', 
			'撮影しました', $imgurl, 'KPML3p.shtml');
	} else {
		result($cgi, 'Shift_JIS', '撮影結果', 
			'撮影画像を取り込めませんでした', undef, 'KPML3.shtml');
	}
}

sub do_printout {
	my($cgi) = @_;
	my $file = $cgi->param('docname') . '.doc';
	unless( -f $file ) {
		result($cgi, 'Shift_JIS', 'エラー', 
			'雛形文書ファイルがありません', undef, 'back()');
		exit;
	}
	printout($file) ?
		result($cgi, 'Shift_JIS', '印刷中', 
		'印刷が終わったらOKボタンをクリックしてください<br>印刷されたアンケート用紙に記入して係にお渡しください<br>ありがとうございました', undef, 'KPML3.shtml') :
		result($cgi, 'Shift_JIS', 'エラー', 
			'Wordがオープンできない', undef, 'back()');
}

sub printout {
	my($file) = @_;
	my $wd = 
		Win32::OLE->GetActiveObject("Word.Application") ||
		Win32::OLE->new("Word.Application", sub {$_[0]->Quit;} ) or return 0;
	my $doc = $wd->Documents->Open($file);
	$doc->PrintOut;
	$doc->Close;
	# $wd->Close;
	return 1;
}

sub capture {
	my($imgfile) = @_;
	my $capturefile = 'c:\Media\Photo\ﾏｲ ｱﾙﾊﾞﾑ\Image001.jpg';
	unlink $capturefile;
	my($window) = FindWindowLike(0, "^PC-CAM Center");
	return unless $window;
	SetForegroundWindow($window);
	SendKeys("%p");
	sleep(5);
	my $result = 0;
	if( -s $capturefile ) {
		my $dir = $0;
		$dir =~ s/[^\/]+$//;
		rename($capturefile, "$dir$imgfile");
		$result = 1;
	}
	$result;
}

sub result {
	my($cgi, $charset, $title, $msg, $imgurl, $url) = @_;
	my $imgtag = $imgurl ? "<img src=\"$imgurl\">" : "";
	my $onclick = 
		$url eq 'close()' ? 'if(opener)opener.location.reload();window.close()' :
		$url eq 'back()' ? 'history.back()' :
		$url ? "window.location.href = '$url'" : 
		'history.back()';
	print $cgi->header(-type => 'text/html', -charset => $charset, -expires => 'now', -Pragma => 'no-cache', -Cache-Control => 'no-cache');
	print <<END;
<html><head>
<title>$title</title>
<meta http-equiv="Content-Type" content="text/html; charset=$charset">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
</head>
<body bgcolor="white">
<p>$msg</p>
$imgtag
<form action="" method="GET">
<input type="button" value="OK" onclick="$onclick">
</form>
</body></html>
END
}
