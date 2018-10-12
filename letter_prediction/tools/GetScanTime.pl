#!/usr/bin/perl
#
# CISC 882 Fall 2009
# Amy Siu 10/03/2009
#
# This script calculates the scan time for "typing" a passage of text using an
# AAC (Augmentative or Alternative Communication) keyboard.
#
# Usage:
# shell% perl GetScanTime.pl -k <keyboard layout> -t <test passage> [-p predictions] [-r report]
#
# e.g. To get scan time with predictions:
# shell% perl GetScanTime.pl -k Keyboard.txt -t TestPassage.txt -p Predictions.txt -r Report.txt
#
# e.g. To get baseline scan time without dynamic row of keys:
# shell% perl GetScanTime.pl -k Keyboard.txt -t TestPassage.txt -r Report.txt
#
# Where:
#   keyboard layout: Text file of the static keyboard layout. Each line represents
#                    one row of keys.
#
#   test passage: Text file of the passage to be "typed". This passage should not
#                 contain any newlines. The corollary is that if the passage has
#                 a newline character, everything from that character (inclusive)
#                 will be not be considered. Upper or lower cases do not matter;
#                 this script will treat every letter as lower case.
#
#   predictions: Optional. Each row should contain the letters for the dynamic row
#                of the keyboard. If a letter is in the predictions, it is always
#                used even if the scan time using the static keyboard is faster. If
#                no predictions file is supplied, this script calculates the scan
#                time for the static keyboard alone without the dynamic row of keys.
#                If the number of predictions for a partilar letter in the test
#                passage exceeds $PredictionLimit (currently set to 5), a warning
#                will be issued in the report. In addtion, those "extra" predictions
#                beyond $PredictionLimit will not be considered. Finally, upper or
#                lower cases do not matter; this script will treat every letter as
#                lower case.
#
#   report: Optional. Each row of the report indicates the letter number, the letter
#           itself, and its scan time. Any letter appearing in the test passage but
#           does not exist in the keyboard layout will trigger a warning in the
#           report.
#
#
# Revision history:
# 1.0  10/01/2009  Amy Siu  Initial version.
#
####################################################################################

use strict; use warnings;

# Variable declarations
my $PredictionLimit = 20;
# If number of predictions exceed this limit, there will be a warning in the report.

my $LayoutFile;
my $PassageFile;
my $PredictionsFile;
my $ReportFile;
my $HavePredictions;
my $WantReport;

my $Temp;
my $NextParam;
my ($Row, $Col);
my $Line;
my $Length;
my $LetterNum;

my %StaticLayout;
my %DynamicLayout;
my ($PassageChar, $PassageCharLowerCase);
my ($Predictions, $OriginalPredictions);
my ($PredictionChar, $PredictionCharLowerCase);
my $PredictionUsed;
my $EOFWarned;
my $ScanTime;
my $TotalScanTime;

# Read in the program params
while (scalar @ARGV > 0){
	$Temp = shift @ARGV;
	if ($Temp eq '-k'){
		$NextParam = 'keyboard';
	}
	elsif ($Temp eq '-t'){
		$NextParam = 'passage';
	}
	elsif ($Temp eq '-p'){
		$NextParam = 'predictions';
	}
	elsif ($Temp eq '-r'){
		$NextParam = 'report';
	}
	elsif (defined $NextParam){
		if ($NextParam eq 'keyboard'){
			$LayoutFile = $Temp;
		}
		elsif ($NextParam eq 'passage'){
			$PassageFile = $Temp;
		}
		elsif ($NextParam eq 'predictions'){
			$PredictionsFile = $Temp;
			$HavePredictions = 'yes';
		}
		elsif ($NextParam eq 'report'){
			$ReportFile = $Temp;
			$WantReport = 'yes';
		}
		undef $NextParam;
	}
}

# Check that we have at least the mandatory program params
if (not defined $LayoutFile or not defined $PassageFile){
	print STDERR "Error: Please provide correct arguments.\n";
	print STDERR "Usage: perl TestHw2.pl -k <keyboard layout> -t <test passage> [-p predictions] [-r report]\n";
	die "Program aborted";
}

# Establish scan times for static portion of the keyboard
open (LAYOUT, "<", $LayoutFile) or die("Error: Cannot open keyboard file $LayoutFile: $!");

if (defined $HavePredictions){
	$Row = 2;
}
else{
	$Row = 1;
}
while (defined ($Line = <LAYOUT>)){
	chomp $Line;
	my $Length = length $Line;
	$Col = 0;
	while ($Col < $Length){
		$Temp = lc (substr $Line, $Col, 1);
		$StaticLayout{$Temp} = $Row + $Col + 1;
		++$Col;
	}
	++$Row;
}
close LAYOUT;

# Open files
open (PASSAGE, "<", $PassageFile) or die("Error: Cannot open test passage file $PassageFile: $!");

if (defined $HavePredictions){
	open (PREDICT, "<", $PredictionsFile) or die("Error: Cannot open predictions file $PredictionsFile: $!");
}

if (defined $WantReport){
	open (REPORT, ">", $ReportFile) or die("Error: Cannot open report file $PredictionsFile: $!");
}

# Initialize report file
if (defined $WantReport){
	if (defined $HavePredictions){
		print REPORT "// Format: letter #|letter from passage|predicted letters|scan time\n";
	}
	else{
		print REPORT "// Format: letter #|letter from passage|scan time\n";
	}
}

# Read in the passage and calculate scan times
# Since the test passage should not have new lines, it has to be a one-line passage
$Line = <PASSAGE>;
chomp $Line;
$TotalScanTime = 0;
$LetterNum = 0;
while (length $Line > 0){
	# Get the next letter from test passage
	$PassageChar = substr $Line, 0, 1, "";
	$PassageCharLowerCase = lc $PassageChar;
	++$LetterNum;

	if (exists $StaticLayout{$PassageCharLowerCase}){
		# The letter from test passage exists in the keyboard, thus proceed to find scan time
		$ScanTime = 0;
		if (defined $HavePredictions){
			# Get the predictions for this letter
			$Predictions = <PREDICT>;
			undef $PredictionUsed;
			$ScanTime = 0;

			# Make sure predictions file is not exhausted prematurely
			if (defined $Predictions){
				chomp $Predictions;

				# Keep a copy of unmodified predictions string for reporting later
				$OriginalPredictions = $Predictions;

				# Discard extra predictions if they exceed the limit of number of predictions
				if (length $Predictions > $PredictionLimit){
					$Predictions = substr $Predictions, 0, $PredictionLimit;

					if (defined $WantReport){
						print REPORT "// Warning: Letter #$LetterNum: Number of predictions exceeds $PredictionLimit.\n";
					}
				}

				# We are not allowed to predict spaces. Therefore replace any spaces in predictions 
				# with '=', which is a character that does not exist in the keyboard. In essence we
				# are discarding the predicted space(s) without modifying the scan time of other
				# predicted letters.
				if ($Predictions =~ m/ /){
					$Predictions =~ s/ /=/g;

					if (defined $WantReport){
						print REPORT "// Warning: Letter #$LetterNum: Predictions contain space(s).\n";
					}
				}

				# See if a prediction can be used
				$Row = 1;
				$Col = 1;
				while (length $Predictions > 0 and not defined $PredictionUsed){
					$PredictionChar = substr $Predictions, 0, 1, "";
					$PredictionCharLowerCase = lc $PredictionChar;
					if ($PassageCharLowerCase eq $PredictionCharLowerCase){
						$PredictionUsed = 'yes';
						$ScanTime = $Row + $Col;
					}
					++$Col;
				} # while (length $Predictions > 0)
			} # if (defined $Predictions)
			else{
				# Predictions file is exhausted when there are still letters from test passage
				$OriginalPredictions = "";

				if (defined $WantReport and not defined $EOFWarned){
					print REPORT "// Warning: Letter #$LetterNum: Predictions file has reached end of file.\n";
					$EOFWarned = 'yes';
				}
			} # Predictions file is exhausted when there are still letters from test passage

			# Default to static keyboard if predictions fail to match letter from test passage,
			# or if predictions file is exhausted
			if (not defined $PredictionUsed){
				$ScanTime = $StaticLayout{$PassageCharLowerCase};
			}

			# Produce report for this letter
			if (defined $WantReport){
				print REPORT "$LetterNum|$PassageChar|$OriginalPredictions|$ScanTime\n";
			}
		} # if (defined $HavePredictions)

		else{
			# Get the scan time from static keyboard
			$ScanTime = $StaticLayout{$PassageCharLowerCase};

			# Produce report for this letter
			if (defined $WantReport){
				print REPORT "$LetterNum|$PassageChar|$ScanTime\n";
			}
		} # No predictions

		$TotalScanTime += $ScanTime;
	} # if (exists $StaticLayout{$PassageCharLowerCase})

	else{
		# The letter from test passage does not exist in the keyboard
		if (defined $WantReport){
			print REPORT "// Warning: Letter #$LetterNum: '$PassageChar' does not exist in keyboard layout.\n";
			# Still need to read from predictions file so that the next letter from test passage
			# will match the correct line of predicted letters
			$Temp = <PREDICT>;
		}
	} # Letter does not exist in keyboard

} # while (length $Line > 0)

# Produce final count
print "Total scan time: $TotalScanTime\n";

if (defined $WantReport){
	print REPORT "// Total scan time: $TotalScanTime\n";
}

# Close files
close PASSAGE;

if (defined $HavePredictions){
	close PREDICT;
}

if (defined $WantReport){
	close REPORT;
}
