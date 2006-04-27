package Llgal::Misc ;

use strict ;

use Exporter 'import' ;
use vars qw(@EXPORT) ;

@EXPORT = qw (
    system_with_output
) ;

# system routine which:
# - takes a description followed by cmdline arguments
# - returns a table composed of the status followed by STDERR and STDOUT lines

sub system_with_output {
    my $descr = shift ;
    pipe (my $pipe_out, my $pipe_in) ;
    my $pid = fork() ;
    if ($pid < 0) {
	close $pipe_in ;
	close $pipe_out ;
	return ( -1, "Fork failed while trying to $descr\n" ) ;
    } elsif ($pid > 0) {
	close $pipe_in ;
	waitpid ($pid, 0) ;
	my $status = $? >> 8 ;
	$status = -1
	    if $status == 255 ;
	my @lines = <$pipe_out> ;
	close $pipe_out ;
	return ( $status , @lines ) ;
    } else {
	close $pipe_out ;
	open STDERR, ">&", $pipe_in ;
	open STDOUT, ">&", $pipe_in ;
	{ exec @_ } ;
	print $pipe_in "Exec of $_[0] failed while trying to $descr\n" ;
	close $pipe_in ;
	exit -1 ;
    }
}

1;
