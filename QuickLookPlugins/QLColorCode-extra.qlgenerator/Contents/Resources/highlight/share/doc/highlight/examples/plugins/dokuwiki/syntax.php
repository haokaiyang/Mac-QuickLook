<?php
/*
Plugin Name: Highlight
Plugin URI: http://www.andre-simon.de
Description: Plugin which uses the highlight utility to generate coloured source code
Author: André  Simon
Version: 1.2
Author URI: http://www.andre-simon.de


This file is part of Highlight.

Highlight is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Highlight is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Highlight.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
== Description ==

The highlight utility converts source code of 120 programming languages to HTML 
with syntax highlighting. This plugin pipes the content of <highlight>-Tags associated
with a lang parameter to highlight, and returns the output code which is included
in the Wiki page.

Usage:

Paste the following in the edit section of the wiki editing form:

<highlight cpp>#include <stdio.h>

int main (void){
  printf("This is some random code");
  return 0;
}</highlight>

Use the lang parameter to define the programming language (c, php, py, xml, etc).
See the highlight documentation to learn all possible languages.
See the syntax.php file for some formatting options (line numbering, code
indentation, line wrapping etc).

== Installation ==

1. Install highlight (www.andre-simon.de) on your host
2. Unzip the dokuwiki_highlight.zip file and upload the content to the 
   `lib/plugins/` directory
 */
 
if(!defined('DOKU_INC')) define('DOKU_INC',realpath(dirname(__FILE__).'/../../').'/');
if(!defined('DOKU_PLUGIN')) define('DOKU_PLUGIN',DOKU_INC.'lib/plugins/');
require_once(DOKU_PLUGIN.'syntax.php');
 
class syntax_plugin_highlight extends DokuWiki_Syntax_Plugin {

    function getInfo(){
        return array(
            'author' => 'Andre Simon',
            'email'  => 'andre.simon1@gmx.de',
            'date'   => '2007-05-29',
            'name'   => 'Highlight Plugin',
            'desc'   => 'Plugin which uses the highlight utility (http://www.andre-simon.de) instead of Geshi for source code highlighting',
            'url'    => 'http://wiki.splitbrain.org/wiki:plugins',
        );
    }
 
    /**
     * What kind of syntax are we?
     */
    function getType(){
        return 'formatting';
    }
 
    /**
     * What kind of syntax do we allow (optional)
     */
//    function getAllowedTypes() {
//        return array();
//    }
 
    /**
     * What about paragraphs? (optional)
     */
    function getPType(){
      return 'block';
    }
 
    /**
     * Where to sort in?
     */ 
    function getSort(){
        return 199;
    }
 
 
    /**
     * Connect pattern to lexer
     */
    function connectTo($mode) {
      $this->Lexer->addEntryPattern('<highlight(?=[^\r\n]*?>.*?</highlight>)',$mode,'plugin_highlight');
    }
 
    function postConnect() {
      $this->Lexer->addExitPattern('</highlight>','plugin_highlight');
    }

    /**
     * Handle the match
     */
    function handle($match, $state, $pos, &$handler){

        switch ($state) {
          case DOKU_LEXER_ENTER :
		break;
          case DOKU_LEXER_UNMATCHED : 
             list($lang, $content) = preg_split('/>/u',$match,2);
             $lang = trim($lang);
             return array($state, $lang, $content);

          case DOKU_LEXER_EXIT :
              break;
        }
        return array();
    }
 
    /**
     * Create output
     */
    function render($mode, &$renderer, $data) {
	// Highlight options:
	$hl_options=array();
	$hl_options['hl_binary']='highlight';  // path to the highlight binary
	$hl_options['linenumbers']=false;
	$hl_options['theme']='kwrite';       // set color theme
	$hl_options['linenumber-start']=1;
	$hl_options['linenumber-zeroes']=1;  // set to 1 if line numbers should be padded with zeros
	$hl_options['linenumber-length']=2;
	$hl_options['reformat-style']="gnu"; // possible values for C, C++ and Java Code: ansi, gnu, java, kr, linux
	$hl_options['replace-tabs']=4;       //number of spaces which replace a tab
	$hl_options['wrap-style']=2;         //0 -> disable, 1-> wrap, 2-> wrap and indent function names
	$hl_options['wrap-line-length']=80;  // if wrap-style <>0, this defines the line length before wrapping takes place


       if($mode == 'xhtml'){
            list($state, $lang, $input_code) = $data;
			$lang = preg_replace("'[^a-zA-Z]'","",$lang);
            switch ($state) {
              case DOKU_LEXER_ENTER :
			break;
 
              case DOKU_LEXER_UNMATCHED : // $renderer->doc .= $renderer->_xmlEntities($match); break;
		
			$search = array("&amp;","&quot;", "&lt;", "&gt;","&#92;","&#39;","&nbsp;");
			$replace = array("&","\"", "<", ">","\\","\'", " ");
			$input_code = str_replace($search, $replace, $input_code);
	
			$descriptorspec = array(
			0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
			1 => array("pipe", "w")  // stdout is a pipe that the child will write to
			);
			
			$hl_cmd_str = $hl_options['hl_binary'];
			$hl_cmd_str .= ' --inline-css -f ';
			
			if ($hl_options['linenumbers']){
				$hl_cmd_str .= " -l -m ";
				$hl_cmd_str .= $hl_options['linenumber-start'];
				if ($hl_options['linenumber-zeroes']){
					$hl_cmd_str .= " -z -j ";
					$hl_cmd_str .= $hl_options['linenumber-length'];
				}
			}
			
			if ($hl_options['replace-tabs']) {
				$hl_cmd_str .= " -t ";
				$hl_cmd_str .= $hl_options['replace-tabs'];
			}
			
			if ($hl_options['wrap-style']){
				$hl_cmd_str .= ($hl_options['wrap-style'] == 1)? ' -V ':' -W ';
				$hl_cmd_str .= " -J ";
				$hl_cmd_str .= $hl_options['wrap-line-length'];
			}
			
			if ($hl_options['reformat-style']){
				$hl_cmd_str .= " -F ";
				$hl_cmd_str .= $hl_options['reformat-style'];
			}
			
			if ($hl_options['theme']){
					$hl_cmd_str .= " -s ";
					$hl_cmd_str .= $hl_options['theme'];
			}

			$hl_cmd_str .= " -S $lang ";
	
			$process = proc_open($hl_cmd_str, $descriptorspec, $pipes);
	
			if (is_resource($process)) {
	
				fwrite($pipes[0], $input_code);
				fclose($pipes[0]);
	
				$output = stream_get_contents($pipes[1]);
				fclose($pipes[1]);
	
				// It is important that you close any pipes before calling
				// proc_close in order to avoid a deadlock
				proc_close($process);
			}
			if (!strlen($output)) {
				$renderer->doc .= "<small>ERROR: Execution of highlight ($hl_cmd_str) failed or missing input. Check binary  path.</small>"; 
				$renderer->doc .= "<pre style=\"font-size:9pt;\">";
				$renderer->doc .= $renderer->_xmlEntities($input_code); 
				$renderer->doc .= "</pre>"; 
				
			} else {
				$renderer->doc .= "<pre style=\"font-size:9pt;\">";
				$renderer->doc .= $output;
				$renderer->doc .= "</pre>"; 
			}

			//$renderer->doc .= "<br>cmd=".$hl_cmd_str;

			break;
              case DOKU_LEXER_EXIT :
			break;
            }
            return true;
        }
        return false;
   }
}

