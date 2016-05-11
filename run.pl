#!/usr/bin/perl
use Carp;
use Time::HiRes qw(time sleep);
use Getopt::Long;

$options{defaultdb} = 'sacred_experiments';
$options{RR_CONTAINER} = 'hmlatapie/reproducible_research';
$options{RR_CONTAINER} = $ENV{RR_CONTAINER}
	if $ENV{RR_CONTAINER};

$usage = <<EOS;
$0 cmd options
	valid commands:
		start name 
			--pull
				will pull latest
		test name 
	options:
		--defaultdb=
			defaults to $options{defaultdb}
		--RR_CONTAINER
			defaults to $options{RR_CONTAINER}
EOS

GetOptions(
	'stringparam=s' => \$options{stringparam},
	'RR_CONTAINER=s' => \$options{RR_CONTAINER},
	'booleanparam' => \$options{booleanparam},
	'pull' => \$options{pull},
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
docker pull $options{RR_CONTAINER} 
EOS

	execute($cmd);
	execute('docker pull hmlatapie/mongodb')
		if $options{pull};

	execute('docker pull $options{RR_CONTAINER}')
		if $options{pull};

	execute("docker run -d --name $mongodb -e AUTH=no hmlatapie/mongodb");

	$cmd =<<EOS;
docker run -d --name $name --link $mongodb:mongodb --volume=\$(pwd)/rr:/root/rr $options{RR_CONTAINER} /bin/bash -c "while true; do date; sleep 3600; done"
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
	
	print "executing command: $cmd\n";
	open my $f, "$cmd |";
	print
		while <$f>;
}

