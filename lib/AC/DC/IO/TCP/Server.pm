# -*- perl -*-

# Copyright (c) 2009 AdCopy
# Author: Jeff Weisberg
# Created: 2009-Mar-27 15:01 (EDT)
# Function: tcp server
#
# $Id: Server.pm,v 1.3 2010/09/07 15:31:37 jaw Exp $

package AC::DC::IO::TCP::Server;
use AC::DC::Debug 'tcp';
use Socket;
use strict;

our @ISA = 'AC::DC::IO::TCP';

sub new {
    my $class = shift;
    my $port  = shift;
    my $nextc = shift;

    my $me = bless {
        info	  => "server tcp/$port",
        nextclass => $nextc,
    }, $class;

    my $fd;

    socket($fd, PF_INET, SOCK_STREAM, 0);
    setsockopt($fd, SOL_SOCKET, SO_REUSEADDR, 1);
    my $i = bind($fd, sockaddr_in($port, INADDR_ANY));

    fatal( "cannot bind to tcp/$port: $!" ) unless $i;

    listen( $fd, 128 );
    $me->init($fd);
    $me->wantread(1);

    verbose("server started on tcp/$port");

    return $me;
}

sub _readable {
    my $me = shift;

    my $newfd;
    my $i = accept( $newfd, $me->{fd} );
    return verbose("tcp accept failed: $!" ) unless $i;

    my $ip = inet_ntoa( (sockaddr_in(getpeername($newfd)))[1] );
    debug( "new tcp connection from $ip" );

    my $next = $me->{nextclass};
    $next->new( $newfd, $ip );
}


1;
