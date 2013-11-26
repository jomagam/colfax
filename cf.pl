use strict;

my $rank = 1;
my @all;
my (%time, %seconds);

while(my $line = <>){
    if($line =~ m{^(.*?)\s+$rank\s+(\d+)\s+(\d+)\s+([\d-:]+)\s+([\d-:]+)\s+([\d-:]+)\s+([\d-:]+)\s+([\d-:]+)\s+([\d:]+)}){
	my $first = $1;
	my $divp = $2;
	my $sexp = $3;
	$time{$first}{64} = $4;
	$time{$first}{103} = $5;
	$time{$first}{159} = $6;
	$time{$first}{199} = $7;
	$time{$first}{end} = $8;
	my $pace = $9;

	$time{$first}{rank} = $time{$first}{rank_end} = $rank;

        $seconds{$first}{end} = convert($time{$first}{end});

	foreach my $ss (keys %{$time{$first}}){
	    next if $ss eq 'end';
	    next if $ss eq 'rank';
	    my $secs = convert($time{$first}{$ss});
	    if($secs > 0){
		$seconds{$first}{$ss} = $secs
	    }
	    else {
		$seconds{$first}{$ss} = int($seconds{$first}{end} * $ss / 262);
#		print "SETTING seconds{$first}{$ss} to $seconds{$first}{$ss} from $seconds{$first}{end}\n";
	    }
	}
    }
    else {
	warn $line;
    }

    $rank++;
}

foreach my $ss (64, 103, 159, 199){
    my @sort = sort {$seconds{$a}{$ss} <=> $seconds{$b}{$ss}} keys %time;

    foreach(my $srank = 0; $srank < @sort; $srank++){
#	print "$srank($ss) $sort[$srank] $seconds{$sort[$srank]}{$ss}\n";
	$time{$sort[$srank]}{"rank_$ss"} = $srank+1;
    }
}

my @d = (64, 103, 159, 199, 'end');

for(my $d=1; $d<@d; $d++){
    foreach my $runner (keys %time){
	my ($plus, $minus);
	foreach my $other_runner (keys %time){
	    $minus++ if $time{$runner}{"rank_" . $d[$d-1]} < $time{$other_runner}{"rank_" .$d[$d-1]} and $time{$runner}{"rank_$d[$d]"} > $time{$other_runner}{"rank_$d[$d]"};
#	    print qq{$time{$runner}{"rank_" . $d[$d-1]} < $time{$other_runner}{"rank_" .$d[$d-1]} and $time{$runner}{"rank_$d[$d]"} > $time{$other_runner}{"rank_$d[$d]"} \n};
	    $plus++ if $time{$runner}{"rank_" . $d[$d-1]} > $time{$other_runner}{"rank_" .$d[$d-1]} and $time{$runner}{"rank_$d[$d]"} < $time{$other_runner}{"rank_$d[$d]"};
	}
	$time{$runner}{"plus_$d[$d]"} = $plus + 0;
	$time{$runner}{"minus_$d[$d]"} = $minus + 0;

#	print qq{time{$runner}{"minus_$d[$d]"} = $minus\n};
#	print qq{time{$runner}{"plus_$d[$d]"} = $plus\n};
    }
}


foreach my $first (sort {$time{$a}{rank} <=> $time{$b}{rank}} keys %time){
    print "$first\t$time{$first}{64}($time{$first}{rank_64})\t\t$time{$first}{103}($time{$first}{rank_103} $time{$first}{plus_103}+ $time{$first}{minus_103}-)\t\t$time{$first}{159}($time{$first}{rank_159} $time{$first}{plus_159}+ $time{$first}{minus_159}-)\t\t$time{$first}{199}($time{$first}{rank_199} $time{$first}{plus_199}+ $time{$first}{minus_199}-)\t\t$time{$first}{end}($time{$first}{rank} $time{$first}{plus_end}+ $time{$first}{minus_end}-)\t\n";
}










sub convert {
    my $timestr = shift;

    if($timestr =~ m{(\d+):(\d+)(:(\d+))?}){
	if($3){
	    return $1*3600+$2*60+$4;
	}
	else {
	    return $1*60+$2;
	}
    }
    return;
}
