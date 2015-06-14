#!/usr/bin/perl -w

#To use it in openhab:
#Number I_Vigiecrues	"Water level is: [%s]"	{ exec="<[/usr/local/libexec/openhab_vigicrues.pl --idspc '5' --idstation '1100':3600000:REGEX((.*?);.*)]" }


#Declaration of Perl Modules to use.
use strict;
use HTML::TreeBuilder;
use Pod::Usage;
use Getopt::Long;

my ($idspc,$idstation,$warning,$critical, $mesure, $date);
my $trmesure = 0;
my $trdate = 0;

GetOptions(
           's|spc|idspc=i' => \$idspc,
           'i|ista|idstation=i' => \$idstation,
        );

if(!$idspc ||!$idstation){ print "VigiCrues -  Error in options."; }

my $html = "http://www.vigicrues.ecologie.gouv.fr/niveau3.php?idstation=$idstation&idspc=$idspc&typegraphe=h&AffProfondeur=24&AffRef=tous&AffPrevi=non&nbrstations=5&ong=2";

#Parse html content using html-treebuilder:
my $root = HTML::TreeBuilder->new_from_url($html);
$root->eof();

my @tables = $root->look_down(_tag => 'table');
while (@tables) {
    my $node = shift @tables;
    if (ref $node) {
        unshift @tables, $node->content_list;
    }
    else {
        if($node =~ /(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2})/)
        {
                $date = "$1/$2/$3 $4:$5";
                #print "my date : " . $date . "\n";
                $trdate = 1;
        }

        if($node =~ /(-?\d+)\.(\d+)/)
        {
                $mesure = sprintf("%.2f",$node);
                #print "my mesure : " . $mesure . "\n";
                $trmesure = 1;
        }

        if($trmesure eq 1 && $trdate eq 1) { last;}
    }
}
$root = $root->delete;

print "$mesure;$date";
