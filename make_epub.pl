#!/bin/perl
#####################################################################
#
#   make_epub.pl
#
#   Create the ePub book structure from the original source files
#
#####################################################################

use strict;
use warnings;
use File::Copy;
use File::Path 'make_path';
use File::Spec::Functions;

my $src=catdir("C:",
               "Documents and Settings",
               "coopera",
               "My Documents",
               "My Dropbox",
               "Documents",
               "Books",
               "Civic Shop Manual");
my $build="build";
my $verbose=1;

# get_chapter( file )
sub get_chapter {
    my $file = $_[0];
    if( $file =~ m/(\d+)-.*/ ) {
        return $1;
    }
    undef;
}

# copy_section( source_dir, dest_dir, @resources )
sub copy_section {
    my ( $src, $dest, @resources ) = @_;

    print "Copying chapter:\n--  SRC: $src\n-- DEST: $dest\n";
    opendir( DIR, $src ) or die $!;
    while( my $file = readdir(DIR) ) {
        print "Processing file : $file\n";
        my $chap = get_chapter( $file );
        next if ( not defined $chap );

        my $chap_path = catdir($dest, $chap);
        make_path( $chap_path, {verbose=>$verbose} );
        copy( catfile( $src, $file ), $chap_path );
    }
    closedir( DIR );

    foreach my $file (@resources) {
        print "Processing file : $file\n";
        copy( catfile( $src, $file ), $dest );
    }
}

# copy_resources( source_dir, dest_dir,
sub copy_resources {
    # Copy chapter resources
    # Print Copying Resources
    # mkdir -p "$BUILD"/OEBPS/civic_45D_MRC/res
    # cp "$SRC"/CivHtml/*.css "$BUILD"/OEBPS/civic_45D_MRC/res
}

copy_section( catdir($src,"CBHtml"),
              catdir($build,"OEBPS","civic_2d_body"),
              qw(excl.gif line1.gif Contents2.htm) );
