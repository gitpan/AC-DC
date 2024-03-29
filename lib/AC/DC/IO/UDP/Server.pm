#!/usr/local/bin/perl
# -*- perl -*-

# Copyright (c) 2010 by Jeff Weisberg
# Author: Jeff Weisberg <jaw @ tcp4me.com>
# Created: 2010-Nov-22 13:21 (EST)
# Function: 
#
# $Id: Server.pm,v 1.1 2010/12/02 18:16:21 jaw Exp $

package AC::DC::IO::UDP::Server;
use AC::DC::Debug 'udp';
use Socket;
use strict;

our @ISA = 'AC::DC::IO::UDP';

my $BUFSIZ = 65536;

sub new {
    my $class = shift;
    my $port  = shift;
    my $nextc = shift;

    my $me = bless {
        info	  => "server udp/$port",
        nextclass => $nextc,
    }, $class;

    my $fd;

    socket($fd, PF_INET, SOCK_DGRAM, 0);
    setsockopt($fd, SOL_SOCKET, SO_REUSEADDR, 1);
    my $i = bind($fd, sockaddr_in($port, INADDR_ANY));

    fatal( "cannot bind to udp/$port: $!" ) unless $i;

    listen( $fd, 128 );
    $me->init($fd);
    $me->wantread(1);

    verbose("server started on udp/$port");

    return $me;
}

sub _readable {
    my $me = shift;

    debug( "new udp connection" );

    my $next = $me->{nextclass};
    $next->new( $me );
}


1;
