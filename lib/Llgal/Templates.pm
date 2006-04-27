package Llgal::Templates ;

use strict ;

use Llgal::Misc ;

use vars qw(@EXPORT) ;

@EXPORT = qw (
	      find_generic_template_file
	      find_template_file
	      get_llgal_files
	      give_templates
	      ) ;

# copy a file
sub copy_file {
    my $self = shift ;
    my $messages = $self->{messages} ;
    my $filename = shift ;
    my $srcdir = shift ;
    my $destdir = shift ;
    my ($status, @output) = system_with_output
	("copy '$filename' from '$srcdir'",
	"cp", "-f", "$srcdir/$filename", "$destdir/$filename") ;
    if ($status) {
	# die on whatever error
	$messages->immediate_external_warnings (@output) ;
	die "Failed to get a copy of '$filename'.\n" ;
    }
}

# find path to the template file in generic directories
sub find_generic_template_file {
    my $self = shift ;
    my $opts = shift ;
    my $filename = shift ;
    my $check = shift ;
    foreach my $dir (@{$opts->{template_dirs}}) {
	return $dir
	    if -e "$dir/$filename" ;
    }
    return $self->{user_share_dir}
	if -e "$self->{user_share_dir}/$filename" ;
    die "File '$self->{llgal_share_dir}/$filename' does not exist.\nPlease install llgal properly.\n"
	unless -e "$self->{llgal_share_dir}/$filename" or !$check ;
    return $self->{llgal_share_dir} ;
}

# find path to the template, using the local one if it exists
sub find_template_file {
    my $self = shift ;
    my $opts = shift ;
    my $filename = shift ;
    my $check = shift ;
    return $self->{local_llgal_dir}
	if -e "$self->{local_llgal_dir}/$filename" ;
    return find_generic_template_file $self, $opts, $filename, $check ;
}

# get a template file from generic directories and save it to local directory
sub get_template_file {
    my $self = shift ;
    my $opts = shift ;
    my $filename = shift ;
    my $messages = $self->{messages} ;
    if (-e "$self->{destination_dir}$self->{local_llgal_dir}/$filename") {
	$messages->print ("Found $filename in $self->{destination_dir}$self->{local_llgal_dir}/, using it.\n") ;
    } else {
	my $srcdir = find_generic_template_file $self, $opts, $filename, 1 ;
	$messages->print ("No $filename in $self->{destination_dir}$self->{local_llgal_dir}/, getting a copy from $srcdir\n") ;
	copy_file $self, $filename, $srcdir, "$self->{destination_dir}$self->{local_llgal_dir}" ;
    }
}

# Give templates to the given directory
sub give_templates {
    my $self = shift ;
    my $opts = shift ;
    my $destdir = shift ;
    my $messages = $self->{messages} ;

    if ( ! -e $destdir ) {
	$messages->print ("Creating template directory $destdir...\n") ;
	mkdir $destdir
	    or die "Failed to create $destdir ($!)" ;
    }

    foreach my $filename
	( $opts->{css_filename}, $opts->{filmtile_filename}, $opts->{index_link_image_filename},
	  $opts->{prev_slide_link_image_filename}, $opts->{next_slide_link_image_filename},
	  $opts->{indextemplate_filename}, $opts->{slidetemplate_filename} ) {
	if ( -e "$destdir/$filename" ) {
	    $messages->print ("$filename already exists in $destdir.\n") ;
	} else {
	    my $srcdir = find_generic_template_file $self, $opts, $filename, 1 ;
	    $messages->print ("$filename does not exist in $destdir, getting a copy from $srcdir...\n") ;
	    copy_file $self, $filename, $srcdir, $destdir ;
	}
    }
}

# Get llgal files
sub get_llgal_files {
    my $self = shift ;
    my $opts = shift ;
    my $messages = $self->{messages} ;

    # Get the film tile for the index
    if ($opts->{show_no_film_effect}) {
	$messages->print ("Omitting film effect.\n") ;
    } elsif ($opts->{filmtile_location}) {
	$messages->print ("Using the film tile that is available on $opts->{filmtile_location}.\n") ;
    } else {
	get_template_file $self, $opts, $opts->{filmtile_filename} ;
    }

    # Get link images
    if ($opts->{index_link_image}) {
	if ($opts->{index_link_image_location}) {
	    $messages->print ("Using the index link image that is available on $opts->{index_link_image_location}.\n") ;
	} else {
	    get_template_file $self, $opts, $opts->{index_link_image_filename} ;
	}
    }
    if ($opts->{prev_slide_link_image} and ! $opts->{prev_slide_link_preview}) {
	if ($opts->{prev_slide_link_image_location}) {
	    $messages->print ("Using the prev slide link image that is available on $opts->{prev_slide_link_image_location}.\n") ;
	} else {
	    get_template_file $self, $opts, $opts->{prev_slide_link_image_filename} ;
	}
    }
    if ($opts->{next_slide_link_image} and ! $opts->{next_slide_link_preview}) {
	if ($opts->{next_slide_link_image_location}) {
	    $messages->print ("Using the next slide link image that is available on $opts->{next_slide_link_image_location}.\n") ;
	} else {
	    get_template_file $self, $opts, $opts->{next_slide_link_image_filename} ;
	}
    }

    # Get the css
    if ($opts->{css_location}) {
	$messages->print ("Using the CSS that is available on $opts->{css_location}.\n") ;
    } else {
	get_template_file $self, $opts, $opts->{css_filename} ;
    }
}

1 ;
