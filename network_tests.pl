#!/usr/bin/perl
#tcpserver.pl

use IO::Socket::INET;
use IO::Socket::SSL;
use Data::Dumper;
use DBD::mysql;
use threads;
# flush after every write
$| = 1;

my $dsn = 'dbi:mysql:garage:127.0.0.1:3306';
my $user='mysql';
my $pass = '';

my $dsr = 'dbi:mysql:radio:127.0.0.1:3306';

my ($socket,$client_socket);
my ($peeraddress,$peerport);

# creating object interface of IO::Socket::INET modules which internally does
# socket creation, binding and listening at the specified port address.
SSL_Passwd_cb=>'passwordsuckit';
$socket = new IO::Socket::SSL (
localhost => '0.0.0.0', #'127.0.0.1',
LocalPort => '3131',
Proto => 'tcp',
Listen => 5,
Reuse => 1,
Timeout => 4,
SSL_version=>'SSLv23',
SSL_server=>true,
SSL_cert_file=>'cert.pem',
SSL_key_file=>'key.pem') or die 'ERROR in SSL Socket Creation : $! \n  ' ;

print " SERVER Waiting for client connection on port 3130\n";
print "local address: ", $socket->sockaddr(),"\n";
my $plug=1;
my $addr;


sub garage_check{
	print "Connected from: ",$addr->peerhost();# Display messages
        print " Port: ", $addr->peerport(), "\n";
        my $dbh = DBI->connect($dsn,$user,$pass) or warn "Can't connect to DB: $DBI::errstr\n";
        my $nth = $dbh->prepare("select current_status from status");
        my $the_status=$nth->execute();
        my @status_row;
        while (@status_row = $nth->fetchrow()){
             print Dumper(@status_row);
             $status=$status_row[0];
        }
        print Dumper(@status_row);
        $nth->finish();
        print Dumper($status);
	return $status;
}
#$addr= $socket->accept() or warn "failed to accept handshake or some shit: $!, $SSL_ERROR";
while(1)
{

#$addr= $socket->accept() or warn "failed to accept handshake or some shit: $!, $SSL_ERROR";
    $SIG{CHLD}='IGNORE';
	while($addr= $socket->accept())
	{

	    if($pid=fork){
	    }
	    else
	    {
		my $status=garage_check();
		#print "Connected from: ",$addr->peerhost();# Display messages
		#print " Port: ", $addr->peerport(), "\n";
		#my $dbh = DBI->connect($dsn,$user,$pass) or warn "Can't connect to DB: $DBI::errstr\n";
		#my $nth = $dbh->prepare("select current_status from status");
		#my $the_status=$nth->execute();
		#my @status_row;
		#while (@status_row = $nth->fetchrow()){
	#		print Dumper(@status_row);	
	#		$status=$status_row[0];
	#	}
	#	print Dumper(@status_row);
	#	$nth->finish();
	#	print Dumper($status);
		my $result='';
		print "enter me\n";
		while (<$addr>) 
		{
			chomp($_);
			print Dumper($_);
			$result=$_;
			#print "what the fuck $result\n";
			#print "the line: "+$result +"\n";
			#print Dumper($result);
			last if $_ =~m/<>/gi;
			#print $addr $_;
		}
		#int rando = rand(2000);
		if ($result =~ m/status_me_bitch/i)
		{
		    if ($status == 1)
		    {
			print "closed\n";
			print $addr 'closed><';
		    }
		    if ($status == 2)
		    {	
			print "closing\n";
			print $addr 'closing><';
		    }
		    if ($status == 3)
		    {
			print "opening\n";
			print $addr 'opening><';
		    }
		    if ($status == 4)
		    {
			print "opened\n";
			print $addr 'opened><';
		    }
		}
		if ($result =~ m/command/i)
		{
			print $addr 'got_it><';
			print "got it\n";
			system("/media/my_book/video/garage/garage.py");		
		}
		
		#print "never exits\n";
		#print $result+"\n";
		#$result='';
		# we can also read from socket through recv()  in IO::Socket::INET
		# $client_socket->recv($data,1024);
		
		$addr->close();
		print "where do I block?\n";
		print "CHILD PID: ".$pid."\n";
		exit(0);
	    }
	}

#print "closed\n";
#$socket->close(SSL_ctx_free=>true);
}
print "exit the while\n";
