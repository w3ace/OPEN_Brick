#!/usr/bin/perl
use strict;
use warnings;

for (my $steps = 0; $steps <  ; $steps++) {
	# bod ...
}


my $dir = path("/tmp"); # /tmp

my $file = $dir->child("file.txt"); # /tmp/file.txt

# Get a file_handle (IO::File object) you can write to
# with a UTF-8 encoding layer
my $file_handle = $file->openw_utf8();

my @list = ('a', 'list', 'of', 'lines');

foreach my $line ( @list ) {
    # Add the line to the file
    $file_handle->print($line . "\n");
}