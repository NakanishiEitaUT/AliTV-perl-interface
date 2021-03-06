use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Genome') };

can_ok('AliTV::Genome', qw(_get_seq_ids _get_uniq_seq_ids _get_orig_seq_ids));

my %params = (
   name => 'Test genome',
   sequence_files => ['data/fasta-input.fasta', 'data/fasta-input2.fasta']
);

my $obj = new_ok('AliTV::Genome' => [%params]);

# define the expected sets for orig and uniq dataset
my @expected_orig = ("Test", "Test2", "Test3");
my @expected_uniq = ("TestA", "TestB", "TestC");

# test if each orig name is returned in case of no unique sequence name initialization
my $counter = 0;
foreach my $orig (@expected_orig)
{
   is($obj->_orig_id_to_uniq_id($orig), $orig, sprintf("Original sequence name number %d was returned for non-initialized unique names", ++$counter));
}

# a non existing original ID should cause an exception
throws_ok { $obj->_orig_id_to_uniq_id('non_existing_orig_id'); } qr/Original ID 'non_existing_orig_id' was not found in genome named 'Test genome'!/, 'Exception caused by a non existing original ID';

# test if non existing uniq names lead to an exception
$counter = 0;
my $expected_die_msg = qr/It seems that no unique ids have been generated./;
foreach my $uniq (@expected_uniq)
{
   throws_ok { $obj->_uniq_id_to_orig_id($uniq); } $expected_die_msg, sprintf("Exception caused by unique id %d as expected", ++$counter);
}

### generate unique IDs
$obj->set_uniq_seq_names("TestA" => "Test", "TestB" => "Test2", "TestC" => "Test3");

# test if each original ID is converted into correct unique ID after initialization of unique IDs
foreach my $idx (1..@expected_orig)
{
   is($obj->_orig_id_to_uniq_id($expected_orig[$idx-1]), $expected_uniq[$idx-1], sprintf("Original sequence ID %d returned correct unique ID", $idx));
}

# a non existing original ID should still cause an exception
throws_ok { $obj->_orig_id_to_uniq_id('non_existing_orig_id'); } qr/Original ID 'non_existing_orig_id' was not found in genome named 'Test genome'!/, 'Exception still caused by a non existing original ID';

# test if each unique ID is converted into correct original ID after initialization of unique IDs
foreach my $idx (1..@expected_uniq)
{
   is($obj->_uniq_id_to_orig_id($expected_uniq[$idx-1]), $expected_orig[$idx-1], sprintf("Unique sequence ID %d returned correct original ID", $idx));
}

done_testing;
