%module highlight
%include stl.i
%include std_string.i
%apply const std::string& { const string& };
%apply  std::string {  string };

%{
#include "../../src/core/codegenerator.h"
%}

%include "../../src/core/enums.h"
%include "../../src/core/languagedefinition.h"
%include "../../src/core/codegenerator.h"
