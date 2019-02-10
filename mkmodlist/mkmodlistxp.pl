#!/usr/bin/perl
# mkmodlist.pl - make module list XPDFJ source from 'modlist' and 'author'
# 2004 nakajima@netstock.co.jp
use FileHandle;
use strict;

my $Limit = shift;

my $mtime = mtime("modlist");
my $dlsip = read_dlsip("dlsip");
my $data = read_modlist("modlist");
my($author, $distmodule) = read_author("author");
write_xp("modlist.xp", $mtime, $dlsip, $data, $author, $distmodule);

sub mtime {
	my($srcfile) = @_;
	localtime((stat("$srcfile"))[9]);
}

sub read_dlsip {
	my($srcfile) = @_;
	my $fh = new FileHandle $srcfile or die;
	print "reading $srcfile...\n";
	my $xp = "<OL>\n";
	my $indata = 0;
	my $dl = 0;
	while(<$fh>) {
		s/&nbsp;/ /g;
		if( $indata ) {
			if( m#</dl># ) {
				$indata = 0;
			} elsif( m#^<dt><b>(.+)</b></dt># ) {
				$xp .= "</DL>\n" if $dl;
				$xp .= "<LI>" . escape($1) . "</LI>\n<DL labelsize='20'>\n";
				$dl = 1;
			} elsif( m#^<tr# ) {
				my @tmp;
				while( m#<td>(.+?)</td>#g ) {
					push @tmp, $1;
				}
				$xp .= "<DT>$tmp[0]</DT><DD>" . escape($tmp[2]) . "</DD>\n";
			}
		} elsif( m#^<dl># ) {
			$indata = 1;
		}
	}
	$xp .= "</DL>\n</OL>\n";
	$xp;
}

sub read_modlist {
	my($srcfile) = @_;
	my %data;
	my($page, $pkg);
	my $indata = 0;
	my($name, $dlsip, $desc, $author);
	my $fh = new FileHandle $srcfile or die;
	print "reading $srcfile...\n";
	my $count = 0;
	while(<$fh>) {
		s/&nbsp;/ /g;
		if( m#^-- http://search.cpan.org/modlist/(.+) --$# ) {
			($page, $pkg) = split '/', $1;
			$page =~ s/_/ /g;
			$pkg .= "::" if $pkg;
		} elsif( /^  <tr class=[rs]>$/ ) {
			$indata = 1;
		} elsif( $indata ) {
			if( /href=\"\/search.+?\">(.+?)</ ) {
				$name = $1;
			} elsif( /href=\"\/dlsip.+?\">(.+?)</ ) {
				$dlsip = $1;
			} elsif( /width=\"80%\">(.+?)</ ) {
				$desc = $1;
			} elsif( /href=\"\/~.+?\">(.+?)</ ) {
				$author = $1;
			} elsif( /<\/tr>/ ) {
				$indata = 0;
				$data{$page}{$pkg}{$name} = [$dlsip, $desc, $author];
				# print "$name, $dlsip, $desc, $author\n";
				$count++;
			}
		}
	}
	close $fh;
	print "$count modules\n";
	return \%data;
}

sub read_author {
	my($srcfile) = @_;
	my $fh = new FileHandle $srcfile or die;
	print "reading $srcfile...\n";
	my $count = 0;
	my(%author, %distmodule, $data, $stat, 
		$rname, $rdesc, $rdate, $mname, $mdist);
	while(<$fh>) {
		s/&nbsp;/ /g;
		if( $stat eq 'release' ) {
			if( m#<td><a .+?/\">(.+?)<# ) {
				$rname = $1;
			} elsif( m#<td>([^<]+)<# ) {
				$rdesc = $1;
			} elsif( m#<td nowrap>(.+?)<# ) {
				$rdate = $1;
				push @{$data->{release}}, [$rname, $rdesc, $rdate];
			} elsif( m#</table># ) {
				$stat = '';
			}
		} elsif( $stat eq 'module' ) {
			if( m#<td><a .+?\">(.+?)<# ) {
				$mname = $1;
			} elsif( m#<td nowrap><a .+?\">(.+?)<# ) {
				$mdist = $1;
				push @{$distmodule{$mdist}}, $mname;
			} elsif( m#</table># ) {
				$stat = '';
			}
		} elsif( m#^-- http://search.cpan.org/~(.+) --$# ) {
			my $id = uc($1);
			$data = $author{$id} = {id => $id};
			$count++;
		} elsif( m# class=t1>(.+)<# ) {
			$data->{name} = $1;
		} elsif( m#\"mailto:.+?\">(.+?)<# ) {
			$data->{mail} = $1;
		} elsif( m#\"http:.+?\">(http:.+?)<# ) {
			$data->{hp} = $1;
		} elsif( m# class=t2># ) {
			$stat = 'release';
		} elsif( m# class=t3># ) {
			$stat = 'module';
		}
	}
	print "$count authors\n";
	(\%author, \%distmodule);
}

sub write_xp {
	my($dstfile, $mtime, $dlsip, $data, $author, $distmodule) = @_;
	my $fh = new FileHandle ">$dstfile" or die;
	print "writing $dstfile...\n";

	print $fh <<END;
<?xml version="1.0" encoding="iso-8859-1"?>
<XPDFJ version="0.1">
<do file="stddefs.inc"/>
<do file="toc.inc"/>
<do file="index.inc"/>
<setoption name="missdest" value="neglect"/>
<HXOUTLINE level="2,3"/>
<alias tag="G" aliasof="S" font="\$FontH{gothic_helvetica}"/>
<alias tag="GB" aliasof="S" font="\$FontH{gothic_helvetica_bold}"/>
<FOOTER page="odd" pstyle="align:e">{page}</FOOTER>
<FOOTER page="even" pstyle="align:b">{page}</FOOTER>
END

	my $pagecount = 0;
	for my $page(sort keys %$data) {
		$pagecount++;
		if( $Limit && $pagecount > $Limit ) {
			last;
		}
		print $fh <<END;
<HEADER page="odd" pstyle="align:e">$pagecount.$page</HEADER>
<HEADER page="even" pstyle="align:b">$pagecount.$page</HEADER>
<BODY>
END
		for my $pkg(sort keys %{$data->{$page}}) {
			if( $pkg ) {
				#print $fh "<H2 nooutline='1'>$pkg</H2>\n";
				print $fh "<H3>$pkg</H3>\n";
			} else {
				print $fh "<H2>$pagecount.$page</H2>\n";
			}
			print $fh <<END;
<eval>print qq($page  $pkg\\n)</eval>
<TABLE pstyle='linefeed:120%' cellwidth='115,35,240,60' cellpadding='3'>
END
			my $count = 0;
			for my $name(sort keys %{$data->{$page}{$pkg}}) {
				my($dlsip, $desc, $author) = @{$data->{$page}{$pkg}{$name}};
				my $mname = $name;
				$name =~ s/::/::<Null\/>/g;
				my $idx = "";
				my @part = split(/::/, $mname);
				for( my $j = 0; $j < @part; $j++ ) {
					my $part = $part[$j];
					my @tmp;
					for( my $k = 0; $k < @part; $k++ ) {
						push @tmp, ($k == $j ? "<G>$part[$k]</G>" : $part[$k]);
					}
					$idx .= "<INDEX reading='$part'><term><T>".
						join('::<Null/>', @tmp)."</T></term></INDEX>";
				}
				$desc = escape($desc);
				if( $count++ % 2 == 0 ) {
					print $fh "<TR cellbox='f' cellboxstyle='fillcolor:0.85'>";
				} else {
					print $fh "<TR>";
				}
				print $fh "<TD><T><Dest name='$mname'/>$idx<GB>$name</GB></T></TD><TD><S fontsize='8' withbox='n' withboxstyle='link:DLSIP'>$dlsip</S></TD><TD><G>$desc</G></TD><TD><S fontsize='9' withbox='n' withboxstyle='link:$author'>$author</S></TD></TR>\n";
			}
			print $fh "</TABLE>\n";
		}
		print $fh "</BODY>\n";
	}

	print $fh <<END;
<HEADER page="odd" pstyle="align:e">Authors</HEADER>
<HEADER page="even" pstyle="align:b">Authors</HEADER>
<BODY>
<H2>Authors</H2>
END

	my $authcount = 0;
	my($firstchr, $lastchr);
	for my $id(sort keys %$author) {
		$firstchr = substr($id, 0, 1);
		if( $firstchr ne $lastchr ) {
			$authcount++;
			if( $Limit && $authcount > $Limit ) {
				last;
			}
			print $fh "<H3 headereven='Authors - $firstchr' headerodd='Authors - $firstchr'>$firstchr</H3><eval>print qq(Authors - $firstchr\\n)</eval>\n";
			print "Authors - $firstchr\n";
			$lastchr = $firstchr;
		}
		my $data = $author->{$id};
		my($name, $mail, $hp) = @$data{qw(name mail hp)};
		print $fh <<END;
<TABLE pstyle='linefeed:120%' cellwidth='75,375' cellpadding='3' cellbox='f' cellboxstyle='fillcolor:0.85' preskip='10' postnobreak='1' nobreak='1'><TR>
<TD><T><Dest name='$id'/><GB>$id</GB></T></TD>
<TD><P pstyle='align:b; beginindent:[0,40]'><GB>$name</GB> <S withbox='n' withboxstyle='link:URI:mailto:$mail'>&lt;$mail&gt;</S> <S withbox='n' withboxstyle='link:URI:$hp'>$hp</S></P></TD>
</TR></TABLE>
END
		for my $rdata(@{$data->{release}}) {
			my($rname, $rdesc, $rdate) = @$rdata;
			print $fh "<P pstyle='align:b; beginindent:[20,40]; nobreak:1; linefeed:120%; preskip:25%; postskip:25%'>",
				"<GB>$rname</GB> <S fontsize='8'>[$rdate]</S> <G>$rdesc</G>";
			if( $distmodule->{$rname} ) {
				my @names;
				for my $name(@{$distmodule->{$rname}}) {
					my $mname = $name;
					my $nname = $name;
					$nname =~ s/::/::<Null\/>/g;
					push @names, 
						"<S withbox='n' withboxstyle='link:$mname'>$nname</S>";
				}
				print $fh " <G>(", join(" ", @names), ")</G>";
			}
			print $fh "</P>\n";
		}
	}
	print $fh "</BODY>\n";

	print $fh <<END;
<HEADER page="odd" pstyle="align:e">INDEX</HEADER>
<HEADER page="even" pstyle="align:b">INDEX</HEADER>
<BODY cols="3">
<H2>INDEX</H2>
<MAKEINDEX dot=". " title="- {title} -"/>
</BODY>
<FOOTER page="odd" clear="1"/>
<FOOTER page="even" clear="1"/>
<HEADER page="odd" clear="1"/>
<HEADER page="even" clear="1"/>
<BODY page='1' evenpages="1">
<HR/>
<SKIP skip="15"/>
<P align='center' tstyle='fontsize:16'><B>Perl5 CPAN Module List</B></P>
<SKIP skip="15"/>
<HR/>
<SKIP skip="20"/>
<P>
This is the Perl5 CPAN (Comprehensive Perl Archive Network) Module List downloaded from http://search.cpan.org/ at $mtime.
</P>
<SKIP skip="20"/>
<TOC dot=". "/>
<SKIP skip="20"/>
<HR/>
<SKIP skip="15"/>
<P>
Arrangement: Yasushi Nakajima &lt;nakajima\@netstock.co.jp&gt; (Kansai.pm, Nestock corporation)
Made with PDFJ and XPDFJ modules.
</P>
<NEWPAGE/>
<P>
<Dest name="DLSIP"/>
The module status DLSIP symbols are as follows.
</P>
<SKIP skip="20"/>
$dlsip
</BODY>

<print file="\$Args{outfile}"/>
</XPDFJ>
END
	close $fh;
}

sub escape {
	my($str) = @_;
	$str =~ s/&/&amp;/g;
	$str =~ s/</&lt;/g;
	$str =~ s/>/&gt;/g;
	$str =~ s/'/&apos;/g;
	$str =~ s/\"/&quot;/g;
	$str;
}
