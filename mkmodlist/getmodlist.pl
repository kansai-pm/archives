#!/usr/bin/perl
# getmodlist.pl - get module and author list from search.cpan.org
# 2004 nakajima@netstock.co.jp
use LWP::UserAgent;
use FileHandle;
use strict;

my $ua = LWP::UserAgent->new;
$ua->timeout(10);

my @genre = qw(modlist author dlsip);

my %fh;
for my $genre(@genre) {
	$fh{$genre} = new FileHandle ">$genre" or die "cannot open $genre\n";
}

my %alreadyurl;

getpage($ua, "http://search.cpan.org/dlsip", 'dlsip');
getpage($ua, "http://search.cpan.org/", 'modlist');

sub getpage {
	my($ua, $url, $genre) = @_;
	return if $alreadyurl{$url};
	$alreadyurl{$url} = 1;
	print "[$genre] $url\n";
	my $response = $ua->get($url);
	unless( $response->is_success ) {
		print $response->status_line;
		return;
	}
	my $page = $response->content;
	my $out = $fh{$genre};
	print $out "\n-- $url --\n";
	print $out $page;
	my($host) = $url =~ m|^(http://[^/]+)|;
	while( $page =~ m#<a href=\"(/modlist/.+?)\"#g ) {
		my $linkurl = "$host$1";
		getpage($ua, $linkurl, 'modlist');
	}
	while( $page =~ m#<a href=\"(/~\w+)\"#g ) {
		my $linkurl = "$host$1";
		getpage($ua, $linkurl, 'author');
	}
}
