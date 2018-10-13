    #!/usr/bin/perl
use warnings;
use strict;

my $questionFile;
my $answerFile;
my $QuestionHandler;

if($#ARGV == 1) {
	# Read question&answer file to the file handler
	($answerFile,$questionFile) = @ARGV;
	open($QuestionHandler,$questionFile) or die "Failed to open '$questionFile'.\n";
	
}else {
	# only read answer file, input question from cmd
	($answerFile) = @ARGV;
	$QuestionHandler = *STDIN;
}

# let's first define parsing rules using regular expression!
# rule of parse the numbers
my $Numbers = '.*?(\d+\,\d*|\d* ?\d*\/\d+|\d*\.?\d+).*?';
# rule of parse the company names
my $Dow = '.*?(Dow[\' ]|[Ii]ndustrials [Aa]verage).*?';
my $Delta = '.*?(Delta|Delta Air Lines|Delta Airlines).*?';
my $Disney = '.*?(Walt Disney|Disney).*?';
my $IBM = '.*?(IBM|International Business Machines).*?';
my $Merrill = '.*?(Merrill Lynch|Merrill).*?';
my $SP = '.*?(S&P|Standard & Poor.* 500).*?';
my $Others = '.*?(UAL|AMR|BankAmerica|Capital Cites|Philip Morris|Pacific Telesis Group).*?';
# rule of parse the verbs 
my $Increase = '.*?([Rr][io]se|increases|increased|increase|jumped|go up).*?';
my $Decrease = '.*?([Ff][ae]ll|[Dd]own|drop|decline|crumble|s[ia]nk|lower|ground to|go down|downward|never resumed).*?';
my $Open = '.*?([Oo]pen.*? at|opened).*?';
my $Close = '.*?([Cc]lose.*? to|[Cc]lose.*? at|trading at|fell.*? to|fell.*? at|sank.*? to).*?';

# 1 read each question from handler
# 2 parse company name and question type  
if($#ARGV < 1) {
	print "Please ask me question:\n";
}
while (<$QuestionHandler>){
	# chop \n and init variables
	chop $_; 
    my ($Type,$CompanyName,$Verb)=(-1,'','');

	# we only support 2 types question
    if (/what|how/i){
        $Type = 1;
	}elsif(/did/i){
        $Type = 0;
    }else {
        $Type = -1;
    }
    
    # parse company name from question
    if (/$Dow/i){
        $CompanyName = $Dow;
    }elsif(/$Disney/i){
        $CompanyName = $Disney;
    }elsif(/$SP/i){
        $CompanyName = $SP;
    }elsif(/$IBM/i){
        $CompanyName = $IBM;
    }elsif(/$Delta/i){
        $CompanyName = $Delta;
    }elsif(/$Merrill/i){
        $CompanyName = $Merrill;
    }elsif(/$Others/i){
		$CompanyName = $Others;
	}else {
		print "A: No available information due to no such company name.\n";
		next;
    }
    
    # parse prediction verb from question
	# ask 3 trend: 0 ask fall, 1 ask rise, 3 ask rise or fall
	my $Trend = 0;
	if (/$Increase/ and /$Decrease/) {
		$Trend=2;
	}elsif (/$Increase/){
        $Verb = $Increase;
		$Trend = 1;
    }elsif(/$Decrease/){
        $Verb = $Decrease;
    }elsif(/$Open/){
        $Verb = $Open;
    }elsif(/$Close/){
        $Verb = $Close;
    }
	#else { print "No available information due to no such prediction.\n";next;}

	# Output Question and Answer if exist
	print "--------------------------------------------------------------------------";
    print "\nQ: $_\n";
    
    my $found = 0;
    my $lineNo = -1;
    open(my $ansHandler,$answerFile) or die "Failed to open '$answerFile'!\n";

    while (<$ansHandler>){
		chop $_;
        $lineNo = $lineNo + 1;
		if(/$CompanyName/ eq "") {
			next;
		}

        if($Type == 0) {
			#if(/$Verb/ eq ""){next;}
			if($Trend == 2){
           	    $found = 1;
				if(/$Increase/){
               		print "A: It rose.\n";
				}else{
					print "A: It fell.\n";
				}
         		print "Source(line $lineNo): $_\n";
			}
           	elsif(/$Verb/) {
           	    $found = 1;
		   	 	if($Trend) {
           	    	print "A: It rose.\n";
		   	 	}else {
		   	 		print "A: It fell.\n";
		   	 	}
           	 	print "Source(line $lineNo): $_\n";
           	}
        }
        elsif ($Type == 1) {
			if(/$Numbers/ eq "") {next;}
			#if(/$Verb/ eq ""){next;}
            if (/$CompanyName.*?($Verb $Numbers)/) {
                $found = 1;
                print "A: $4\n";
                print "Source(line $lineNo): $_\n" ;
				#print " (line $lineNo)\n";
            }
            elsif (/$CompanyName.*?($Numbers $Verb)/)
            {
                $found = 1;
				if($3 eq "500") {next;}
                print "A: $3\n";
                print "Source(line $lineNo): $_\n"; 
				#print "(line $lineNo)\n";
            }
        }
		else{
			print "A: Don't support this type question, please begin with what/how/did\n";
			last;
		}
    }
	close $ansHandler;

    if (!$found){
        print "A: No information available!\n";
    }

	if($#ARGV < 1) {
		print "\n>>Please ask me question (ctr+c to terminate):\n";
	}
}

