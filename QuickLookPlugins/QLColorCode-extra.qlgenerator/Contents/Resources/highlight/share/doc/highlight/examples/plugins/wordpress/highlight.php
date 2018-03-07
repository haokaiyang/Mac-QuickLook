<?php
/*
Plugin Name: Highlight
Plugin URI: http://www.andre-simon.de
Description: Plugin which uses the highlight utility to generate coloured source code
Author: Andre Simon
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

// Highlight options:

$hl_options=array();
$hl_options['hl_binary']='highlight';  // path to the highlight binary
$hl_options['theme']='kwrite';         // set color theme
$hl_options['linenumbers']=true;
$hl_options['linenumber-start']=1;
$hl_options['linenumber-zeroes']=1;  // set to 1 if line numbers should be padded with zeros
$hl_options['linenumber-length']=2;
$hl_options['reformat-style']="gnu"; // possible values for C, C++ and Java Code: ansi, gnu, java, kr, linux
$hl_options['replace-tabs']=4;       // number of spaces which replace a tab
$hl_options['wrap-style']=2;         // 0 -> disable, 1-> wrap, 2-> wrap and indent function names
$hl_options['wrap-line-length']=60;  // if wrap-style <>0, this defines the line length before wrapping takes place

class as_highlight {
	
	var $ch_is_excerpt = false;
	function __construct()
	{
		add_filter('the_content',array(&$this, 'hl_the_content_filter'),1);
	}
	// PHP 4 Constructor
	function as_highlight ()
	{
		$this->__construct() ;
	}
	
	function as_highlight_code($matches){
		global $hl_options;
		
		$lang = preg_replace("'[^a-zA-Z]'","",$matches[1]);
		// undo nl and p formatting
		$input_code = $matches[2];
		$input_code = preg_replace("'<br\s*\/?>\r?\n?'","\n",$input_code);
		$search = array("&amp;","&quot;", "&lt;", "&gt;","&#92;","&#39;","&nbsp;");
		$replace = array("&","\"", "<", ">","\\","\'", " ");
		$input_code = str_replace($search, $replace, $input_code);
		
		$descriptorspec = array(
		0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
		1 => array("pipe", "w")  // stdout is a pipe that the child will write to
		);
		
		$hl_cmd_str = $hl_options['hl_binary'];
		$hl_cmd_str .= ' --inline-css -I -f ';
		
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
			if (function_exists("stream_get_contents"))
			{
				$output = stream_get_contents($pipes[1]);
			}
			else
			{
				$output = "";
				while (!feof($pipes[1])) $output .= fgets($pipes[1]);
			}
			fclose($pipes[1]);

			// It is important that you close any pipes before calling
			// proc_close in order to avoid a deadlock
			$return_value = proc_close($process);
		}
		$newContent = "<pre>". $output ."</pre>";
		return $newContent;
	}
	
	function hl_the_content_filter($content) {
			return preg_replace_callback("/<pre\s+.*lang\s*=\"(.*)\">(.*)<\/pre>/siU",
							array(&$this, "as_highlight_code"),
							$content);
	}
}

if (!function_exists('as_highlight'))
	$as_highlight = new as_highlight();

?>
