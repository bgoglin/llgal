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
    $self->{delayed_warning} = 0 ;
    $self->{pending_warnings} = "" ;
    return $self ;
}

sub copy {
    my $self = shift ;
    my $new_self = {
	indent => $self->{indent},
	percentage_total => $self->{percentage_total},
	percentage_in_progress => $self->{percentage_in_progress},
	delayed_warning => $self->{delayed_warning},
	pending_warnings => $self->{pending_warnings},
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

sub warning {
    my $self = shift ;
    while (@_) {
	my $line = shift ;
	chomp $line ;
	if ($self->{delayed_warning}) {
	    $self->{pending_warnings} .= $warning_prefix.$line."\n" ;
	} else {
	    print $warning_prefix.$line."\n" ;
	}
    }
}

sub delay_warnings {
    my $self = shift ;
    $self->{delayed_warning} = 1 ;
}

sub show_delayed_warnings {
    my $self = shift ;
    print $self->{pending_warnings} ;
    $self->{pending_warnings} = "" ;
    $self->{delayed_warning} = 0 ;
}

# percentage printing

sub init_percentage {
    my $self = shift ;
    $self->{delayed_warning} = 1 ;
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
    $self->show_delayed_warnings () ;
}


1 ;
