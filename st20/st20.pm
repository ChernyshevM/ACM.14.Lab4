package ST20; 
use strict;
use LWP::UserAgent;
use HTTP::Request;
my $region;

sub st20
{       $region = 2;
        print "1. *Add regions*\n";
        print "2. *Load the List from dbm-file*\n";
        print "3. *Save the List to the dbm-file*\n";
        print "4. *Send to the DB*\n";
        print "5. *Exit*\n";


        my %List;
        my %command =  (1 => \&AddRegion,
                        2 => \&LoadFromFile,
                        3 => \&SaveToFile,
                        4 => \&SendToBase);

        print " \nEnter number of operation :   ";
        while (<STDIN>)
        {
                chomp;
                exit if $_ == 5;
                if ($command{$_})
                {
                        $command{$_}->(\%List);
                }
                else
                {
                        print "Don't know!    ";
                }
                print "\nEnter number of operation :   ";
        }
}
sub by_num
{
        return $a <=> $b;
}

sub AddRegion
{       no warnings 'uninitialized';
        my($param1) = @_;
        my $tmp = (sort by_num keys %$param1)[-1] + 1;

        print "Enter Region:     ";
        chomp (my $Region = <STDIN>);

        print "Enter Department:     ";
        chomp (my $Department= <STDIN>);

        print "Enter Employee :     ";
        chomp (my $Employee= <STDIN>);

        print "Enter 1, if region is Middle Europe, else enter 0:      ";
        chomp (my $Prpost= <STDIN>);

        %$param1 = (%$param1, $tmp, [$Region, $Department, $Employee, $Prpost]);

        print "The region $Region $Department has been added to the list \n";
}

sub LoadFromFile
{       no warnings 'uninitialized';
        my($param1) = @_;
        my @tmpmass;
        my %tmphash;
        my $n = 0;

        if (dbmopen (%tmphash, '1', undef))
        {
                foreach $n(sort keys %tmphash)
                {
                        my @tmpmass = split(/::/, $tmphash{$n});

                        %$param1 = (%$param1, (sort by_num keys %$param1)[-1] + 1, \@tmpmass);

                }
                dbmclose (%tmphash);
                print "\nSuccessfully loaded!\n";
        }
        else
        {
                print "\nThe file can not be loaded\n";
        }

        my $u;
        my $k = 0;

        foreach $u (sort by_num keys %$param1)
        {
                $k++;
                print "$k. ID = $u $param1->{$u}[0] $param1->{$u}[1], $param1->{$u}[2] \n";
        }
        print "\nList is empty! \n" if $k == 0;
}
sub SaveToFile
{
        my($param1) = @_;
        my %tmphash;
        my $n = 0;
        my $k = 0;

        print "Enter Size of file     ";
        chomp (my $FileSize = <STDIN>);

        if (dbmopen (%tmphash, $FileSize, 0664))
        {
                %tmphash = ();

                foreach $n (sort by_num keys %$param1)
                {
                        $k++;
                        $tmphash{$k} = join ("::", ($param1->{$n}[0], $param1->{$n}[1], $param1->{$n}[2], $param1->{$n}[3]));

                }

                dbmclose (%tmphash);
                print "\nSuccessfully saved!\n";
        }
        else
        {
                print "\nThe list can not be saved!\n";
        }
}

sub SendToBase
{		my($param1) = @_;
        my $s = 'http://localhost/cgi-bin/lab3.cgi';
        my $ua = new LWP::UserAgent;
        my $req;

        foreach my $n (sort by_num keys %$param1)
        {
                $req = new HTTP::Request(GET => $s.'?region='.$region.'&Region='.$param1->{$n}[0].'&Department='.$param1->{$n}[1].'&Employee='.$param1->{$n}[2].'&Prpost='.$param1->{$n}[3].'&type=doedit&id=');
                $ua->request($req);
        }
}
return 1;
