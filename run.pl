#!/usr/bin/perl
use Carp;
use Time::HiRes qw(time sleep);
use Getopt::Long;

$options{defaultdb} = 'sacred_experiments';

$usage = <<EOS;
$0 cmd options
	valid commands:
		start name 
		test name 
	options:
		--defaultdb=
			defaults to $options{defaultdb}
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
	execute('docker pull hmlatapie/mongodb');
	execute("docker run -d --name $mongodb -e AUTH=no hmlatapie/mongodb");

	$cmd =<<EOS;
docker run -d --name $name --link $mongodb:mongodb --volume=\$(pwd)/rr:/root/rr hmlatapie/reproducible_research /bin/bash -c "while true; do date; sleep 3600; done"
EOS
	execute($cmd);
}
elsif($command eq 'test')
{
	$name = shift;
	confess $usage
		if !$name;

	$mongodb = "$name\_mongo";

	execute("docker exec -it $name /bin/bash -c \"./sacred/examples/01_hello_world.py -m mongodb:27017:$options{defaultdb}\"");
	execute("docker exec -it $mongodb /bin/bash -c \"mongo $options{defaultdb} --eval 'printjson(db.getCollectionNames())'\"");

	$js_cmd =<<EOS;
cursor = db.default.runs.find();
while ( cursor.hasNext() ) {
	printjson( cursor.next() );
}
EOS
	execute("docker exec -it $mongodb /bin/bash -c \"mongo $options{defaultdb} --eval '$js_cmd'\"");
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

