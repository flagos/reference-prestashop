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

$sql = "SELECT ps_product_lang.name, ps_manufacturer.name as manufacturer, ps_product.id_product, ps_product_lang.meta_keywords, ps_category_lang.name
        FROM ps_product_lang
        INNER JOIN ps_product
        ON ps_product_lang.id_product=ps_product.id_product
        INNER JOIN ps_manufacturer
        ON ps_product.id_manufacturer=ps_manufacturer.id_manufacturer
	INNER JOIN ps_category_product
	ON ps_product.id_product=ps_category_product.id_product
	INNER JOIN ps_category_lang
	ON ps_category_lang.id_category=ps_category_product.id_category AND ps_category_lang.id_lang=ps_product_lang.id_lang where ps_category_lang.id_lang=2";

$sth = $dbh->prepare($sql);
$sth->execute
    or die "SQL Error: $DBI::errstr\n";

     while (@row = $sth->fetchrow_array) {
     	$row[0]=~ s/\[.*\]//;
          my $custom_tags = "";
	  my $category_tags = "";
	  my $manufacturer_tags = "";
	  if ($row[3] =~ m/.*cosmetique\s*,(.*)/){

		$custom_tags = $1;
#		print "*** $row[0]= $custom_tags id_product= $row[2] lang= $row[4]\n";	
	  }
	$sql2 = "SELECT ps_category_lang.meta_keywords, ps_category_lang.name, ps_category_lang.id_category
		FROM ps_category_product
		INNER JOIN ps_category_lang
		ON ps_category_lang.id_category=ps_category_product.id_category 
		WHERE ps_category_product.id_product=$row[2] AND  ps_category_lang.id_lang=2";

	$sth2 = $dbh->prepare($sql2);
	$sth2->execute
	    or die "SQL Error: $DBI::errstr\n";
     while (@row2 = $sth2->fetchrow_array) {
		$row2[0] =~ s/,*\s*lilibio\s*//;
		$row2[0] =~ s/,*\s*bio\s*//;
		$row2[0] =~ s/,*\s*cosmetique\s*//;
		$row2[0] =~ s/,*\s*grenoble\s*//;
                $row2[0] =~ s/,\s*,/,/;

		$category_tags .= "$row2[0], ";

	}	
	$category_tags = substr($category_tags, 0, 255);
#	print "category tags: $category_tags\n";

	$sql2 = "SELECT ps_manufacturer_lang.meta_keywords
		FROM ps_manufacturer_lang
		INNER JOIN ps_product
		ON ps_manufacturer_lang.id_manufacturer=ps_product.id_manufacturer
		WHERE ps_product.id_product=$row[2] AND  ps_manufacturer_lang.id_lang=2";
      $sth2 = $dbh->prepare($sql2);
      $sth2->execute
	or die "SQL Error: $DBI::errstr\n";
	while (@row2 = $sth2->fetchrow_array) {
	     $row2[0] =~ s/,*\s*lilibio\s*//;
	     $row2[0] =~ s/,*\s*bio\s*//;
             $row2[0] =~ s/,*\s*cosmetique\s*//;
	     $row2[0] =~ s/,*\s*grenoble\s*//;
    	     $manufacturer_tags .= "$row2[0], ";
       }
#	print "manufacturer tags: $manufacturer_tags\n";

	my $tags = "$category_tags, $manufacturer_tags, $row[0], $row[1], $row[4], lilibio, bio,grenoble, naturel, cosmetique, $custom_tags ";
	$tags =~ s/\s+/ /;
	$tags =~ s/(,\s*,)+/,/;
        $tags =~ s/(,\s*,)+/,/;
	$tags =~ s/(,\s*,)+/,/;
	
	$tags = substr($tags, 0, 254); 


	  print "UPDATE ps_product_lang SET ps_product_lang.meta_keywords = \"$tags\" WHERE ps_product_lang.id_product = $row[2];\n";
	   }



