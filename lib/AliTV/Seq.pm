package AliTV::Seq;

use base AliTV::Base;

use Bio::Seq;
use Bio::SeqIO;

sub file
{
    my $self = shift;

    $self->SUPER::file(@_);

    my $fileio  = Bio::SeqIO->new(-file => $self->{file});

    $self->{_seq_obj} = $fileio->next_seq();
}

sub id
{
    my $self = shift;

    return $self->_Map2BioSeq("id", @_);
}

sub seq
{
    my $self = shift;

    return $self->_Map2BioSeq("seq", @_);
}

sub seqlength
{
    my $self = shift;

    # there is no setter implemented, therefore @_ does not need to be
    # provided
    return $self->_Map2BioSeq("length");
}

sub _Map2BioSeq
{
    my $self = shift;
    my $method = shift;

    unless (exists $self->{_seq_obj})
    {
	$self->_logdie('The sequence storage attribute does not exist');
    }

    unless (ref($self->{_seq_obj}) eq "Bio::Seq")
    {
	$self->_logdie('The sequence storage attribute is not a Bio::Seq object');
    }

    return $self->{_seq_obj}->$method(@_);
}

sub _initialize
{
    my $self = shift;

    # we want to have an empty Bio::Seq object to store everything
    # required
    $self->{_seq_obj} = Bio::Seq->new();

}

sub prep_json
{
    my $self = shift;

    my $output = {
	genome_id => $self->id(),
	length => $self->seqlength(),
	seq => $self->seq(),
    };

    return $output;
}

sub from_bioseq
{
    my $self = shift;
    my $seq_obj = shift;

    # test if it is a Bio::Seq object
    unless (ref($seq_obj) eq "Bio::Seq")
    {
	$self->_logdie('The parameter does not seem to be a Bio::Seq object');
    }

    $self->{_seq_obj} = $seq_obj->clone();
}

1;

=head1 AliTV::Seq

AliTV::Seq - The AliTV class representing a sequence object

=head1 SYNOPSIS

  use AliTV::Seq;

  my $seq_obj = AliTV::Seq->new(-file => 'input.fasta');
  print $seq_obj->id(), " ", $seq_obj->seqlength(), "\n";

=head1 DESCRIPTION

This is the AliTV class to represent a sequence. The sequence can be
loaded from a file and some basic attributes of the sequences can be
accessed:

=over 4

=item Sequence identifier

=item Sequence length

=item Sequence 

=back

=head1 METHODS

=head1 AUTHOR

Frank Foerster, E<lt>foersterfrank@gmx.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Frank Foerster

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10 or,
at your option, any later version of Perl 5 you may have available.


=cut
