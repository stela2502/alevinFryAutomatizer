#! /usr/bin/perl

use Getopt::Long;
use strict;
use File::Basename;

my ( $script, $sbatch, $samples, $help, $debug, $outpath);

Getopt::Long::GetOptions(
	"-script=s"                 => \$script,
	"-sbatch=s"                 => \$sbatch,
	"-samples=s{,}" 	    => \$samples,
	"-outpath=s"                => \$outpath,
	"-help"                     => \$help,
	"-debug"                    => \$debug
);

if ($help) {
	print helpString();
	exit;
}
unless ( -e $script ) {
	print helpString("ERROR:missing example script");
	exit;
}

unless ( -e $sbatch ) {
	print helpString("ERROR:missing example script");
	exit;
}

unless ( -f $samples ) {
	print helpString("ERROR:missing samples table");
	exit;
}
 

sub  helpString {
	my $errorMessage = shift;
	$errorMessage = ' ' unless ( defined $errorMessage );
	return "
 $errorMessage
 Command line options for the preparation of alevin-fry scripts to run single samples
 the files should be a long list of R1 anf R2 files for one or more samples.
 The samples need to be defined in the filesnames before the _L00 part of the file.
 
 Both scrips can contain the strings R1FILES, R2FILES, SNAME, SSNAME and OUTPATH.
 The OUTPATH is created as \$outpath/\$sname, R[12]FILES are a space separated list of the files from the same sample
 and SNAME is the long sname whereas SSNAME will be replaced by a shortened sname (md5sum of the real one)
 
   -script    :the example script The strings R1FILES and R2FILES will be replaced by the fastq files
               the string SNAME will be replaced by the long sname
               the string SSNAME will be replaced by a short sname
   -sbatch    :the example sbatch script to run the other script on the nodes
   -outpath   :where should the data be stored (sname subfolders)
   -samples   :a tab separated table with first column sample name and second column (absolute) file path
               If the file path is not absolute the samples table needs to be in the same path as the fastq files.
   -help      :print this help
   -debug     :verbose output

 The script outputs a list of sbatch commands that you can pipe into a file and 'bash' run them.
 ";
}


## split the files into file groups one group per samples with R1 and R2

my ($tmp, @tmp);

my $groups = {};

open my $samp , "<".$samples or die "Could not open the samples file $samples\n$!\n";

my $samPath = dirname($samples);

foreach $tmp ( <$samp>) {
	chomp($tmp);
	@tmp = split("\t", $tmp);
	if (! exists($groups->{$tmp[1]}) ){
		$groups->{$tmp[1]} = { "R1" => [], "R2" => [] };	
	}
	unless ( $tmp[0] =~ m!^/! ){
		$tmp[0] = $samPath."/".$tmp[0];
	}

	if ( $tmp[0] =~m/R1/ ){
		push( @{$groups->{$tmp[1]}->{'R1'}}, $tmp[0] );
	}elsif ( $tmp[0] =~m/R2/ ){
                push( @{$groups->{$tmp[1]}->{'R2'}}, $tmp[0] );

        } else{
		warn("fastq file '$tmp[0]' is neither a R1 or R2 file - ignored\n");
        }

}

warn "I found these samples:". join("\n", sort keys %$groups )."\n\n";


open my $fh, '<', $script  or die "Can't open file $script:\n $!";
read $fh, my $script_content, -s $fh;
close $fh;

open my $fh, '<', $sbatch  or die "Can't open file $sbatch:\n $!";
read $fh, my $sbatch_content, -s $fh;
close $fh;

my ( $R1, $R2,$sname, $ssname );
$ssname = 1;
foreach my $sname ( keys %$groups ){
        next if ( $sname =~m/Undetermined/ );
	$R1 = join(" ", @{$groups->{$sname}->{'R1'}});
	$R2 = join(" ", @{$groups->{$sname}->{'R2'}});
	#print "THIS IS THE MERGED R!?: $R1\n";
	$tmp = &replace(  $script_content, "samp".$ssname, $R1, $R2, $sname, $outpath  );
	open $fh, ">", "$outpath/$sname"."_script.sh" or die "Can't open file $outpath/$sname"."_script.sh:\n $!";
	print $fh $tmp;
	close $fh;
	system( "chmod +x $outpath/$sname"."_script.sh");
	$tmp = &replace( $sbatch_content, "samp".$ssname, $R1, $R2, $sname, $outpath  );

	open $fh, ">", "$outpath/$sname.sbatch.sh" or die "Can't open file $outpath/$sname.sbatch.sh:\n $!";
        print $fh $tmp;
        close $fh;

	print "sbatch $outpath/$sname.sbatch.sh\n";
	$ssname = $ssname +1;
}

sub replace {
	my ($text, $ssname, $R1, $R2, $sname, $outpath )= @_;
  
	$text =~ s/R1FILES/$R1/g;
	$text =~ s/R2FILES/$R2/g;
        $text =~ s/SSNAME/$ssname/g;
	$text =~ s/SNAME/$sname/g;
	$text =~ s!OUTPATH!$outpath/$sname!g;
	return( $text );
}
	

