#!/usr/bin/perl -I/home/phil/perl/cpan/GitHubCrud/lib/
#-------------------------------------------------------------------------------
# Convert Dita to Html forms
# Philip R Brenan at gmail dot com, www.ryffine.com, 2019
#-------------------------------------------------------------------------------
use warnings FATAL => qw(all);
use strict;
use Carp qw(confess cluck);
use Data::Dump qw(dump);
use Data::Edit::Xml;
use Data::Table::Text qw(:all);
use GitHub::Crud;
use utf8;

use feature qw(say current_sub);
sub upload           {&develop ? 0 : 1}                                         # Upload to S3 Bucket if true and the conversion is at 100%, 2 - upload to S3 Bucket regardless, 0 - no upload to S3 Bucket.
sub home             {q(/home/phil/r/z/ditaToHtmlForms/)}                       # Home folder containing all the other folders.
sub in               {fpd(&home,    qw(in))}                                    # Input documents folder.
sub out              {fpd(&home,    qw(out))}                                   # Converted documents output folder.
sub perl             {fpd(&home,    qw(perl))}                                  # Perl folder.
sub ghUser           {q(philiprbrenan)}                                         # GitHub repo owner

sub convertFile($)                                                              # Convert a file
 {my ($inputFile) = @_;                                                         # File

  my $x = Data::Edit::Xml::new($inputFile);                                     # Parse the source file

  $x->by(sub                                                                    # Convert the source Dita to Html
   {my ($o) = @_;
    $o->change_html_concept;
    $o->wrapWith_head if $o->at_title_concept;
    $o->change_body_conbody;
    $o->change_a_xref;

    if ($o->at_p)                                                               # p
     {if (my $id = $o->id)
       {$o->putLastAsText(<<END);
<input name="$id" size="32" type="text"/>
END
       }
     }

    if ($o->at_ol or $o->at_ul)                                                 # ol/ul
     {if (my $id = $o->id)
       {for my $l(@$o)
         {my $name = $id.q(_).nameFromString($o->stringContent);
          my $type = -t $o eq q(ol) ? q(checkbox) : q(radio);
          $l->putFirstAsText(<<END);
<input name="$name" type="$type"/>
END
         }
       }
     }
   });

  my $o = swapFilePrefix($inputFile, in, out);                                  # Output file
     $o = setFileExtension($o, q(html));
  my $html = -p $x;
  owf($o, $html);                                                               # Write html

  if (1)
   {my $u = ghUser;
    my @files = ([fne($o), $html],                                              # Files to create on GitHub
                 [fne($inputFile), readBinaryFile($inputFile)]);
    for my $file(@files)
     {my ($f, $c) = @$file;
      GitHub::Crud::writeFileUsingSavedToken($u, qq($u.github.io), $f, $c);
     }
    lll "Please see:  $u.github.io/".fne($o);
   }
 }

lll "Convert Dita to Html Forms";

my @inputFiles = searchDirectoryTreesForMatchingFiles(in);                      # Input files

for my $input(@inputFiles)                                                      # Convert each input file
 {convertFile($input);
 }

GitHub::Crud::writeFileFromFileUsingSavedToken(ghUser, ghUser.qq(.github.io),   # Back up perl
  fpf(qw(perl), fne($0)), $0);
