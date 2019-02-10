use Win32::OLE;
use strict;

my $wd = 
	Win32::OLE->GetActiveObject("Word.Application") ||
	Win32::OLE->new("Word.Application", sub {$_[0]->Quit;} ) or die;
my $doc = $wd->Documents->Open("KPML3.doc");
# my $doc = Win32::OLE->GetObject("KPML2.doc") or die;
$doc->PrintOut;
$doc->Close;
# $wd->Close;
