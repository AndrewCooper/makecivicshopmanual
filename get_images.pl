#!/bin/perl
#####################################################################
#
#   get_images.pl
#
#   Find and print a list of all images referenced by
#   HTML files in the manual.
#
#####################################################################

use strict;
use warnings;
use File::Basename 'fileparse';
use File::Spec;
use File::Find;
use Text::CSV;

my $src=File::Spec->catdir(
            "C:",
            "Documents and Settings",
            "coopera",
            "My Documents",
            "My Dropbox",
            "Documents",
            "Books",
            "Civic Shop Manual");
my $build="build";
my $verbose=1;

sub validate_img($) {
    my $img = shift;
    
    return 0 if( $img =~ /[\d]+-[\w]+\.(?:gif|png|jpg)/i );
    return 0 if( $img =~ /wd-[\w]+\.(?:gif|png|jpg)/i );
    
    return 1;
}

sub guess_refactor($$) {
    my $dir = shift;
    my $img = shift;

    # Split reference dir into components
    if ($dir eq ".") { $dir = ""; }
    $dir = lc($dir);
    my @dirs = File::Spec->splitdir( $dir );

    # Parse img to remove any leading directories
    my ($imgfile,$imgpath,$imgext) = fileparse($img, qr/\.[^.]*/);
    
    # Normalize to lowercase
    $imgfile = lc( $imgfile );
    
    # Strip inconvenient characters like whitespace
    # and punctuation
    $imgfile =~ s/[\s'":;]//g;
    
    # For now, add directory into image filename
    # to ease comparisons for better refactoring.
    $imgfile = $imgfile."_".join('_',@dirs).$imgext;
    
    # Convert any reference directory components to '..'
    # to reach the project root
    for( my $i = 0; $i < scalar @dirs; ++$i ) {
        if( $dirs[$i] ne "." ) {
            $dirs[$i] = "..";
        }
    }
    
    # Place normalized images in $PROJ_ROOT/common
    $imgfile = File::Spec->catfile( @dirs, "common", $imgfile );
    
    # Return refactored image name
    return $imgfile;
}

sub process_html {
    my $filename = $_;
    my $filepath = $File::Find::name;
    my $dir = File::Spec->abs2rel( $File::Find::dir, $src );
    my $csv = Text::CSV->new( {eol=>"\n",always_quote=>1} );
    
    return unless ( $filename =~ m/\.(htm|html)$/ );
    
    open( my $fh, "<", $filepath ) or die "cannot open < $filepath: $!";
    while(<$fh>) {
        my @imgs = /src="(.*?.(?:gif|png|jpg))"/ig;
        foreach my $img (@imgs) {
            if( validate_img( $img ) ) {
                # Generate CSV line
                # 0 : Reference directory
                # 1 : Reference image
                # 2 : Refactored image
                # 3 : Refactor operation
                #     (C)opy, (R)ename, (I)gnore
                my $fields = [ $dir, $img, guess_refactor( $dir, $img ), "C" ];
                $csv->print( *STDOUT, $fields );
            }
        }
    }
    close( $fh );
}

find( \&process_html, $src );
