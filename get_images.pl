#!/bin/perl

use strict;
use warnings;
use File::Spec::Functions;
use File::Find;

my $src=catdir("C:",
               "Documents and Settings",
               "coopera",
               "My Documents",
               "My Dropbox",
               "Documents",
               "Books",
               "Civic Shop Manual");

sub process
{
    return unless ( $_ =~ m/\.(gif|jpg|png|bmp)$/ );
    print( CSVFILE "$_,$File::Find::dir,$File::Find::name\n" );
}

open( CSVFILE, ">", "images.csv" ) or die "cannot open : $!";
find( \&process, $src );
close( CSVFILE );

