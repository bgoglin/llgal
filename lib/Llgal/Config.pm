package Llgal::Config ;

use strict ;

require Llgal::Messages ;
require Llgal::Utils ;

use Getopt::Long ;
use I18N::Langinfo qw(langinfo CODESET) ;
use Locale::gettext ;
use POSIX qw(strftime) ;
use Text::ParseWords ;

######################################################################
# default values that will be restored if the associated option is set to -1

my $index_cellpadding_default = 3 ;
my $pixels_per_row_default = 0 ; # unlimited
my $thumbnail_width_max_default = 113 ;
my $thumbnail_height_max_default = 75 ;
my $thumbnails_per_row_default = 5 ;
my $slide_height_max_default = 0 ; # unlimited
my $slide_width_max_default = 0 ; # unlimited
my $text_slide_width_default = 400 ;
my $text_slide_height_default = 300 ;

######################################################################
# early cmdline parsing

sub early_parse_cmdline_options {
    my $self = shift ;
    Getopt::Long::Configure('passthrough') ;
    GetOptions(
	       'd=s'	=> \$self->{destination_dir},
	       ) ;
    # restore default behavior: process all options and warn on error
    Getopt::Long::Configure('nopassthrough') ;
}

######################################################################
# gettext strings are prefixed to distinguish between identical strings

sub init_llgal_gettext {
    my $self = shift ;
    textdomain ("llgal") ;
    bindtextdomain ("llgal", $self->{locale_dir}) ;
}

sub llgal_gettext {
    my $id = shift ;
    my $string = gettext ($id) ;
    $string =~ s/^[^|]+\|// ;
    return $string ;
}

######################################################################
# configuration variables characteristics

# normal option characteristics
my $OPT_IS_NUMERIC = 1 ;
my $OPT_IS_STRING = 2 ;
my $OPT_IS_NONEMPTY_STRING = 3 ;

my $normal_opts_type = {
# Name of generic llgal files
    captions_header_filename => $OPT_IS_NONEMPTY_STRING,
    css_filename => $OPT_IS_NONEMPTY_STRING,
    filmtile_filename => $OPT_IS_NONEMPTY_STRING,
    index_link_image_filename => $OPT_IS_NONEMPTY_STRING,
    prev_slide_link_image_filename => $OPT_IS_NONEMPTY_STRING,
    next_slide_link_image_filename => $OPT_IS_NONEMPTY_STRING,
    indextemplate_filename => $OPT_IS_NONEMPTY_STRING,
    slidetemplate_filename => $OPT_IS_NONEMPTY_STRING,
# location of generic llgal files that are available on the web
    css_location => $OPT_IS_STRING,
    filmtile_location => $OPT_IS_STRING,
    index_link_image_location => $OPT_IS_STRING,
    prev_slide_link_image_location => $OPT_IS_STRING,
    next_slide_link_image_location => $OPT_IS_STRING,
# Location and name of generated files
    index_filename => $OPT_IS_NONEMPTY_STRING,
    slide_filenameprefix => $OPT_IS_STRING,
    scaled_image_filenameprefix => $OPT_IS_NONEMPTY_STRING,
    thumbnail_image_filenameprefix => $OPT_IS_NONEMPTY_STRING,
    captions_filename => $OPT_IS_NONEMPTY_STRING,
    user_scaled_image_filenameprefix => $OPT_IS_NONEMPTY_STRING,
    user_thumbnail_image_filenameprefix => $OPT_IS_NONEMPTY_STRING,
    path_separator_replacement => $OPT_IS_NONEMPTY_STRING,
# Index
    index_cellpadding => $OPT_IS_NUMERIC, # >= 0, -1 for default
    list_links => $OPT_IS_NUMERIC,
    pixels_per_row => $OPT_IS_NUMERIC, # > 0, 0 for unlimited, -1 for default
    thumbnails_per_row => $OPT_IS_NUMERIC, # > 0, 0 for unlimited, -1 for default
    thumbnails_dimensions_from_css => $OPT_IS_NUMERIC,
    thumbnail_height_max => $OPT_IS_NUMERIC, # > 0, -1 for default
    thumbnail_width_max => $OPT_IS_NUMERIC, # > 0, 0 for unlimited, -1 for default
    show_caption_under_thumbnails => $OPT_IS_NUMERIC,
    show_film_effect => $OPT_IS_NUMERIC,
    MVI_link_to_target => $OPT_IS_NUMERIC,
    FIL_link_to_target => $OPT_IS_NUMERIC,
    DIR_link_to_target => $OPT_IS_NUMERIC,
    LNK_link_to_target => $OPT_IS_NUMERIC,
# Slides
    make_no_slides => $OPT_IS_NUMERIC,
    make_slide_filename_from_filename => $OPT_IS_NUMERIC,
    make_slide_filename_from_extension => $OPT_IS_NUMERIC,
    slide_dimensions_from_css => $OPT_IS_NUMERIC,
    slide_width_max => $OPT_IS_NUMERIC, # > 0, 0 for unlimited, -1 for default
    slide_height_max => $OPT_IS_NUMERIC, # > 0, 0 for unlimited, -1 for default
    text_slide_width => $OPT_IS_NUMERIC, # > 0, -1 for default
    text_slide_height => $OPT_IS_NUMERIC, # > 0, -1 for default
    index_link_image => $OPT_IS_NUMERIC,
    prev_slide_link_image => $OPT_IS_NUMERIC,
    next_slide_link_image => $OPT_IS_NUMERIC,
    prev_slide_link_preview => $OPT_IS_NUMERIC,
    next_slide_link_preview => $OPT_IS_NUMERIC,
    link_between_last_and_first => $OPT_IS_NUMERIC,
    make_slide_title_from_caption => $OPT_IS_NUMERIC,
    show_all_exif_tags => $OPT_IS_NUMERIC,
    slide_link_to_full_image => $OPT_IS_NUMERIC,
# Captions
    captions_removal_line => $OPT_IS_NONEMPTY_STRING,
    make_caption_from_image_comment => $OPT_IS_STRING,
    make_caption_from_image_timestamp => $OPT_IS_NUMERIC,
    make_caption_from_filename => $OPT_IS_NUMERIC,
    make_caption_from_extension => $OPT_IS_NUMERIC,
    show_dimensions => $OPT_IS_NUMERIC,
    show_size => $OPT_IS_NUMERIC,
    slide_counter_format => $OPT_IS_STRING,
# Text
    index_title_default => $OPT_IS_STRING,
    index_link_text => $OPT_IS_NONEMPTY_STRING,
    parent_gallery_link_text => $OPT_IS_NONEMPTY_STRING,
    prev_gallery_link_text => $OPT_IS_STRING,
    next_gallery_link_text => $OPT_IS_STRING,
    prev_slide_link_text => $OPT_IS_NONEMPTY_STRING,
    next_slide_link_text => $OPT_IS_NONEMPTY_STRING,
    MVI_link_text => $OPT_IS_STRING,
    FIL_link_text => $OPT_IS_STRING,
    DIR_link_text => $OPT_IS_STRING,
    alt_full_text => $OPT_IS_STRING,
    alt_scaled_text => $OPT_IS_STRING,
    alt_thumbnail_text => $OPT_IS_STRING,
    alt_film_tile_text => $OPT_IS_STRING,
    over_scaled_text => $OPT_IS_STRING,
    over_thumbnail_text => $OPT_IS_STRING,
    over_index_link_text => $OPT_IS_STRING,
    over_prev_slide_link_text => $OPT_IS_STRING,
    over_next_slide_link_text => $OPT_IS_STRING,
    show_size_unit => $OPT_IS_STRING,
    timestamp_format_in_caption => $OPT_IS_NONEMPTY_STRING,
    credits_text => $OPT_IS_STRING,
# What files to insert
    image_extensions => $OPT_IS_STRING,
    movie_extensions => $OPT_IS_STRING,
    add_all_files => $OPT_IS_NUMERIC,
    add_subdirs => $OPT_IS_NUMERIC,
    sort_criteria => $OPT_IS_NONEMPTY_STRING,
# Sections
    entitle_sections => $OPT_IS_NUMERIC,
    separate_sections => $OPT_IS_NUMERIC,
    recursive_sections => $OPT_IS_NUMERIC,
# Recursion
    parent_gallery_link => $OPT_IS_NUMERIC,
    link_subgalleries => $OPT_IS_NUMERIC,
# Various
    codeset => $OPT_IS_STRING,
    language => $OPT_IS_STRING,
    scaled_create_command =>  $OPT_IS_STRING,
    thumbnail_create_command =>  $OPT_IS_STRING,
    force_image_regeneration => $OPT_IS_NUMERIC,
    recursive => $OPT_IS_NUMERIC,
    www_access_rights => $OPT_IS_NUMERIC,
    www_extension => $OPT_IS_NONEMPTY_STRING,
} ;

# options whose input or output is non-trivial:

# options that have a special parsing routine
my $special_opts_with_input = {
    local_llgal_dir => 1,
    exclude => 1,
    include => 1,
    additional_configuration_file => 1,
    additional_template_dir => 1,
    show_exif_tags => 1,
    section_dir => 1,
    verbose => 1,
} ;

# internal options that have a special outputting routine
my $special_opts_with_output = {
    excludes => 1,
    template_dirs => 1,
    show_exif_tags => 1,
    section_dirs => 1,
} ;

# stuff that is not stored in the option hash but need be outputted
my $special_nonopts_with_output = {
    local_llgal_dir => 1,
    verbose => 1,
} ;

# internal options that are never output
my $special_opts_without_output = {
    default_thumb_xdim => 1,
    default_thumb_ydim => 1,
} ;

# options whose merging is done as array
my $special_opts_merging_as_array = {
    excludes => 1,
    template_dirs => 1,
} ;

######################################################################
# manage configuration variables

# overwrite current_opts (1st argument) with overwriting_opts (2nd)
sub merge_opts {
    my $current_opts = shift ;
    my $overwriting_opts = shift ;
    foreach my $key (keys %{$overwriting_opts}) {
	if (defined $overwriting_opts->{$key}) {
	    if (defined $special_opts_merging_as_array->{$key}
		and defined $current_opts->{$key}) {
		$current_opts->{$key} = [@{$current_opts->{$key}}, @{$overwriting_opts->{$key}}] ;
	    } else {
		$current_opts->{$key} = $overwriting_opts->{$key}
	    }
	}
    }
}

# overwrite current_opts with overwriting_opts in a new hash, without changing the originals
sub merge_opts_into {
    my $current_opts = shift ;
    my $overwriting_opts = shift ;
    my $new_opts = {} ;
    merge_opts ($new_opts, $current_opts) ;
    merge_opts ($new_opts, $overwriting_opts) ;
    return $new_opts ;
}

# set default to all uninitialized options
sub add_defaults {
    my $current_opts = shift ;

    my $default_opts = {
# Name of generic llgal files
	captions_header_filename => "captions.header",
	css_filename => "llgal.css",
	filmtile_filename => "tile.png",
	index_link_image_filename => "index.png",
	prev_slide_link_image_filename => "prev.png",
	next_slide_link_image_filename => "next.png",
	indextemplate_filename => "indextemplate.html",
	slidetemplate_filename => "slidetemplate.html",
# Location of llgal files if already on the web
	css_location => "",
	filmtile_location => "",
	index_link_image_location => "",
	prev_slide_link_image_location => "",
	next_slide_link_image_location => "",

# Location and name of generated files
# name of the index file (-i)
	index_filename => "index",
# prefix of HTML slide filenames
	slide_filenameprefix => "slide_",
# scaled and thumbnail image filename prefix
	scaled_image_filenameprefix => "scaled_",
	thumbnail_image_filenameprefix => "thumb_",
# captions filename
	captions_filename => "captions",
# additional prefix of user-provided scaled images
	user_scaled_image_filenameprefix => "my",
# additional prefix of user-provided thumbnails
	user_thumbnail_image_filenameprefix => "my",
# character to use to replace / in the thumbnail/scaled of subdir images
	path_separator_replacement => "@",

# Index
# cellpadding value for the thumbnail index tables (-p)
	index_cellpadding => $index_cellpadding_default,
# list links outside f the table (-L)
	list_links => 0,
# how many pixels per row at most in index (--wx)
	pixels_per_row => $pixels_per_row_default,
# how many thumbnails per row at most in index (-w)
	thumbnails_per_row => $thumbnails_per_row_default,
# do not output thumbnails dimensions
	thumbnails_dimensions_from_css => 0,
# max height of a thumbnail (--ty)
	thumbnail_height_max => $thumbnail_height_max_default,
# scale thumb longer dimension (--tx)
	thumbnail_width_max => $thumbnail_width_max_default,
# write captions under thumbnails on index page (-u)
	show_caption_under_thumbnails => 0,
# show the film effect in the index of thumbnails (--fe)
	show_film_effect => 0,
# link thumbnails to target instead of slide
	MVI_link_to_target => 0,
	FIL_link_to_target => 0,
	DIR_link_to_target => 0,
	LNK_link_to_target => 0,

# Slides
# make no slides, just thumbnail links to images (-s)
	make_no_slides => 0,
# use image names as slide names (-n)
	make_slide_filename_from_filename => 0,
# also use image extension in the slide names
	make_slide_filename_from_extension => 0,
# do not output dimensions for slides, let the css do it
	slide_dimensions_from_css => 0,
# max width of the slides (--sx)
	slide_width_max => $slide_width_max_default,
# max height of the slides (--sy)
	slide_height_max => $slide_height_max_default,
# default text slide width
	text_slide_width => $text_slide_width_default,
# default text slide height
	text_slide_height => $text_slide_height_default,
# use an image for link from a slide to the index, previous or next slide
	index_link_image => 0,
	prev_slide_link_image => 0,
	next_slide_link_image => 0,
# use an image preview for link from a slide to the previous or next slide
	prev_slide_link_preview => 0,
	next_slide_link_preview => 0,
# do not link between last and first slides or galleries
	link_between_last_and_first => 1,
# use captions as slide titles (-k)
	make_slide_title_from_caption => 0,
# show a table of exif tags
	show_exif_tags => [],
# link scaled to full
	slide_link_to_full_image => 1,

# Captions
# this line will be placed in caption generated file
# the user may remove it to prevent llgal from removing the caption file with --clean
	captions_removal_line => "REMOVE THIS LINE IF LLGAL SHOULD NOT REMOVE THIS FILE",
# use image comment as captions (--cc)
	make_caption_from_image_comment => 0,
# use image timestamp as captions (--ct)
	make_caption_from_image_timestamp => 0,
# preserve image names as captions (--cf)
	make_caption_from_filename => 0,
# to write image dimensions (-a or --ad)
	show_dimensions => 0,
# to write image size (-a or --as)
	show_size => 0,
# omit the image slide from the caption (--nc)
	slide_counter_format => "&nbsp;&nbsp;&nbsp;(%0n/%t)",

# Text
# title of the gallery (--title)
	index_title_default => llgal_gettext ("index_title|Index of pictures"),
# label of link to the parent gallery
	parent_gallery_link_text => llgal_gettext ("parent_gallery_link_text|Back to parent gallery"),
# label of link to previous gallery
	prev_gallery_link_text => llgal_gettext ("prev_gallery_link_text|Previous gallery "),
# label of link to previous gallery
	next_gallery_link_text => llgal_gettext ("next_gallery_link_text|Next gallery "),
# label of link from slides to index
	index_link_text => llgal_gettext ("index_link_text|Index"),
# label of link from a slide to the previous one
	prev_slide_link_text => llgal_gettext ("prev_slide_link_text|&lt;&lt;Prev"),
# label of link from a slide to the next one
	next_slide_link_text => llgal_gettext ("next_slide_link_text|Next&gt;&gt;"),
# label of text inserted as a section title
	section_text => llgal_gettext ("section_text|Section "),
# text prefixing the link text
	MVI_link_text => llgal_gettext ("MVI_link_text|Open movie "),
	FIL_link_text => llgal_gettext ("FIL_link_text|Download file "),
	DIR_link_text => llgal_gettext ("DIR_link_text|Open subgallery "),
# alternative text for full-size images in slides
	alt_full_text => llgal_gettext ("alt_full_text|"),
# alternative text for scaled images in slides
	alt_scaled_text => llgal_gettext ("alt_scaled_text|Scaled image "),
# alternative text for thumbnails in the index
	alt_thumbnail_text => llgal_gettext ("alt_thumbnail_text|Thumbnail "),
# alternative text for film tile
	alt_film_tile_text => llgal_gettext ("alt_film_tile_text|Film Tile"),
# text shown when the mouse pointer is over a scaled image in a slide
	over_scaled_text => llgal_gettext ("over_scaled_text|Click to see full size "),
# text shown when the mouse pointer is over a thumbnail
	over_thumbnail_text => llgal_gettext ("over_thumbnail_text|Click to enlarge "),
# text shown when the mouse pointer is over a link to the index
	over_index_link_text => llgal_gettext ("over_index_link_text|Return to the index"),
# text shown when the mouse pointer is over a link to the previous slide
	over_prev_slide_link_text => llgal_gettext ("over_prev_slide_link_text|Previous slide "),
# text shown when the mouse pointer is over a link to the next slide
	over_next_slide_link_text => llgal_gettext ("over_next_slide_link_text|Next slide "),
# change kB to another unit (--asu)
	show_size_unit => llgal_gettext ("show_size_unit|kB"),
# format of the timestamp in captions, when enabled (--ct)
	timestamp_format_in_caption => llgal_gettext ("timestamp_format_in_caption|%y-%m-%d %H:%M:%S"),
# credits line at the bottom of the index
	credits_text => llgal_gettext ("credits_text|created with <a href=\"http://home.gna.org/llgal\">llgal</a>"),

# What files to insert in the gallery
# image and movie extensions
	image_extensions => "jpg|jpeg|png|gif|tif|tiff|bmp",
	movie_extensions => "mpg|mpeg|avi|mov|ogm|wmv",
# add all files, not only images and movies (-A)
	add_all_files => 0,
# add subdirectories to entry list (-S)
	add_subdirs => 0,
# exclude/include
	excludes => [],
# sort criteria
	sort_criteria => "name",

# Sections
# section directories
	section_dirs => [],
# do we add a text slide to entitle sections
	entitle_sections => 0,
# do we separate sections in the gallery
	separate_sections => 0,
# do we create sections for all subdirectories
	recursive_sections => 0,

# Recursion
# add links between subgalleries
	link_subgalleries => 0,
# generate header and footer for link to parent gallery
	parent_gallery_link => 0,

# Various
# codeset to be set in HTML headers (--codeset)
	codeset => langinfo (CODESET ()),
# language to be used for generated text in HTML pages (--lang)
# default is actually useless since we set it before reading the defaults
	language => "",
# user-added directories where templates might be found
	template_dirs => [],
# commands to generate thumbnails and scaled images
	scaled_create_command => "convert -scale <MAXW>x<MAXH> <IN> <OUT>",
	thumbnail_create_command => "convert -scale <MAXW>x<MAXH> <IN> <OUT>",
# force thumbnails and scaled images regeneration
	force_image_regeneration => 0,
# makes everything world-readable (--www)
	www_access_rights => 0,
# extension of generate webpages (--php)
	www_extension => "html",
    } ;

    # merge given options _into_ defaults
    merge_opts ($default_opts, $current_opts) ;
    return $default_opts ;
}

######################################################################
# Create usage now to use defaults values

sub die_usage {
    my $self = shift ;
    my $usage = << "END_OF_USAGE" ;
This is llgal $self->{version}, the image slide show generator.
Syntax:  llgal [-option -option ...]
Behavior Options:
  llgal generates a gallery, except with one of the following options:
    --clean            remove all generated files
    --cleanall         remove all generated and user modified files
    --gc               generate or update the captions file
    --gt [<dir>]       give templates to the directory <dir>
    -h, --help         display this brief help
    -v, --verbose      display notice messages
    -V, --version      show version
Additional Behavior Options:
  The behavior might also be modified with the following options,
  either when generating a gallery or not:
    --config <s>       pass an additional configuration files
    -d <dir>           operate in directory <dir> (current directory)
    -f                 force thumbnail and scaled slide regeneration
    --gencfg <file>    generate the configuration file <file>
    --option <s>       pass an additional option as in configuration files
    -R                 run recursively in subdirectories
Selecting files:
    -A                 add all non-image non-video files to the list of slides
    --exclude <s>      exclude matching files
    --include <s>      include matching files that were excluded
    -P <dir>           add a section with images in subdirectory <dir>
    --Pall             add sections and images from all subdirectories
    --Ps               separate sections in the index with a line and a title
    -S                 add subdirectories to the list of slides
Layout Options:
    -a                 write image sizes under thumbnails on index page
    --ad               like -a, but write only the image dimensions
    --as               like -a, but write only the file size
    --asu <s>          change file size unit (kB)
    --cc [<s>]         use image comments as captions
    --cf               use file names as captions
    --ct [<format>]    use image timestamps as captions
    --codeset <s>      change the codeset in HTML pages
    --exif [<tags>]    show exif tags on each slide
    --fe               show a film effect in the index of thumbnails
    -i <file>          name of the main thumbnail index file (index)
    -k                 use the image captions for the HTML slide titles
    -L                 list links outside of the table
    --lang <s>         change the locale
    --li               use images for links in slides
    --lt               use thumbnail preview for links in slides
    -n                 use image file names for the HTML slide files
    --nc               omit the image count from the captions
    --nf               omit the link from slides' scaled images to full unscaled
    -p <n>             cellpadding value of thumbnail index tables (3)
    --parent-gal       add links to the parent gallery
    --php              use php extension for generated webpages
    --Rl               add links between subgalleries
    -s                 make no HTML slides, link thumbnails to images
    --sort <s>         sort files with criteria <s>
    --templates <dir>  use templates in <dir>
    --title <s>        title of the index of the gallery (Index of pictures)
    --sx <n>           limit image width in slides to <n> pixels
    --sy <n>           limit image height in slides to <n> pixels
    --tx <n>           limit thumbnail width to <n> pixels (113)
    --ty <n>           limit thumbnail height to <n> pixels (75)
    -u                 write captions under thumbnails on index page
    --uc <url>         use a CSS file that is already available on the web
    --ui <url>         use filmtile and link images that are already available on the web
    -w <n>             rows in thumbnail index are at most <n> images wide (5)
    --www              make all llgal files world-readable
    --wx <n>           rows in thumbnail index are at most <n> pixels wide
  Default values are given in parentheses (where applicable).
Author:  Brice Goglin
Homepage:  http://home.gna.org/llgal
Report bugs to:  <llgal-users AT gna.org>
END_OF_USAGE
    die $usage ;
}

######################################################################
# do not show usage when dying from inside Getoptions

my $no_usage_on_getoptions_error = 0 ;

######################################################################
# parse options in config files

# forward declaration
sub parse_custom_config_file ;

# option parsing global variables
my $recursive_included_configuration_file = 0 ;
my $current_configuration_file = undef ;

# in case of option parsing error
sub process_option_error {
    my $error = shift ;
    $no_usage_on_getoptions_error = 1 ;
    if (defined $current_configuration_file) {
	my $file = $current_configuration_file ;
	$current_configuration_file = undef ; # reset here since we won't be able to reset anywhere else
	die "Line #$. of $file:\n  $error.\n" ;
    } else {
	die "$error.\n" ;
    }
}

# process one option line
sub process_option {
    my $self = shift ;
    my $opts = shift ;
    my $messages = $self->{messages} ;
    my $line = shift ;
    chomp $line ;

    if ($line =~ m/^([^ ]+)\s*=.+$/) {
	my $optname = $1 ;
	my $type = $normal_opts_type->{$optname} ;
	if (defined $type) {
	    # use the options type to choose parsing

	    if ($type == $OPT_IS_NUMERIC) {
		# any match is fine
		if ($line =~ m/^[^ ]+\s*=\s*(\d+)$/) {
		    $opts->{$optname} = $1 ;
		} else {
		    process_option_error "Configuration option <$optname> value must be numeric (in <$line>)" ;
		}

	    } elsif ($type == $OPT_IS_STRING) {
		# value must be quoted
		if ($line =~ m/^[^ ]+\s*=\s*"(.*)"$/) {
		    $opts->{$optname} = $1 ;
		} else {
		    process_option_error "Configuration option <$optname> value must be a string (in <$line>)" ;
		}

	    } elsif ($type == $OPT_IS_NONEMPTY_STRING) {
		# value must be quoted and non-empty
		if ($line =~ m/^[^ ]+\s*=\s*"(.+)"$/) {
		    $opts->{$optname} = $1 ;
		} else {
		    process_option_error "Configuration option <$optname> value must be a non-empty string (in <$line>)" ;
		}

	    }

	} elsif ($special_opts_with_input->{$optname}) {
	    # not a normal option, must be special

	    if ($line =~ m/^local_llgal_dir\s*=\s*"(.*)"$/) {
		# the local llgal directory name may only be changed
		# during early configuration
		if ($self->{early_configuration}) {
		    $self->{local_llgal_dir} = $1 ;
		} elsif ($1 ne $self->{local_llgal_dir}) {
		    $messages->warning ("Ignoring changes to the name of the local llgal directory outside of") ;
		    $messages->warning ("system- and user-wide configuration files.") ;
		}

	    } elsif ($line =~ m/^exclude\s*=\s*"(.+)"$/) {
		my $entry = () ;
		$entry->{excluded} = 1 ;
		$entry->{filter} = $1 ;
		push (@{$opts->{excludes}}, $entry) ;

	    } elsif ($line =~ m/^exclude\s*=\s*"(.+)"$/) {
		my $entry = () ;
		$entry->{excluded} = 0 ;
		$entry->{filter} = $1 ;
		push (@{$opts->{excludes}}, $entry) ;

	    } elsif ($line =~ m/^additional_configuration_file\s*=\s*"(.+)"$/) {
		my $file = $1 ;
		if ($recursive_included_configuration_file++ >= 10) {
		    $no_usage_on_getoptions_error = 1 ;
		    die "Not opening '$file' since too much configuration files were recursively included, loop detected ?\n" ;
		}
		my $saved_current_configuration_file = $current_configuration_file ;
		parse_custom_config_file $self, $opts, $file ;
		$current_configuration_file = $saved_current_configuration_file ;
		$recursive_included_configuration_file-- ;

	    } elsif ($line =~ m/^additional_template_dir\s*=\s*"(.+)"$/) {
		push (@{$opts->{template_dirs}}, $1) ;

	    } elsif ($line =~ m/^show_exif_tags\s*=\s*"(.*)"$/) {
		push (@{$opts->{show_exif_tags}}, split (/,/, $1));

	    } elsif ($line =~ m/^section_dir\s*=\s*"(.+)"$/) {
		push (@{$opts->{section_dirs}}, $1) ;

	    } elsif ($line =~ m/^verbose\s*=\s*(\d+)$/) {
		$messages->{verbose} = $1 ;

	    } else {
		process_option_error "Unrecognized configuration option line <$line>" ;
	    }

	} else {
	    process_option_error "Unknown configuration option <$optname>" ;
	}
    } else {
	process_option_error "Configuration must be given <opt> = <value> (was $line)" ;
    }

    return $opts ;
}

sub parse_generic_config_file {
    my $self = shift ;
    my $messages = $self->{messages} ;
    my $opts = {} ;
    my $file = shift ;

    # TODO: remove this one day (maybe on march 14th 2006, since it will be 6 month ?)
    # warn on obsolete file
    my $oldconffile = $file ;
    $oldconffile =~ s@$self->{local_llgal_dir}/llgalrc$@.llgalrc@ ;
    $oldconffile =~ s@llgal/llgalrc$@llgalrc@ ;
    $messages->warning ("Obsolete configuration file $oldconffile skipped, should be moved to $file.")
	if -e $oldconffile ;

    # generic configuration files may not exist
    if (open CONF, $file) {
	$current_configuration_file = $file ;
	while (<CONF>) {
	    process_option $self, $opts, $_
		if (/^[^#]/ and !/^(\s*)$/) ;
	}
	$current_configuration_file = undef ;
	close CONF ;
    }
    return $opts ;
}

sub parse_custom_config_file {
    my $self = shift ;
    my $opts = shift ;
    my $file = shift ;
    my $messages = $self->{messages} ;

    # don't use a capitalized file handle since it would be shared across recursive calls
    if (open my $conf, $file) {
	$messages->notice ("Reading additional configuration file '$file'...\n");
	$current_configuration_file = $file ;
	while (<$conf>) {
	    process_option $self, $opts, $_
		if (/^[^#]/ and !/^(\s*)$/) ;
	}
	$current_configuration_file = undef ;
	close $conf ;
    } else {
	# custom configuration files have to exist
	$no_usage_on_getoptions_error = 1 ;
	die "Failed to open additional configuration file '$file' ($!).\n" ;
    }
}

######################################################################
# process command-line arguments (overriding defaults above)

sub parse_cmdline_options {
    my $self = shift ;
    my $opts = {} ;

    if (!GetOptions(
# behaviors
	'clean'		=> \$self->{clean_asked},
	'cleanall'	=> \$self->{cleanall_asked},
	'gc'		=> \$self->{generate_captions},
	'gt:s'		=> sub {
				shift ; my $value = shift ;
				$value = "local" if !$value ;
				$self->{give_templates} = $value ;
				},
	'v|verbose'	=> \$self->{messages}->{verbose},
	'h|help'	=> \$self->{help_asked},
	'V|version'	=> \$self->{version_asked},
	'f'		=> \$opts->{force_image_regeneration},
	'gencfg=s'	=> \$self->{generate_config},
	'config=s'	=> sub { shift ; parse_custom_config_file $self, $opts, shift ; },
	'R'		=> \$opts->{recursive},

# layout
	'A'		=> \$opts->{add_all_files},
	'a'		=> sub { $opts->{show_dimensions} = $opts->{show_size} = 1 ; },
	'ad'		=> \$opts->{show_dimensions},
	'as'		=> \$opts->{show_size},
	'asu=s'		=> \$opts->{show_size_unit},
	'cc:s'		=> sub {
				shift ; my $value = shift ;
				if ($value eq "") { $opts->{make_caption_from_image_comment} = "std,exif" ; }
				elsif ($value eq "0") { $opts->{make_caption_from_image_comment} = "" ; }
				else { $opts->{make_caption_from_image_comment} = $value ; }
				},
	'cf'		=> \$opts->{make_caption_from_filename},
	'ct:s'		=> sub {
	                        shift ; my $value = shift ;
				$opts->{make_caption_from_image_timestamp} =  1 ;
				if ($value ne "") { $opts->{timestamp_format_in_caption} = $value ; }
			    },
	'ctf=s'		=> \$opts->{timestamp_format_in_caption},
	'codeset=s'     => \$opts->{codeset},
	'exif:s'	=> sub {
	                        shift ; my $value = shift ;
				if ($value eq "") { $opts->{show_all_exif_tags} = 1 ; }
				else { push (@{$opts->{show_exif_tags}}, split (/,/, $value)) ; }
			    },
	'fe'		=> \$opts->{show_film_effect},
	'i=s'		=> \$opts->{index_filename},
	'k'		=> \$opts->{make_slide_title_from_caption},
	'L'		=> \$opts->{list_links},
	'lang=s'        => \$opts->{language},
	'li'		=> sub { $opts->{index_link_image} = 1 ; $opts->{prev_slide_link_image} = 1 ; $opts->{next_slide_link_image} = 1 ; },
	'lt'		=> sub { $opts->{prev_slide_link_preview} = 1 ; $opts->{next_slide_link_preview} = 1 ; },
	'n'		=> \$opts->{make_slide_filename_from_filename},
	'nc'		=> sub { $opts->{slide_counter_format} = "" ; },
	'nf'		=> sub { $opts->{slide_link_to_full_image} = 0 ; },
	'option=s'	=> sub { shift ; process_option $self, $opts, shift ; },
	'P=s'		=> \@{$opts->{section_dirs}},
	'Pall'		=> \$opts->{recursive_sections},
	'Ps'		=> sub { $opts->{entitle_sections} = 1 ; $opts->{separate_sections} = 1 ; },
	'p=i'		=> \$opts->{index_cellpadding},
	'php'		=> sub { $opts->{www_extension} = "php" ; },
	'Rl'		=> \$opts->{link_subgalleries},
	'S'		=> \$opts->{add_subdirs},
	's'		=> \$opts->{make_no_slides},
	'sort=s'	=> \$opts->{sort_criteria},
	'templates=s'	=> \@{$opts->{template_dirs}},
	'title=s'	=> \$opts->{index_title},
	'sx=i'		=> \$opts->{slide_width_max},
	'sy=i'		=> \$opts->{slide_height_max},
	'tx=i'		=> \$opts->{thumbnail_width_max},
	'ty=i'		=> \$opts->{thumbnail_height_max},
	'u'		=> \$opts->{show_caption_under_thumbnails},
	'uc=s'          => \$opts->{css_location},
	'ui=s'          => sub { shift ; my $url = shift ;
				 $opts->{filmtile_location} = $url ;
				 $opts->{index_link_image_location} = $url ;
				 $opts->{prev_slide_link_image_location} = $url ;
				 $opts->{next_slide_link_image_location} = $url ;
			     },
	'w=i'		=> \$opts->{thumbnails_per_row},
	'www'		=> \$opts->{www_access_rights},
	'wx=i'		=> \$opts->{pixels_per_row},
	'exclude=s'	=> sub {
				shift ;
				my $entry = () ;
				$entry->{filter} = shift ;
				$entry->{excluded} = 1 ;
				push @{$opts->{excludes}}, $entry ;
				},
	'include=s'	=> sub {
				shift ;
				my $entry = () ;
				$entry->{filter} = shift ;
				$entry->{excluded} = 0 ;
				push @{$opts->{excludes}}, $entry ;
				},
	'parent-gal'	=> \$opts->{parent_gallery_link},
    )) {
	# there has been an error during command line parsing
	if ($no_usage_on_getoptions_error) {
	    # the error has already been displayed
	    exit -1 ;
	} else {
	    die_usage ($self) ;
	}
    }

    return $opts ;
}

######################################################################
# check and defaults

# check whether an argument is an integer
sub is_integer {
    my $s = shift ;
    return $s eq int($s) ;
}

# various common checks and definitions
sub prepare_common_variables {
    my $self = shift ;
    my $opts = shift ;

    # check a few string that have to be non-empty and may need to be single file without path
    die "Please give a non-empty directory name without path as a local llgal directory\n"
	if $self->{local_llgal_dir} eq "" or $self->{local_llgal_dir} =~ m@/@ ;
}

# various checks and definitions to process the captions
sub prepare_captions_variables {
    my $self = shift ;
    my $opts = shift ;

    prepare_common_variables $self, $opts ;

    # check a few string that have to be non-empty and may need to be single file without path
    die "Please give a non-empty filename without path as a caption filename\n"
	if $opts->{captions_filename} eq "" or $opts->{captions_filename} =~ m@/@ ;
    die "Please give a non-empty caption removal line\n"
	if $opts->{captions_removal_line} eq "" ;
}

# various check and definitions to create the gallery
sub prepare_gallery_variables {
    my $self = shift ;
    my $opts = shift ;
    my $messages = $self->{messages} ;

    prepare_captions_variables $self, $opts ;

    # check a few string that have to be non-empty and may need to be single file without path
    die "Please give a non-empty filename without path as a CSS filename\n"
	if $opts->{css_filename} eq "" or $opts->{css_filename} =~ m@/@ ;
    die "Please give a non-empty filename without path as a film tile filename\n"
	if $opts->{filmtile_filename} eq "" or $opts->{filmtile_filename} =~ m@/@ ;
    die "Please give a non-empty filename without path as a index link image filename\n"
	if $opts->{index_link_image_filename} eq "" or $opts->{index_link_image_filename} =~ m@/@ ;
    die "Please give a non-empty filename without path as a previous slide link image filename\n"
	if $opts->{prev_slide_link_image_filename} eq "" or $opts->{prev_slide_link_image_filename} =~ m@/@ ;
    die "Please give a non-empty filename without path as a next slide link image filename\n"
	if $opts->{next_slide_link_image_filename} eq "" or $opts->{next_slide_link_image_filename} =~ m@/@ ;
    die "Please give a non-empty filename without path as a index template filename\n"
	if $opts->{indextemplate_filename} eq "" or $opts->{indextemplate_filename} =~ m@/@ ;
    die "Please give a non-empty filename without path as a slide template filename\n"
	if $opts->{slidetemplate_filename} eq "" or $opts->{slidetemplate_filename} =~ m@/@ ;

    die "Please give a non-empty string without path as a slide filename prefix\n"
	if $opts->{scaled_image_filenameprefix} eq "" or $opts->{scaled_image_filenameprefix} =~ m@/@ ;
    die "Please give a non-empty string without path as a thumbnail filename prefix\n"
	if $opts->{thumbnail_image_filenameprefix} eq "" or $opts->{thumbnail_image_filenameprefix} =~ m@/@ ;
    die "Please give a non-empty filename without path as a index filename\n"
	if $opts->{index_filename} eq "" or $opts->{index_filename} =~ m@/@ ;
    die "Please give a non-empty string without path as a user-given scaled image prefix\n"
	if $opts->{user_scaled_image_filenameprefix} eq "" or $opts->{user_scaled_image_filenameprefix} =~ m@/@ ;
    die "Please give a non-empty string without path as a user-given thumbnail image prefix\n"
	if $opts->{user_thumbnail_image_filenameprefix} eq "" or $opts->{user_thumbnail_image_filenameprefix} =~ m@/@ ;

    # css location
    if ($opts->{css_location} =~ m@^(.*/)$@) {
	$opts->{css_location} .= $opts->{css_filename} ;
    }

    # images location
    if ($opts->{filmtile_location} =~ m@^(.*)/$@) {
	$opts->{filmtile_location} .= $opts->{filmtile_filename} ;
    }
    if ($opts->{index_link_image_location} =~ m@^(.*/)$@) {
	$opts->{index_link_image_location} .= $opts->{index_link_image_filename} ;
    }
    if ($opts->{prev_slide_link_image_location} =~ m@^(.*/)$@) {
	$opts->{prev_slide_link_image_location} .= $opts->{prev_slide_link_image_filename} ;
    }
    if ($opts->{next_slide_link_image_location} =~ m@^(.*/)$@) {
	$opts->{next_slide_link_image_location} .= $opts->{next_slide_link_image_filename} ;
    }

    # cannot have --sx/sy and -s
    die "Please choose between --sx/--sy and -s\n"
	if ($opts->{slide_height_max} or $opts->{slide_width_max}) and $opts->{make_no_slides} ;

    # thumbnail_width_max must be > 0 or 0 for unlimited
    die "Please give an integer value for thumbnail width max\n"
	unless is_integer ($opts->{thumbnail_width_max}) ;
    if ($opts->{thumbnail_width_max} < 0) {
	$messages->notice ("Thumbnail width max value < 0, restoring to default (".
	    ($thumbnail_width_max_default?$thumbnail_width_max_default:"unlimited") .")\n") ;
	$opts->{thumbnail_width_max} = $thumbnail_width_max_default ;
    }
    die "Please give a positive thumbnail width max value (or 0 for unlimited)\n"
	unless $opts->{thumbnail_width_max} >= 0 ;

    # thumbnail_height_max must be > 0
    die "Please give an integer value for thumbnail height max\n"
	unless is_integer ($opts->{thumbnail_height_max}) ;
    if ($opts->{thumbnail_height_max} < 0) {
	$messages->notice ("Thumbnail height max value < 0, restoring to default ($thumbnail_height_max_default)\n") ;
	$opts->{thumbnail_height_max} = $thumbnail_height_max_default ;
    }
    die "Please give a positive thumbnail height max value\n"
	unless $opts->{thumbnail_height_max} > 0 ;

    # thumbnails_per_row must be > 0 or 0 for unlimited
    die "Please give an integer value for thumbnails per row\n"
	unless is_integer ($opts->{thumbnails_per_row}) ;
    if ($opts->{thumbnails_per_row} < 0) {
	$messages->notice ("Thumbnails per row value < 0, restoring to default (".
	    ($thumbnails_per_row_default?$thumbnails_per_row_default:"unlimited") .")\n") ;
	$opts->{thumbnails_per_row} = $thumbnails_per_row_default ;
    }
    die "Please give a positive thumbnails per row value (or 0 for unlimited)\n"
	unless $opts->{thumbnails_per_row} >= 0 ;

    # pixels_per_row must be > 0 or 0 for unlimited
    die "Please give an integer value for pixels per row\n"
	unless is_integer ($opts->{pixels_per_row}) ;
    if ($opts->{pixels_per_row} < 0) {
	$messages->notice ("Pixels per row value < 0, restoring to default (".
	    ($pixels_per_row_default?$pixels_per_row_default:"unlimited") .")\n") ;
	$opts->{pixels_per_row} = $pixels_per_row_default ;
    }
    die "Please give a positive pixels per row value (or 0 for unlimited)\n"
	unless $opts->{pixels_per_row} >= 0 ;

    # index_cellpadding must be >= 0
    die "Please give an integer value for index cellpadding\n"
	unless is_integer ($opts->{index_cellpadding}) ;
    if ($opts->{index_cellpadding} < 0) {
	$messages->notice ("Index cellpadding value < 0, restoring to default ($index_cellpadding_default)\n") ;
	$opts->{index_cellpadding} = $index_cellpadding_default ;
    }
    die "Please give a positive or null index cellpadding value\n"
	unless $opts->{index_cellpadding} >= 0 ;

    # text_slide_width must be > 0
    die "Please give an integer value for text slide width\n"
	unless is_integer ($opts->{text_slide_width}) ;
    if ($opts->{text_slide_width} < 0) {
	$messages->notice ("Text slide width value < 0, restoring to default ($text_slide_width_default)\n") ;
	$opts->{text_slide_width} = $text_slide_width_default ;
    }
    die "Please give a positive text slide width value\n"
	unless $opts->{text_slide_width} > 0 ;

    # text_slide_height must be > 0
    die "Please give an integer value for text slide height\n"
	unless is_integer ($opts->{text_slide_height}) ;
    if ($opts->{text_slide_height} < 0) {
	$messages->notice ("Text slide height value < 0, restoring to default ($text_slide_height_default)\n") ;
	$opts->{text_slide_height} = $text_slide_height_default ;
    }
    die "Please give a positive text slide height value\n"
	unless $opts->{text_slide_height} > 0 ;

    # slide_width_max must be > 0, 0 for unlimited
    die "Please give an integer value for slide width max\n"
	unless is_integer ($opts->{slide_width_max}) ;
    if ($opts->{slide_width_max} < 0) {
	$messages->notice ("Slide width max value < 0, restoring to default (".
	    ($slide_width_max_default?$slide_width_max_default:"unlimited") .")\n") ;
	$opts->{slide_width_max} = $slide_width_max_default ;
    }
    die "Please give a positive slide width max value (or 0 for unlimited)\n"
	unless $opts->{slide_width_max} >= 0 ;

    # slide_height_max must be > 0, 0 for unlimited
    die "Please give an integer value for slide height max\n"
	unless is_integer ($opts->{slide_height_max}) ;
    if ($opts->{slide_height_max} < 0) {
	$messages->notice ("Slide height max value < 0, restoring to default (".
	    ($slide_height_max_default?$slide_height_max_default:"unlimited") .")\n") ;
	$opts->{slide_height_max} = $slide_height_max_default ;
    }
    die "Please give a positive slide height max value (or 0 for unlimited)\n"
	unless $opts->{slide_height_max} >= 0 ;

    # either pixels or thumbnails per row must be limited
    die "Please limit pixels or thumbnails per row\n"
	unless $opts->{pixels_per_row} > 0 or $opts->{thumbnails_per_row} > 0 ;

    # adapt text slide width and height in case of --sx/sy
    if ($opts->{slide_height_max} > 0) {
	$opts->{text_slide_width} = $opts->{text_slide_width} / $opts->{text_slide_height} * $opts->{slide_height_max} ;
	$opts->{text_slide_height} = $opts->{slide_height_max} ;
    }
    if ($opts->{slide_width_max} > 0 and $opts->{text_slide_width} > $opts->{slide_width_max}) {
	$opts->{text_slide_height} = $opts->{text_slide_height} / $opts->{text_slide_width} * $opts->{slide_width_max} ;
	$opts->{text_slide_width} = $opts->{slide_width_max} ;
    }

    # thumbnail default size (for text and link slide especially)
    if ($opts->{thumbnail_width_max} > 0) {
	($opts->{default_thumb_xdim}, $opts->{default_thumb_ydim}) = ($opts->{thumbnail_width_max}, $opts->{thumbnail_height_max}) ;
    } else {
	($opts->{default_thumb_xdim}, $opts->{default_thumb_ydim}) = ($opts->{thumbnail_height_max} * 4/3, $opts->{thumbnail_height_max}) ;
    }

    # convert options for thumbnails
    my $thumb_MAXH = $opts->{thumbnail_height_max} ;
    my $thumb_MAXW = $opts->{thumbnail_width_max} > 0 ? $opts->{thumbnail_width_max} : "" ;
    $opts->{thumbnail_create_command} =~ s/<MAXH>/$thumb_MAXH/g ;
    $opts->{thumbnail_create_command} =~ s/<MAXW>/$thumb_MAXW/g ;

    # convert options for slides
    my $scaled_MAXH = $opts->{slide_height_max} > 0 ? $opts->{slide_height_max} : "" ;
    my $scaled_MAXW = $opts->{slide_width_max} > 0 ? $opts->{slide_width_max} : "" ;
    $opts->{scaled_create_command} =~ s/<MAXH>/$scaled_MAXH/g ;
    $opts->{scaled_create_command} =~ s/<MAXW>/$scaled_MAXW/g ;
}

#######################################################################
# If --gencfg was invoked, generate a configuration file

sub generate_config {
    my $self = shift ;
    my $file = shift ;
    my $opts = shift ;
    my $messages = $self->{messages} ;

    $messages->print ("Generating config file '$file'.\n") ;
    if (-e "$file") {
	my $old_file = "$file.save.". (strftime('%Y-%m-%d_%H:%M:%S' ,localtime)) ;
	$messages->warning ("Renaming old configuration file '$file' as '$old_file'") ;
	rename "$file", "$old_file" ;
    }

    open NEWCFG, ">$file"
	or die "Cannot open $file ($!).\n" ;

    print NEWCFG "# This is a llgal configuration file.\n" ;
    print NEWCFG "# It was automatically generated on ". (scalar localtime) .".\n" ;
    print NEWCFG "# You may modify and reuse it as you want.\n" ;
    print NEWCFG "\n" ;

    for my $optname (sort (keys %{$normal_opts_type}, keys %{$special_opts_with_output}, keys %{$special_nonopts_with_output})) {

	if (defined $special_nonopts_with_output->{$optname}) {

	    if ($optname eq "local_llgal_dir") {
		print NEWCFG "local_llgal_dir = \"$self->{local_llgal_dir}\"\n" ;

	    } elsif ($optname eq "verbose") {
		print NEWCFG "verbose = $messages->{verbose}\n" ;

	    } else {
		die "Unknown non-options $optname to output.\n" ;
	    }

	} elsif (defined $special_opts_with_output->{$optname}) {
	    next if not defined $opts->{$optname} ;
	    # special options that need special output

	    if ($optname eq "show_exif_tags") {
		print NEWCFG "show_exif_tags = \"". (join (",", @{$opts->{show_exif_tags}})) ."\"\n" ;

	    } elsif ($optname eq "template_dirs") {
		if (@{$opts->{template_dirs}}) {
		    map {
			print NEWCFG "additional_template_dir = \"$_\"\n" ;
		    } @{$opts->{template_dirs}} ;
		}

	    } elsif ($optname eq "excludes") {
		if (@{$opts->{excludes}}) {
		    map {
			print NEWCFG ($_->{excluded} ? "exclude" : "include"). " = \"". $_->{filter} ."\"\n" ;
		    } @{$opts->{excludes}} ;
		}

	    } elsif ($optname eq "section_dirs") {
		if (@{$opts->{section_dirs}}) {
		    map {
			print NEWCFG "section_dir = \"$_\"\n" ;
		    } @{$opts->{section_dirs}} ;
		}

	    } else {
		die "Unknown special internal option $optname to output.\n" ;
	    }

	} else {
	    next if not defined $opts->{$optname} ;
	    # normal options

	    my $type = $normal_opts_type->{$optname} ;
	    if (defined $type) {

		if ($type == $OPT_IS_NUMERIC) {
		    print NEWCFG "$optname = $opts->{$optname}\n" ;
		} elsif ($type == $OPT_IS_STRING or $type == $OPT_IS_NONEMPTY_STRING) {
		    print NEWCFG "$optname = \"$opts->{$optname}\"\n" ;
		} else {
		    die "Unknown normal option type $type.\n" ;
		}

	    } else {
		die "Unknown ge option $optname to output.\n" ;
	    }
	}
    }

    print NEWCFG "\n" ;
    close NEWCFG ;
}

1 ;
