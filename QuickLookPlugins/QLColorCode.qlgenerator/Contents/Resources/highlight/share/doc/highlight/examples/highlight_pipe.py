from subprocess import *

class HighlightPipe:
	""" This Python package serves as interface to the highlight utility.
	Input and output streams are handled with pipes.
	Command line parameter length is validated before use."""
	
	def __init__(self):
		self.cmd = 'highlight'
		self.src=''
		self.options=dict()
		self.success=False
		
	def getResult(self):
		cmd = self.cmd
		for k, v in self.options.iteritems():
			option=" --%s" % k
			if ( v != '1'): option += "=%s" % v
			if (len(option)<50): cmd += option
		p = Popen(cmd, shell=True, bufsize=512, stdin=PIPE, stdout=PIPE, stderr=PIPE, close_fds=True)
		(child_stdin, child_stdout, child_stderr) = (p.stdin, p.stdout, p.stderr)

		child_stdin.write(self.src)
		child_stdin.close()
		err_msg = child_stderr.readlines()
		if (len(err_msg)>0): return err_msg
		self.success=True
		return child_stdout.readlines()
			
			
###############################################################################

def main():
	gen = HighlightPipe();
	gen.options['syntax'] = 'c'
	gen.options['style'] = 'vim'
	gen.options['enclose-pre'] = '1'
	gen.options['fragment'] = '1'
	gen.options['inline-css'] = '1'
	gen.src = 'int main ()\n{ return 0; }'

	print gen.getResult()
	if not gen.success: print "Execution failed."
 
if __name__=="__main__":
	main()
