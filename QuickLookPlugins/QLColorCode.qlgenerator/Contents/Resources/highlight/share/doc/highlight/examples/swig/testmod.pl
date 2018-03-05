# Perl SWIG module test script
#
# Import highlight.pm, which is the interface for the highlight.so module.
# See highlight.pm for all available attributes and class members.

use highlight;

#get a generator instance (for HTML output)
my $gen = highlightc::CodeGenerator_getInstance($highlightc::HTML);


#initialize the generator with a colour theme and the language definition
$gen->initTheme("/usr/share/highlight/themes/kwrite.style");
$gen->loadLanguage("/usr/share/highlight/langDefs/c.lang");

#set some parameters
$gen->setIncludeStyle(1);
$gen->setEncoding("ISO-8859-1");

#get output string
my $output=$gen->generateString("int main(int argc, char **argv) {\n".
                           " HighlightApp app;\n".
                           " return app.run(argc, argv);\n".
                           "}\n");
print $output;

# clear the instance
highlightc::CodeGenerator_deleteInstance($gen);
