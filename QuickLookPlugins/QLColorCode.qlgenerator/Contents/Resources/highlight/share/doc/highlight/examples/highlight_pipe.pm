package highlight_pipe;

# This Perl package serves as interface to the highlight utility.
# Input and output streams are handled with pipes.
# Command line parameter length is validated before use.

use IPC::Open3;

my $hl_bin='highlight';

sub new {
 my $object = shift;
 my $ref = {};
 bless($ref,$object);
 return($ref);
}

sub getResult {
  my $object = shift;
  my $src = shift;

  my @hl_args = ();
  my $option;
  while ( my ($key, $value) = each(%$object) ) {
        $option =" --$key";
        if ($value ne "1") {$option .= "=$value"};
        if (length($option)<50) { push (@hl_args, $option); }
  }
  local(*HIS_IN, *HIS_OUT, *HIS_ERR);

  my $childpid = IPC::Open3::open3(\*HIS_IN, \*HIS_OUT, \*HIS_ERR, $hl_bin. join ' ', @hl_args) 
                 or die ("error invoking highlight");

  print HIS_IN $src;
  close(HIS_IN);            # Give end of file to kid.

  my @outlines = <HIS_OUT>; # Read till EOF.
  my @errlines = <HIS_ERR>; # Read till EOF.
  close HIS_OUT;
  close HIS_ERR;
  waitpid($childpid, 0);

  if (@errlines) { die (join '\n', @errlines); }

  return join '', @outlines;
}

###############################################################################
# Sample code:

# insert use statement in other perl scripts:
#use highlight_pipe;

my $html = highlight_pipe -> new();

$html->{'syntax'} ='c';
$html->{'fragment'} = 1;
$html->{'inline-css'} = 1;
$html->{'enclose-pre'} = 1;
$html->{'style'} = 'vim';

my $input='int main () { return 0; }';
my $output=$html->getResult($input);

print "Result:\n$output\n";
