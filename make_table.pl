#!/usr/bin/perl
use strict;
use warnings;

sub shannon{
	my %hash = %{$_[0]};
	my $total = $_[1];
	my $shannon_index=0;
	foreach my $key (keys %hash){
		$shannon_index += ($hash{$key}/$total) * log($hash{$key}/$total) *-1;
	}
	return $shannon_index;
}

my %merged_counts = ();
open(MERGED_COUNTS,"merged_ASVs_counts.tsv") || die("cannot open file!");
while(<MERGED_COUNTS>){
	my $line = $_;
	chomp($line);
	if ( $line =~ /^ASV\_/ ){
		my @spl = split("\t",$line);
		$merged_counts{$spl[0]} = $spl[1];
	}
}
close(MERGED_COUNTS);
my %merged_tax = ();
open(MERGED_TAX,"merged_ASVs_taxonomy.tsv") || die("cannot open file!");
while(<MERGED_TAX>){
	my $line = $_;
	chomp($line);
	if ( $line =~ /^ASV\_/ ){
		my @spl = split("\t",$line);
		$merged_tax{$spl[0]} = $spl[1] . ";" . $spl[2] . ";" . $spl[3] . ";" . $spl[4] . ";" . $spl[5] . ";" . $spl[6] . ";" . $spl[7];
	}
}
close(MERGED_TAX);
open(FORWARD_COUNTS,"singles_forward_ASVs_counts.tsv") || die("cannot open file!");
while(<FORWARD_COUNTS>){
	my $line = $_;
	chomp($line);
	if ( $line =~ /^ASV\_/ ){
		my @spl = split("\t",$line);
		$merged_counts{"forward" . $spl[0]} = $spl[1];
	}
}
close(FORWARD_COUNTS);
open(FORWARD_TAX,"singles_forward_ASVs_taxonomy.tsv") || die("cannot open file!");
while(<FORWARD_TAX>){
	my $line = $_;
	chomp($line);
	if ( $line =~ /^ASV\_/ ){
		my @spl = split("\t",$line);
		$merged_tax{"forward" . $spl[0]} = $spl[1] . ";" . $spl[2] . ";" . $spl[3] . ";" . $spl[4] . ";" . $spl[5] . ";" . $spl[6] . ";" . $spl[7];
	}
}
close(FORWARD_TAX);
open(REVERSE_COUNTS,"singles_reverse_ASVs_counts.tsv") || die("cannot open file!");
while(<REVERSE_COUNTS>){
	my $line = $_;
	chomp($line);
	if ( $line =~ /^ASV\_/ ){
		my @spl = split("\t",$line);
		$merged_counts{"reverse" . $spl[0]} = $spl[1];
	}
}
close(REVERSE_COUNTS);
open(REVERSE_TAX,"singles_reverse_ASVs_taxonomy.tsv") || die("cannot open file!");
while(<REVERSE_TAX>){
	my $line = $_;
	chomp($line);
	if ( $line =~ /^ASV\_/ ){
		my @spl = split("\t",$line);
		$merged_tax{"reverse" . $spl[0]} = $spl[1] . ";" . $spl[2] . ";" . $spl[3] . ";" . $spl[4] . ";" . $spl[5] . ";" . $spl[6] . ";" . $spl[7];
	}
}
close(FORWARD_TAX);
my %combined = ();
my $total = 0;
foreach my $key (keys %merged_tax ){
	$combined{$merged_tax{$key}} += $merged_counts{$key};
	$total += $merged_counts{$key};
}
print "TOTAL: $total\n";
my %domain = ();
my %phylum = ();
my %class = ();
my %order = ();
my %family = ();
my %genus = ();
my %species = ();
foreach my $key (keys %combined ){
	my @spl = split(/\;/,$key);
	$domain{$spl[0]}+= $combined{$key};
	$phylum{$spl[1]} += $combined{$key};
	$class{$spl[2]} += $combined{$key};
	$order{$spl[3]} += $combined{$key};
	$family{$spl[4]} += $combined{$key};
	$genus{$spl[5]} += $combined{$key};
	$species{$spl[6]} += $combined{$key};
}
my $domain_shannon = shannon(\%domain,$total);
my $phylum_shannon = shannon(\%phylum,$total);
my $class_shannon = shannon(\%class,$total);
my $order_shannon = shannon(\%order,$total);
my $family_shannon = shannon(\%family,$total);
my $genus_shannon = shannon(\%genus,$total);
my $species_shannon = shannon(\%species,$total);
open(SHANNON_VALUES,">","shannon_index.txt") || die("cannot open file!");
print SHANNON_VALUES "DOMAIN: $domain_shannon\n";
print SHANNON_VALUES "PHYLUM: $phylum_shannon\n";
print SHANNON_VALUES "CLASS: $class_shannon\n";
print SHANNON_VALUES "ORDER: $order_shannon\n";
print SHANNON_VALUES "FAMILY: $family_shannon\n";
print SHANNON_VALUES "GENUS: $genus_shannon\n";
print SHANNON_VALUES "SPECIES: $species_shannon\n";
close(SHANNON_VALUES);
open(SUMMARY,">","summary_table.tsv") || die("cannot open file!");
print SUMMARY "classification\tabundance\t%abundance\n";
foreach my $key ( sort { $combined{$b} <=> $combined{$a} } keys (%combined) ){
	my $proportion = ($combined{$key}/$total)*100;
	print SUMMARY "$key\t$combined{$key}\t$proportion\n";
}
close(SUMMARY);
open(GENUS_PLOT,">","genus_plot.tsv") || die("cannot open file!");
foreach my $key ( keys %genus ){
	my $replace_key = $key;
	$replace_key=~s/ /\_/g;
	print GENUS_PLOT "$replace_key\t$genus{$key}\n";
}
close(GENUS_PLOT);
