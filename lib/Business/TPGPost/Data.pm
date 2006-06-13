package Business::TPGPost::Data;
use strict;
use base 'Exporter';
use vars qw($VERSION @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Carp;
use YAML;

$VERSION   = 0.04;
@EXPORT    = qw();
@EXPORT_OK = qw(zones table);
%EXPORT_TAGS = ("ALL" => [@EXPORT_OK]);

sub zones {
   my %zones = (
      0 => [ qw(NL) ],
      1 => [ qw(BE LU) ],
      2 => [ qw(DK DE FR MC IT AT ES GB SE) ],
      3 => [ qw(EE FI HU IE LV LT PL PT SI SK CZ) ],
      4 => [ qw(AL AD BA BG CY FO GI GR GL IS HR LI MK MT MD NO UA RO SM CS 
                TR VA RU CH) ],
   );
   my %z;
   foreach my $key (keys %zones) {
      foreach my $val (@{$zones{$key}}) {
         $z{$val} = $key;
      }
   }
   return \%z;
}

sub table {
my $table = Load(<<'...');
---
# Netherlands
netherlands:
  # Letters (brievenbuspost)
  small:
    stamp:
      '0,19': 0.39
      '20,49': 0.78
      '50,99': 1.17
      '100,249': 1.56
      '250,499': 2.25
      '500,1999': 3.00
      '2000,3000': 3.00
    machine:
      '0,19': 0.38
      '20,49': 0.68
      '50,99': 0.98
      '100,249': 1.28
      '250,499': 1.88
      '500,2000': 2.48
  # Parcels (paketten)
  large:
    stamp: 
      '0,10000': 6.20
    machine:
      '0,10000': 6.20
  # Register (aangetekend)
  register:
    stamp: 
      '0,1000': 6.45
    machine:
      '0,1000': 6.25
# Outside of the Netherlands
world:
  basic:
    # Within Europe (zone 1..4)
    europe:
      # Letters (brievenbuspost)
      small:
        priority:
          '0,19': 0.69
          '20,49': 1.38
          '50,99': 2.07
          '100,249': 2.76
          '250,499': 5.15
          '500,999': 8.50
          '1000,2000': 10.25
        standard: 
          '0,19': 0.65
          '20,49': 1.12
          '50,99': 1.65
          '100,249': 2.25
          '250,499': 3.70
          '500,999': 6.00
          '1000,2000': 7.50
      # Internationaal Pakket Basis
      large:
        priority:
          '0,249': 3.40
          '250,499': 5.50
          '500,2000': 10.60
        standard: 
          '0,249': 2.85
          '250,499': 4.25
          '500,2000': 7.70
    # Outside Europe
    world: 
      # Letters (brievenbuspost)
      small:
        priority:
          '0,19': 0.85
          '20,49': 1.70
          '50,99': 2.55
          '100,249': 5.15
          '250,499': 10.20
          '500,999': 19.30
          '1000,2000': 20.25
        standard: 
          '0,19': 0.80
          '20,49': 1.30
          '50,99': 1.84
          '100,249': 3.30
          '250,499': 6.25
          '500,999': 9.10
          '1000,2000': 11.50
      # Internationaal Pakket Basis
      large:
        priority:
          '0,249': 5.60
          '250,499': 11.00
          '500,2000': 20.75
        standard: 
          '0,249': 3.85
          '250,499': 7.40
          '500,2000': 11.75
  # Internationaal Pakket Plus (Track&Trace)
  plus: 
    zone:
      1: 
        '0,1999': 12.00
        '2000,4999': 16.75
        '5000,9999': 21.00
        '10000,19999': 28.00
        '20000,30000': 41.00
      2: 
        '0,1999': 12.75
        '2000,4999': 18.50
        '5000,9999': 24.00
        '10000,19999': 32.25
        '20000,30000': 45.25
      3: 
        '0,1999': 17.00
        '2000,4999': 22.00
        '5000,9999': 27.75
        '10000,19999': 36.00
        '20000,30000': 48.50
      4: 
        '0,1999': 17.25
        '2000,4999': 22.25
        '5000,9999': 28.00
        '10000,20000': 37.50
      # Outside of Europe, Priority/Economy allowed
      5: 
        priority: 
          '0,1999': 22.75
          '2000,4999': 30.25
          '5000,9999': 52.00
          '10000,20000': 98.00
        economy: 
          '0,1999': 16.75 
          '2000,4999': 22.50
          '5000,9999': 34.00
          '10000,20000': 52.25
  # Register ("aangetekend")
  register:
    europe:
      '0,99': 6.95
      '100,249': 6.95
      '250,499': 8.10
      '500,999': 11.00
      '1000,2000': 11.75
    world:
      '0,99': 7.25
      '100,249': 8.75
      '250,499': 13.90
      '500,999': 22.05
      '1000,2000': 22.25
...
   return $table;
}

#################### main pod documentation begin ###################
=head1 NAME

Business::TPGPost::Data - Shipping cost data for Business::TPGPost

=head1 DESCRIPTION

Data module for Business::TPGPost containing shipping cost
information, country zones etc.

Nothing to see here, the show is over, move along please

=head1 AUTHOR

M. Blom, 
E<lt>blom@cpan.orgE<gt>, 
L<http://menno.b10m.net/perl/>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=head1 SEE ALSO

L<Business::TPGPost>, 
L<http://www.tpgpost.nl/>

=cut

1;
