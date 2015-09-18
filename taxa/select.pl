#!/usr/local/bin/perl -w

use warnings;
use strict;

my $KEYDIR = '.';

die "Supply only one keyword to search on!\n"  if @ARGV != 1;
my $word = $ARGV[0];

my @words = build_query($word);
print join("\n", @words), "\n";



################### SUBROUTINES #########################

sub build_query {
        my $word = shift;
        my @words = read_file($word, 0);
        return (@words);
}


sub read_file {
        my $word = shift;
        #my $level = shift;
		my @words;

        my $file = "$KEYDIR/$word.txt";
		
        # Stop condition
		#if (! -e $file) {
		#	return ();
		#}

        open my $fh, $file or die "Could not open \"$file\".\n";
		#$level++;
        while (my $line = <$fh>) {
                $line =~ /^\s+$/ and next;
                $line =~ s/\r|\n//g;
                #push(@words, read_file($line, $level));

                if (! -e "$KEYDIR/$line.txt") {
					push(@words, $line);
				} else {
					push(@words, read_file($line))
				}
        }
        close $fh;
       
        return (@words);
}
