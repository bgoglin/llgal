package Llgal::Messages ;

use strict ;

use vars qw(@EXPORT) ;

@EXPORT = qw (new) ;

# messaging context

sub new {
    my $self = {} ;
    bless $self ;
    $self->{indent} = "" ;
    $self->{percentage_total} = 0 ;
    $self->{delayed_warnings} = "" ;
    return $self ;
}

sub copy {
    my $self = shift ;
    my $new_self = {
	indent => $self->{indent},
	percentage_total => $self->{percentage_total},
	delayed_warnings => $self->{delayed_warnings},
    } ;
    bless $new_self ;
    return $new_self ;
}

# indented printing

sub print {
    my $self = shift ;
    print $self->{indent} ;
    print @_ ;
}

sub indent {
    my $self = shift ;
    $self->{indent} .= "  " ;
}

# Warnings are shown after each step of processing to avoid
# breaking precentage progressions and so

my $warning_prefix = "!! " ;

sub add_warning {
    my $self = shift ;
    $self->{delayed_warnings} .= $warning_prefix.(shift)."\n" ;
}

sub add_external_warnings {
    my $self = shift ;
    while (@_) {
	my $line = shift ;
	chomp $line ;
	add_warning "# $line" ;
    }
}

sub show_warnings {
    my $self = shift ;
    print $self->{delayed_warnings} ;
    $self->{delayed_warnings} = "" ;
}

sub immediate_warning {
    my $self = shift ;
    print $warning_prefix.(shift)."\n" ;
}

sub immediate_external_warnings {
    my $self = shift ;
    while (@_) {
	my $line = shift ;
	chomp $line ;
	immediate_warning "# $line" ;
    }
}

# percentage printing

sub init_percentage {
    my $self = shift ;
    $self->{percentage_total} = shift ;
    print "  0%" ;
}

sub update_percentage {
    my $self = shift ;
    my $i = shift ;
    my $val = int($i*100/$self->{percentage_total}) ;
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
    my $self = shift ;
    print "\b\b\b\b100%\n" ;
}


1 ;
