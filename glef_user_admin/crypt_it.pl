#!/usr/bin/perl

$newp = $ARGV[0]."1234";
print crypt($newp, "aa");
