#!/usr/bin/perl
use strict;
use warnings;

my %index_hash = ();
my $name;
my $print_next=0;
my %max_index_hash = ();
open(INDEX,'SNP44859_S262_L001_I1_001.fastq') || die("cannot open file!");
while(<INDEX>){
	my $line = $_;
	chomp($line);
	if ( $line =~ /^\@M0/ ){
		$name = $line;
		$print_next=1;
	}elsif ( $print_next==1 ){
		#push(@{$index_hash{$line}},$name);
		$index_hash{$line}{$name}=1;
		$max_index_hash{$line}++;
		$print_next=0;
	}
}
close(INDEX);
my $max_index=0;
my $correct_index;
foreach my $key (keys %max_index_hash){
	if ( $max_index < $max_index_hash{$key} ){
		$max_index = $max_index_hash{$key};
		$correct_index = $key;
	}
}
$print_next=0;
open(WRITE1,">","SNP44859_S262_L001_R1.demultiplex.fastq") || die("cannot open file!");
open(READ1,"SNP44859_S262_L001_R1_001.fastq") || die("cannot open file!");
while(<READ1>){
	my $line = $_;
	chomp($line);
	if ( $line =~ /^\@M0/ ){
		$name=$line;
		if ( exists $index_hash{$correct_index}{$name} ){
			$print_next=1;
			print WRITE1 "$line\n";
		}
	}elsif( $print_next == 1){
		#prints sequence
		print WRITE1 "$line\n";
		$print_next++;
	}elsif ( $print_next == 2 ){
		print WRITE1 "$line\n";
		$print_next++;
	}elsif ( $print_next == 3 ){
		print WRITE1 "$line\n";
		$print_next=0;
	}
}
close(READ1);
close(WRITE1);
$print_next=0;
open(WRITE2,">","SNP44859_S262_L001_R2.demultiplex.fastq") || die("cannot open file!");
open(READ2,"SNP44859_S262_L001_R2_001.fastq") || die("cannot open file!");
while(<READ2>){
	my $line = $_;
	chomp($line);
	if ( $line =~ /^\@M0/ ){
		my @spl = split(/ 2/,$line);
		$name = $spl[0] . " 1" . $spl[1];
		if ( exists $index_hash{$correct_index}{$name} ){
			$print_next=1;
			print WRITE2 "$line\n";
		}
	}elsif( $print_next == 1){
		print WRITE2 "$line\n";
		$print_next++;
	}elsif( $print_next == 2 ){
		print WRITE2 "$line\n";
		$print_next++;
	}elsif( $print_next == 3 ){
		print WRITE2 "$line\n";
		$print_next++;
	}
}
close(READ2);
close(WRITE2);
