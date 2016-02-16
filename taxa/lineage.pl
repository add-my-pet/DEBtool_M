#!/usr/local/bin/perl -w

use warnings;
use strict;

my $KEYDIR = '.';
my $root = 'Animalia';

die "Supply only one leaf keyword to search on!\n"  if @ARGV != 1;
my $leaf = $ARGV[0];

my %children; my %parent;
my @words = build_query($root);


#foreach my $k (keys %parent) {
#	print "$k: " . join("-", @{$parent{$k}}) . "\n";
#}


my @tree = get_tree($leaf);
unshift(@tree,$leaf);

#print join("\n", @tree), "\n\n";
print join("\n", reverse @tree), "\n";



################### SUBROUTINES #########################

sub build_query {
        my $word = shift;
        my @words = read_file($word, 0);
        return ($word, @words);
}


sub get_tree {
	my $tax = shift;
	my @tax;

	my $parent = @{$parent{$tax}}[0];

	if (!$parent) {
		return ();
	}

	push(@tax, $parent);
	push(@tax, get_tree($parent));

	return(@tax);
}


sub read_file {
		my $word = shift;
		my $level = shift;
		my @words;
		
		# Stop condition
		my $file = "$KEYDIR/$word.txt";
		if (! -e $file) {
			return ();
		}

		open my $fh, $file or die "Could not open \"$file\".\n";
		$level++;
		while (my $line = <$fh>) {
			$line =~ /^\s+$/ and next;
			$line =~ s/\r|\n//g;
			push(@{$parent{$line}}, $word);
			push(@{$parent{$line}}, read_file($line, $level));
		}
		close $fh;
		
		return (@words);
}
