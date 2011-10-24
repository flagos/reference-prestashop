#!/usr/bin/perl

use DBI;

require "config.pl";

# Uncomment to debug
#print "host: ".$Presta_host;
#print "port: ".$Presta_port;
#print "DB: ".$Presta_db;
#print "user: ".$Presta_login;
#print "pass: ".$Presta_pass."\n";

local $| = 1; # Autoflush STDOUT                                                                                                                                             

my $dbh = DBI->connect('dbi:mysql:'.$Presta_db.':'.$Presta_host.':'.$Presta_port, $Presta_login,$Presta_pass)
 or die "Connection Error: $DBI::errstr\n";

$sql = "SELECT ps_product_lang.name, ps_manufacturer.name as manufacturer, ps_product.ean13,ps_product.price
        FROM ps_product_lang
        INNER JOIN ps_product
        ON ps_product_lang.id_product=ps_product.id_product
        INNER JOIN ps_manufacturer
        ON ps_product.id_manufacturer=ps_manufacturer.id_manufacturer
	INNER JOIN ps_category_product
	ON ps_product.id_product=ps_category_product.id_product
	INNER JOIN ps_category_lang
	ON ps_category_lang.id_category=ps_category_product.id_category AND ps_category_lang.id_lang=ps_product_lang.id_lang WHERE ps_product.ean13 != \"\"";

$sth = $dbh->prepare($sql);
$sth->execute
    or die "SQL Error: $DBI::errstr\n";

     while (@row = $sth->fetchrow_array) {
	   print "$row[3] $row[2] $row[0] $row[1]\n" 
	   }



