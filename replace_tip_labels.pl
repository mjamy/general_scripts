#!/usr/bin/perl

#  replace_tip_labels.pl
#
#  Created by Mahwash Jamy on 2018-06-19.
#  Updated 2025-02-05.

use strict;
use warnings;

die "\nReplaces tip labels in a tree file in newick format based on a user specified table.\n\nUsage: replace_tip_labels.pl <tre file> <replacement tsv> <output>\n\n" unless @ARGV == 3;

my ($tree, $tsv, $output) = @ARGV;

my %new_tip;

# Build a hash where the keys (old tip label) point to the new tip label
open(my $in_tsv, "<", $tsv) or die "error opening $tsv for reading";

while (my $line = <$in_tsv>) {
    chomp $line;
    my ($find, $replace) = split("\t", $line);
    $new_tip{$find} = $replace;
}

close $in_tsv;

# Read entire Newick tree as a single string
open(my $in_tree, "<", $tree) or die "error opening $tree for reading";
my $newick_tree = do { local $/; <$in_tree> };  # Slurp mode to read full file
close $in_tree;

# Sort keys by length (longest first) to avoid partial matches
my @sorted_keys = sort { length($b) <=> length($a) } keys %new_tip;

# Perform replacements
foreach my $key (@sorted_keys) {
    my $escaped_key = quotemeta($key);  # Escape special regex characters
    $newick_tree =~ s/\b$escaped_key\b/$new_tip{$key}/g;
}

# Write modified tree to output file
open(my $out_tree, ">", $output) or die "error opening $output for writing";
print $out_tree $newick_tree;
close $out_tree;

