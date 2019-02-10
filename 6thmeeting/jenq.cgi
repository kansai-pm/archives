#!/usr/bin/perl
# jenq.cgi - simple enquete cgi
# 2004 nakajima@netstock.co.jp
use CGI;
use FileHandle;
use strict;
use vars qw($VERSION);

$VERSION = "1.2";

my %Cfg = readcfgfile("$0.cfg");

main(new CGI);

sub fatal {
	my($q, $msg) = @_;
	print $q->header('text/plain');
	print $msg;
	exit;
}

sub main {
	my($q) = @_;
	my $enq = $q->param('enq');
	fatal($q, "missing enq param") unless $enq;
	my $enqdir = "$Cfg{datadir}/$enq";
	fatal($q, "missing $enqdir directory") unless -d $enqdir;
	my $reqfile = "$Cfg{datadir}/$enq/require";
	my %require;
	if( -f $reqfile ) {
		%require = readcfgfile($reqfile);
	}
	#my $start = $q->param('start');
	my $num = $q->param('n');
	my $max = $q->param('m') ? $q->param('m') + 1 : $num;
	my $next = $num + 1;
	my %ans;
	my $miss = "";
	for( my $qno = 1; $qno < $max; $qno++ ) {
		my $ans = join ',', $q->param("Q$qno");
		$ans{$qno} = $ans;
		if( $ans =~ /^\s*$/ && $require{$qno} ) {
			$miss .= ', ' if $miss ne '';
			$miss .= "$require{$qno} ";
		}
	}
	my $showfile;
	my $end = 0;
	if( !$num ) { 
		$showfile = "$enqdir/start.html";
		fatal($q, "missing $showfile") unless -f $showfile;
	} elsif( $miss ) {
		$showfile = "$enqdir/miss.html";
		fatal($q, "missing $showfile") unless -f $showfile;
	} else {
		$showfile = "$enqdir/Q$num.html";
		unless( -f $showfile ) {
			$showfile = "$enqdir/q$num.html";
			unless( -f $showfile ) {
				$showfile = "$enqdir/end.html";
				$end = 1;
				fatal($q, "missing $showfile") unless -f $showfile;
			}
		}
	}
	my $number = 0;
	if( $end ) {
		my($sec, $min, $hour, $day, $mon, $year) = localtime;
		$year += 1900;
		$mon++;
		my $date = sprintf("%04d/%02d/%02d %02d:%02d:%02d", $year, $mon, $day, 
			$hour, $min, $sec);
		my $user = $q->remote_user || $q->remote_addr;
		my $csvfile = "$Cfg{csvdir}/$enq.csv";
		my $fh = new FileHandle (-f $csvfile ? "+<$csvfile" : "+>$csvfile")
			or fatal($q, "cannot open $csvfile");
		flock $fh, 2;
		seek $fh, 0, 0;
		my $firstline = <$fh>;
		($number) = $firstline =~ /(\d+)/;
		$number++;
		seek $fh, 0, 0;
		printf $fh "%8d\n", $number;
		seek $fh, 0, 2;
		print $fh join(',', ($number, "\"$date\"", "\"$user\"", 
			map {quote($ans{$_})} sort {$a <=> $b} keys %ans)), "\n";
		flock $fh, 8;
		close $fh;
	}
	my $baseurl = "$Cfg{cgiurl}?enq=$enq";
	my $url = join '&', ($baseurl, 
		(map {urlparam("Q$_", $ans{$_})} sort keys %ans), 
		"n=$next");
	my $params .= join '', (hiddenfield(enq => $enq), 
		(map {hiddenfield("Q$_", $ans{$_})} sort keys %ans),
		hiddenfield(n => $next));
	print $q->header(-type => 'text/html', -charset => 'Shift_JIS');
	my $fh = new FileHandle $showfile
		or fatal($q, "cannot open $showfile");
	while(<$fh>) {
		s/#MISS/$miss/g;
		s/#CGI/$Cfg{cgiurl}/g;
		s/#ENQ/$baseurl&n=1/g;
		s/#QN/Q$num/g;
		s/#A(\d+)/$url&Q$num=$1/g;
		s/#V(\d+)/nl2br(html_escape($ans{$1}))/ge;
		s/#NUM/$number/g;
		s/<!--\s*#PARAMS\s*-->/$params/g;
		print;
	}
}

sub quote {
	local($_) = @_;
	if( /^\d+$/ ) {
		$_;
	} else {
		s/\"/\"\"/g;
		"\"$_\"";
	}
}

sub nl2br {
	local($_) = @_;
	s/\r?\n/<br>/g;
	$_;
}

sub html_escape {
	local($_) = @_;
	s/&/&amp;/g;
	s/</&lt;/g;
	s/>/&gt;/g;
	s/\"/&quot;/g;
	$_;
}

sub url_escape {
	local($_) = @_;
	s/([^;\/?:@&=+\$,A-Za-z0-9\-_.!~*'()])/sprintf("%%%02X",ord($1))/ge;
	$_;
}

sub hiddenfield {
	my($name, $value) = @_;
	$value = html_escape($value);
	"<input type=\"hidden\" name=\"$name\" value=\"$value\">";
}

sub urlparam {
	my($name, $value) = @_;
	$value = url_escape($value);
	"$name=$value";
}

sub readcfgfile {
	my($cfgfile, %Cfg) = @_;
	my($invalue, $endmark, $key, $value);
	my $F = new FileHandle;
	
	open($F, "$cfgfile");
	$invalue = 0;
	while(<$F>) {
		if( $invalue ) {
			if( /^$endmark$/ ) { 
				$invalue = 0; 
			} else { 
				$Cfg{$key} .= $_; 
			}
		} elsif( /^(\w+)\s*=\s*(.+)/ ) {
			$key = $1;
			$value = $2;
			if( $value =~ /^<<(.+)/ ) {
				$endmark = $1;
				$invalue = 1;
			} else { 
				$value =~ s/^\"// and $value =~ s/\"\s*$//;
				$Cfg{$key} = $value; 
			}
		}
	}
	close($F);
	return %Cfg;
}
