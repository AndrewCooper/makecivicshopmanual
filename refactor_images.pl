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
use File::Basename 'fileparse';
use File::Copy;
use File::Path 'make_path';
use File::Spec::Functions;
use File::Find;
use Text::CSV;

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

my %css_renames= (
    "/CBHtml:Ie4only.css" => "../Common/style.css"
);

my %img_renames= (
    "/CBHtml:civic_cars.jpg"    => "../Common/civic_cars.jpg"  ,
    "/CBHtml:EB/01_b.jpg"       => "../Common/01_b.jpg"        ,
    "/CBHtml:EB/02_body.jpg"    => "../Common/02_body.jpg"     ,
    "/CBHtml:EB/03_b.jpg"       => "../Common/03_b.jpg"        ,
    "/CBHtml:EB/04_b.jpg"       => "../Common/04_b.jpg"        ,
    "/CBHtml:EB/05_b.jpg"       => "../Common/05_b.jpg"        ,
    "/CBHtml:EB/06_body.jpg"    => "../Common/06_body.jpg"     ,
    "/CBHtml:EB/grey_button.jpg"=> "../Common/grey_button.jpg" ,
    "/CBHtml:1-2a29.gif"        => "1-2a29.gif"                ,
    "/CBHtml:1-3a29.gif"        => "1-3a29.gif"                ,
    "/CBHtml:1-4a29.gif"        => "1-4a29.gif"                ,
    "/CBHtml:grys_n.gif"        => "asdlfkjelfkjesfjkalsdkjfe"
);

sub load_renames {
    my($filename, $directories, $suffix) = fileparse(__FILE__);
    my $imgpath = catdir( $directories, "images.csv" );
    
    my $csv = Text::CSV->new() or die "$!";
    
    open( my $fh, "<", $imgpath ) or die "$imgpath: $!";;
    while( my $row = $csv->getline( $fh ) {
        $img_renames{ $row->[0].":".$row->[1] } = $row->[2];
    }
    close($fh);
}

sub rename_img($$) {
    my $dir = shift;
    my $old = shift;
    my $key = "$dir:$old";
    if( exists $img_renames{$key} ) {
        return $img_renames{$key};
    }
    print "WARNING :: Rename not found for $key\n";
    return $old;
}

sub rename_css($$) {
    my $dir = shift;
    my $old = shift;
    my $key = "$dir:$old";
    if( exists $css_renames{$key} ) {
        return $css_renames{$key};
    }
    print "WARNING :: Rename not found for $key\n";
    return $old;
}

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub process_html {
    my $filename = $_;
    my $filepath = $File::Find::name;
    my $dir = substr( $File::Find::dir, length($src) );
    
    return unless ( $filename =~ m/\.(htm|html)$/ );
    
    open( my $fh, "<", $filepath ) or die "cannot open < $filepath: $!";;
    while(<$fh>) {
        my $modified = 0;
        my $line = $_;
        
        if( s/src="grys_<img src="(.)\.gif">"/
              src="grys_$1.gif"/i ) {
              $modified = 1;
        }
        
        if( s/src="(.*?.(?:gif|png|jpg))"/
             "src=\"".rename_img($dir,$1)."\""/ie ) {
             $modified = 1;
        }

        if( s/href="(.*?.(?:css))"/
             "href=\"".rename_css($dir,$1)."\""/ie ) {
             $modified = 1;
        }
        
        if( $modified ) {
            print "BEFORE :: ".trim($line)."\n";
            print "AFTER  :: ".trim($_)."\n";
            print "\n";
        }

    }
    close( $fh );

}

find( \&process_html, catdir($src,"CBHtml") );
