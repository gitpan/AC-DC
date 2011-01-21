# -*- perl -*-

# Copyright (c) 2009 by dCopy
# Author: Jeff Weisberg
# Created: 2009-Dec-22 11:14 (EST)
# Function: time_t <=> iso8601
#
# $Id: ISOTime.pm,v 1.4 2010/10/30 20:27:53 jaw Exp $

package AC::ISOTime;
use AC::Import;
use Time::Local;
use POSIX;
use strict;
our @EXPORT = qw(isotime timeiso);

sub isotime {
    my $t = shift;
    my $precision = shift;

    return unless $t;
    $precision ||= 6;
    my $f = sprintf("%.${precision}f", $t - int($t));
    $f =~ s/^0//;
    $f = '' if $f =~ /\.0+$/;
    return strftime( '%Y%m%dT%H%M%S', gmtime($t)) . $f . 'Z';

}

sub timeiso {
    my $iso = shift;

    return unless $iso;
    $iso =~ s/\s//g;

    my($date, $time) = split /T/, $iso;
    $time ||= '00:00:00Z';
    my($year, $mon, $day) = $date =~ /(\d{4})-?(\d{2})-?(\d{2})?/;
    $day ||= 1;	# day is optional

    ($time, my $tz) = $time =~ /([^-+Z]+)(.*)/;
    my($hr, $min, $sec) = $time =~ /(\d{2}):?(\d{2}):?(.*)/;
    ($sec, my $frac) = $sec =~ /(\d+)(\.\d+)?/;

    my($tzsign, $tzhr, $tzmin) = $tz =~ /(-?)(\d{2}):?(\d{2})?/;
    $tzmin ||= 0;
    $tzhr = $tzmin = 0 if $tz eq 'Z';

    my $t = timegm($sec,$min,$hr, $day, $mon-1, $year);
    $t += $frac;
    $t -= (3600 * $tzhr + 60 * $tzmin) * ($tzsign ? -1 : 1);

    return $t;
}

1;
