package Llgal::Misc ;

use strict ;
use Exporter 'import' ;
use vars qw(@EXPORT ) ;

@EXPORT = qw (
    indented_print
    save_and_indent
    restore_indent
    add_warning
    add_external_warnings
    show_warnings
    immediate_warning
    immediate_external_warnings
    init_percentage
    print_percentage
    end_percentage
    system_with_output
    is_integer
    copy_file
    back_path
    make_safe_url
    make_safe_url_nowarn
    make_readable
    make_readable_and_traversable
) ;

use URI::Escape ;

# Print messages with indentation according to recursion level

my $indent = "" ;

sub save_and_indent {
    my $saved_indent = $indent ;
    $indent .= "  " ;
    return $saved_indent ;
}

sub restore_indent {
    $indent = shift ;
}

sub indented_print {
    print $indent ;
    print @_ ;
}

# Warnings are shown after each step of processing to avoid
# breaking precentage progressions and so

my $tmp_warning = "" ;

sub add_warning {
    $tmp_warning .= "!! ".(shift)."\n" ;
}

sub add_external_warnings {
    while (@_) {
	my $line = shift ;
	chomp $line ;
	add_warning "# $line" ;
    }
}

sub show_warnings {
    print $tmp_warning ;
    $tmp_warning = "" ;
}

sub immediate_warning {
    print "!! ".(shift)."\n" ;
}

sub immediate_external_warnings {
    while (@_) {
	my $line = shift ;
	chomp $line ;
	immediate_warning "# $line" ;
    }
}

# Print percentage

sub init_percentage {
    print "  0%" ;
}

sub print_percentage {
    my ($i,$n) = (shift,shift) ;
    my $val = int($i*100/$n) ;
    print "\b\b\b\b" ;
    if ($val == 100) {
	print "100%" ;
    } elsif ($val >= 10) {
	print " ".$val."%" ;
    } else {
	print "  ".$val."%" ;
    }
}

sub end_percentage {
    print "\b\b\b\b100%\n" ;
}

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

# check whether an argument is an integer

sub is_integer {
    my $s = shift ;
    return $s eq int($s) ;
}

# copy a file
sub copy_file {
    my $filename = shift ;
    my $srcdir = shift ;
    my $destdir = shift ;
    my ($status, @output) = system_with_output
	("copy '$filename' from '$srcdir'",
	"cp", "-f", "$srcdir/$filename", "$destdir/$filename") ;
    if ($status) {
	# die on whatever error
	immediate_external_warnings @output ;
	die "Failed to get a copy of '$filename'.\n" ;
    }
}

# revert a path into ..
sub back_path {
    my $dir = shift ;
    $dir =~ s/([^\/]+)/../g ;
    return $dir ;
}

# generating safe url
sub make_safe_url_nowarn {
    my $file = shift ;
    my $safe = uri_escape ($file) ;
    return $safe ;
}

sub make_safe_url {
    my $file = shift ;
    my $safe = uri_escape ($file) ;

    add_warning "Non-ascii characters were escaped in filename '$file'."
	if $safe ne $file and $file =~ /[\x80-\xFF]/ ;

    return $safe ;
}

# Chmod

sub make_readable {
    my $file = shift ;
    my ($status, @output) = system_with_output ("make world readable",
						"chmod", "a+r", $file) ;
    add_external_warnings @output
	if $status ;
}

sub make_readable_and_traversable {
    my $file = shift ;
    my ($status, @output) = system_with_output ("make world readable and traversable",
						"chmod", "a+rx", $file) ;
    add_external_warnings @output
	if $status ;
}

1;
