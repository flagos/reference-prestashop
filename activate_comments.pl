#!/usr/bin/perl

use DBI;

require "config.pl";

# Uncomment to debug
#print "host: ".$Presta_host;
#print "port: ".$Presta_port;
#print "DB: ".$Presta_db;
#print "user: ".$Presta_login;
#print "pass: ".$Presta_pass."\n";


my $dbh = DBI->connect('dbi:mysql:'.$Presta_db.':'.$Presta_host.':'.$Presta_port, $Presta_login,$Presta_pass)
 or die "Connection Error: $DBI::errstr\n";

$sql = "SELECT ps_product.id_product
        FROM ps_product";

$sth = $dbh->prepare($sql);
$sth->execute
    or die "SQL Error: $DBI::errstr\n";

print "delete from ps_product_comment_criterion_product where id_product_comment_criterion = 5;";

     while (@row = $sth->fetchrow_array) {
     	$row[0]=~ s/\[.*\]//;
          print "INSERT ps_product_comment_criterion_product SET id_product= $row[0], id_product_comment_criterion = 5;\n";
	   }



