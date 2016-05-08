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

	$mongodb = "$name\_mongo";

	`mkdir -p rr`;	

	$cmd =<<EOS;
docker pull hmlatapie/reproducible_research
EOS

	execute($cmd);
	execute('docker pull tutum/mongodb');
	execute("docker run -d --name $mongodb -e AUTH=no tutum/mongodb");

	$cmd =<<EOS;
docker run -d --name $name --link $mongodb --volume=\$(pwd)/rr:/root/rr hmlatapie/reproducible_research /bin/bash -c "while true; do date; sleep 3600; done"
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

