<?php

/**This PHP class serves as interface to the highlight utility.
Input and output streams are handled with pipes.
Command line parameters are validated before use.
*/

class HighlightPipe {

  // alter these members to control highlight output
  // see manpage for the options

  var $hl_option = array(
  'hl_bin' => 'highlight',     // configure path of highlight binary
  'syntax' => 'txt',
  'theme' => 'kwrite',
  'force' => 1,
  'linenumbers' => 0,
  'line-number-length' => 4,
  'line-number-start' => 0,
  'zeroes' => 0,
  'wraptype' => 0,
  'line-length' => 0,
  'reformat' => '',
  'kw-case' => '',
  'replace-tabs' => 0,
  'encoding' => '',
  'enclose-pre' => 1,
  'inline-css' => 1,
  'fragment' => 1,
  );

  // this member contains the input source code
  var $input='';

  // this member will contain the command string after getResult() was called
  var $hl_cmd_str='';

  function getInfo(){
        return array(
            'author' => 'Andre Simon',
            'email'  => 'andre.simon1@gmx.de',
            'date'   => '2008-02-20',
            'url'    => 'http://www.andre-simon.de/',
            'version'    => '1.1',
        );
  }

  // call this method to generate highlighted HTML code
  function getResult() {

        foreach ($this->hl_option as $key => $value) {
          $this->hl_option[$key] = $this->validate( $value );
        }

	$descriptorspec = array(
	0 => array("pipe", "r"),
	1 => array("pipe", "w")
	);
	
	$this->hl_cmd_str = $this->hl_option['hl_bin'];
	
	if ($this->hl_option['linenumbers']){
		$this->hl_cmd_str .= " -l -m 1";
		/*$this->hl_cmd_str .= $this->get_config('hl_linenumbersberstart');*/
		if ($this->hl_option['zeroes']){
			$this->hl_cmd_str .= " -z ";
		}
		if ($this->hl_option['line-number-length']!='0' && is_numeric($this->hl_option['line-number-length'])) {
			$this->hl_cmd_str .= ' -j ';
			$this->hl_cmd_str .=$this->hl_option['line-number-length'];
		}
	}
	
	if (is_numeric($this->hl_option['replace-tabs']) and $this->hl_option['replace-tabs']>0) {
		$this->hl_cmd_str .= " -t ";
                $this->hl_cmd_str .= $this->hl_option['replace-tabs'];
	}
	
	if ($this->hl_option['wraptype']>0){
		$this->hl_cmd_str .= ($this->hl_option['wraptype'] == 1)? ' -V ':' -W ';
		if ($this->hl_option['line-length']>0 && is_numeric($this->hl_option['line-length'])) {
			$this->hl_cmd_str .= " -J ";
			$this->hl_cmd_str .= $this->hl_option['line-length'];
		}
	}
	
	if (strlen($this->hl_option['reformat'])>1){
		$this->hl_cmd_str .= " -F ";
		$this->hl_cmd_str .= $this->hl_option['reformat'];
	}

	if (strlen($this->hl_option['kw-case'])>1){
		$this->hl_cmd_str .= " --kw-case ";
		$this->hl_cmd_str .= $this->hl_option['kw-case'];
	}

	if ($this->hl_option['force']){
		$this->hl_cmd_str .= " --force ";
	}

	if ($this->hl_option['inline-css']){
		$this->hl_cmd_str .= " --inline-css ";
	}

	if ($this->hl_option['fragment']){
		$this->hl_cmd_str .= " -f ";
	}
	
	if ($this->hl_option['theme']){
		$this->hl_cmd_str .= " -s ";
		$this->hl_cmd_str .= $this->hl_option['theme'];
	}

	if ($this->hl_option['encoding']){
		$this->hl_cmd_str .= " -u ";
		$this->hl_cmd_str .= $this->hl_option['encoding'];
	}

	if ($this->hl_option['enclose-pre']){
		$this->hl_cmd_str .= " --enclose-pre ";
	}

	$this->hl_cmd_str .= " -S  ";
	$this->hl_cmd_str .= $this->hl_option['syntax'];

	$process = proc_open($this->hl_cmd_str, $descriptorspec, $pipes);
	if (is_resource($process)) {

		fwrite($pipes[0], $this->input);
		fclose($pipes[0]);

		$output = stream_get_contents($pipes[1]);
		fclose($pipes[1]);

		// It is important that you close any pipes before calling
		// proc_close in order to avoid a deadlock
		proc_close($process);
	}
        return $output;
    }

 
   // PRIVATE STUFF
   var $special = array(' ', '/','!','&','*','\\', '.', '|', '´','\'', '<', '>');

   function validate($string) {
      return (strlen($string)>50)? "" : str_replace($this->special,"",$string);
   }

  }

/*****************************************************************************/

/*

// Sample code:

  $generator = new HighlightPipe;
  $generator->input='int main () { return 0; }';

  $generator->hl_option['theme']='neon';
  $generator->hl_option['syntax']='c';

  $result= $generator->getResult();

  print $result;
*/

?>