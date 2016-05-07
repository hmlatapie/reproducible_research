#!/usr/bin/perl
use Carp;
use Time::HiRes qw(time sleep);
use Getopt::Long;

$usage = <<EOS;
$0 cmd options
	valid commands:
		start name 
			 
	options:
EOS

GetOptions(
	'stringparam=s' => \$options{stringparam},
	'booleanparam' => \$options{booleanparam}
	);

confess $usage
	if !@ARGV;

$command = shift;

if($command eq 'start')
{
	$name = shift;
	confess $usage
		if !$name;

	$cmd =<<EOS;
docker run -d --name $name hmlatapie/reproducible_research:latest /bin/bash -c "while true; do date; sleep 3600; done"
EOS
	execute($cmd);
}
else
{
	confess $usage;
}

sub execute
{
	my ($cmd) = @_;
	open my $f, "$cmd |";
	print
		while <$f>;
}

