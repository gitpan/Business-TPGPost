package Business::TPGPost;

use strict;
use Business::TPGPost::Data qw/:ALL/;
use Carp;
use List::Util qw/reduce/;

our $VERSION     = '0.04';
our $ERROR       = undef;

sub new {
   my ($class, %parameters) = @_;
   my $self = bless ({}, ref ($class) || $class);
      $self->{_zone} = undef;
      $self->{_weight} = undef;
      $self->{_large} = 0;
      $self->{_priority} = 0;
      $self->{_tracktrace} = 0;
      $self->{_register} = 0;
      $self->{_receipt} = 0;
      $self->{_machine} = 0;
   return $self;
}

sub country {
   my ($self, $cc) = @_;
   
   if($cc) {
      my $zones = zones();
      $self->{_zone} = defined $zones->{$cc} ? $zones->{$cc} : '5';
   } 
   return $self->{_zone};
}

sub weight {
   my ($self, $weight) = @_;

   $self->{_weight} = $weight if($weight);
   return $self->{_weight};
}

sub large {
   my ($self, $large) = @_;

   $self->{_large} = $large if($large);
   return $self->{_large};
}

sub priority {
   my ($self, $priority) = @_;

   $self->{_priority} = 1 if($priority);
   return $self->{_priority};
}

sub tracktrace {
   my ($self, $tracktrace) = @_;

   $self->{_tracktrace} = $tracktrace if($tracktrace);
   return $self->{_tracktrace};
}

sub register {
   my ($self, $register) = @_;

   $self->{_register} = $register if($register);
   return $self->{_register};
}

sub receipt {
   my ($self, $receipt) = @_;

   $self->{_receipt} = $receipt if($receipt);
   return $self->{_receipt};
}

sub machine {
   my ($self, $machine) = @_;

   $self->{_machine} = $machine if($machine);
   return $self->{_machine};

}

sub calculate {
   my ($self, %opt) = @_;
   $self->country($opt{country}) if($opt{country});
   $self->weight($opt{weight}) if($opt{weight});
   $self->large(1) if($opt{large});
   $self->priority(1) if($opt{priority});
   $self->tracktrace(1) if($opt{tracktrace});
   $self->register(1) if($opt{register});
   $self->receipt(1) if($opt{receipt});
   $self->machine(1) if($opt{machine});
   $self->{_cost} = undef;

   croak "Not enough information!" 
      unless(defined $self->_zone && $self->weight);

   # > 2000 grams automatically means 'tracktrace'
   $self->tracktrace(1) if($self->weight > 2000);

   # Zone 1..4 (with tracktrace) automagically means 'priority'
   $self->priority(1) if($self->country < 5 && $self->tracktrace);

   # Registered (aangetekend) automagically means 'priority'
   $self->priority(1) if($self->register);

   # Fetch the interesting table 
   my $ref = _pointer_to_element(table(), $self->_generate_path);
   my $table = $$ref;

   my $highest = 0;
   foreach my $key (keys %{$table}) {
      my ($lo, $hi) = split ',', $key;
      $highest = $hi if($hi > $highest);
      if($self->{_weight} >= $lo && $self->{_weight} <= $hi) {
         $self->{_cost} = $table->{$key};
         last;
      }
   }
   $ERROR = $self->{_weight} - $highest. " grams too heavy (max: $highest gr.)"
      if($highest < $self->{_weight});

   ### Receipt ("Bericht van ontvangst")
   if($self->register && $self->receipt) {
      if($self->_zone) {                # World
         $self->{_cost} += 1.40;
      } else {                          # Netherlands
         $self->{_cost} += 1.15 unless($self->machine);
      }
   }

   return ($self->{_cost}) ? sprintf("%0.2f", $self->{_cost}) : undef;
}

sub _zone {
   my $self = shift;
   return $self->{_zone};
}

sub _generate_path {
   my $self = shift;

   my @p;

   if($self->_zone) { 
      push @p, 'world';                         # world
      if($self->register) {
         push @p, 'register',                   # w/register
              ($self->_zone < 5)                # w/register/(europe|world)
                     ? 'europe'
                     : 'world';
      } elsif($self->tracktrace) {
         push @p, 'plus', 'zone', $self->_zone; # w/plus/zone/[1..5]
         push @p, ($self->priority == 1)        # w/plus/zone/5/(prio|eco)
                  ? 'priority' 
                  : 'economy' if($self->_zone == 5);
      } else {
         push @p, 
            'basic',                            # w/basic
            ($self->_zone < 5)                  # w/basic/(europe|world)
                   ? 'europe'
                   : 'world',
            ($self->large == 1)                 # w/basic/(e|w)/(large|small)
                   ? 'large'
                   : 'small',
            ($self->priority == 1)              # w/basic/(e|w)/(l|s)/(p|s)
                   ? 'priority'
                   : 'standard';
      }
   } else {
      push @p, 'netherlands';                   # netherlands
      if($self->register) {
         push @p, 'register';                   #
      } else {
         push @p, ($self->large == 1)           # n/(large|small)
                   ? 'large'
                   : 'small';
      } 
      push @p, ($self->machine == 1) ? 'machine' : 'stamp';
   }
   return @p;
}

sub _pointer_to_element {       # Thanks 'merlyn'!
   require List::Util;
   return List::Util::reduce(sub { \($$a->{$b}) }, \shift, @_);
}

#################### main pod documentation begin ###################

=head1 NAME

Business::TPGPost - Calculate Dutch (TPG Post) shipping costs

=head1 SYNOPSIS

  use Business::TPGPost;

  my $tpg = Business::TPGPost->new();
     $tpg->country('DE');
     $tpg->weight('534');
     $tpg->large(1);
     $tpg->priority(1);
     $tpg->tracktrace(1);
     $tpg->register(1);
     $tpg->receipt(1);

  my $costs = $tpg->calculate or die $Business::TPGPost::ERROR;
  

or

  use Business::TPGPost;

  my $tpg = Business::TPGPost->new();
  my $costs = $tpg->calculate(
                  country    =>'DE', 
                  weight     => 534, 
                  large      => 1, 
                  tracktrace => 1,
                  register   => 1,
                  receipt    => 1
              ) or die $Business::TPGPost::ERROR;

=head1 DESCRIPTION

This module calculates the shipping costs for the Dutch TPG Post,
based on country, weight and priority shipping (or not), etc.

The shipping cost information is based on 'Tarieven juni 2006'.

It returns the shipping costs in euro or undef (which usually means
the parcel is heavier than the maximum allowed weight; check
C<$Business::TPGPost::ERROR>).

=head2 METHODS

The following methods can be used

=head3 new

C<new> creates a new C<Business::TPGPost> object. No more, no less.

=head3 country

Sets the country (ISO 3166, 2-letter country code) and returns the
zone number used by TPG Post (or 0 for The Netherlands (NL)).

This value is mandatory for the calculations.

=head3 weight

Sets and/or returns the weight of the parcel in question in grams.

This value is mandatory for the calculations.

=head3 large

Sets and/or returns the value of this option. Defaults to 0 (meaning:
the package will fit through the mail slot).

=head3 priority

Sets and/or returns the value of this option. Defaults to 0 (meaning:
standard class (or economy class, where standard is not available)).

=head3 tracktrace

Sets and/or returns the value of this options. Defaults to 0 (meaning:
no track & trace feature wanted). When a parcel destined for abroad
weighs over 2 kilograms, default is 1, while over 2kg it's not even
optional anymore.

=head3 register

Sets and/or returns the value of this options. Defaults to 0 (meaning:
parcel is not registered (Dutch: aangetekend)).

=head3 receipt

Sets and/or returns the value of this options. Defaults to 0 (meaning:
receipt not requested for registered parcels).

=head3 machine

Sets and/or returns the value of this options. Defaults to 0 (meaning:
stamps will be used, not the machine (Dutch: frankeermachine)).

Only interesting for destinies within NL. Note that "Pakketzegel AVP"
and "Easystamp" should also use this option.

=head3 calculate

Method to calculate the actual shipping cost based on the input (see
methods above). These options can also be passed straight in to this method
(see L<SYNOPSIS>).

Two settings are mandatory: country and weight. The rest are given a
default value that will be used unless told otherwise.

Returns the shipping costs in euro, or undef (see $Business::TPGPost::ERROR
in that case).

=head1 BUGS

Please do report bugs/patches to 
L<http://rt.cpan.org/Public/Dist/Display.html?Name=Business-TPGPost>

=head1 CAVEAT

The Dutch postal agency (TPG Post) uses many, many, many various ways
for you to ship your parcels. Some of them are included in this module,
but a lot of them not (maybe in the future? Feel free to patch ;-)

This module handles the following shipping ways (page numbers refer to the 
TPG Post booklet (sorry, all in Dutch)):

=head2 Nederland

=head3 Brievenbuspost

=over 4

=item Brieven, drukwerken, kaarten, buspakjes

Pagina 6

=item Aangetekend (tot 1kg)

Pagina 8, incl. toeslag handtekening retour

=back

=head3 Paketten

=over 4

=item Basis Pakket

Pagina 10

=back

=head2 Buitenland

=head3 Brievenbuspost

=over 4

=item Brieven, drukwerken, kaarten, buspakjes

Pagina 36

=back

=head3 Pakketten

=over 4

=item Internationaal Pakket Basis

Pagina 37

=item Internationaal Pakket Plus (EU)

Pagina 38

=item Internationaal Pakket Plus (buiten EU)

Pagina 38

=back

=head3 Extra Zeker

=over 4

=item Aangetekend

Pagina 40

=item Bericht van ontvangst

Pagina 40

=back

These should be the most commom methods of shipment.

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

L<http://www.tpgpost.nl/>, 
L<http://www.iso.org/iso/en/prods-services/iso3166ma/index.html>

=cut

#################### main pod documentation end ###################

1;
