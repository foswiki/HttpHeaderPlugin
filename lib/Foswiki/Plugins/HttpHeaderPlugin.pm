# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# See License details at the end of this file.
#
# (c) 2010 Oliver Krueger, oliver@wiki-one.net

=pod

---+ package Foswiki::Plugins::HttpHeaderPlugin

When developing a plugin it is important to remember that
Foswiki is tolerant of plugins that do not compile. In this case,
the failure will be silent but the plugin will not be available.
See %SYSTEMWEB%.InstalledPlugins for error messages.

=cut

package Foswiki::Plugins::HttpHeaderPlugin;

use strict;
use warnings;

use Foswiki::Func    ();    # The plugins API
use Foswiki::Plugins ();    # For the API version

use constant DEBUG => 1;    # toggle me

our $VERSION           = '$Rev: 8536 $';
our $RELEASE           = '1.0';
our $SHORTDESCRIPTION  = 'Add additional lines to the HTTP header of a page.';
our $NO_PREFS_IN_TOPIC = 1;
our $additionalHeaders;
our $inUse = 0;

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 2.0 ) {
        Foswiki::Func::writeWarning( 'Version mismatch between ',
            __PACKAGE__, ' and Plugins.pm' );
        return 0;
    }

    Foswiki::Func::registerTagHandler( 'ADDHTTPHEADER', \&_ADDHTTPHEADER );

    # Plugin correctly initialized
    return 1;
}

sub _ADDHTTPHEADER {
    my ( $session, $params, $theTopic, $theWeb ) = @_;

    my $header_name  = $params->{name}  || $params->{_DEFAULT};
    my $header_value = $params->{value} || '';

    if ( defined($header_name) && $header_name ne '' ) {

        $header_name =~ s/[\(\)<>@,;:\\\"\/\[\]\?=\{\}\s\t]//g;

        # SMELL: maybe strip some more non-ascii chars
        # SMELL: check the value field-content, too!
        $additionalHeaders->{$header_name} = $header_value;
        $inUse = 1;
    }

    Foswiki::Func::writeDebug(
        "HttpHeaderPlugin ADDHTTPHEADER name:$header_name value:$header_value")
      if DEBUG;

    return "";
}

sub modifyHeaderHandler {
    my ( $headers, $query ) = @_;

    if ( $inUse && Foswiki::Func::getContext()->{view} ) {
        foreach my $header_name ( keys %$additionalHeaders ) {
            Foswiki::Func::writeDebug(
                "HttpHeaderPlugin modifyHeaderHandler name:$header_name value:"
                  . $additionalHeaders->{$header_name} )
              if DEBUG;
            $headers->{$header_name} = $additionalHeaders->{$header_name};
        }
    }

    return "";
}

1;

__END__
Foswiki - The Free and Open Source Wiki, http://foswiki.org/

Copyright (C) 2008-2010 Foswiki Contributors. Foswiki Contributors
are listed in the AUTHORS file in the root of this distribution.
NOTE: Please extend that file, not this notice.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version. For
more details read LICENSE in the root of this distribution.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

As per the GPL, removal of this notice is prohibited.
