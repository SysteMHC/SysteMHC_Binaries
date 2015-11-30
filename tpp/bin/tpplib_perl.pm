package tpplib_perl;

# hack-y little set of routines to get at useful routines in tpplib without a proper perl module
# (building perl modules turns out to be an ugly mess for many end users)
# uses the increasingly misnamed tpp_hostname commandline app to get at needed tpplib functions

use FindBin;
my $tpp_hostname = "$FindBin::Bin/tpp_hostname";


sub hasValidPepXMLFilenameExt {
  my $fname=shift;
  my $ext = `$tpp_hostname hasValidPepXMLFilenameExt! $fname`;
  return $ext;
}

sub hasValidProtXMLFilenameExt {
  my $fname=shift;
  my $ext = `$tpp_hostname hasValidProtXMLFilenameExt! $fname`;
  return $ext;
}

sub uncompress_to_tmpfile {
  my $fname=shift;
  my $maxchar=shift;
  $maxchar = "" unless defined($maxchar);
  my $tmpfname = `$tpp_hostname uncompress_to_tmpfile!$maxchar $fname`;
  return $tmpfname;
}

sub getGnuplotBinary {
  my $exename = `$tpp_hostname getGnuplotBinary!`;
  return $exename;
}

sub getTPPVersionInfo {
  my $versionInfo = `$tpp_hostname versionInfo!`;
  return $versionInfo;
}

sub get_tpp_hostname {
 my $hostname = `$tpp_hostname`;
  if ("" eq $hostname) {
    $hostname="localhost";
  }
  return $hostname;
}

# taken off the web
sub read_query_string
{
    local ($buffer, @pairs, $pair, $name, $value, %FORM);
    # Read in text
    $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
    if ($ENV{'REQUEST_METHOD'} eq "POST")
    {
        read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    } else
    {
        $buffer = $ENV{'QUERY_STRING'};
    }
    @pairs = split(/&/, $buffer);
    foreach $pair (@pairs)
    {
        ($name, $value) = split(/=/, $pair);
        $value =~ tr/+/ /;
        $value =~ s/%(..)/pack("C", hex($1))/eg;
	if ($value =~ /;/) {
	    print "GET query string failure, found illegal character ';' ...\n";
	}
	else {
	    $FORM{$name} = $value;
	}
    }
    %FORM;
}

1; # required so that file can be correctly included in another script
   #- gives a 'true' response when loaded 
