#!/usr/bin/perl -I/home/phil/perl/cpan/GitHubCrud/lib/
#-------------------------------------------------------------------------------
# Convert Dita to Html forms and load to GitHub
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
sub ghRepo           {ghUser.q(.github.io)}                                     # GitHub repo name

sub convertFile($)                                                              # Convert a file
 {my ($inputFile) = @_;                                                         # File

  my $source = expandWellKnownUrlsInDitaFormat readFile($inputFile);            # Read the source

  my $x = Data::Edit::Xml::new($source);                                        # Parse the source

  $x->by(sub                                                                    # Convert the source Dita to Html
   {my ($o) = @_;
    $o->change_html_concept;
    $o->wrapWith_head if $o->at_title_concept;
    $o->change_div_section;
    $o->change_h2_title_section;
    $o->change_body_conbody;
    $o->change_a_xref;
    $o->change_b_uicontrol;

    if ($o->at_p)                                                               # p
     {if (my $id = $o->id)
       {$o->putLastAsText(<<END);
<input name="$id" size="32" type="text" onchange="updateFields('$id', this.value)"/>
END
       }
     }

    if ($o->at_ol or $o->at_ul)                                                 # ol/ul
     {if (my $id = $o->id)
       {for my $l(@$o)
         {my $name = $id.q(_).nameFromString($o->stringContent);
          my $type = -t $o eq q(ol) ? q(checkbox) : q(radio);
          $l->putFirstAsText(<<END);
<input name="$name" type="$type" onchange="updateFields('$name', this.value)"/>
END
         }
       }
     }
   });

  my $o = swapFilePrefix($inputFile, in, out);                                  # Output file
     $o = setFileExtension($o, q(html));

  my $title = $x->go_head_title->stringContent;                                 # Get title of form
  $x->go_body->putLastAsText(<<END);                                            # Js to collect values
<script>
var fieldValues = {};
function updateFields(field, value)
 {fieldValues[field] = value;
  const m = document.getElementById("mailto");
  const e = m.getAttribute("outputclass");
  const s = encodeURIComponent("Ryffine Migration Readiness Assessment");
  const b = encodeURIComponent(JSON.stringify(fieldValues));
  m.href  = "mailto:"+e+"?subject="+s+"&body="+b
 }
</script>
END
  my $html = -p $x;
  owf($o, $html);                                                               # Write html

  if (1)                                                                        # Send files to GitHub
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

my @inputFiles = searchDirectoryTreesForMatchingFiles(in, qw(xml dita));        # Input files

for my $input(@inputFiles)                                                      # Convert each input file
 {convertFile($input);
 }

sub sendGH($$)                                                                  # Write a file to GitHub
 {my ($s, $t) = @_;
  GitHub::Crud::writeFileFromFileUsingSavedToken(ghUser, ghRepo, $s, $t);       # Back up perl
 }

if (1)
 {sendGH(fpf(qw(perl), fne($0)), $0);                                           # Perl
  sendGH(q(selfServiceXref.pdf), q(/home/phil/r/www/doc/out/xref.pdf));         # Self service xref
 }
