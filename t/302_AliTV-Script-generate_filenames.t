use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('AliTV::Script') };

can_ok('AliTV::Script', qw(generate_filenames));

my @input = ();
my @expected = ();
my @output = ();
my $testname = "";

my @tests = (
    {
     desc          => "project given, but no YAML",
     input         => [ "testproj", undef, undef, 0, undef ],
     expected      => [ "testproj", "testproj.json", "testproj.log", "testproj.yml" ],
    },

    {
     desc          => "project and YAML given",
     input         => [ "testproj", undef, undef, 0, "testyml.yml" ],
     expected      => [ "testproj", "testproj.json", "testproj.log", "testyml.yml" ],
    },

    {
     desc          => "no project given, but YAML given",
     input         => [ undef, undef, undef, 0, "testproj.yml" ],
     expected      => [ "testproj", "testproj.json", "testproj.log", "testproj.yml" ],
    },

    {
     desc          => "no project and no YAML given",
     input         => [ undef, undef, undef, 0, undef ],
     expected      => [ "testproj", "testproj.json", "testproj.log", "testproj.yml" ],
     autogenerated => 1
    },

    {
     desc          => "project given, but no YAML, YAML file exists",
     input         => [ "testproj", undef, undef, 0, undef ],
     create_file   => [ "testproj.yml" ],
     exception_exp => "File 'testproj.yml' exists... Unless you specify --overwrite the file will not be overwritten!"
    },

    {
     desc          => "project given, but no YAML, YAML file exists, overwrite",
     input         => [ "testproj", undef, undef, 1, undef ],
     create_file   => [ "testproj.yml" ],
     expected      => [ "testproj", "testproj.json", "testproj.log", "testproj.yml" ],
    },

    {
     desc          => "project given, but no YAML, output file exists",
     input         => [ "testproj", undef, undef, 0, undef ],
     create_file   => [ "testproj.json" ],
     exception_exp => "File 'testproj.json' exists... Unless you specify --overwrite the file will not be overwritten!"
    },

    {
     desc          => "project given, but no YAML, output file exists, overwrite",
     input         => [ "testproj", undef, undef, 1, undef ],
     create_file   => [ "testproj.json" ],
     expected      => [ "testproj", "testproj.json", "testproj.log", "testproj.yml" ],
    },

    {
     desc          => "project given, but no YAML, log file exists",
     input         => [ "testproj", undef, undef, 0, undef ],
     create_file   => [ "testproj.log" ],
     expected      => [ "testproj", "testproj.json", "testproj.log", "testproj.yml" ],
    },

    );

foreach my $case (@tests)
{
    my @output = ();

    if (exists $case->{create_file})
    {
	foreach my $file2create (@{$case->{create_file}})
	{
	    open(FH, ">", $file2create) || die "Unable to create file '$file2create'";
	    close(FH) || die "Unable to close file '$file2create'";
	}
    }

    unless (exists $case->{exception_exp})
    {
	lives_ok { @output = AliTV::Script::generate_filenames(@{$case->{input}}) } 'No exception expected for '.$case->{desc};
	
	if (exists $case->{autogenerated})
	{
	    ok($output[0] =~ /^autogen_.{7}$/, 'Autogenerated project name has expected format');
	    $case->{expected} = [ $output[0], $output[0].".json", $output[0].".log", $output[0].".yml" ];
	}

	is_deeply(\@output, $case->{expected}, $case->{desc});
    } else {
	throws_ok { @output = AliTV::Script::generate_filenames(@{$case->{input}}) } qr/$case->{exception_exp}/, 'Exception expected for '.$case->{desc};
    }

    if (exists $case->{create_file})
    {
	foreach my $file2delete (@{$case->{create_file}})
	{
	    unlink($file2delete) ||die "Unable to delete file '$file2delete'";
	}
    }

}

done_testing;
