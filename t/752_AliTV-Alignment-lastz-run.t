use strict;
use warnings;

use Test::More;
use Test::Exception;
use Data::Dumper;
use Bio::SeqIO;

my $input = Bio::SeqIO->new(-file => "data/vectors/vectors.fasta");
my @seq_set = ();

while (my $seq = $input->next_seq())
{
   push(@seq_set, $seq);
}

@seq_set = sort {$a->id() cmp $b->id()} (@seq_set);

my @output = ();

my $expected = [
    [84.29,   82,   4296, "M13mp18",           1832, 1913,  1, "M13mp18",           2333, 2402,  1],
    [65.71,  633,   4389, "M13mp18",           1832, 2385,  1, "M13mp18",           1847, 2412,  1],
    [96.55,   58,   5293, "M13mp18",           1832, 1889,  1, "M13mp18",           2318, 2375,  1],
    [89.83,   59,   4878, "M13mp18",           1836, 1894,  1, "M13mp18",           2307, 2365,  1],
    [67.75,  319,   6910, "M13mp18",           2281, 2576,  1, "M13mp18",           2293, 2591,  1],
    [70.60, 1287,  29365, "M13mp18",           6001, 7249,  1, "pUC19",                1, 1130,  1],
    [85.38, 1045,  36177, "M13mp18",           6001, 6787, -1, "pBluescribeKSPlus",    1, 1031,  1],
    [93.82,  458,  34936, "M13mp18",           5487, 5923, -1, "pBluescribeKSPlus",    1,  458,  1],
    [77.90,  289,   4040, "M13mp18",           6230, 6410, -1, "pUC19",                1,  289,  1],
    [99.74, 1945, 185016, "pBR322",            2340, 4284,  1, "pBluescribeKSPlus", 1020, 2964,  1],
    [73.91,  761,  17020, "pBR322",            2069, 2736, -1, "pUC19",                1,  687,  1],
    [99.65, 2010, 190180, "pBR322",            2352, 4361, -1, "pUC19",              678, 2686,  1],
    [78.77, 1091,  31683, "pBluescribeKSPlus",    1, 1031, -1, "pUC19",                1,  903,  1],
    [99.95, 1933, 184340, "pBluescribeKSPlus", 1032, 2964, -1, "pUC19",              754, 2686,  1],
   ];

BEGIN { use_ok('AliTV::Alignment::lastz') }

can_ok( 'AliTV::Alignment::lastz', qw(run) );

my $obj = new_ok('AliTV::Alignment::lastz' => [-parameters => [qw(--format=MAF --noytrim --gapped --strand=both --ambiguous=iupac)], -callback => sub { push(@output,  \@_); }] );

throws_ok { $obj->run() } qr/You need to specify a parameter/, 'Exception raised if no parameters are provided for alignment run method';
throws_ok { $obj->run(1) } qr/You need to specify an array reference/, 'Exception raised if no array reference is provided for alignment run method';

$obj->run(\@seq_set);

is(@{$obj->{_alignments}}+0, @{$expected}+0, 'Number of obtained alignment is correct');

foreach my $aln (@{$obj->{_alignments}})
{
	my @fields = (sprintf("%.2f", $aln->{identity})+0, $aln->{len}, $aln->{score}, map { $_->{id}, $_->{start}, $_->{end}, $_->{strand} } (@{$aln->{seqs}}));
	push(@output, \@fields);
}

# sort expected and output
@output = sort sort_output_expected (@output);
@{$expected} = sort sort_output_expected (@{$expected});

is_deeply(\@output, $expected, 'Obtained alignments and expected alignments are equal');

done_testing;

sub sort_output_expected
{
	return join("-", @{$a}) cmp join("-", @{$b});
}
