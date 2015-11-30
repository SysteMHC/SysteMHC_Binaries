package StatUtilities;

###############################################################################
# Program     : StatUtilities.pm
# Author      : Eric Deutsch <edeutsch@systemsbiology.org>
#
# Description : (Originally SBEAMS::Connection::Utilities
#
#		This is part of the SBEAMS::Connection module which contains
#               generic utilty methods.)
#
# SBEAMS is Copyright (C) 2000-2005 Institute for Systems Biology
# This program is governed by the terms of the GNU General Public License (GPL)
# version 2 as published by the Free Software Foundation.  It is provided
# WITHOUT ANY WARRANTY.  See the full description of GPL terms in the
# LICENSE file distributed with this software.
#
###############################################################################


use strict;
use vars qw( $DBADMIN $PHYSICAL_BASE_DIR );
use vars qw(@ERRORS
           );
my $log = '';

###############################################################################
# Constructor
###############################################################################
sub new {
    my $this = shift;
    my $class = ref($this) || $this;
    my $self = {};
    bless $self, $class;
    return($self);
}


###############################################################################
# histogram
#
# Given an input array of data, calculate a histogram, CDF and other goodies
###############################################################################
sub histogram {
  my $self = shift || croak("parameter self not passed");
  my %args = @_;
  my $SUB_NAME = "histogram";
  my $VERBOSE = 0;

  #### Decode the argument list
  my $data_array_ref = $args{'data_array_ref'};
  my $min = $args{'min'};
  my $max = $args{'max'};
  my $bin_size = $args{'bin_size'};


  #### Create a return result structure
  my $result;
  $result->{result} = 'FAILED';


  #### extract out the data array and sort
  #my @data = @{$data_array_ref};
  #### Extract only the non-empty elements
  my @data;
  foreach my $element (@{$data_array_ref}) {
    if (defined($element) && $element gt '' && $element !~ /^\s+$/) {
      push(@data,$element);
    }
  }
  my @sorted_data = sort sortNumerically @data;
  my $n_elements = scalar(@data);
  return $result unless ($n_elements >= 1);


  #### Determine some defaults if they were not supplied
  if (!defined($min) || !defined($max) || !defined($bin_size)) {

    #### If the user didn't supply a min, set to the minimum aray value
    my $user_min = 1;
    if (!defined($min)) {
      $min = $sorted_data[0];
      $user_min = 0;
    }

    #### If the user didn't supply a max, set to the maximum aray value
    my $user_max = 1;
    if (!defined($max)) {
      $max = $sorted_data[$#sorted_data];
      $user_max = 0;
    }

    #### Determine the desired data range and a rounded range
    my $range = $max - $min;
    my $round_range = find_nearest([1000,500,100,50,20,10,
      5,2,1,0.5,0.25,0.1,0.05,0.02,0.01,0.005,0.002,0.001],$range);
    print "n_elements=$n_elements, min=$min, max=$max, range=$range, ".
      "round_range=$round_range<BR>\n" if ($VERBOSE);
    if ($round_range == 0) {
      print "Histogram error: round_range = 0<BR>\n";
      return $result;
    }


    #### If the user didn't supply a bin_size, determine roughly the
    #### number of desired bins based on the number of data points we
    #### have (the more points, the larger the number of bins) and
    #### then pick the closest round bin_size
    if (!defined($bin_size)) {
      my $desired_bins;
      $desired_bins = 10 if ($n_elements < 50);
      $desired_bins = 20 if ($n_elements >= 50 && $n_elements <= 200);
      $desired_bins = 30 if ($n_elements >= 200 && $n_elements <= 1000);
      $desired_bins = 40 if ($n_elements > 1000);
      $bin_size = ( $max - $min ) / $desired_bins;
      $bin_size = find_nearest([1000,500,100,50,20,10,5,2,1,0.5,0.25,0.1,
        0.05,0.02,0.01,0.005,0.002,0.001],$bin_size);
      print "Setting bin_size to $bin_size<BR>\n" if ($VERBOSE);
    }

    #### If the user didn't supply a min, then round off the min
    unless ($user_min) {
      print "range = $range,  round_range = $round_range,  ".
        "original min = $min<BR>\n" if ($VERBOSE);
      my $increment = ( $round_range / 10.0 );
      $increment = find_nearest([1000,500,100,50,20,10,5,2,1,0.5,0.25,0.1,
        0.05,0.02,0.01,0.005,0.002,0.001],$increment);
      $increment = 0.001 if ($increment < 0.001);
      $min = int( $min / $increment - 0.5 ) * $increment;
      print "Setting min to $min<BR>\n" if ($VERBOSE);
    }


    #### If the user didn't supply a max, then round off the max
    unless ($user_max) {
      print "range = $range,  round_range = $round_range,  ".
        "original max = $max<BR>\n" if ($VERBOSE);
      my $increment = ( $round_range / 10.0 );
      $increment = find_nearest([1000,500,100,50,20,10,5,2,1,0.5,0.25,0.1,
        0.05,0.02,0.01,0.005,0.002,0.001],$increment);
      $increment = 0.001 if ($increment < 0.001);
      $max = int( $max / $increment + 1.5 ) * $increment;
      print "Setting max to $max<BR>\n" if ($VERBOSE);
    }

  }


  #### To work around a floating-point imprecision problems (i.e. where
  #### 0.25 can become 0.250000000001), round to the bin_size precision
  my $precision = 0;
  $bin_size =~ /\d+\.(\d+)/;
  $precision = length($1) if ($1);

  #### Define arrays for the x axis, y axis, and displayed x axis (i.e.
  #### only the numbers we want to show being present and formatted nicely).
  my @xaxis;
  my @yaxis;
  my @xaxis_disp;

  #### Loop through all the bins, preparing the arrays
  my $ctr = $min;
  my $n_bins = 0;
  while ($ctr < $max) {
    push(@xaxis,$ctr);
    my $fixed_ctr = $ctr;
    $fixed_ctr = sprintf("%15.${precision}f",$ctr) if ($precision);
    $fixed_ctr =~ s/ //g;
    push(@xaxis_disp,$fixed_ctr);
    push(@yaxis,0);
    $ctr += $bin_size;
    $n_bins++;
  }


  #### We cannot always display all x axis numbers due to crowding, so
  #### use approximately 10 displayed numbers on the X axis as a rule of thumb
  my $x_label_skip = int( $n_bins / 10.0 );
  $x_label_skip = 1 if ($x_label_skip < 1);

  #### Override with some special, common cases
  $x_label_skip = 4
    if ($bin_size eq 0.25 && $x_label_skip >=3 && $x_label_skip <=5);
  print "x_label_skip=$x_label_skip, bin_size=$bin_size<BR>\n" if ($VERBOSE);

  #### Start off by keeping the first point
  my $skip_ctr = $x_label_skip;

  #### Loop through all the x axis points and blank some out for display
  for (my $i=0; $i<$n_bins; $i++) {
    if ($skip_ctr == $x_label_skip) {
      $skip_ctr = 1;
    } else {
      $xaxis_disp[$i] = '';
      $skip_ctr++;
    }
  }


  #### Loop through all the input data and place in appropriate bins
  my $total = 0;
  my $n_below_histmin = 0;
  my $n_above_histmax = 0;
  $n_elements = 0; # Reset back to 0 and count only non-empty numbers
  foreach my $element (@data) {

    #### If the value is empty then ignore - ALREADY DONE ABOVE
    #print "$n_elements: element = $element<BR>\n";
    #next unless (defined($element));
    #next unless ($element gt '');
    #next if ($element =~ /^\s+$/);

    #### If the data point is outside the range, don't completely ignore
    if ($element < $min || $element >= $max) {
      if ($element < $min) {
        $n_below_histmin++;
      } else {
        $n_above_histmax++;
      }

    #### If it is within the range, update the histogram
    } else {
      my $bin = ( $element - $min ) / $bin_size;
      $bin = int($bin);
      $yaxis[$bin]++;
    }

    #### Keep some additional statistics for latest calculations
    $total += $element;
    $n_elements++;

  }


  #### Calculate some statistics of this dataset
  my $divisor = $n_elements;
  $divisor = 1 if ($divisor < 1);
  my $mean = $total / $divisor;


  #### Loop through all the bins and calculate the CDF
  my @cdf;
  my $sum = $n_below_histmin;
  for (my $i=0; $i<$n_bins; $i++) {
    $sum += $yaxis[$i];
    $cdf[$i] = $sum / $divisor;
  }


  #### Calculate the standard deviation now that we know the mean
  my $stdev = 0;
  foreach my $element (@data) {

    #### If the value is empty then ignore - ALREADY DONE ABOVE
    #next unless (defined($element));
    #next unless ($element gt '');
    #next if ($element =~ /^\s+$/);

    $stdev += ($element-$mean) * ($element-$mean);
  }
  $divisor = $n_elements - 1;
  $divisor = 1 if ($divisor < 1);
  $stdev = sqrt($stdev / $divisor);


  #### Fill the output data structure with goodies that we've learned
  $result->{xaxis} = \@xaxis;
  $result->{xaxis_disp} = \@xaxis_disp;
  $result->{yaxis} = \@yaxis;
  $result->{cdf} = \@cdf;

  $result->{n_bins} = $n_bins;
  $result->{bin_size} = $bin_size;
  $result->{histogram_min} = $min;
  $result->{histogram_max} = $max;

  $result->{minimum} = $sorted_data[0];
  $result->{maximum} = $sorted_data[$#sorted_data];
  $result->{total} = $total;
  $result->{n_elements} = $n_elements;
  $result->{mean} = $mean;
  $result->{stdev} = $stdev;
  $n_elements = 1 if ($n_elements < 1);
  $result->{median} = $sorted_data[int($n_elements/2)];
  $result->{quartile1} = $sorted_data[int($n_elements*0.25)];
  $result->{quartile3} = $sorted_data[int($n_elements*0.75)];
  $result->{SIQR} = ($result->{quartile3}-$result->{quartile1})/2;

  $result->{ordered_statistics} = ['n_elements','minimum','maximum','total',
    'mean','stdev','median','SIQR','quartile1','quartile3',
    'n_bins','bin_size','histogram_min','histogram_max'];

  $result->{result} = 'SUCCESS';

  return $result;


} # end histogram



###############################################################################
# discrete_value_histogram
#
# Given an input array of data, calculate a histogram using the discrete
# values in the data
###############################################################################
sub discrete_value_histogram {
  my $self = shift || croak("parameter self not passed");
  my %args = @_;
  my $SUB_NAME = "discrete_value_histogram";
  my $VERBOSE = 0;

  #### Decode the argument list
  my $data_array_ref = $args{'data_array_ref'};


  #### Create a return result structure
  my $result;
  $result->{result} = 'FAILED';


  #### extract out the data array and sort
  #my @data = @{$data_array_ref};
  #### Extract only the non-empty elements
  my @data;
  foreach my $element (@{$data_array_ref}) {
    if (defined($element) && $element gt '' && $element !~ /^\s+$/) {
      push(@data,$element);
    }
  }
  my $n_elements = scalar(@data);
  return $result unless ($n_elements >= 1);

  #### Build a hash of the discrete elements
  my %discrete_elements;
  $n_elements = 0;
  foreach my $element (@data) {
    #### If there are semicolons in the data; treat that as a delimiter
    my @values = split (";",$element);
    foreach my $value ( @values ) {
      #### strip leading and trailing whitespace
      $value =~ s/^\s+//;
      $value =~ s/\s+$//;
      $discrete_elements{$value}++;
      $n_elements++;
    }
  }


  my @xaxis;
  my @xaxis_disp;
  my @yaxis;
  my $min = -1;
  my $max = -1;

  #### Loops over each discrete element and build the arrays needed
  #### for the histogram
  foreach my $element (sort(keys(%discrete_elements))) {
    my $count = $discrete_elements{$element};
    push(@xaxis,$element);
    push(@xaxis_disp,sprintf("%s (%.1f%)",$element,
			$count/$n_elements*100));
    push(@yaxis,$count);
    $max = $count if ($count > $max);
    $min = $count if ($min == -1);
    $min = $count if ($count < $min);
  }
  my $n_discrete_elements = scalar(@xaxis);


  #### Fill the output data structure with goodies that we've learned
  $result->{xaxis} = \@xaxis;
  $result->{xaxis_disp} = \@xaxis_disp;
  $result->{yaxis} = \@yaxis;

  $result->{n_bins} = $n_discrete_elements;
  $result->{n_elements} = $n_elements;

  $result->{minimum} = $min;
  $result->{maximum} = $max;

  $result->{ordered_statistics} = ['n_elements','n_bins'];

  $result->{result} = 'SUCCESS';

  return $result;


} # end discrete_value_histogram



###############################################################################
# find_nearest
###############################################################################
sub find_nearest {
  my $map_array_ref = shift || die("parameter map_array_ref not passed");
  my $value = shift;
  my $SUB_NAME = "histogram";

  my $result = $value;

  my $prev_element = $map_array_ref->[0] * 2;
  foreach my $element (@{$map_array_ref}) {
    if ($element < $value) {
      if ($value - $element gt $prev_element - $element) {
        $result = $prev_element;
      } else {
        $result = $element;
      }
      last;
    }
    $prev_element = $element;
  }

  return $result;

}


###############################################################################
# Numerically
###############################################################################
sub sortNumerically {

  return $a <=> $b;

}



###############################################################################
# average
#
# Given an input array of data, as well as an optional array or weights or
# uncertainties, calculate a mean and final uncertainty
###############################################################################
sub average {
  my $self = shift || croak("parameter self not passed");
  my %args = @_;
  my $SUB_NAME = 'average';
  my $VERBOSE = 0;

  #### Decode the argument list
  my $values_ref = $args{'values'};
  my $errors_ref = $args{'uncertainties'};
  my $weights_ref = $args{'weights'};

  #### Determine nature of the input arrays
  return(undef) unless (defined($values_ref) && @{$values_ref});
  my @values = @{$values_ref};
  my $n_values = scalar(@values);

  my @errors;
  my $n_errors;
  if (defined($errors_ref) && @{$errors_ref}) {
    @errors = @{$errors_ref};
    $n_errors = scalar(@errors);
  }

  my @weights;
  my $n_weights;
  if (defined($weights_ref) && @{$weights_ref}) {
    @weights = @{$weights_ref};
    $n_weights = scalar(@weights);
  }


  #### If no weights or errors were provided, calculate a plain mean
  #### of all non-undef values
  unless ($n_errors || $n_weights) {
    my $n_elements = 0;
    my $total = 0;
    foreach my $element (@values) {
      if (defined($element)) {
	$total += $element;
	$n_elements++;
      }
    }
    return(undef) unless ($n_elements > 0);
    return($total/$n_elements);
  }


  #### If only errors were provided, convert to weights
  if (defined($n_errors) && !defined($n_weights)) {
    unless ($n_errors == $n_values) {
      print "ERROR: $SUB_NAME: values and errors arrays must have same size\n";
      return(undef);
    }
    @weights = ();
    foreach my $element (@errors) {
      if (defined($element) && $element > 0) {
	push(@weights,1.0/($element * $element));
      } else {
	push(@weights,undef);
      }
    }
  }


  #### If both errors and weights were provided, we really should verify


  #### Calculate weighted mean and final uncertainty
  my $array_sum = 0;
  my $weight_sum = 0;
  my $n_elements = 0;
  my $err_sum = 0;
  for (my $i=0; $i<$n_values; $i++) {
    if (defined($values[$i]) && defined($weights[$i])) {
      $array_sum += $values[$i] * $weights[$i];
      $weight_sum += $weights[$i];
      $err_sum += 1.0/($weights[$i] * $weights[$i]);
      $n_elements++;
    }
  }

  my $divisor = $weight_sum;
  $divisor = 1 unless ($divisor);
  my $mean = $array_sum / $divisor;

  if ($n_errors) {
    my $uncertainty = sqrt(1.0/$divisor);
    return($mean,$uncertainty);
  }

  return($mean);

}



###############################################################################
# stdev
#
# Given an input array of data, calculate the standard deviation
###############################################################################
sub stdev {
  my $self = shift || croak("parameter self not passed");
  my %args = @_;
  my $SUB_NAME = 'stdev';
  my $VERBOSE = 0;

  #### Decode the argument list
  my $values_ref = $args{'values'};

  #### Determine nature of the input array
  return(undef) unless (defined($values_ref) && @{$values_ref});
  my @values = @{$values_ref};
  my $n_values = scalar(@values);

  #### Return undef for just one value
  return(undef) if ($n_values < 2);

  #### Calculate the average
  my ($mean) = $self->average(values => $values_ref);
  return(undef) unless (defined($mean));

  #### Calculate the standard deviation now that we know the mean
  my $stdev = 0;
  my $n_elements = 0;
  for (my $i=0; $i<$n_values; $i++) {
    if (defined($values[$i])) {
      $stdev += ($values[$i]-$mean) * ($values[$i]-$mean);
      $n_elements++;
    }
  }

  my $divisor = $n_elements - 1;
  $divisor = 1 if ($divisor < 1);
  $stdev = sqrt($stdev / $divisor);

  return($stdev);

}


###############################################################################
# min
#
# Given an input array of data, return the minimum value
###############################################################################
sub min {
  my $self = shift || croak("parameter self not passed");
  my %args = @_;
  my $SUB_NAME = 'min';

  #### Decode the argument list
  my $values_ref = $args{'values'};

  #### Determine nature of the input array
  return(undef) unless (defined($values_ref) && @{$values_ref});
  my @values = @{$values_ref};
  my $n_values = scalar(@values);

  #### Find the minimum
  my $minimum = undef;
  for (my $i=0; $i<$n_values; $i++) {
    if (defined($values[$i])) {
      if (defined($minimum)) {
	if ($values[$i] < $minimum) {
	  $minimum = $values[$i];
	}
      } else {
	$minimum = $values[$i];
      }

    }
  }

  return($minimum);

}

###############################################################################
# max
#
# Given an input array of data, return the maximum value
###############################################################################
sub max {
  my $self = shift || croak("parameter self not passed");
  my %args = @_;
  my $SUB_NAME = 'max';

  #### Decode the argument list
  my $values_ref = $args{'values'};

  #### Determine nature of the input array
  return(undef) unless (defined($values_ref) && @{$values_ref});
  my @values = @{$values_ref};
  my $n_values = scalar(@values);

  #### Find the minimum
  my $maximum = undef;
  for (my $i=0; $i<$n_values; $i++) {
    if (defined($values[$i])) {
      if (defined($maximum)) {
	if ($values[$i] > $maximum) {
	  $maximum = $values[$i];
	}
      } else {
	$maximum = $values[$i];
      }

    }
  }

  return($maximum);

}
sub get_datetime {
  my $self = shift;
  my @time = localtime();
  my @days = qw(Sun Mon Tue Wed Thu Fri Sat );
  my $year = $time[5] + 1900;
  my $mon = $time[4] + 1;
  my $day = $time[3];
  my $hour = $time [2];
  my $min = $time[1];
  my $sec = $time[0];
  for ( $min, $day, $hour, $mon, $sec ) {
    $_ = '0' . $_ if length( $_ ) == 1;
  }
  my $date = "${year}-${mon}-${day} ${hour}:${min}:${sec}";
  return $date;
}


#+
# Routine to return pseudo-random string of characters
#
# narg: num_chars   Optional, length of character string, def = 8.
# narg: char_set    Optional, character set to use passed as array reference,
#                   def = ( 'A'-'Z', 'a'-'z', 0-9 )
# ret:              Random string of specified length comprised of elements of 
#                   character set.
#-
sub getRandomString {
  my $self =  shift;
  my %args = @_;

  # Use passed number of chars or 8
  $args{num_chars} ||= 8;

  # Use passed char set if any, else use default a-z, A-Z, 0-9
  my @chars = ( ref( $args{char_set} ) eq 'ARRAY' ) ?  @{$args{char_set}} :
                         ( 'A'..'Z', 'a'..'z', 0..9 );

# removed these from default set, 4/2006 (DC)
# qw( ! @ $ % ^ & * ? ) );

  # Thank you perl cookbook... 
  my $rstring = join( "", @chars[ map {rand @chars} ( 1..$args{num_chars} ) ]);
  
  return( $rstring );

}


#+
# Routine returns name of subroutine from which it was called.  if an argument
# is also sent, will return fully qualified namespace name 
# (e.g. SBEAMS::Foo::my_subroutine)
#-
sub get_subname {
  my $self = shift;
  my $package = shift || 0;
  my @call = caller(1);
  $call[3] =~ s/.*:+([^\:]+)$/$1/ unless $package;
  return $call[3];
}

#+
# Utility routine to dump out a hash in key => value formatt
#-
sub dump_hashref {
  my $this = shift;
  my %args = @_;
  return unless $args{href};
  my $mode = $args{mode} || 'text';
  my $eol = ( $mode =~ /HTML/i ) ? "<BR>\n" : "\n";
  my $dumpstr = '';
  for my $k ( keys( %{$args{href}} ) ) {
    my $val = $args{href}->{$_} || '';
    $dumpstr .= "$k => $val" . $eol;
  }
  return $dumpstr;
}

#+
# Utility routine to dump out an array ref
#-
sub dump_arrayref {
  my $this = shift;
  my %args = @_;
  return unless $args{aref};
  my $mode = $args{mode} || 'text';
  my $eol = ( $mode =~ /HTML/i ) ? "<BR>\n" : "\n";
  my $dumpstr = '';
  for my $line ( @{$args{aref}} ) {
    $dumpstr .= $line . $eol;
  }
  return $dumpstr;
}

sub set_page_message {
  my $this = shift;
  my %args = @_;
  return unless $args{msg};

  my $type = ( $args{type} && $args{type} eq 'Error' ) ? 'Error' : 'Info';

  $this->setSessionAttribute( key => '_SBEAMS_message', 
                            value => $type . '::' . $args{msg} );
  
}

sub get_page_message {
  my $this = shift;
  my %args = @_;

  my %color = ( Error => $args{error_color} || 'red',
                Info => $args{info_color} || 'green' );

  my $sbeams_msg = $this->getSessionAttribute( key => '_SBEAMS_message' );
  return '' unless $sbeams_msg;
  my ( $mode, $msg ) = $sbeams_msg =~ /^(\w+)::(.+)$/;

  # In case the format was goofy:
  $mode ||= 'info';
  $msg ||= $sbeams_msg;

  # Clean up
  $this->deleteSessionAttribute( key => '_SBEAMS_message' );
  if ( $args{no_color} ) {
    return $msg; 
  } else {
    $msg = "<FONT COLOR=$color{$mode}>$msg</FONT>"; 
    $msg = "<I>$msg</I>" unless $args{no_italics};
  }
  return $msg;
}

sub get_notice {
  my $this = shift;

  # Default to Core
  my $module = shift || 'Core';
  
  my $file = $PHYSICAL_BASE_DIR . '/lib/conf/' . $module . '/notice.txt';
  open( NOTICE, $file ) || return '';
  
  undef local $/;
  my $msg = <NOTICE>;

  return $msg;
}

sub truncateString {
  my $self = shift;
  my %args = @_;
  return undef unless $args{string};
  my $string = $args{string};
  my $len = $args{len} || 35;

  # Trim trailing space
  chomp( $string );
  $string =~ s/\s*$//;

  if ( $len < length($string) ) {
    $string = substr( $string, 0, $len - 3 ) . '...'; 
  }
  return $string;
}

sub getRomanNumeral {
  my $self = shift;
  my %args = @_;
  return undef unless $args{number};
  unless ( $self->{_rnumerals} ) {
    my %num = ( 1  => 'I',
                2  => 'II',
                3  => 'III',
                4  => 'IV',
                5  => 'V',
                6  => 'VI',
                7  => 'VII',
                8  => 'VIII',
                9  => 'IX',
                10 => 'X',
                11 => 'XI',
                12 => 'XII',
                13 => 'XIII',
                14 => 'XIV',
                15 => 'XV',
                16 => 'XVI',
                17 => 'XVII',
                18 => 'XVIII',
                19 => 'XIX',
                20 => 'XX',
                21 => 'XXI',
                22 => 'XXII',
                23 => 'XXIII',
                24 => 'XXIV',
                25 => 'XXV',
                26 => 'XXVI',
                27 => 'XXVII' );
    $self->{_rnumerals} = \%num;
  }
  return $self->{_rnumerals}->{$args{number}};
}


sub getGaggleXML {
  my $self = shift;
  my %args = @_;
  $args{type} ||= 'direct';
  $args{name} ||= 'generic';
  $args{organism} ||= 'unknown';
  my $xml;

  if ( $args{start} ) {
    $xml =<<"    END";
    <STYLE TYPE="text/css" media="screen">
    div.visible {
    display: inline;
    white-space: nowrap;         
    }
    div.hidden {
    display: none;
    }
    </STYLE>
    <DIV name=gaggle_xml class=hidden>
    <gaggleData version="0.1">
    END
  }

  if ( $args{object} =~ /^namelist$/i ) {
    return unless @{$args{data}};
    my $items = join( "\t", @{$args{data}} );
    $xml .=<<"    END";
    <namelist type='$args{type}' name='$args{name}' species='$args{organism}'>  
    $items
    </namelist>
    END
  } else {
    $log->error( "Unknown object type" );
  }

#  $xml .= "</gaggleData>\n  -->" if $args{end};
  $xml .= "</gaggleData>\n </DIV>" if $args{end};
  return $xml;
}


sub get_admin_mailto {
  my $self = shift;
  my $linktext = shift;

  my ( $email ) = $DBADMIN =~ /(\w+@\w+\.\w+[\w\.]*)/;
  $log->debug( "Email $email extracted from DBADMIN setting: $DBADMIN" );
  return ( $email ) ? "<A HREF=mailto:$email>$linktext</A>" : '';
}



1;


###############################################################################
###############################################################################
###############################################################################

=head1 StatUtils (originally SBEAMS::Connection::Utilities)

A part of the SBEAMS module containing generic utility methods not logically
placed in one of the standard pm's.

=head2 SYNOPSIS

See SBEAMS::Connection and individual methods for usage synopsis.

=head2 DESCRIPTION

This part of the SBEAMS module containing generic utility methods not logically
placed in one of the standard pm's.

=head2 METHODS

=over

=item * B<histogram( see key value input parameters below )>

    Given an array of numbers, calculate a histogram and various other
    statistcs for the array.  All results are returned numerically; no
    image or plot of the histogram is created.

    INPUT PARAMETERS:

      data_array_ref => Required array reference containing the input data
      for which a histogram and statistics are calculated.

      min => Minimum edge of the first bin of the histogram.  If none
      is supplied, a suitable one is chosen.

      max => Maximum edge of the last bin of the histogram?  If none
      is supplied, a suitable one is chosen.

      bin_size => Width of the bins for the histogram.  If none
      is supplied, a suitable one is chosen based on the number of
      data points in the input array; the more data points there are,
      the finer the bin size.


    OUTPUT:

      A hash reference containing all resulting data from the calculation.
      The hash keys are as follows:

        result = SUCCESS or FAILED

        xaxis = Array ref of lower edge of the output histogram ordinate values

        xaxis_disp = Same as xaxis but with minor tick bin labels
        blanked out for use by a histogram display program

        yaxis = Array ref of the number of original array values that
        fall into each bin, corresponding to xaxis

        cdf = Array ref containing the Cumulative Distribution
        Function (CDF) values corresponding to xaxis.  This is
        essentially the count of all data array elements in this bin and
        below.

        n_bins = Scalar number of bins in the histogram

        bin_size = Size of the bins in the histogram, either user
        specified or determined automatcally

        histogram_min = Minimum edge of the first bin of the histogram

        histogram_max = Maximum edge of the last bin of the histogram?

        minimum = Minimum numeric value in the input data array

        maximum = Maximum numeric value in the input data array

        total = Sum of all values in the input data array

        n_elements = Number of elements in the input data array

        mean = Mean (average) value of the elements in the input data array

        stdev = Standard deviation of the values in the input data array

        median = Median value in the input data array (the smallest
        50% of values have value this or less)

        quartile1 = First quartile value of the input data array (the smallest
        25% of values have value this or less)

        quartile3 = Third quartile value of the input data array (the smallest
        75% of values have value this or less)

        SIQR = Semi-interquartile Range (SIRQ) is half of the difference between
        quartile3 and quartile1.  SIQR is analogous to the standard deviation
        but relatively insensitive to outliers (like median is to mean).

        ordered_statistics = Array ref a the list of the scalar
        statistics returned in the hash, in a vaguely logical order,
        suitable for use for dumping out the all returned statistics.



=item * B<find_nearest( $map_array_ref, $value )>

    This internal method is used by histogram to determine round min, max,
    bin_size numbers.  It is a pretty icky function that could stand some
    rewriting to work more generically and better.

    See the histogram() function for usage example

    INPUT PARAMETERS:

      $map_array_ref: Array ref of ordered list of "round" numbers.  An example
      may be [0.25,0.5,1,2,5,10,15,20,25,50,75,100]

      $value: Scalar value which is to be rounded with the supplied array

    OUTPUT:

      The largest value in $map_array_ref that is smaller than $value or the
      end value if $value is out of bounds.


=back

=head2 BUGS

Please send bug reports to the author

=head2 AUTHOR

Eric Deutsch <edeutsch@systemsbiology.org>

=head2 SEE ALSO

SBEAMS::Connection

=cut
