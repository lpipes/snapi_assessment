#!/usr/bin/perl
use strict;
use warnings;
my %read1_names = ();
my %read1_3 = ();
my %read1_4 = ();
my $print_next=0;
my $name;
open(READ1,"SNP44859_S262_L001_R1.filtered.fastq") || die("cannot open file!");
while(<READ1>){
	my $line = $_;
	chomp($line);
	if ( $line =~ /^\@M0/ ){
		$print_next=1;
		$name=$line;
	}elsif( $print_next==1 ){
		$read1_names{$name}=$line;
		$print_next++;
	}elsif( $print_next==2 ){
		$read1_3{$name}=$line;
		$print_next++;
	}elsif ( $print_next==3 ){
		$read1_4{$name}=$line;
		$print_next=0;
	}
}
close(READ1);
my $print_pairs=0;
my $print_singles=0;
open(WRITE1,">","SNP44859_S262_L001_R1.fastq") || die("cannot open file!");
open(WRITE2,">","SNP44859_S262_L001_R2.fastq") || die("cannot open file!");
open(WRITE3,">","SNP44859_S262_L001.singles_forward.fastq") || die("cannot open file!");
open(WRITE4,">","SNP44859_S262_L001.singles_reverse.fastq") || die("cannot open file!");
open(READ2,"SNP44859_S262_L001_R2.filtered.fastq") || die("cannot open file!");
while(<READ2>){
	my $line = $_;
	chomp($line);
	if ( $line =~ /^\@M0/ ){
		my @spl = split(/ 2/,$line);
		$name = $spl[0] . " 1" . $spl[1];
		if ( exists $read1_names{$name} ){
			@spl = split(/\@/,$line);
			print WRITE2 "$line\n";
			@spl = split(/\@/,$name);
			print WRITE1 "$line\n";
			$print_pairs=1;
		}else{
			@spl = split(/\@/,$line);
			print WRITE4 "$line\n";
			$print_singles=1;
		}
	}elsif( $print_pairs==1){
		print WRITE2 "$line\n";
		print WRITE1 "$read1_names{$name}\n";
		print WRITE1 "$read1_3{$name}\n";
		print WRITE1 "$read1_4{$name}\n";
		delete($read1_names{$name});
		$print_pairs++;
	}elsif( $print_singles==1){
		print WRITE4 "$line\n";
		$print_singles++;
	}elsif ( $print_pairs==2){
		print WRITE2 "$line\n";
		$print_pairs++;
	}elsif( $print_pairs==3){
		print WRITE2 "$line\n";
		$print_pairs=0;
	}elsif( $print_singles==2){
		print WRITE4 "$line\n";
		$print_singles++;
	}elsif ( $print_singles==3 ){
		print WRITE4 "$line\n";
		$print_singles=0;
	}
}
close(READ2);
close(WRITE1);
close(WRITE2);
close(WRITE4);
foreach my $key (keys %read1_names){
	my @spl = split(/\@/,$key);
	print WRITE3 "$key\n";
	print WRITE3 "$read1_names{$key}\n";
	print WRITE3 "$read1_3{$key}\n";
	print WRITE3 "$read1_4{$key}\n";
}
close(WRITE3);
