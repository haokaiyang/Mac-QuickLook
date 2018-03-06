/*
 * States definitions file for GNU Enscript.
 * Copyright (c) 1997-1998 Markku Rossi.
 * Author: Markku Rossi <mtr@iki.fi>
 *
 * The latest version of this file can be downloaded from URL:
 *
 *     http://www.iki.fi/~mtr/genscript/enscript.st
 */

/*
 * This file is part of GNU enscript.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

/*
 * $Id: enscript.st,v 1.1 1999/04/20 23:26:45 wsanchez Exp $
 */

/*
 * Guildelines for writing new highlighting rules for the GNU Enscript.
 *
 * - all pretty-printing states should have a document comment like this:
 *
 *   /**
 *    * Name: c
 *    * Description: C programming language.
 *    * Author: Author Name <author@email.address>
 *    * ...
 *
 *   It is used by enscript's --help-pretty-print option to print
 *   description about supported pretty-printing modes.
 *
 * - BEGIN and END rules must call header() and trailer() subroutines:
 *
 *   state c
 *   {
 *     BEGIN {
 *	 header ();
 *     }
 *     END {
 *	 trailer ();
 *     }
 *
 * - each state and possible help-states should have LANGUAGE_SPECIALS rule:
 *
 *     LANGUAGE_SPECIALS {
 *	 language_print ($0);
 *     }
 *
 * - all printing should be done with the language_print() procedure
 *   instead of the print() primitive.
 *
 * These rules ensures that enscript's --help-pretty-print option works
 * and that the many2html utility script can convert all the
 * --pretty-print supported languages to HTML.
 */

/* This script needs at least this version of the States program. */
prereq ("1.5.0");

/*
 * Constants, fonts, etc.
 */

debug = "0";

/* Boolean values. */
true = 1;
false = 0;

font_spec = "Courier@10";

/* These components are resolved from <font_spec>. */
font = "";
ptsize = "";

/*
 * Highlight levels.  Possible values are:
 * - none	no highlighting
 * - light	light highlighting (comments and highlights)
 * - heavy	give all
 */
hl_level = "heavy";

/*
 * Colormodel.	Possible values are:
 * - blackwhite		no colors, just black and white
 * - emacs		similar to emacs' font lock highlighting
 */
colormodel = "blackwhite";

/*
 * Target language.  Possible values are:
 * - enscript		generate enscript special escapes
 * - html		generate HTML
 * - overstrike		generate overstrike (line printers, less)
 * - texinfo		generate Texinfo
 * - rtf                generate Rich Text Format (rtf - MS Word, WordPerfect)
 *                      This code can be suched into MS Word or PowerPoint
 *                      for a pretty version of the code
 */
language = "enscript";

/*
 * How many input files we have.
 */
num_input_files = "1";
current_input_file = 0;

/*
 * Document title.
 */
document_title = "Enscript Output";


/*
 * Color definitions.
 */

cindex = 0;
rgb_values = list ();

sub define_color (name, r, g, b)
{
  rgb_values[cindex] = list (name, r, g, b);
  cindex = cindex + 1;
}

sub color_index (name)
{
  local i;

  for (i = 0; i < length (rgb_values); i = i + 1)
    if (strcmp (rgb_values[i][0], name) == 0)
      return i;

  return -1;
}

sub language_color (name)
{
  local idx;

  idx = color_index (name);
  if (idx < 0)
    panic ("unknown color `", name, "'");

  /*
   * The map_color() subroutine is language specific and defined in
   * *_faces() subroutine.
   */
  map_color (rgb_values[idx][1], rgb_values[idx][2], rgb_values[idx][3]);
}

/* RGB definitions for colors.	These are borrowed from X's rgb.txt file. */

define_color ("black",			0, 0, 0);
define_color ("blue",			0, 0, 255);
define_color ("cadet blue",		95, 158, 160);
define_color ("dark goldenrod",		184, 134, 11);
define_color ("dark olive green",	85, 107, 47);
define_color ("firebrick",		178, 34, 34);
define_color ("forest green",		34, 139, 34);
define_color ("orchid",			218, 112, 214);
define_color ("purple",			160, 32, 240);
define_color ("rosy brown",		188, 143, 143);

define_color ("DarkSeaGreen",		139, 179, 129);
define_color ("Goldenrod",		237, 218, 116);
define_color ("Aquamarine",		67, 183, 186);
define_color ("SeaGreen2",		100, 233, 134);
define_color ("Coral",			247, 101,  65);
define_color ("DarkSlateGray1",		154, 254, 255);


/*
 * General helpers.
 */

sub debug (msg)
{
  if (debug_level)
    print ("DEBUG: ", msg, "\n");
}

sub is_prefix (prefix, string)
{
  return strncmp (prefix, string, length (prefix)) == 0;
}

sub strchr (string, ch)
{
  local len = length (string), i;

  for (i = 0; i < len; i = i + 1)
    if (string[i] == ch)
      return i;

  return -1;
}

sub need_version (major, minor, beta)
{
  local r, v, i;

  regmatch (version, (/([0-9]+)\.([0-9]+)\.([0-9]+)/));
  v = list (int ($1), int ($2), int ($3));
  r = list (major, minor, beta);

  for (i = 0; i < 3; i = i + 1)
    if (v[i] > r[i])
      return 1;
    else if (v[i] < r[i])
      return 0;

  /* Exact match. */
  return 1;
}

/* Highlight types which match expression <re> from string <data>. */
sub highlight_types (data, re)
{
  local match_len;

  while (regmatch (data, re))
    {
      language_print ($B);
      type_face (true);
      language_print ($0);
      type_face (false);

      match_len = length ($B, $0);

      data = substring (data, match_len, length (data));
    }

  language_print (data);
}


/*
 * Output face definitions for different target languages.
 */

sub enscript_faces ()
{
  /* RGB -> PostScript color mapper function. */
  sub map_color (r, g, b)
    {
      return sprintf ("%f %f %f", r div 255.0, g div 255.0, b div 255.0);
    }

  /* No language special characters. */
  LANGUAGE_SPECIALS = 0;

  sub language_print (str)
    {
      print (str);
    }

  sub header ()
    {
      /* Nothing here. */
    }

  sub trailer ()
    {
      /* Nothing here. */
    }

  sub font (name)
    {
      print ("\0font{", name, "@", ptsize, "}");
    }

  sub color (name)
    {
      print ("\0color{", name, "}");
    }

  sub default ()
    {
      print ("\0font{default}");
      if (color)
	print ("\0color{default}");
    }

  sub bold (on)
    {
      if (on)
	{
	  font (bold_font);
	  if (color)
	    color (bold_color);
	}
      else
	default ();
    }

  sub italic (on)
    {
      if (on)
	{
	  font (italic_font);
	  if (color)
	    color (italic_color);
	}
      else
	default ();
    }

  sub bold_italic (on)
    {
      if (on)
	{
	  font (bold_italic_font);
	  if (color)
	    color (bold_italic_color);
	}
      else
	default ();
    }

  sub comment_face (on)
    {
      if (on)
	{
	  font (comment_face_font);
	  if (color)
	    color (comment_face_color);
	}
      else
	default ();
    }

  sub function_name_face (on)
    {
      if (on)
	{
	  font (function_name_face_font);
	  if (color)
	    color (function_name_face_color);
	}
      else
	default ();
    }

  sub variable_name_face (on)
    {
      if (on)
	{
	  font (variable_name_face_font);
	  if (color)
	    color (variable_name_face_color);
	}
      else
	default ();
    }

  sub keyword_face (on)
    {
      if (on)
	{
	  font (keyword_face_font);
	  if (color)
	    color (keyword_face_color);
	}
      else
	default ();
    }

  sub reference_face (on)
    {
      if (on)
	{
	  font (reference_face_font);
	  if (color)
	    color (reference_face_color);
	}
      else
	default ();
    }

  sub string_face (on)
    {
      if (on)
	{
	  font (string_face_font);
	  if (color)
	    color (string_face_color);
	}
      else
	default ();
    }

  sub builtin_face (on)
    {
      if (on)
	{
	  font (builtin_face_font);
	  if (color)
	    color (builtin_face_color);
	}
      else
	default ();
    }

  sub type_face (on)
    {
      if (on)
	{
	  font (type_face_font);
	  if (color)
	    color (type_face_color);
	}
      else
	default ();
    }
}


sub html_faces ()
{
  /* RGB -> HTML color mapper function. */
  sub map_color (r, g, b)
    {
      return sprintf ("#%02X%02X%02X", r, g, b);
    }

  LANGUAGE_SPECIALS = /[<>\&\"]/;

  sub language_print (str)
    {
      str = regsuball (str, /\&/, "&amp;");
      str = regsuball (str, /</, "&lt;");
      str = regsuball (str, />/, "&gt;");
      str = regsuball (str, /\"/, "&quot;");
      print (str);
    }

  sub header ()
    {
      local i;

      if (current_input_file == 1)
	{
	  print ("<!DOCTYPE html PUBLIC \"-//IETF//DTD HTML 2.0//EN\">\n");
	  print ("<HTML>\n<HEAD>\n<TITLE>");
	  language_print (document_title);
      print ("<TITLE>\n</HEAD>\n",
		 color
		 ? "<BODY BGCOLOR=\"#FFFFFF\" TEXT=\"#000000\" LINK=\"#1F00FF\" ALINK=\"#FF0000\" VLINK=\"#9900DD\">"
		 : "<BODY>",
		 "\n<A NAME=\"top\">\n");

	  if (need_version (1, 5, 1) && int (toc) == 1)
	    {
	      if (length (argv) == 0)
		argv[0] = "(stdin)";

	      print ("<H1>Contents</H1>\n<OL>\n");
	      for (i = 0; i < length (argv); i = i + 1)
		print ("  <LI><A HREF=\"#file", i + 1, "\">", argv[i],
		       "</A>\n");
	      print ("</OL>\n<HR>\n");
	    }
	}

      /* print ("<A NAME=\"file", current_input_file, "\">\n<H1>"); */
      /* language_print (filename); */

    /*
      if (int (num_input_files) > 1)
	print (" ", current_input_file, "/", num_input_files);

      print ("</H1>\n");
      */

      /* Navigation bar. */
      if (need_version (1, 5, 1))
	{
	  if (length (argv) >= 2 )
	    {
	      print ("[<A HREF=\"#top\">top</A>]");

	      if (current_input_file == 1)
		print ("[prev]");
	      else
		print ("[<A HREF=\"\#file", current_input_file - 1,
		       "\">prev</A>]");

	      if (current_input_file == length (argv))
		print ("[next]");
	      else
		print ("[<A HREF=\"#file", current_input_file + 1,
		       "\">next</A>]");
	    }
	}
      else
	print ("[<A HREF=\"#top\">top</A>]");
      print ("\n<pre style=\"font-family: Courier; font-size: 9pt\">\n");
    }

  sub trailer ()
    {
/*
      print ("</PRE>
<HR>\n");
      if (current_input_file == int (num_input_files))
	print ("<ADDRESS>Generated by ",
	       "<A HREF=\"http://www.iki.fi/~mtr/genscript/\">",
	     substring (version, strchr (version, 'G'), length (version)),
	     "</A>.</ADDRESS>
</BODY>
</HTML>\n");
*/
      print("</pre></BODY></HTML\n");
    }

  sub color_on (name)
    {
      print ("<FONT COLOR=\"", name, "\">");
    }

  sub color_off ()
    {
      print ("</FONT>");
    }

  sub bold (on)
    {
      if (on)
	print ("<B>");
      else
	print ("</B>");
    }

  sub italic (on)
    {
      if (on)
	print ("<I>");
      else
	print ("</I>");
    }

  sub bold_italic (on)
    {
      if (on)
	print ("<B><I>");
      else
	print ("</I></B>");
    }

  sub comment_face (on)
    {
      if (on)
	{
	  print ("<I>");
	  if (color)
	    color_on (comment_face_color);
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("</I>");
	}
    }

  sub function_name_face (on)
    {
      if (on)
	{
	  print ("<B>");
	  if (color)
	    color_on (function_name_face_color);
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("</B>");
	}
    }

  sub variable_name_face (on)
    {
      if (on)
	{
	  if (color)
	    color_on (variable_name_face_color);
	  else
	    print ("<B>");
	}
      else
	{
	  if (color)
	    color_off ();
	  else
	    print ("</B>");
	}
    }

  sub keyword_face (on)
    {
      if (on)
	{
	  print ("<B>");
	  if (color)
	    color_on (keyword_face_color);
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("</B>");
	}
    }

  sub reference_face (on)
    {
      if (on)
	{
	  print ("<B>");
	  if (color)
	    color_on (reference_face_color);
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("</B>");
	}
    }

  sub string_face (on)
    {
      if (on)
	{
	  if (color)
	    color_on (string_face_color);
	  print ("<B>");
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("</B>");
	}
    }

  sub builtin_face (on)
    {
      if (on)
	{
	  if (color)
	    color_on (builtin_face_color);
	  print ("<B>");
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("</B>");
	}
    }

  sub type_face (on)
    {
      if (on)
	{
	  if (color)
	    color_on (type_face_color);
	  print ("<B>");
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("</B>");
	}
    }
}


sub overstrike_faces ()
{
  sub map_color (r, g, b)
    {
      return "";
    }

  LANGUAGE_SPECIALS = /./;

  sub language_print (str)
    {
      if (italic_flag)
	print (regsuball (str, /[A-Za-z0-9]/, "_\010$0"));
      else if (bold_flag)
	print (regsuball (str, /./, "$0\010$0"));
      else
	print (str);
    }

  sub header ()
    {
      bold_flag = 0;
      italic_flag = 0;
    }

  sub trailer ()
    {
    }

  sub bold (on)
    {
      bold_flag = on;
    }

  sub italic (on)
    {
      italic_flag = on;
    }

  sub bold_italic (on)
    {
    }

  sub comment_face (on)
    {
      italic (on);
    }

  sub function_name_face (on)
    {
      bold (on);
    }

  sub variable_name_face (on)
    {
      bold (on);
    }

  sub keyword_face (on)
    {
      bold (on);
    }

  sub reference_face (on)
    {
      bold (on);
    }

  sub string_face (on)
    {
      bold (on);
    }

  sub builtin_face (on)
    {
      bold (on);
    }

  sub type_face (on)
    {
      italic (on);
    }
}


sub texinfo_faces ()
{
  /* Nop since Texinfo doesn't have colors. */
  sub map_color (r, g, b)
    {
      return "";
    }

  LANGUAGE_SPECIALS = /[{}@]/;

  sub language_print (str)
    {
      str = regsuball (str, /@/, "@@");
      str = regsuball (str, /{/, "@{");
      str = regsuball (str, /}/, "@}");
      print (str);
    }

  sub header ()
    {
      print ("@example\n");
    }

  sub trailer ()
    {
      print ("@end example\n");
    }

  sub bold (on)
    {
      if (on)
	print ("@strong{");
      else
	print ("}");
    }

  sub italic (on)
    {
      if (on)
	print ("@emph{");
      else
	print ("}");
    }

  sub bold_italic (on)
    {
    }

  sub comment_face (on)
    {
      italic (on);
    }

  sub function_name_face (on)
    {
      bold (on);
    }

  sub variable_name_face (on)
    {
      bold (on);
    }

  sub keyword_face (on)
    {
      bold (on);
    }

  sub reference_face (on)
    {
      bold (on);
    }

  sub string_face (on)
    {
    }

  sub builtin_face (on)
    {
      bold (on);
    }

  sub type_face (on)
    {
      if (on)
	print ("@emph{");
      else
	print ("}");
    }
}

/*
 * Definition for RTF output
 * Kevin Grover, <grover@wizard.com>
 */

sub rtf_color_map()
{
  local i;

  print ("{\\colortbl;");
  for (i = 0; i < length (rgb_values); i = i + 1)
    print (sprintf ("\\red%d\\green%d\\blue%d;",
	    rgb_values[i][1],
	    rgb_values[i][2],
	    rgb_values[i][3]));

  print ("}\n");

  return;
}

sub rtf_faces ()
{
  sub language_color (name)
    {
      local idx;

      idx = color_index (name);
      if (idx < 0)
	panic ("unknown color `", name, "'");

      return sprintf("\\cf%d",idx);
    }

  LANGUAGE_SPECIALS = /[\\{}\n]/;

  sub language_print (str)
    {
      str = regsuball (str, /\\\\/, "\\\\");
      str = regsuball (str, /{/, "\\{");
      str = regsuball (str, /}/, "\\}");
      str = regsuball (str, /\n/, "\\line\n");
      print (str);
    }

  sub header ()
    {
      local i;

      if (current_input_file == 1)
	{
	  print ("{\\rtf\\ansi\\deff0\n");
	  print ("{\\fonttbl{\\f0\\fswiss Courier New;}}\n");
	  rtf_color_map();
	}
    }

  sub trailer ()
    {
      if (current_input_file == int (num_input_files))
	print ("}\n");
    }

  sub color_on (name)
    {
      print ("{", name, " ");
    }

  sub color_off ()
    {
      print ("}");
    }

  sub bold (on)
    {
      if (on)
	print ("{\\b ");
      else
	print ("}");
    }

  sub italic (on)
    {
      if (on)
	print ("{\\i ");
      else
	print ("}");
    }

  sub bold_italic (on)
    {
      if (on)
	print ("{\\b\\i ");
      else
	print ("}");
    }

  sub comment_face (on)
    {
      if (on)
	{
	  print ("{\\i ");
	  if (color)
	    color_on (comment_face_color);
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("}");
	}
    }

  sub function_name_face (on)
    {
      if (on)
	{
	  print ("{\\b ");
	  if (color)
	    color_on (function_name_face_color);
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("}");
	}
    }

  sub variable_name_face (on)
    {
      if (on)
	{
	  if (color)
	    color_on (variable_name_face_color);
	  else
	    print ("{\\b ");
	}
      else
	{
	  if (color)
	    color_off ();
	  else
	    print ("}");
	}
    }

  sub keyword_face (on)
    {
      if (on)
	{
	  print ("{\\b ");
	  if (color)
	    color_on (keyword_face_color);
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("}");
	}
    }

  sub reference_face (on)
    {
      if (on)
	{
	  print ("{\\b ");
	  if (color)
	    color_on (reference_face_color);
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("}");
	}
    }

  sub string_face (on)
    {
      if (on)
	{
	  if (color)
	    color_on (string_face_color);
	  print ("{\\b ");
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("}");
	}
    }

  sub builtin_face (on)
    {
      if (on)
	{
	  if (color)
	    color_on (builtin_face_color);
	  print ("{\\b ");
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("}");
	}
    }

  sub type_face (on)
    {
      if (on)
	{
	  if (color)
	    color_on (type_face_color);
	  print ("{\\i ");
	}
      else
	{
	  if (color)
	    color_off ();
	  print ("}");
	}
    }
} /* End RTF */


sub define_faces ()
{
  if (strcmp (language, "enscript") == 0)
    enscript_faces ();
  else if (strcmp (language, "html") == 0)
    html_faces ();
  else if (strcmp (language, "overstrike") == 0)
    overstrike_faces ();
  else if (strcmp (language, "texinfo") == 0)
    texinfo_faces ();
  else if (strcmp (language, "rtf") == 0)
    rtf_faces ();
  else
    panic ("unknown output language `", language, "'");
}


/*
 * Initializations.
 */

start
{
  /* Set debug level. */
  debug_level = int (debug);

  /* Increment input file count. */
  current_input_file = current_input_file + 1;

  /* Resolve fonts. */
  idx = strchr (font_spec, '@');
  if (idx < 0)
    panic ("malformed font spec: `", font_spec, "'");

  font = substring (font_spec, 0, idx);
  ptsize = substring (font_spec, idx + 1, length (font_spec));

  debug (concat ("start: ", font, "@", ptsize));

  /* Construct bold, italic, etc. fonts for our current body font. */
  if (is_prefix ("AvantGarde", font))
    {
      bold_font = "AvantGarde-Demi";
      italic_font = "AvantGarde-BookOblique";
      bold_italic_font = "AvantGarde-DemiOblique";
    }
  else if (regmatch (font, /^Bookman|Souvenir/))
    {
      bold_font = concat ($0, "-Demi");
      italic_font = concat ($0, "-LightItalic");
      bold_italic_font = concat ($0, "-DemiItalic");
    }
  else if (regmatch (font, /^(.*)-Roman$/))
    {
      bold_font = concat ($1, "-Bold");
      italic_font = concat ($1, "-Italic");
      bold_italic_font = concat ($1, "-BoldItalic");
    }
  else if (regmatch (font, /^LucidaSans-/))
    {
      bold_font = concat (font, "Bold");
      italic_font = concat (font, "Oblique");
      bold_italic_font = concat (font, "BoldOblique");
    }
  else
    {
      bold_font = concat (font, "-Bold");
      italic_font = concat (font, "-Oblique");
      bold_italic_font = concat (font, "-BoldOblique");
    }

  /* Define output faces. */
  define_faces ();

  /* Select colormodel. */
  if (strcmp (colormodel, "blackwhite") == 0)
    {
      color = 0;
    }
  else if (strcmp (colormodel, "emacs") == 0)
    {
      color = 1;
      bold_color =			language_color ("black");
      italic_color =			language_color ("black");
      bold_italic_color =		language_color ("black");
      comment_face_color =		language_color ("firebrick");
      function_name_face_color =	language_color ("blue");
      variable_name_face_color =	language_color ("dark goldenrod");
      keyword_face_color =		language_color ("purple");
      reference_face_color =		language_color ("cadet blue");
      string_face_color =		language_color ("rosy brown");
      builtin_face_color =		language_color ("orchid");
      type_face_color =			language_color ("forest green");
    }
  else if (strcmp (colormodel, "ifh") == 0)
    {
      color = 1;
      bold_color =			language_color ("black");
      italic_color =			language_color ("black");
      bold_italic_color =		language_color ("black");
      comment_face_color =		language_color ("DarkSeaGreen");
      function_name_face_color =	language_color ("Coral");
      variable_name_face_color =	language_color ("dark goldenrod");
      keyword_face_color =		language_color ("SeaGreen2");
      reference_face_color =		language_color ("forest green");
      string_face_color =		language_color ("Goldenrod");
      reference_face_color =		language_color ("Aquamarine");
      builtin_face_color =		language_color ("purple");
      type_face_color =			language_color ("DarkSlateGray1");
    }
  else
    panic ("unknown color model `", colormodel, "'");

  /* Select highlight level. */
  if (strcmp (hl_level, "none") == 0)
    {
      comment_face_font =	font;
      function_name_face_font = font;
      variable_name_face_font = font;
      keyword_face_font =	font;
      reference_face_font =	font;
      string_face_font =	font;
      builtin_face_font =	font;
      type_face_font =		font;
    }
  else if (strcmp (hl_level, "light") == 0)
    {
      comment_face_font =	italic_font;
      function_name_face_font = bold_font;

      if (color)
	variable_name_face_font = font;
      else
	variable_name_face_font = bold_font;

      keyword_face_font =	bold_font;
      reference_face_font =	bold_font;
      string_face_font =	font;
      builtin_face_font =	font;
      type_face_font =		font;
    }
  else if (strcmp (hl_level, "heavy") == 0)
    {
      comment_face_font =	italic_font;
      function_name_face_font = bold_font;

      if (color)
	variable_name_face_font = font;
      else
	variable_name_face_font = bold_font;

      keyword_face_font =	bold_font;
      reference_face_font =	bold_font;
      string_face_font =	bold_font;
      builtin_face_font =	bold_font;
      type_face_font =		bold_font;
    }
  else
    panic ("unknown highlight level `", hl_level, "'");

  /* Resolve start state. */
  if (check_startrules ())
    debug ("startstate from startrules");
  if (check_namerules ())
    debug ("startstate from namerules");
}

namerules
{
  /\.(c|h)$/				c;
  /\.(c++|C|H|cpp|cc|cxx)$/		cpp;
  /\.m$/				objc;
  /\.(scm|scheme)$/			scheme;
  /\b\.emacs$|\.el$/			elisp;
  /\.ad(s|b|a)$/			ada;
  /\.[Ss]$/				asm;
  /\.st$/				states;
  /(M|m)akefile.*/			makefile;
  /\.tcl$/				tcl;
  /\.(v|vh)$/				verilog;
  /\.html?$/				html;
  /\bChangeLog$/			changelog;
  /\.(vhd|vhdl)$/			vhdl;
  /\.(scr|.syn|.synth)$/		synopsys;
  /\.idl$/				idl;
  /\.(hs|lhs|gs|lgs)$/			haskell;
  /\.(pm|pl)$/				perl;
  /\.(eps|EPS|ps|PS)$/			postscript;
  /\.py$/				python;
  /\.js$/				javascript;
  /\.java$/				java;
  /\.([Pp][Aa][Ss]|[Pp][Pp]|[Pp])$/	pascal;
  /\.[fF]$/				fortran;
  /\.awk$/				awk;
  /\.sh$/				sh;
  /\.vba$/				vba;
  /^.*$/				passthrough;
}

startrules
{
  /.\010.\010.\010./					nroff;
  /-\*- [Cc] -\*-/					c;
  /-\*- [Cc]\+\+ -\*-/					cpp;
  /-\*- [Aa][Dd][Aa] -\*-/				ada;
  /-\*- [Aa][Ss][Mm] -\*-/				asm;
  /-\*- [Oo][Bb][Jj][Cc] -\*-/				objc;
  /-\*- [Ss][Cc][Hh][Ee][Mm][Ee] -\*-/			scheme;
  /-\*- [Ee][Mm][Aa][Cc][Ss] [Ll][Ii][Ss][Pp] -\*-/	elisp;
  /-\*- [Tt][Cc][Ll] -\*-/				tcl;
  /-\*- [Vv][Hh][Dd][Ll] -\*-/				vhdl;
  /-\*- [Hh][Aa][Ss][Kk][Ee][Ll][Ll] -\*-/		haskell;
  /-\*- [Ii][Dd][Ll] -\*-/				idl;
  /-\*- [Pp][Ee][Rr][Ll] -\*-/				perl;
  /^#![ \t]*\/.*\/perl/					perl;
  /^\04?%!/						postscript;
  /^From:/						mail;
  /^#![ \t]*(\/usr)?\/bin\/[ngmt]?awk/			awk;
  /^#![ \t]*(\/usr)?\/bin\/sh/				sh;
}


/*
 * Helper subroutines and states.
 */

state match_balanced_block
{
  match_balanced_block_start {
    language_print ($0);
    match_balanced_block_count = match_balanced_block_count + 1;
  }

  match_balanced_block_end {
    match_balanced_block_count = match_balanced_block_count - 1;
    if (match_balanced_block_count == 0)
      return $0;

    language_print ($0);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

sub match_balanced_block (starter, ender)
{
  match_balanced_block_count = 1;
  match_balanced_block_start = starter;
  match_balanced_block_end = ender;
  return call (match_balanced_block);
}

state eat_one_line
{
  /.*\n/ {
    language_print ($0);
    return;
  }
}

/*
 * Pass all input through handling only output language specific headers
 * and LANGUAGE_SPECIALS.
 */
state passthrough
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/*
 * Describe all known highlight languages.
 */

state describe_me
{
  / \*$/ {
  }

  / \*\\\/.*/ {
    /* All done. */
    return;
  }

  / \* ?(.*)/ {
    print ($1);
  }
}

state describe_languages
{
  BEGIN {
    print ("Highlighting is supported for the following languages and file formats:\n");
  }
  END {
    print ("\n");
  }
  /^\/\*\*.*$/ {
    call (describe_me);
  }
  /[^\\\/]+/ {
    /* NOP */
  }
  /./ {
    /* NOP */
  }
}

/*
 * Create a HTML report of all supported highlighting rules.
 */

sub html_annotate_mailtos (str)
{
  return regsuball (str, /[-_a-zA-Z0-9\\.]+@[-_a-zA-Z0-9\\.]+/,
		    "<a href=\"mailto:$0\">$0</a>");
}

sub html_quote (str)
{
  str = regsuball (str, /\&/, "&amp;");
  str = regsuball (str, /</, "&lt;");
  str = regsuball (str, />/, "&gt;");
  str = regsuball (str, /\"/, "&quot;");
  return str;
}

sub describe_me_html_print_pending_name ()
{
  if (!language_name_pending)
    return;

  print ("<p>\n<dl compact>\n<dt><b>Name:</b><dd>",
	 html_quote (language_name), "\n");

  language_name_pending = 0;
}

state describe_me_html
{
  / \*$/ {
  }

  / \*\\\/.*/ {
    /* Terminate this state. */
    describe_me_html_print_pending_name ();
    print ("</dl>\n");
    return;
  }

  / \* ?(.*)/ {
    row = $1;
    if (regmatch (row, /Name:(.*)/))
      {
	language_name = $1;
	language_name_pending = 1;
      }
    else if (regmatch (row, /Description:(.*)/))
      {
	/* This starts the new language. */
	title = $1;
	title = regsub (title, /^[ \t]+/, "");
	title = regsub (title, /[ \t\\.]+$/, "");
	print ("<p><li><b>", html_quote (title), "</b><p>\n");
      }
    else if (regmatch (row, /([a-zA-Z]+:)(.*)/))
      {
	describe_me_html_print_pending_name ();
	print ("<dt><b>", html_quote ($1), "</b><dd>",
	       html_annotate_mailtos (html_quote ($2)));
      }
    else
      print (html_annotate_mailtos (html_quote (row)));
  }
}

state describe_languages_html
{
  BEGIN {
    title = "Enscript Highlighting Languages And File Formats";
    print ("<html>\n<head>\n<title>", title, "</title>\n</head>\n<body>\n<h1>",
	   title, "</h1>\n<hr>\n<ul>\n");
  }
  END {
    print ("\n</ul>\n<hr><address>By ", version,
	   "</address>\n</body>\n</html>\n");
  }
  /^\/\*\*.*$/ {
    call (describe_me_html);
  }
  /[^\\\/]+/ {
    /* NOP */
  }
  /./ {
    /* NOP */
  }
}



/*
 * Language specific states
 */

/**
 * Name: ada
 * Description: Ada95 programming language.
 * Author: Rolf Ebert <ebert@waporo.muc.de>
 */

state ada
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /--/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }


  /* Character constants. */
  /'.'|'\\\\.'/ {
    string_face (true);
    language_print ($0);
    string_face (false);
  }

  /* Keywords.
     (build-re '(abort abs abstract accept access aliased
     all and array at begin body case constant declare
     delay delta digits do else elsif end entry
     exception exit for function generic goto if in
     is limited loop mod new not null of or others
     out package pragma private procedure protected raise
     range record rem renames requeue return reverse
     select separate subtype tagged task terminate then type
     until use when while with xor))
   */
  /\b(a(b(ort|s(|tract))|cce(pt|ss)|l(iased|l)|nd|rray|t)|b(egin|ody)\
|c(ase|onstant)|d(e(clare|l(ay|ta))|igits|o)\
|e(ls(e|if)|n(d|try)|x(ception|it))|f(or|unction)|g(eneric|oto)\
|i(f|n|s)|l(imited|oop)|mod|n(ew|ot|ull)|o(f|r|thers|ut)\
|p(ackage|r(agma|ivate|o(cedure|tected)))\
|r(a(ise|nge)|e(cord|m|names|queue|turn|verse))\
|s(e(lect|parate)|ubtype)|t(a(gged|sk)|erminate|hen|ype)|u(ntil|se)\
|w(h(en|ile)|ith)|xor)\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: asm
 * Description: Assembler listings.
 * Author: Markku Rossi <mtr@iki.fi>
 */

state asm
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /;/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* Labels are averything at the beginning of the line, ending to ':' */
  /^[^\t ]+:/ {
    function_name_face (true);
    language_print ($0);
    function_name_face (true);
  }

  /* Asm operands are indented. */
  /^([ \t]+)([^ \t]+)/ {
    language_print ($1);

    keyword_face (true);
    language_print ($2);
    keyword_face (false);
  }

  /* And finally, highlight string constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }
}


/**
 * Name: awk
 * Description: AWK programming language.
 * Author: Juergen Kahrs <Juergen.Kahrs@t-online.de>
 */

state awk
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /#/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Excutable script. */
  /^#!/ {
    reference_face (true);
    language_print ($0);
    call (eat_one_line);
    reference_face (false);
  }

  /* Keywords. */
  /\b(ARG(C|V|IND)|BEGIN|CONVFMT|E(N(D|VIRON)|RRNO)\
|F(I(ELDWIDTHS|LENAME)|NR|S)|IGNORECASE|N[FR]|O(FMT|FS|RS)\
|R(LENGTH|S(TART)?|T)|SUBSEP\
|atan2|break|c(lose|o(ntinue|s))|d(elete|o)|e(lse|x(it|p))\
|f(flush|or|unction)|g(((en)?sub)|etline)|i(f|n(dex|t)?)\
|l(ength|og)|match|next(file)?|return|while|print[f]?\
|rand|s(in|ub(str)?|ystem|p(lit|rintf)|qrt|rand|trftime|ystime)\
|to(lower|upper))\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: c
 * Description: C programming language.
 * Author: Markku Rossi <mtr@iki.fi>
 */

c_keyword_re =
/* Keywords, but not types, goto, and case.
   (build-re '(break continue default do else for if return sizeof
   switch while))
 */
  /\b(break|continue|d(efault|o)|else|for|if|return|s(izeof|witch)|while)\b/;

c_type_re =
/* Types.
   (build-re '(auto char const double enum extern float int long
   register short signed static struct typedef union unsigned void
   volatile))
 */
  /\b(auto|c(har|onst)|double|e(num|xtern)|float|int|long|register\
|s(hort|igned|t(atic|ruct))|typedef|un(ion|signed)|vo(id|latile))\b/;

state c_comment
{
  /\*\\\// {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
   language_print ($0);
  }
}

state c_string
{
  /\\\\./ {
    language_print ($0);
  }
  /\"/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state c_ppline
{
  /* Comments within a pre-processor line. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }
  /* Include line. */
  /(include)([ \t]+)/ {
    reference_face (true);
    language_print ($1);
    reference_face (false);
    language_print ($2);
    call (c_ppline_include);
    return;
  }
  /* Define line. */
  /(define)([ \t]+)/ {
    reference_face (true);
    language_print ($1);
    reference_face (false);
    language_print ($2);
    call (c_ppline_define);
    return;
  }
  /* Simple directives:
     (build-re '(undef if ifdef ifndef endif elif else line error pragma))
   */
  /\b(e(l(if|se)|ndif|rror)|if(|def|ndef)|line|pragma|undef)\b/ {
    reference_face (true);
    language_print ($0);
    reference_face (false);
    call (c_ppline_tokensequence);
    return;
  }
  /* An unknown pre-processor directive. */
  /[a-zA-Z_][^ \t\n]*/ {
    reference_face (true);
    language_print ($0);
    reference_face (false);
    call (c_ppline_tokensequence);
    return;
  }
  /\n/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state c_ppline_include
{
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
    call (c_ppline_comments_strings_chars);
    return;
  }
  /<[^<>]+>/ {
    string_face (true);
    language_print ($0);
    string_face (false);
    call (c_ppline_comments_strings_chars);
    return;
  }
  /[a-zA-Z_][a-zA-Z_0-9]*/ {
    variable_name_face (true);
    print ($0);
    variable_name_face (false);
    call (c_ppline_comments_strings_chars);
    return;
  }
  /\n/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state c_ppline_define
{
  /([a-zA-Z_][a-zA-Z_0-9]*)(\([^\)]*\))?/ {
    if (strcmp ($2, "") != 0)
      {
	function_name_face (true);
	language_print ($1);
	function_name_face (false);
	language_print ($2);
      }
    else
      {
	variable_name_face (true);
	language_print ($1);
	variable_name_face (false);
      }
    call (c_ppline_comments_strings_chars);
    return;
  }
  /\n/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state c_ppline_comments_strings_chars
{
  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }
  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }
  /* Character constants. */
  /'.'|'\\\\.'/ {
    string_face (true);
    language_print ($0);
    string_face (false);
  }
  /\n/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state c_ppline_tokensequence
{
  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }
  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }
  /* Character constants. */
  /'.'|'\\\\.'/ {
    string_face (true);
    language_print ($0);
    string_face (false);
  }
  /* defined() operators. */
  /(defined)(\()([^\)]+)(\))/ {
    reference_face (true);
    language_print ($1);
    reference_face (false);
    language_print ($2);

    variable_name_face (true);
    language_print ($3);
    variable_name_face (false);

    language_print ($4);
  }
  /* Variable references. */
  /\b[a-zA-Z_][a-zA-Z_0-9]*\b/ {
    variable_name_face (true);
    language_print ($0);
    variable_name_face (false);
  }
  /\n/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state c
{
  BEGIN {
    if (need_version (1, 5, 1))
      c_function_name_re
	= /^([A-Za-z][a-zA-Z0-9_\* ]+)([ \*])([a-zA-Z_][a-zA-Z_0-9]*)([ \t]*\()/;
    else
      c_function_name_re = 0;

    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }
  /\/\// {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Pre-processor lines. */
  /^#/ {
    language_print ($0);
    call (c_ppline);
  }

  /* Character constants. */
  /'.'|'\\\\.'/ {
    string_face (true);
    language_print ($0);
    string_face (false);
  }

  /* Keywords. */
  c_keyword_re {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  /* Types. */
  c_type_re {
    type_face (true);
    language_print ($0);
    type_face (false);
  }

  /* Labels and case tags.  Emacs accepts also bare numbers. */
  /([a-zA-Z0-9_]+)(:)/ {
    if (strcmp ($1, "default") == 0)
      {
	/* `default' is a keyword. */
	keyword_face (true);
	language_print ($1);
	keyword_face (false);
      }
    else
      {
	reference_face (true);
	language_print ($1);
	reference_face (false);
      }

    language_print ($2);
  }

  /* Goto, case and the target. */
  /\<(goto|case)\>([ \t]+)(-?[A-Za-z_][A-Za-z_0-9]*)?/ {
    keyword_face (true);
    language_print ($1);
    keyword_face (false);

    language_print ($2);

    if (length ($3) > 0)
      {
	reference_face (true);
	language_print ($3);
	reference_face (false);
      }
  }

  /*
   * Function definitions, but only if you code with the one and only
   * usable indentation style (GNU).
   */
  /^([a-zA-Z_][a-zA-Z_0-9]*)([ \t]*\()/ {
    function_name_face (true);
    language_print ($1);
    function_name_face (false);

    language_print ($2);
  }

  /* Function definitions and prototypes for other (loser) coding styles. */
  c_function_name_re {
    garbage = $1;
    middle_garbage = $2;
    function_name = $3;
    tail_garbage = $4;

    highlight_types (garbage, c_type_re);

    language_print (middle_garbage);

    function_name_face (true);
    language_print (function_name);
    function_name_face (false);

    language_print (tail_garbage);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: changelog
 * Description: ChangeLog files.
 * Author: Markku Rossi <mtr@iki.fi>
 */

state changelog
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Date entries.  Both new and old formats. */
  /^([^ \t]........[0-9: ]*)([^<]+)(<)([A-Za-z0-9_.-]+@[A-Za-z0-9_.-]+)(>)/ {
    string_face (true);
    language_print ($1);
    string_face (false);

    reference_face (true);
    language_print ($2);
    reference_face (false);

    language_print ($3);

    variable_name_face (true);
    language_print ($4);
    variable_name_face (false);

    language_print ($5);
  }

  /* File descriptions with function names. */
  /(^\t\* )([^\(]+)(\()([^\)]+)(\):)/ {
    language_print ($1);

    function_name_face (true);
    language_print ($2);
    function_name_face (false);

    language_print ($3);

    keyword_face (true);
    language_print ($4);
    keyword_face (false);

    language_print ($5);
  }

  /* File descriptions without function names. */
  /(^\t\* )([^ :]+)(:)/ {
    language_print ($1);

    function_name_face (true);
    language_print ($2);
    function_name_face (false);

    language_print ($3);
  }

  /* Function name descriptions without file names. */
  /(^\t\()([^\)]+)(\):)/ {
    language_print ($1);

    keyword_face (true);
    language_print ($2);
    keyword_face (false);

    language_print ($3);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: cpp
 * Description: C++ programming language.
 * Author: Markku Rossi <mtr@iki.fi>
 */

cpp_keyword_re =
/* Keywords, but not types, goto, and case.
   (build-re '(asm break catch continue default delete do else for if
   new operator overload return sizeof switch this throw try while))
  */
  /\b(asm|break|c(atch|ontinue)|d(e(fault|lete)|o)|else|for|if|new\
|o(perator|verload)|return|s(izeof|witch)|t(h(is|row)|ry)|while)\b/;

cpp_type_re =
/* Types.
   (build-re '(auto bool char class complex const double enum extern
   float friend inline int long private protected public register
   short signed static struct template typedef union unsigned virtual
   void volatile))
  */
  /\b(auto|bool|c(har|lass|o(mplex|nst))|double|e(num|xtern)|f(loat|riend)\
|in(line|t)|long|p(r(ivate|otected)|ublic)|register\
|s(hort|igned|t(atic|ruct))|t(emplate|ypedef)|un(ion|signed)\
|v(irtual|o(id|latile)))\b/;

state cpp
{
  BEGIN {
    if (need_version (1, 5, 1))
      cpp_function_name_re
	= /^([A-Za-z][a-zA-Z0-9_\* ]+)([ \*])([a-zA-Z_][a-zA-Z_0-9:~]*)([ \t]*\()/;
    else
      cpp_function_name_re = 0;

    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }
  /\/\// {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Pre-processor lines. */
  /^#/ {
    language_print ($0);
    call (c_ppline);
  }

  /* Character constants. */
  /'.'|'\\\\.'/ {
    string_face (true);
    language_print ($0);
    string_face (false);
  }

  /* Keywords. */
  cpp_keyword_re {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  /* Types. */
  cpp_type_re {
    type_face (true);
    language_print ($0);
    type_face (false);
  }

  /* Remove false labels. */
  /[a-zA-Z0-9_]+::/ {
    language_print ($0);
  }

  /* Labels and case tags.  Emacs accepts also bare numbers. */
  /([a-zA-Z0-9_]+)(:)/ {
    if (strcmp ($1, "default") == 0)
      {
	/* `default' is a keyword. */
	keyword_face (true);
	language_print ($1);
	keyword_face (false);
      }
    else if (strcmp ($1, "public") == 0
	     || strcmp ($1, "private") == 0
	     || strcmp ($1, "protected") == 0)
      {
	/* These use the `type' face. */
	type_face (true);
	language_print ($1);
	type_face (false);
      }
    else
      {
	reference_face (true);
	language_print ($1);
	reference_face (false);
      }

    language_print ($2);
  }

  /* Goto and its target. */
  /\<(goto|case)\>([ \t]+)(-?[A-Za-z_][A-Za-z_0-9]*)?/ {
    keyword_face (true);
    language_print ($1);
    keyword_face (false);

    language_print ($2);

    if (length ($3) > 0)
      {
	reference_face (true);
	language_print ($3);
	reference_face (false);
      }
  }

  /*
   * Function definitions, but only if you code with the one and only
   * usable indentation style (GNU).
   */
  /^([a-zA-Z_][a-zA-Z_0-9:~]*)([ \t]*\()/ {
    function_name_face (true);
    language_print ($1);
    function_name_face (false);

    language_print ($2);
  }

  /* Function definitions and prototypes for other (loser) coding styles. */
  cpp_function_name_re {
    garbage = $1;
    middle_garbage = $2;
    function_name = $3;
    tail_garbage = $4;

    highlight_types (garbage, cpp_type_re);

    language_print (middle_garbage);

    function_name_face (true);
    language_print (function_name);
    function_name_face (false);

    language_print (tail_garbage);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: diff
 * Description: normal diffs
 * Author: buchal@ifh.bau-verm.uni-karlsruhe.de
 */

state diff
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /^[0-9]/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /^</ {
    function_name_face (true);
    language_print ($0);
    call (eat_one_line);
    function_name_face (false);
  }

  /^>/ {
    reference_face (true);
    language_print ($0);
    call (eat_one_line);
    reference_face (false);
  }
  /^[^\ ]/ {
    string_face (true);
    language_print ($0);
    call (eat_one_line);
    string_face (false);
  }
}


/**
 * Name: diffu
 * Description: unified diffs
 * Author: buchal@ifh.bau-verm.uni-karlsruhe.de
 */

state diffu
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /^\@\@/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /^-/ {
    function_name_face (true);
    language_print ($0);
    call (eat_one_line);
    function_name_face (false);
  }

  /^+/ {
    reference_face (true);
    language_print ($0);
    call (eat_one_line);
    reference_face (false);
  }
  /^[^\ ]/ {
    string_face (true);
    language_print ($0);
    call (eat_one_line);
    string_face (false);
  }
}


/**
 * Name: delphi
 * Description: Delphi programming language.
 * Author: Michael Van Canneyt <michael@tfdec1.fys.kuleuven.ac.be>
 */

state delphi
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }
  /* comments */
  /(\{|\(\*)/ {
    comment_face (true);
    language_print ($0);
    call (pascal_comment);
    comment_face (false);
  }
  /* C++ -style comments */
  /\/\// {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }
  /* strings */
  /[\']/ {
    string_face (true);
    language_print ($0);
    call (pascal_string);
    string_face (false);
  }
  /* Keywords.
     (build-re '(and asm array begin case const constructor destructor
     div do downto else end file for function goto if implementation
     in inline interface label mod nil not object of or packed
     procedure program record repeat set shlr string then to type
     unit until uses var while with xor As class except exports
     finalization finally inherited initialization is library property
     raise threAdvar try absolute abstract assembler automated cdecl
     default dispid dynamic export external far forward index message
     name near nodefault override pascal private protected public
     published read register resident stdcall stored virtual write)
     t)
   */
  /\b(A[sS]\
|[aA]([bB][sS]([oO][lL][uU][tT][eE]|[tT][rR][aA][cC][tT])|[nN][dD]\
|[rR][rR][aA][yY]|[sS]([mM]|[sS][eE][mM][bB][lL][eE][rR])\
|[uU][tT][oO][mM][aA][tT][eE][dD])\
|[bB][eE][gG][iI][nN]\
|[cC]([aA][sS][eE]|[dD][eE][cC][lL]|[lL][aA][sS][sS]\
|[oO][nN][sS][tT](|[rR][uU][cC][tT][oO][rR]))\
|[dD]([eE]([fF][aA][uU][lL][tT]|[sS][tT][rR][uU][cC][tT][oO][rR])\
|[iI]([sS][pP][iI][dD]|[vV])|[oO](|[wW][nN][tT][oO])\
|[yY][nN][aA][mM][iI][cC])\
|[eE]([lL][sS][eE]|[nN][dD]\
|[xX]([cC][eE][pP][tT]|[pP][oO][rR][tT](|[sS])|[tT][eE][rR][nN][aA][lL]))\
|[fF]([aA][rR]\
|[iI]([lL][eE]|[nN][aA][lL]([iI][zZ][aA][tT][iI][oO][nN]|[lL][yY]))\
|[oO][rR](|[wW][aA][rR][dD])|[uU][nN][cC][tT][iI][oO][nN])\
|[gG][oO][tT][oO]\
|[iI]([fF]|[mM][pP][lL][eE][mM][eE][nN][tT][aA][tT][iI][oO][nN]\
|[nN](|[dD][eE][xX]|[hH][eE][rR][iI][tT][eE][dD]\
|[iI][tT][iI][aA][lL][iI][zZ][aA][tT][iI][oO][nN]|[lL][iI][nN][eE]\
|[tT][eE][rR][fF][aA][cC][eE])\
|[sS])\
|[lL]([aA][bB][eE][lL]|[iI][bB][rR][aA][rR][yY])\
|[mM]([eE][sS][sS][aA][gG][eE]|[oO][dD])\
|[nN]([aA][mM][eE]|[eE][aA][rR]|[iI][lL]\
|[oO]([dD][eE][fF][aA][uU][lL][tT]|[tT]))\
|[oO]([bB][jJ][eE][cC][tT]|[fF]|[rR]|[vV][eE][rR][rR][iI][dD][eE])\
|[pP]([aA]([cC][kK][eE][dD]|[sS][cC][aA][lL])\
|[rR]([iI][vV][aA][tT][eE]\
|[oO]([cC][eE][dD][uU][rR][eE]|[gG][rR][aA][mM]|[pP][eE][rR][tT][yY]\
|[tT][eE][cC][tT][eE][dD]))\
|[uU][bB][lL][iI]([cC]|[sS][hH][eE][dD]))\
|[rR]([aA][iI][sS][eE]\
|[eE]([aA][dD]|[cC][oO][rR][dD]|[gG][iI][sS][tT][eE][rR]|[pP][eE][aA][tT]\
|[sS][iI][dD][eE][nN][tT]))\
|[sS]([eE][tT]|[hH][lL][rR]\
|[tT]([dD][cC][aA][lL][lL]|[oO][rR][eE][dD]|[rR][iI][nN][gG]))\
|[tT]([hH]([eE][nN]|[rR][eE]A[dD][vV][aA][rR])|[oO]|[rR][yY]|[yY][pP][eE])\
|[uU]([nN]([iI][tT]|[tT][iI][lL])|[sS][eE][sS])\
|[vV]([aA][rR]|[iI][rR][tT][uU][aA][lL])\
|[wW]([hH][iI][lL][eE]|[iI][tT][hH]|[rR][iI][tT][eE])|[xX][oO][rR])\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }
}


/**
 * Name: elisp
 * Description: Emacs LISP.
 */

state elisp
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /;/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Definitions. */
  /(\([ \t]*)(defun)([ \t]+\(?)([!\$%&\*\/:<=>\?~_^a-zA-Z][!\$%&\*\/:<=>\?~_^a-zA-Z0-9.+\-]*)/ {
    /* Starting garbage. */
    language_print ($1);

    /* Keyword `defun'. */
    keyword_face (true);
    language_print ($2);
    keyword_face (false);

    /* Middle garbage. */
    language_print ($3);

    /* Function name. */
    function_name_face (true);
    language_print ($4);
    function_name_face (false);
  }

  /* ':'-names, Emacs highlights these, so do we. */
  /([ \t])(:[!\$%&\*\/:<=>\?~_^a-zA-Z0-9.+\-]*)/ {
    language_print ($1);
    reference_face (true);
    language_print ($2);
    reference_face (false);
  }

  /* Keywords taken out of fond-lock.el.  Added: and, or, lambda.
     (build-re '(and or lambda cond if while let let* prog progn
     progv prog1 prog2 prog* inline catch throw save-restriction
     save-excursion save-window-excursion save-selected-window
     save-match-data unwind-protect condition-case track-mouse
     eval-after-load eval-and-compile eval-when-compile when
     unless do flet labels return return-from with-output-to-temp-buffer
     with-timeout))
   */
  /\b(and|c(atch|ond(|ition-case))|do\
|eval-(a(fter-load|nd-compile)|when-compile)|flet|i(f|nline)\
|l(a(bels|mbda)|et(|*))|or|prog(|*|1|2|n|v)|return(|-from)\
|save-(excursion|match-data|restriction|selected-window|window-excursion)\
|t(hrow|rack-mouse)|un(less|wind-protect)\
|w(h(en|ile)|ith-(output-to-temp-buffer|timeout)))\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: fortran
 * Description: Fortran77 programming language.
 * Author: Keith Refson <Keith.Refson@earth.ox.ac.uk>
 *	   Markku Rossi <mtr@iki.fi>
 */

state fortran_string
{
  /[\']/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state fortran_io
{
   /\)/ {
     language_print ($0);
     return;
   }

  /* IO Keywords.  (build-re '(FMT UNIT REC END ERR FILE STATUS
     ACCESS FORM RECL BLANK IOSTAT EXIST OPENED NUMBER NAME
     SEQUENTIAL DIRECT FORMATTED UNFORMATTED NEXTREC)) */
  /\BbACCESS|BLANK|DIRECT|E(ND|RR|XIST)|F(ILE|MT|ORM(|ATTED))|IOSTAT\
|N(AME|EXTREC|UMBER)|OPENED|REC(|L)|S(EQUENTIAL|TATUS)\
|UN(FORMATTED|IT))\b/ {

      keyword_face (true);
      language_print ($0);
      keyword_face (false);
   }

  /* IO Keywords.  (build-re '(fmt unit rec end err file status
     access form recl blank iostat exist opened number name
     sequential direct formatted unformatted nextrec)) */
  /\b(access|blank|direct|e(nd|rr|xist)|f(ile|mt|orm(|atted))|iostat\
|n(ame|extrec|umber)|opened|rec(|l)|s(equential|tatus)\
|un(formatted|it))\b/ {

      keyword_face (true);
      language_print ($0);
      keyword_face (false);
   }
   LANGUAGE_SPECIALS {
      language_print ($0);
   }
}

state fortran
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /^[cC!\*]/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /[\']/ {
    string_face (true);
    language_print ($0);
    call (fortran_string);
    string_face (false);
  }

  /* Comparators.  We have to roll by hand because of the
     dots - "\b" doesn't delimit here. */
  /\.(and|eqv?|g(e|t)|l(e|t)|ne(qv)?|not|or)\./ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  /* Comparators.  We have to roll by hand because of the
     dots - "\b" doesn't delimit here. */
  /\.(AND|EQV?|G(E|T)|L(E|T)|NE(QV)?|NOT|OR)\./ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  /* IO Statement (build-re '(open close read
  write inquire backspace endfile rewind )) */
  /\b(backspace|close|endfile|inquire|open|re(ad|wind)|write)\b/ {

    keyword_face (true);
    language_print ($0);
    keyword_face (false);
    call (fortran_io);
  }

  /* IO Statement (build-re '(OPEN CLOSE READ
  WRITE INQUIRE BACKSPACE ENDFILE REWIND )) */
  /\b(BACKSPACE|CLOSE|ENDFILE|INQUIRE|OPEN|RE(AD|WIND)|WRITE)\b/ {

    keyword_face (true);
    language_print ($0);
    keyword_face (false);
    call (fortran_io);
  }

  /* Keywords.  (build-re '( block\ *data call
     character\\*\[0-9\]+ common complex\\*\[0-9\]+ continue
     data dimension do double\ *precision else elseif end enddo
     endfile endif entry equivalence external format function
     go\ *to if implicit include integer\\*\[0-9\]+ intrinsic
     logical\\*\[0-9\]+ parameter pause print program
     real\\*\[0-9\]+ return  save stop subroutine then while )) */
  /\b(block *data|c(all|haracter\*[0-9]+|o(m(mon|plex\*[0-9]+)|ntinue))\
|d(ata|imension|o(|uble *precision))\
|e(lse(|if)|n(d(|do|file|if)|try)|quivalence|xternal)|f(ormat|unction)\
|go *to|i(f|mplicit|n(clude|t(eger\*[0-9]+|rinsic)))|logical\*[0-9]+\
|p(a(rameter|use)|r(int|ogram))|re(al\*[0-9]+|turn)\
|s(ave|top|ubroutine)|then|while)\b/ {

    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }
  /* Keywords.  (build-re '( block\ *data call
     character\\*\[0-9\]+ COMMON COMPLEX\\*\[0-9\]+ CONTINUE
     DATA DIMENSION DO DOUBLE\ *PRECISION ELSE ELSEIF END ENDDO
     ENDFILE ENDIF ENTRY EQUIVALENCE EXTERNAL FORMAT FUNCTION
     GO\ *TO IF IMPLICIT INCLUDE INTEGER\\*\[0-9\]+ INTRINSIC
     LOGICAL\\*\[0-9\]+ PARAMETER PAUSE PRINT PROGRAM
     REAL\\*\[0-9\]+ RETURN  SAVE STOP SUBROUTINE THEN WHILE )) */
  /\b(BLOCK *DATA|C(ALL|HARACTER\*[0-9]+|O(M(MON|PLEX\*[0-9]+)|NTINUE))\
|D(ATA|IMENSION|O(|UBLE *PRECISION))\
|E(LSE(|IF)|N(D(|DO|FILE|IF)|TRY)|QUIVALENCE|XTERNAL)|F(ORMAT|UNCTION)\
|GO *TO|I(F|MPLICIT|N(CLUDE|T(EGER\*[0-9]+|RINSIC)))|LOGICAL\*[0-9]+\
|P(A(RAMETER|USE)|R(INT|OGRAM))|RE(AL\*[0-9]+|TURN)\
|S(AVE|TOP|UBROUTINE)|THEN|WHILE)\b/ {

    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: haskell
 * Description: Haskell programming language.
 *
 * Simple highlighting treating keywords, comments, strings and type
 * expressions specially.
 *
 * Author: Hans-Wolfgang Loidl <hwloidl@dcs.gla.ac.uk>
 * Date: 27/2/97
 */

state haskell
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /\{\-/ {
    comment_face (true);
    language_print ($0);
    call (haskell_comment);
    comment_face (false);
  }

  /* One line comments. */
  /\-\-/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* Built-in beasts (GHC specific). */
  /\b\_/ {
    keyword_face (true);
    language_print ($0);
    call (haskell_builtin);
    keyword_face (false);
  }

  /* Type declarations. */
  /::/ {
    type_face (true);
    language_print ($0);
    call (eat_one_line);
    /* call (haskell_type); */
    type_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (haskell_string);
    string_face (false);
  }

  /* Pre-processor lines. */
  /^#/ {
    reference_face (true);
    language_print ($0);
    call (eat_one_line);
    /* call (haskell_ppline); */
    reference_face (false);
  }

  /* Character constants. */
  /'.'|'\\.'/ {
    string_face (true);
    language_print ($0);
    string_face (false);
  }

  /* Keywords.
     I took that from haskell.el. The True Way to do it would be to grab it
     out of the on-line haskell report (actually, The Real True Way would
     be to write a Haskell program that extracts different kinds of
     keywords and to partially evaluate it wrt the Haskell report; but that
     might be a wee overkill).
     (let ((strings
	'("case" "class" "data" "default" "deriving" "else" "hiding" "if" "import" "in" "\
	  infix" "infixl" "infixr" "instance" "interface" "let" "module" "of" "renaming" "\
	  then" "to" "type" "where" )))
      (make-regexp strings)
     )
     ==>
     \(infix\|then\)\|c\(ase\|lass\)\|d\(ata\|e\(fault\|riving\)\)\|else\|hiding\|i\([fn]\|mport\|n\(fix[lr]\|stance\|terface\)\)\|let\|module\|of\|renaming\|t\(o\|ype\)\|where
   */
  /\b((infix|then)|c(ase|lass)|d(ata|e(fault|riving))|else|hiding|i([fn]|mport|n(fix[lr]|stance|terface))|let|module|of|renaming|t(o|ype)|where)\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state haskell_comment
{
  /\-\}/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
   language_print ($0);
  }
}

/*
state haskell_one_line_comment
{
  /\n/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
   language_print ($0);
  }
}
*/

/* HWL: for GHC builtin objects like _parGlobal_ i.e. not std Haskell */
state haskell_builtin
{
  /(\_\b)| / {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
   language_print ($0);
  }
}

state haskell_type
{
  /* ToDo: Implement type continuation lines:
	   If the line ends in a -> or the next starts with a -> then we
	   are still in a type expression
  */
  /\n/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
   language_print ($0);
  }
}

state haskell_string
{
  /\\\\./ {
    language_print ($0);
  }
  /\"/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state haskell_ppline
{
  /\/\*/ {
    /* Comment within a pre-processor line. */
    reference_face (false);
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
    reference_face (true);
  }
  /\n/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: html
 * Description: Hypertext markup language HTML.
 * Author: Markku Rossi <mtr@iki.fi>
 */

state html_tag
{
  />/ {
    language_print ($0);
    return;
  }
  /\"/ {
    keyword_face (false);
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
    keyword_face (true);
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state html_entity
{
  /;/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state html_script_tag {
  /\"/ {
    keyword_face (false);
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
    keyword_face (true);
  }
  /([lL][aA][nN][gG][uU][aA][gG][eE]=\")([^\"]*)(\")/ {
    html_script_language = $2;

    language_print ($1);
    keyword_face (false);

    string_face (true);
    language_print ($2);
    string_face (false);

    keyword_face (true);
    language_print ($3);
  }
  />/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state html_skip_script
{
  /* Terminator for nested scripts. */
  /<\/[sS][cC][rR][iI][pP][tT]>/ {
    from_html_terminator = $0;
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state html
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Scripts. */
  /<[sS][cC][rR][iI][pP][tT]/ {
    keyword_face (true);
    language_print ($0);

    /* The default script language is JavaScript. */
    html_script_language = "JavaScript";
    call (html_script_tag);
    keyword_face (false);

    if (strcmp (html_script_language, "JavaScript") == 0) {
      /* A nested JavaScript block. */
      from_html = 1;
      from_html_terminator = "";
      call (javascript);
      keyword_face (true);
      language_print (from_html_terminator);
      keyword_face (false);
    } else {
      /* An unknown scripting language, skip it. */
      from_html_terminator = "";
      call (html_skip_script);
      keyword_face (true);
      language_print (from_html_terminator);
      keyword_face (false);
    }
  }

  /</ {
    keyword_face (true);
    language_print ($0);
    call (html_tag);
    keyword_face (false);
  }
  /&/ {
    keyword_face (true);
    language_print ($0);
    call (html_entity);
    keyword_face (false);
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: idl
 * Description: IDL (CORBA Interface Definition Language)
 */

state idl
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }
  /\/\// {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* Character constants. */
  /'.'|'\\\\.'/ {
    string_face (true);
    language_print ($0);
    string_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Pre-processor lines. */
  /^#/ {
    reference_face (true);
    language_print ($0);
    call (c_ppline);
    reference_face (false);
  }

  /* Boolean literals */
  /\b(TRUE|FALSE)\b/ {
    string_face (true);
    language_print ($0);
    string_face (false);
  }

  /* Keywords.
    (build-re '(any attribute boolean case char const context default double
    enum exception fixed float in inout interface long module Object
    octet oneway out native raises readonly sequence short string struct switch
    typedef unsigned union void wchar wstring))
  */
  /\b(Object|a(ny|ttribute)|boolean|c(ase|har|on(st|text))|d(efault|ouble)\
|e(num|xception)|f(ixed|loat)|in(|out|terface)|long|module|native\
|o(ctet|neway|ut)|r(aises|eadonly)|s(equence|hort|tr(ing|uct)|witch)\
|typedef|un(ion|signed)|void|w(char|string))\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: java
 * Description: Java programming language.
 * Author: Paul Fisher <pnfisher@eos.ncsu.edu>
 */

state java
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }
  /\/\// {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Character constants. */
  /'.'|'\\\\.'/ {
    string_face (true);
    language_print ($0);
    string_face (false);
  }

  /* Keywords.
     (build-re '(abstract boolean break byte case catch char class
     const continue default do double else extends false final finally
     float for goto if implements import instanceof int interface long
     native new null package private protected public return short static
     super switch synchronized this throw throws transient true try void
     volatile while))
  */
  /\b(abstract|b(oolean|reak|yte)|c(a(se|tch)|har|lass|on(st|tinue))\
|d(efault|o(|uble))|e(lse|xtends)|f(alse|inal(|ly)|loat|or)|goto\
|i(f|mp(lements|ort)|n(stanceof|t(|erface)))|long|n(ative|ew|ull)\
|p(ackage|r(ivate|otected)|ublic)|return\
|s(hort|tatic|uper|witch|ynchronized)|t(h(is|row(|s))|r(ansient|ue|y))\
|vo(id|latile)|while)\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: javascript
 * Description: JavaScript language.
 * Author: Markku Rossi <mtr@iki.fi>
 */

from_html = 0;

state javascript_string
{
  /\\\\./ {
    language_print ($0);
  }
  /[\']/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state javascript
{
  BEGIN {
    if (!from_html)
      header ();
  }
  END {
    if (!from_html)
      trailer ();
  }

  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }
  /\/\// {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* '' strings. */
  /[\']/ {
    string_face (true);
    language_print ($0);
    call (javascript_string);
    string_face (false);
  }

  /* Function definitions. */
  /\b(function)([ \t]+)([A-Za-z\$_][A-Za-z\$_0-9]*)([ \t]*\()/ {
    keyword_face (true);
    language_print ($1);
    keyword_face (false);

    language_print ($2);

    function_name_face (true);
    language_print ($3);
    function_name_face (false);

    language_print ($4);
  }

  /* Keywords.
     (build-re '(
     abstract boolean break byte case catch char class const continue
     default do double else extends false final finally float for function
     goto if implements import in instanceof int interface long native new
     null package private protected public return short static super switch
     synchronized this throw throws transient true try var void while with
     ))
   */
  /\b(abstract|b(oolean|reak|yte)|c(a(se|tch)|har|lass|on(st|tinue))\
|d(efault|o(|uble))|e(lse|xtends)|f(alse|inal(|ly)|loat|or|unction)\
|goto|i(f|mp(lements|ort)|n(|stanceof|t(|erface)))|long\
|n(ative|ew|ull)|p(ackage|r(ivate|otected)|ublic)|return\
|s(hort|tatic|uper|witch|ynchronized)|t(h(is|row(|s))|r(ansient|ue|y))\
|v(ar|oid)|w(hile|ith))\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  /* Built-in objects.
     (build-re '(Math Date eval parseInt parseFloat))
   */
  /\b(Date|Math|eval|parse(Float|Int))\b/ {
    builtin_face (true);
    language_print ($0);
    builtin_face (false);
  }

  /* Terminator for nested JavaScript programs. */
  /<\/[sS][cC][rR][iI][pP][tT]>/ {
    from_html_terminator = $0;
    return;
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: mail
 * Description: Mail and news articles.
 * Author: Markku Rossi <mtr@iki.fi>
 */

state mail_body
{
  BEGIN {
    reference_face (false);
  }
  /^[ \t]+>/ {
    reference_face (true);
    language_print ($0);
    call (eat_one_line);
    reference_face (false);
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state mail
{
  BEGIN {
    header ();
    reference_face (true);
  }
  END {
    trailer ();
  }

  /^[ \t]*$/ {
    /* Move to the mail body. */
    call (mail_body);
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: makefile
 * Description: Make program's definition files.
 * Author: Markku Rossi <mtr@iki.fi>
 */

state sh_eat_to_apostrophe
{
  /\'/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state sh_eat_to_grave
{
  /`/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state makefile
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /#/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }
  /* An escaped double quote, this doesn't start a string constant. */
  /\\\"/ {
    language_print ($0);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Shell apostrophe quote. */
  /\'/ {
    string_face (true);
    language_print ($0);
    call (sh_eat_to_apostrophe);
    string_face (false);
  }

  /* Shell grave quote. */
  /`/ {
    string_face (true);
    language_print ($0);
    call (sh_eat_to_grave);
    string_face (false);
  }

  /* Variable references. */

  /\$\(/ {
    language_print ($0);
    reference_face (true);
    str = match_balanced_block (/\(/, /\)/);
    reference_face (false);
    language_print (str);
  }

  /\${/ {
    language_print ($0);
    reference_face (true);
    str = match_balanced_block (/{/, /}/);
    reference_face (false);
    language_print (str);
  }

  /* Targets. */
  /^[^ \t\r\n]+:/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: nroff
 * Description: Manual pages formatted with the nroff program.
 * Author: Markku Rossi <mtr@iki.fi>
 */

state nroff_italic
{
  BEGIN {
  }
  /_\010(.)/ {
    language_print ($1);
  }
  /([^_])\010.\010.\010./ {
    bold (true);
    language_print ($1);
    call (nroff_bold);
    bold (false);
    italic (true);
  }
  /.|\n/ {
    italic (false);
    language_print ($0);
    return;
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state nroff_bold
{
  /([^_])\010.\010.\010./ {
    language_print ($1);
  }
  /_\010(.)/ {
    italic (true);
    language_print ($1);
    call (nroff_italic);
    italic (false);
    bold (true);
  }
  /.|\n/ {
    bold (false);
    language_print ($0);
    return;
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state nroff
{
  BEGIN {
    header ();
  }

  END {
    trailer ();
  }

  /_\010(.)/ {
    italic (true);
    language_print ($1);
    call (nroff_italic);
  }
  /([^_])\010.\010.\010./ {
    bold (true);
    language_print ($1);
    call (nroff_bold);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: objc
 * Description: Objective-C programming language.
 * Author: Markku Rossi <mtr@iki.fi> with help of Emacs' `font-lock.el'.
 */

objc_keyword_re =
/* Keywords.	Basicly C + some extras, *but* not goto and case.
   (build-re '(break continue default do else for if return sizeof
   switch while self super _cmd id Class SEL IMP BOOL YES NO nil Nil))
 */
  /\b(BOOL|Class|IMP|N(O|il)|SEL|YES|_cmd|break|continue|d(efault|o)|else\
|for|i(d|f)|nil|return|s(elf|izeof|uper|witch)|while)\b/;

objc_type_re =
/* Types.
   (build-re '(auto extern register static typedef struct union enum
   signed unsigned short long int char float double void volatile
   const id oneway in out inout bycopy byref))
 */
  /\b(auto|by(copy|ref)|c(har|onst)|double|e(num|xtern)|float\
|i(d|n(|out|t))|long|o(neway|ut)|register|s(hort|igned|t(atic|ruct))\
|typedef|un(ion|signed)|vo(id|latile))\b/;


state objc_method_line
{
  /* Argument declarations after the method.
   $1      $2                       $3       $4 $5           $6      $7 */
  /([ \t]*)([A-Za-z_][A-Za-z_0-9]*)?(:[ \t]*)(\(([^)\n]+)\))?([ \t]*)([A-Za-z_][A-Za-z_0-9]*)/ {
    language_print ($1);

    if (length ($2) > 0)
      {
	function_name_face (true);
	language_print ($2);
	function_name_face (false);
      }

    language_print ($3);

    if (length ($4) > 0)
      {
	language_print ("(");
	type_face (true);
	language_print ($5);
	type_face (false);
	language_print (")");
      }

    language_print ($6);

    variable_name_face (true);
    language_print ($7);
    variable_name_face (false);
  }

  /\n/ {
    language_print ($0);
    return;
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state objc_method_continuation_line
{
  /* Method names and arguments on lines following the function declaration.
    $1      $2                       $3       $4 $5           $6      $7 */
  /^([ \t]*)([A-Za-z_][A-Za-z_0-9]*)?(:[ \t]*)(\(([^)\n]+)\))?([ \t]*)\
([A-Za-z_][A-Za-z_0-9]*)/ {
    language_print ($1);

    if (length ($2) > 0)
      {
        function_name_face (true);
        language_print ($2);
        function_name_face (false);
      }

    language_print ($3);

    if (length ($4) > 0)
      {
        language_print ("(");
        type_face (true);
        language_print ($5);
        type_face (false);
        language_print (")");
      }

    language_print ($6);

    variable_name_face (true);
    language_print ($7);
    variable_name_face (false);

    /* Highlight all remaining arguments on this line. */
    call (objc_method_line);
  }

  /*
   * If the previous one didn't match, we'r done with this method
   * declaration.
   */
  /()/ {
    return;
  }
}

state objc_compiler_directive_line
{
  /([ \t:<(,]*)([A-Za-z_][A-Za-z_0-9]*)/ {
    language_print ($1);

    function_name_face (true);
    language_print ($2);
    function_name_face (false);
  }

  /*
   * If the previous one didn't match, we'r done with this directive.
   * Yes, that should match an empty string.
   */
  /()/ {
    return;
  }
}

state objc
{
  BEGIN {
    if (need_version (1, 5, 1))
      objc_function_name_re
	= /^([A-Za-z][a-zA-Z0-9_\* ]+)([ \*])([a-zA-Z_][a-zA-Z_0-9]*)([ \t]*\()/;
    else
      objc_function_name_re = 0;

    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }
  /\/\// {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Pre-processor lines. */
  /^#/ {
    language_print ($0);
    call (c_ppline);
  }

  /* Compiler directives. */
  /(@)([A-Za-z][A-Za-z0-9]*)\>/ {
    /* Leading garbage. */
    language_print ($1);

    /* The directive. */
    keyword_face (true);
    language_print ($2);
    keyword_face (false);

    /* And all the remaining stuff on this line. */
    call (objc_compiler_directive_line);
  }

  /* Character constants. */
  /'.'|'\\\\.'/ {
    string_face (true);
    language_print ($0);
    string_face (false);
  }

  /* Keywords. */
  objc_keyword_re {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  /* Types. */
 objc_type_re {
    type_face (true);
    language_print ($0);
    type_face (false);
  }

  /* Method names.  First, on the same line as the function declaration.
   $1           $2        $3      $4 $5           $6      $7 */
  /(^[+-][ \t]*)(PRIVATE)?([ \t]*)(\(([^)\n]+)\))?([ \t]*)([A-Za-z_]\
[A-Za-z_0-9]*)/ {
    language_print ($1);

    if (length ($2) > 0)
      {
	type_face (true);
	language_print ($2);
	type_face (false);
      }

    language_print ($3);

    if (length ($4) > 0)
      {
	language_print ("(");
	type_face (true);
	language_print ($5);
	type_face (false);
	language_print (")");
      }

    language_print ($6);

    function_name_face (true);
    language_print ($7);
    function_name_face (false);

    /* Highlight arguments from the same line. */
    call (objc_method_line);

    /*
     * Method names and arguments on lines following the function declaration.
     */
    call (objc_method_continuation_line);
  }

  /*
   * Labels and case tags.  These must remain as a sole statement on a line,
   * otherwise we detect selectors.  Emacs accepts also bare numbers.
   */
  /^([ \t]*)([a-zA-Z0-9_]+)(:[ \t]*)$/ {
    language_print ($1);
    if (strcmp ($2, "default") == 0)
      {
	/* `default' is a keyword. */
	keyword_face (true);
	language_print ($2);
	keyword_face (false);
      }
    else
      {
	reference_face (true);
	language_print ($2);
	reference_face (false);
      }

    language_print ($3);
  }

  /* Goto, case and the target. */
  /\<(goto|case)\>([ \t]+)(-?[A-Za-z_][A-Za-z_0-9]*)?/ {
    keyword_face (true);
    language_print ($1);
    keyword_face (false);

    language_print ($2);

    if (length ($3) > 0)
      {
	reference_face (true);
	language_print ($3);
	reference_face (false);
      }
  }

  /*
   * Function definitions, but only if you code with the one and only
   * usable indentation style (GNU).
   */
  /^([a-zA-Z_][a-zA-Z_0-9]*)([ \t]*\()/ {
    function_name_face (true);
    language_print ($1);
    function_name_face (false);

    language_print ($2);
  }

  /* Function definitions and prototypes for other (loser) coding styles. */
  objc_function_name_re {
    garbage = $1;
    middle_garbage = $2;
    function_name = $3;
    tail_garbage = $4;

    highlight_types (garbage, objc_type_re);

    language_print (middle_garbage);

    function_name_face (true);
    language_print (function_name);
    function_name_face (false);

    language_print (tail_garbage);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: pascal
 * Description: Pascal programming language
 * Author: Michael Van Canneyt <michael@tfdec1.fys.kuleuven.ac.be>
 */

state pascal_comment
{
  /(\}|\*\))/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state pascal_string
{
  /[\']/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state pascal
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }
  /* comments */
  /(\{|\(\*)/ {
    comment_face (true);
    language_print ($0);
    call (pascal_comment);
    comment_face (false);
  }
  /* strings */
  /[\']/ {
    string_face (true);
    language_print ($0);
    call (pascal_string);
    string_face (false);
  }
  /* Keywords.
     (build-re '(and asm array begin case const constructor destructor div
     do downto else end file for function goto if implementation in inline
     interface label mod nil not object of or packed procedure program record
     repeat set shlr string then to type unit until uses var while with xor)
     t)
   */
  /\b([aA]([nN][dD]|[rR][rR][aA][yY]|[sS][mM])|[bB][eE][gG][iI][nN]\
|[cC]([aA][sS][eE]|[oO][nN][sS][tT](|[rR][uU][cC][tT][oO][rR]))\
|[dD]([eE][sS][tT][rR][uU][cC][tT][oO][rR]|[iI][vV]|[oO](|[wW][nN][tT][oO]))\
|[eE]([lL][sS][eE]|[nN][dD])\
|[fF]([iI][lL][eE]|[oO][rR]|[uU][nN][cC][tT][iI][oO][nN])\
|[gG][oO][tT][oO]\
|[iI]([fF]|[mM][pP][lL][eE][mM][eE][nN][tT][aA][tT][iI][oO][nN]\
|[nN](|[lL][iI][nN][eE]|[tT][eE][rR][fF][aA][cC][eE]))\
|[lL][aA][bB][eE][lL]|[mM][oO][dD]|[nN]([iI][lL]|[oO][tT])\
|[oO]([bB][jJ][eE][cC][tT]|[fF]|[rR])\
|[pP]([aA][cC][kK][eE][dD]\
|[rR][oO]([cC][eE][dD][uU][rR][eE]|[gG][rR][aA][mM]))\
|[rR][eE]([cC][oO][rR][dD]|[pP][eE][aA][tT])\
|[sS]([eE][tT]|[hH][lL][rR]|[tT][rR][iI][nN][gG])\
|[tT]([hH][eE][nN]|[oO]|[yY][pP][eE])\
|[uU]([nN]([iI][tT]|[tT][iI][lL])|[sS][eE][sS])|[vV][aA][rR]\
|[wW]([hH][iI][lL][eE]|[iI][tT][hH])|[xX][oO][rR])\b/ {
  keyword_face (true);
  language_print ($0);
  keyword_face (false);
  }
}


/**
 * Name: perl
 * Description: Perl programming language.
 *
 * Author: Jim Villani, Logistics Management Institute (jvillani@lmi.org)
 */

state perl_comment
{
  /\*\\\// {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
   language_print ($0);
  }
}

state perl_dquot_string
{
  /\\\\./ {
    language_print ($0);
  }
  /\"/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state perl_quot_string
{
  /\\\\./ {
    language_print ($0);
  }
  /[\']/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state perl_bquot_string
{
  /\\\\./ {
    language_print ($0);
  }
  /`/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state perl
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /#.*$/ {
    comment_face (true);
    language_print ($0);
    comment_face (false);
  }

  /* Ignore escaped quote marks */
  /\\\"/ {
    language_print ($0);
  }
  /\\\'/ {
    language_print ($0);
  }
  /\\\`/ {
    language_print ($0);
  }

  /* stuff after a -> is a method,
   * don't bold just because it looks like a keyword
   */
  /->\w+/ {
    language_print ($0);
  }

  /* stuff between a - and a => is a named parameter,
   * don't bold just because it looks like a keyword
   */
  /-\w+=>/ {
    language_print ($0);
  }

  /* In cgi files, JavaScript might be imbedded, so we need to look out
   * for the JavaScript comments, because they might contain something
   * we don't like, like a contraction (don't, won't, etc.)
   * We won't put them in comment face, because they are not perl
   * comments.
   */
  /\/\// {
    language_print ($0);
    call (eat_one_line);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (perl_dquot_string);
    string_face (false);
  }
  /[\']/ {
    string_face (true);
    language_print ($0);
    call (perl_quot_string);
    string_face (false);
  }

  /* Backquoted command string */
  /`/ {
    string_face (true);
    language_print ($0);
    call (perl_bquot_string);
    string_face (false);
  }

  /* Variables */
  /[$%@&]+\w+/ {
    keyword_face (false);
    language_print ($0);
  }

  /* Keywords. From perl distribution's toke.c
     abs accept alarm and atan2 bind binmode bless caller chdir chmod
     chomp chop chown chr chroot close closedir cmp connect continue cos
     crypt dbmclose dbmopen defined delete die do dump each else elsif
     endgrent endhostent endnetent endprotoent endpwent endservent eof
     eq eval exec exists exit exp fcntl fileno flock for foreach fork
     format formline ge getc getgrent getgrgid getgrnam gethostbyaddr
     gethostbyname gethostent getlogin getnetbyaddr getnetbyname
     getnetent getpeername getpgrp getppid getpriority getprotobyname
     getprotobynumber getprotoent getpwent getpwnam getpwuid getservbyname
     getservbyport getservent getsockname getsockopt glob gmtime goto
     grep gt hex if index int ioctl join keys kill last lc lcfirst le
     length link listen local localtime log lstat lt m map mkdir msgctl
     msgget msgrcv msgsnd my ne new next no not oct open opendir or ord
     pack package pipe pop pos print printf prototype push q qq quotemeta
     qw qx rand read readdir readline readlink readpipe recv redo ref
     rename require reset return reverse rewinddir rindex rmdir s scalar
     seek seekdir select semctl semget semop send setgrent sethostent
     setnetent setpgrp setpriority setprotoent setpwent setservent
     setsockopt shift shmctl shmget shmread shmwrite shutdown sin sleep
     socket socketpair sort splice split sprintf sqrt srand stat study
     sub substr symlink syscall sysopen sysread sysseek system syswrite
     tell telldir tie tied time times tr truncate uc ucfirst umask undef
     unless unlink unpack unshift untie until use utime values vec wait
     waitpid wantarray warn while write x xor y
   */
  /\b(a(bs|ccept|larm|nd|tan2)|b(in(d|mode)|less)|c(aller|h(dir|mod\
|o(mp|p|wn)|r(|oot))|lose(|dir)|mp|o(n(nect|tinue)|s)|rypt)\
|d(bm(close|open)|e(fined|lete)|ie|o|ump)|e(ach|ls(e|if)|nd(gr|host|net|proto\
|pw|serv)ent|of|q|val|x(ec|i(sts|t)|p))|f(cntl|ileno|lock|or(|each|k\
|m(at|line)))|g(e(|t(c|gr(ent|gid|nam)|host(by(addr|name)|ent)|login\
|net(by(addr|name)|ent)|p(eername|grp|pid|riority|roto(by(addr|name|number)\
|ent)|w(ent|nam|uid))|s(erv(by(name|port)|ent)|ock(name|opt))))|lob|mtime\
|oto|rep|t)|hex|i(f|n(t|dex)|octl)|join|k(eys|ill)|l(ast|c(|first)|e(|ngth)\
|i(nk|sten)|o(cal(|time)|g)|stat|t)|m|m(ap|kdir|sg(ctl|get|rcv|snd)|y)\
|n(e(|w|xt)|o(|t))|o(ct|pen(|dir)|r(|d))|p(ack(|age)|ipe|o(p|s)|r(int(|f)\
|ototype)|ush)|q(|q|uotemeta|w|x)|r(and|e(a(d(|dir|lin(e|k)|pipe))|cv\
|do|f|name|quire|set|turn|verse|winddir)|index|mdir)|s(|calar|e(e(k|kdir)\
|lect|m(ctl|get|op)|nd|t((gr|host|net)ent|p(grp|r(iority|otoent)|went)\
|s(ervent|ockopt)))|h(ift|m(ctl|get|read|write)|utdown)|in|leep|o(cke(t|tpair)\
|rt)|p(li(ce|t)|rintf)|qrt|rand|t(at|udy)|u(b|bstr)|y(mlink|s(call|open|read\
|s(eek|tem)|write)))|t(ell(|dir)|i(e|ed|m(e|es))|r(|uncate))|u(c(|first)\
|mask|n(def|l(ess|ink)|pack|shift|ti(e|l))|se|time)|v(alues|ec)|w(a(i(t(|pid))\
|ntarray|rn)|hile|rite)|x(|or)|y)\b/ {

    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: postscript
 * Description: PostScript programming language.
 *
 * Author: Dave Hylands (DHylands@creo.com)
 */

state ps_string
{
  /\\\\./ {
    language_print ($0);
  }
  /[\)]/ {
    language_print ($0);
    return;
  }
  /[\(]/ {
    /* Balanced ()'s in a string */
    language_print ($0);
    call (ps_string);
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state ps_encoded_string
{
  /[\>]/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state postscript
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /%/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /[\(]/ {
    string_face (true);
    language_print ($0);
    call (ps_string);
    string_face (false);
  }

  /[\<]/ {
    string_face (true);
    language_print ($0);
    call (ps_encoded_string);
    string_face (false);
  }

  /* Keywords.

     I built the keyword list using the following PostScript program

	/str 128 string def
	/outFile \(ps.txt)(w)file def
	/proc
	{
	    pop //str cvs outFile exch writestring outFile (\n) writestring
	} bind def

	systemdict /proc load forall
	statusdict /proc load forall
	errordict  /proc load forall

    I then ran:

	sort ps.txt | uniq | fmt > ps.key

    I then went through the list and removed << >> [ ] and obvious Harlequin
    extensions. Many of the keywords remaining are not documented in the Red
    Book but are implemented in some Adobe implementations (especially the
    ones from statusdict). I decided to leave them in.

    And since I don't have emacs (gasp), I wrote a program which takes the
    ps.key file and generates the regular expression. This was faster than
    trying to install emacs and figure out how it works.

    Also note that PostScript doesn't require whitespace in front of keywords.
    In particular, text can follow immediately after any of the following
    characters:

	> { } ) [ ] /

    and can be followed immediately by the following:

	< { } ( [ ] /

    in addition to white space.

    Contents of ps.key:

    $error .error 11x17tray 12x24tray 15x24tray = == =print =scratch =string
    FontDirectory GlobalFontDirectory ISOLatin1Encoding
    Run SharedFontDirectory SpecialRun StandardEncoding
    VMerror a2tray a3tray a4tray a5tray abs add aload
    anchorsearch and appletalktype arc arcn arct arcto array ashow astore
    atan authors awidthshow b5tray begin bind bitshift blackoverprint blink
    broadsheettray buildtime bytesavailable cachestatus ceiling cexec
    charpath checkpassword checkscreen clear cleardictstack clearinterrupt
    cleartomark clip clippath closefile closepath closescc colorimage concat
    concatmatrix configurationerror copy copypage cos count countdictstack
    countexecstack counttomark cshow currentblackgeneration
    currentcacheparams currentcmykcolor currentcolor currentcolorrendering
    currentcolorrenderingintent currentcolorscreen currentcolorspace
    currentcolortransfer currentdash currentdevparams currentdict
    currentdlhooks currentfile currentflat currentfont currentglobal
    currentgray currentgstate currenthalftone currenthalftonephase
    currenthsbcolor currentinterceptcolorspace currentlinecap
    currentlinejoin currentlinewidth currentmatrix currentmiterlimit
    currentobjectformat currentoverprint currentpacking currentpagedevice
    currentpoint currentrelativeneutrals currentreproductioncriteria
    currentrgbcolor currentscreen currentseparationcolornames
    currentseparationorder currentshared currentstrokeadjust
    currentsystemparams currenttransfer currenttrapintent
    currentundercolorremoval currentuserparams curveto cvi cvlit cvn cvr
    cvrs cvs cvx daytime def defaultblackoverprint
    defaulthandleerror defaultmatrix defaultmirrorprint defaultpagemargin
    defaultpageparams defaultprocesscolors defaulttimeouts definefont
    defineresource defineuserobject deletefile devdismount devforall
    devformat deviceinfo devmount devstatus dict dictfull dictstack
    dictstackoverflow dictstackunderflow disableinterrupt diskonline
    diskstatus div dlclearcaches dostartpage dosysstart dtransform dup echo
    eerom eescratch eexec enableinterrupt end endofjob eoclip eofill eq
    erasepage errorbeep errordict exch exec execdict execform execstack
    execstackoverflow execuserobject executeonly executive exit exp exposure
    false file filekind filelinenumber filename filenameforall fileposition
    fill filter findcharstrings findcolorrenderingintent findencoding
    findfont findpgfont findresource flattenpath floor flush flushcache
    flushfile for forall gcheck ge genericpaper get getinterval getknown
    getsccconfig gettopfile gettoprealfile globaldict glyphshow grestore
    grestoreall gsave gstate gt handleerror hardwareiomode
    identmatrix idiv idlefonts idtransform if ifelse
    image imagemask index ineofill infill initclip initgraphics initialized
    initializedisk initmatrix instroke internaldict interrupt
    interruptenabled inueofill inufill inustroke invalidaccess invalidexit
    invalidfileaccess invalidfont invalidrestore invertmatrix ioerror
    ismanualfeed itransform jobname jobsource jobstate jobstring jobtimeout
    known kshow languagelevel lastmode le ledgertray legaltray length
    lettertray limitcheck lineto listfilesinestack ln load
    loadcurrentpagedevice loadsetpagedevice log loop lt makefont makepattern
    manualfeedtimeout margins mark matchtemplate matrix maxlength
    medialength mediasize mediawidth mirrorprint mod moveto mul ne neg
    negativeprint newpath noaccess nocurrentpoint not null nulldevice
    openscc or packedarray pagecount pagemargin pageparams pagestackorder
    pagetype pathbbox pathforall pop print printererror printermessage
    printername printerstatus printerupset printobject processcolors product
    prompt pstack put putinterval quit ramsize rand rangecheck rcheck
    rcurveto read readhexstring readline readonly readstring realtime
    rectclip rectfill rectstroke renamefile repeat resetfile resetprinter
    resolution resourceforall resourcestatus restore reversepath revision
    rlineto rmoveto roll rootfont rotate round rrand run save scale
    scalefont sccbatch sccfiles sccinteractive scheck screenforall search
    selectfont sendctrld sendpcmd sendprinterstate serialnumber serverdict
    setaccuratescreens setbbox setblackgeneration setblackoverprint setblink
    setcachedevice setcachedevice2 setcachelimit setcacheparams setcharwidth
    setcmykcolor setcolor setcolorrendering setcolorrenderingintent
    setcolorscreen setcolorspace setcolortransfer setdash
    setdefaultblackoverprint setdefaultmirrorprint setdefaultpagemargin
    setdefaultpageparams setdefaultprocesscolors setdefaulttimeouts
    setdevparams setdlhooks setdostartpage setdosysstart seteescratch
    setexposure setfileposition setflat setfont setglobal setgray setgstate
    sethalftone sethalftonephase sethardwareiomode sethsbcolor setidlefonts
    setinterceptcolorspace setjobtimeout setlinecap setlinejoin setlinewidth
    setmargins setmatrix setmirrorprint setmiterlimit setnegativeprint
    setobjectformat setoverprint setpacking setpage setpagedevice
    setpagemargin setpageparams setpageseen setpagestackorder setpagetype
    setpassword setpattern setprintername setprocesscolors
    setrelativeneutrals setreproductioncriteria setresolution setrgbcolor
    setsccbatch setsccconfig setsccinteractive setscreen setshared
    setsoftwareiomode setstderr setstdio setstrokeadjust setsystemparams
    settransfer settrapintent setucacheparams setundercolorremoval
    setuserdiskpercent setuserparams setvmthreshold shareddict show showpage
    sin softwareiomode sqrt srand stack stackoverflow stackunderflow start
    startjob startpage status statuscommand statusdict stop stopped store
    string stringwidth stroke strokepath sub superstop superstopped
    switchsetting syntaxerror system systemdict tabloidtray timeout token
    transform translate true truncate type typecheck uappend ucache
    ucachestatus ueofill ufill undef undefined undefinedfilename
    undefinedresource undefinedresult undefinefont undefineresource
    undefineuserobject unmatchedmark unregistered upath userdict
    userdiskpercent usertime ustroke ustrokepath validatefont version
    vmreclaim vmstatus waittimeout wcheck where widthshow write
    writehexstring writeobject writestring xcheck xor xshow xyshow yshow
  */
  /(\b|[\>\{\}\)\[\]\/])\
(\$error|\.error|1(1x17tray|2x24tray|5x24tray)|=(|=|print|s(cratch|tring))\
|FontDirectory|GlobalFontDirectory|ISOLatin1Encoding|Run|S\
(haredFontDirectory|pecialRun|tandardEncoding)|VMerror|a(2tray|3tray\
|4tray|5tray|bs|dd|load|n(chorsearch|d)|ppletalktype|r(c(|n|t(|o))|ray)|s\
(how|tore)|tan|uthors|widthshow)|b(5tray|egin|i(nd|tshift)|l\
(ackoverprint|ink)|roadsheettray|uildtime|ytesavailable)|c(achestatus|e\
(iling|xec)|h(arpath|eck(password|screen))|l(ear(|dictstack|interrupt\
|tomark)|ip(|path)|ose(file|path|scc))|o(lorimage|n(cat(|matrix)\
|figurationerror)|py(|page)|s|unt(|dictstack|execstack|tomark))|show|ur\
(rent(blackgeneration|c(acheparams|mykcolor|olor(|rendering(|intent)|s\
(creen|pace)|transfer))|d(ash|evparams|ict|lhooks)|f(ile|lat|ont)|g(lobal\
|ray|state)|h(alftone(|phase)|sbcolor)|interceptcolorspace|line(cap|join\
|width)|m(atrix|iterlimit)|o(bjectformat|verprint)|p(a(cking|gedevice)\
|oint)|r(e(lativeneutrals|productioncriteria)|gbcolor)|s(creen|eparation\
(colornames|order)|hared|trokeadjust|ystemparams)|tra(nsfer|pintent)|u\
(ndercolorremoval|serparams))|veto)|v(i|lit|n|r(|s)|s|x))|d(aytime|e(f(\
|ault(blackoverprint|handleerror|m(atrix|irrorprint)|p(age(margin\
|params)|rocesscolors)|timeouts)|ine(font|resource|userobject))|letefile|v\
(dismount|for(all|mat)|iceinfo|mount|status))|i(ct(|full|stack(|overflow\
|underflow))|s(ableinterrupt|k(online|status))|v)|lclearcaches|os(tartpage\
|ysstart)|transform|up)|e(cho|e(rom|scratch|xec)|n(ableinterrupt|d(\
|ofjob))|o(clip|fill)|q|r(asepage|ror(beep|dict))|x(ch|ec(|dict|form|stack\
(|overflow)|u(serobject|t(eonly|ive)))|it|p(|osure)))|f(alse|i(l(e(|kind\
|linenumber|name(|forall)|position)|l|ter)|nd(c(harstrings\
|olorrenderingintent)|encoding|font|pgfont|resource))|l(attenpath|oor\
|ush(|cache|file))|or(|all))|g(check|e(|nericpaper|t(|interval|known\
|sccconfig|top(file|realfile)))|l(obaldict|yphshow)|restore(|all)|s(ave\
|tate)|t)|ha(ndleerror|rdwareiomode)|i(d(entmatrix|iv|lefonts|transform)\
|f(|else)|mage(|mask)|n(dex|eofill|fill|it(clip|graphics|ialized(|isk)\
|matrix)|stroke|ter(naldict|rupt(|enabled))|u(eofill|fill|stroke)|v(alid\
(access|exit|f(ileaccess|ont)|restore)|ertmatrix))|oerror|smanualfeed\
|transform)|job(name|s(ource|t(ate|ring))|timeout)|k(nown|show)|l(a\
(nguagelevel|stmode)|e(|dgertray|galtray|ngth|ttertray)|i(mitcheck|neto\
|stfilesinestack)|n|o(ad(|currentpagedevice|setpagedevice)|g|op)|t)|m(a\
(ke(font|pattern)|nualfeedtimeout|r(gins|k)|t(chtemplate|rix)|xlength)\
|edia(length|size|width)|irrorprint|o(d|veto)|ul)|n(e(|g(|ativeprint)\
|wpath)|o(access|currentpoint|t)|ull(|device))|o(penscc|r)|p(a(ckedarray\
|ge(count|margin|params|stackorder|type)|th(bbox|forall))|op|r(int(|er\
(error|message|name|status|upset)|object)|o(cesscolors|duct|mpt))|stack\
|ut(|interval))|quit|r(a(msize|n(d|gecheck))|c(heck|urveto)|e(a(d(\
|hexstring|line|only|string)|ltime)|ct(clip|fill|stroke)|namefile|peat|s\
(et(file|printer)|o(lution|urce(forall|status))|tore)|v(ersepath|ision))\
|lineto|moveto|o(ll|otfont|tate|und)|rand|un)|s(ave|c(ale(|font)|c(batch\
|files|interactive)|heck|reenforall)|e(arch|lectfont|nd(ctrld|p(cmd\
|rinterstate))|r(ialnumber|verdict)|t(accuratescreens|b(box|l(ack\
(generation|overprint)|ink))|c(ache(device(|2)|limit|params)|harwidth\
|mykcolor|olor(|rendering(|intent)|s(creen|pace)|transfer))|d(ash|e(fault\
(blackoverprint|mirrorprint|p(age(margin|params)|rocesscolors)|timeouts)\
|vparams)|lhooks|os(tartpage|ysstart))|e(escratch|xposure)|f(ileposition\
|lat|ont)|g(lobal|ray|state)|h(a(lftone(|phase)|rdwareiomode)|sbcolor)|i\
(dlefonts|nterceptcolorspace)|jobtimeout|line(cap|join|width)|m(a(rgins\
|trix)|i(rrorprint|terlimit))|negativeprint|o(bjectformat|verprint)|p(a\
(cking|ge(|device|margin|params|s(een|tackorder)|type)|ssword|ttern)|r\
(intername|ocesscolors))|r(e(lativeneutrals|productioncriteria|solution)\
|gbcolor)|s(c(c(batch|config|interactive)|reen)|hared|oftwareiomode|t(d\
(err|io)|rokeadjust)|ystemparams)|tra(nsfer|pintent)|u(cacheparams\
|ndercolorremoval|ser(diskpercent|params))|vmthreshold))|h(areddict|ow(\
|page))|in|oftwareiomode|qrt|rand|t(a(ck(|overflow|underflow)|rt(|job\
|page)|tus(|command|dict))|o(p(|ped)|re)|r(ing(|width)|oke(|path)))|u(b\
|perstop(|ped))|witchsetting|y(ntaxerror|stem(|dict)))|t(abloidtray|imeout\
|oken|r(ans(form|late)|u(e|ncate))|ype(|check))|u(append|cache(|status)\
|eofill|fill|n(def(|ine(d(|filename|res(ource|ult))|font|resource\
|userobject))|matchedmark|registered)|path|s(er(di(ct|skpercent)|time)\
|troke(|path)))|v(alidatefont|ersion|m(reclaim|status))|w(aittimeout|check\
|here|idthshow|rite(|hexstring|object|string))|x(check|or|show|yshow)\
|yshow)\
(\b|[\<\{\}\(\[\]\/])/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: python
 * Description: Python programming language.
 * Author: Andy Eskilsson <Andy.Eskilsson@telelogic.se>
 */

state python_string
{
  /\\\\./ {
    language_print ($0);
  }
  python_string_end {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state python
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /#/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }
  /* Python strings */
  /(\"\"\"|[\'][\'][\'])/ {
    python_string_end = regexp($0);
    string_face (true);
    language_print ($0);
    call (python_string);
    string_face (false);
  }

  /(\"|[\'])/ {
    python_string_end = regexp( $0 );
    string_face (true);
    language_print ($0);
    call (python_string);
    string_face (false);
  }


  /* Function */
  /([ \t]*)(def)([ \t]+)([^(]*)/ {
    /* indentation */
    language_print ($1);

    /* def */
    keyword_face (true);
    language_print ($2);
    keyword_face (false);

    /* middle */
    language_print ($3);

    /* Function name. */
    function_name_face (true);
    language_print ($4);
    function_name_face (false);
  }

    /* Keywords */
/\\b(a(nd|ssert)|break|c(lass|ontinue)|de(f|l)\\
|e(l(if|se(|:))|x(cept(|:)|ec))|f(inally:|or|rom)|global\\
|i(f|mport|n|s)|lambda|not|or|p(ass|rint)|r(aise|eturn)|try:|while)\\b/ {
  keyword_face (true);
  language_print ($0);
  keyword_face (false);
}

  LANGUAGE_SPECIALS {
    language_print ($0);
  }

}


/**
 * Name: scheme
 * Description: Scheme programming language.
 * Author: Markku Rossi <mtr@iki.fi>
 */

state scheme
{
  BEGIN {
    header ();
    if (need_version (1, 5, 2))
      {
	/*
	 * Modify regexp character syntax so that we can distinguish all
	 * scheme symbols.
	 */
	extras = list ('!', '$', '%', '&', '*', '/', ':', '<',
		       '=', '>', '?', '~', '^', '.', '+', '-');
	for (i = 0; i < length (extras); i = i + 1)
	  regexp_syntax (extras[i], 'w');
      }
  }
  END {
    trailer ();
  }

  /* Comments. */
  /;/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Definitions. */
  /(\([ \t]*)(define)([ \t]+\(?)([!\$%&\*\/:<=>\?~_^a-zA-Z][!\$%&\*\/:<=>\?~_^a-zA-Z0-9.+\-]*)/ {
    /* Starting garbage. */
    language_print ($1);

    /* Keyword `define'. */
    keyword_face (true);
    language_print ($2);
    keyword_face (false);

    /* Middle garbage. */
    language_print ($3);

    /* Function name. */
    function_name_face (true);
    language_print ($4);
    function_name_face (false);
  }

  /* ':'-names, Emacs highlights these, so do we. */
  /([ \t])(:[!\$%&\*\/:<=>\?~_^a-zA-Z0-9.+\-]*)/ {
    language_print ($1);
    reference_face (true);
    language_print ($2);
    reference_face (false);
  }

  /* Keywords.
     "=>" + "set!" +
     (build-re '(else define unquote unquote-splicing quote lambda
     if begin cond and or case let let* letrec do delay quasiquote))
   */
  /=>|\bset!|\b(and|begin|c(ase|ond)|d(e(fine|lay)|o)|else|if\
|l(ambda|et(|\*|rec))|or|qu(asiquote|ote)|unquote(|-splicing))\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: sh
 * Description: Bourne shell programming language.
 * Author: Juergen Kahrs <Juergen.Kahrs@t-online.de>
 */

state sh
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /#/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Excutable script. */
  /^#!/ {
    reference_face (true);
    language_print ($0);
    call (eat_one_line);
    reference_face (false);
  }

  /* Keywords. */
  /\b(CDPATH|HOME|IFS|MAIL((CHECK)?|(PATH)?)|P(ATH|S(1|2))|SH(ACCT|ELL)|\
break|c(ase|d|ontinue)|do(ne)?|e(cho|lse|sac|val|x(ec|it|port))|f(i|or)|\
getopts|hash|i[fn]|limit|newgrp|pwd|re(ad(only)?|turn)|s(et|hift)|\
t(est|hen|imes|rap|ype)|u(limit|mask|n(limit|set))|w(ait|hile))\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: sql
 * Description: Sybase 11 SQL.
 * Author: Chris Jack <chris_jack@msn.com>
 */

state sql_comment
{
  /\\\/\*/ {
    language_print ($0);
    call (sql_comment);
  }
  /\*\\\// {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
   language_print ($0);
  }
}

state sql_string
{
  /\\\\./ {
    language_print ($0);
  }
  /[\']/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state sql
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (sql_comment);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Character constants. */
  /[\']/ {
    string_face (true);
    language_print ($0);
    call (sql_string);
    string_face (false);
  }

  /* Keywords.
   */
  /\b(\
[Aa][Bb][Ss]|\
[Aa][Cc][Oo][Ss]|\
[Aa][Dd][Dd]|\
[Aa][Ll][Ll]|\
[Aa][Ll][Ll][Oo][Ww]_[Dd][Uu][Pp]_[Rr][Oo][Ww]|\
[Aa][Ll][Tt][Ee][Rr]|\
[Aa][Nn][Dd]|\
[Aa][Nn][Ss][Ii][Nn][Uu][Ll][Ll]|\
[Aa][Nn][Ss][Ii]_[Pp][Ee][Rr][Mm][Ii][Ss][Ss][Ii][Oo][Nn][Ss]|\
[Aa][Nn][Yy]|\
[Aa][Rr][Ii][Tt][Hh]_[Oo][Vv][Ee][Rr][Ff][Ll][Oo][Ww]|\
[Aa][Rr][Ii][Tt][Hh][Aa][Bb][Oo][Rr][Tt]|\
[Aa][Rr][Ii][Tt][Hh][Ii][Gg][Nn][Oo][Rr][Ee]|\
[Aa][Ss]|\
[Aa][Ss][Cc]|\
[Aa][Ss][Cc][Ii][Ii]|\
[Aa][Ss][Ii][Nn]|\
[Aa][Tt]|\
[Aa][Tt][Aa][Nn]|\
[Aa][Tt][Nn]2|\
[Aa][Uu][Tt][Hh][Oo][Rr][Ii][Zz][Aa][Tt][Ii][Oo][Nn]|\
[Aa][Uu][Tt][Oo]|\
[Aa][Vv][Gg]|\
[Bb][Ee][Gg][Ii][Nn]|\
[Bb][Ee][Tt][Ww][Ee][Ee][Nn]|\
[Bb][Ii][Nn][Aa][Rr][Yy]|\
[Bb][Rr][Ee][Aa][Kk]|\
[Bb][Rr][Oo][Ww][Ss][Ee]|\
[Bb][Uu][Ll][Kk]|\
[Bb][Uu][Ll][Kk][Cc][Oo][Pp][Yy]|\
[Bb][Yy]|\
[Cc][Aa][Ss][Cc][Aa][Dd][Ee]|\
[Cc][Ee][Ii][Ll][Ii][Nn][Gg]|\
[Cc][Hh][Aa][Ii][Nn][Ee][Dd]|\
[Cc][Hh][Aa][Rr]|\
[Cc][Hh][Aa][Rr]_[Cc][Oo][Nn][Vv][Ee][Rr][Tt]|\
[Cc][Hh][Aa][Rr]_[Ll][Ee][Nn][Gg][Tt][Hh]|\
[Cc][Hh][Aa][Rr][Aa][Cc][Tt][Ee][Rr]|\
[Cc][Hh][Aa][Rr][Ii][Nn][Dd][Ee][Xx]|\
[Cc][Hh][Ee][Cc][Kk]|\
[Cc][Hh][Ee][Cc][Kk][Pp][Oo][Ii][Nn][Tt]|\
[Cc][Ll][Oo][Ss][Ee]|\
[Cc][Ll][Uu][Ss][Tt][Ee][Rr][Ee][Dd]|\
[Cc][Oo][Ll]_[Ll][Ee][Nn][Gg][Tt][Hh]|\
[Cc][Oo][Ll]_[Nn][Aa][Mm][Ee]|\
[Cc][Oo][Mm][Mm][Ii][Tt]|\
[Cc][Oo][Mm][Pp][Uu][Tt][Ee]|\
[Cc][Oo][Nn][Ff][Ii][Rr][Mm]|\
[Cc][Oo][Nn][Ss][Tt][Rr][Aa][Ii][Nn][Tt]|\
[Cc][Oo][Nn][Tt][Ii][Nn][Uu][Ee]|\
[Cc][Oo][Nn][Tt][Rr][Oo][Ll][Rr][Oo][Ww]|\
[Cc][Oo][Nn][Vv][Ee][Rr][Tt]|\
[Cc][Oo][Ss]|\
[Cc][Oo][Tt]|\
[Cc][Oo][Uu][Nn][Tt]|\
[Cc][Rr][Ee][Aa][Tt][Ee]|\
[Cc][Uu][Rr][Rr][Ee][Nn][Tt]|\
[Cc][Uu][Rr][Ss][Oo][Rr]|\
[Cc][Uu][Rr][Uu][Nn][Rr][Ee][Ss][Ee][Rr][Vv][Ee][Dd][Pp][Gg][Ss]|\
[Dd][Aa][Tt][Aa]_[Pp][Gg][Ss]|\
[Dd][Aa][Tt][Aa][Bb][Aa][Ss][Ee]|\
[Dd][Aa][Tt][Aa][Ll][Ee][Nn][Gg][Tt][Hh]|\
[Dd][Aa][Tt][Ee][Aa][Dd][Dd]|\
[Dd][Aa][Tt][Ee][Dd][Ii][Ff][Ff]|\
[Dd][Aa][Tt][Ee][Ff][Ii][Rr][Ss][Tt]|\
[Dd][Aa][Tt][Ee][Ff][Oo][Rr][Mm][Aa][Tt]|\
[Dd][Aa][Tt][Ee][Nn][Aa][Mm][Ee]|\
[Dd][Aa][Tt][Ee][Pp][Aa][Rr][Tt]|\
[Dd][Aa][Tt][Ee][Tt][Ii][Mm][Ee]|\
[Dd][Bb]_[Ii][Dd]|\
[Dd][Bb]_[Nn][Aa][Mm][Ee]|\
[Dd][Bb][Cc][Cc]|\
[Dd][Ee][Aa][Ll][Ll][Oo][Cc][Aa][Tt][Ee]|\
[Dd][Ee][Cc][Ii][Mm][Aa][Ll]|\
[Dd][Ee][Cc][Ll][Aa][Rr][Ee]|\
[Dd][Ee][Ff][Aa][Uu][Ll][Tt]|\
[Dd][Ee][Ff][Ii][Nn][Ee]|\
[Dd][Ee][Gg][Rr][Ee][Ee][Ss]|\
[Dd][Ee][Ll][Ee][Tt][Ee]|\
[Dd][Ee][Ss][Cc]|\
[Dd][Ii][Ff][Ff][Ee][Rr][Ee][Nn][Cc][Ee]|\
[Dd][Ii][Ss][Kk]|\
[Dd][Ii][Ss][Tt][Ii][Nn][Cc][Tt]|\
[Dd][Oo][Uu][Bb][Ll][Ee]|\
[Dd][Rr][Oo][Pp]|\
[Dd][Uu][Mm][Mm][Yy]|\
[Dd][Uu][Mm][Pp]|\
[Ee][Ll][Ss][Ee]|\
[Ee][Nn][Dd]|\
[Ee][Nn][Dd][Tt][Rr][Aa][Nn]|\
[Ee][Rr][Rr][Ll][Vv][Ll]|\
[Ee][Rr][Rr][Oo][Rr]|\
[Ee][Rr][Rr][Oo][Rr][Dd][Aa][Tt][Aa]|\
[Ee][Rr][Rr][Oo][Rr][Ee][Xx][Ii][Tt]|\
[Ee][Ss][Cc][Aa][Pp][Ee]|\
[Ee][Xx][Cc][Ee][Pp][Tt]|\
[Ee][Xx][Ee][Cc][Uu][Tt][Ee]|\
[Ee][Xx][Ii][Ss][Tt][Ss]|\
[Ee][Xx][Ii][Tt]|\
[Ee][Xx][Pp]|\
[Ff][Ee][Tt][Cc][Hh]|\
[Ff][Ii][Ll][Ll][Ff][Aa][Cc][Tt][Oo][Rr]|\
[Ff][Ii][Pp][Ss][Ff][Ll][Aa][Gg][Gg][Ee][Rr]|\
[Ff][Ll][Oo][Aa][Tt]|\
[Ff][Ll][Oo][Oo][Rr]|\
[Ff][Ll][Uu][Ss][Hh][Mm][Ee][Ss][Ss][Aa][Gg][Ee]|\
[Ff][Oo][Rr]|\
[Ff][Oo][Rr][Ee][Ii][Gg][Nn]|\
[Ff][Rr][Oo][Mm]|\
[Gg][Ee][Tt][Dd][Aa][Tt][Ee]|\
[Gg][Oo][Tt][Oo]|\
[Gg][Rr][Aa][Nn][Tt]|\
[Gg][Rr][Oo][Uu][Pp]|\
[Hh][Aa][Vv][Ii][Nn][Gg]|\
[Hh][Ee][Xx][Tt][Oo][Ii][Nn][Tt]|\
[Hh][Oo][Ll][Dd][Ll][Oo][Cc][Kk]|\
[Hh][Oo][Ss][Tt]_[Nn][Aa][Mm][Ee]|\
[Ii][Dd][Ee][Nn][Tt][Ii][Tt][Yy]|\
[Ii][Dd][Ee][Nn][Tt][Ii][Tt][Yy]_[Ii][Nn][Ss][Ee][Rr][Tt]|\
[Ii][Ff]|\
[Ii][Gg][Nn][Oo][Rr][Ee]_[Dd][Uu][Pp]_[Kk][Ee][Yy]|\
[Ii][Gg][Nn][Oo][Rr][Ee]_[Dd][Uu][Pp]_[Rr][Oo][Ww]|\
[Ii][Mm][Aa][Gg][Ee]|\
[Ii][Nn]|\
[Ii][Nn][Dd][Ee][Xx]|\
[Ii][Nn][Dd][Ee][Xx]_[Cc][Oo][Ll]|\
[Ii][Nn][Ss][Ee][Rr][Tt]|\
[Ii][Nn][Tt]|\
[Ii][Nn][Tt][Ee][Gg][Ee][Rr]|\
[Ii][Nn][Tt][Ee][Rr][Ss][Ee][Cc][Tt]|\
[Ii][Nn][Tt][Oo]|\
[Ii][Nn][Tt][Tt][Oo][Hh][Ee][Xx]|\
[Ii][Oo]|\
[Ii][Ss]|\
[Ii][Ss][Nn][Uu][Ll][Ll]|\
[Ii][Ss][Oo][Ll][Aa][Tt][Ii][Oo][Nn]|\
[Kk][Ee][Yy]|\
[Kk][Ii][Ll][Ll]|\
[Ll][Aa][Nn][Gg][Uu][Aa][Gg][Ee]|\
[Ll][Cc][Tt]_[Aa][Dd][Mm][Ii][Nn]|\
[Ll][Ee][Vv][Ee][Ll]|\
[Ll][Ii][Kk][Ee]|\
[Ll][Ii][Nn][Ee][Nn][Oo]|\
[Ll][Oo][Aa][Dd]|\
[Ll][Oo][Gg]|\
[Ll][Oo][Gg]10|\
[Ll][Oo][Ww][Ee][Rr]|\
[Ll][Rr][Uu]|\
[Ll][Tt][Rr][Ii][Mm]|\
[Mm][Aa][Xx]|\
[Mm][Ii][Nn]|\
[Mm][Ii][Rr][Rr][Oo][Rr]|\
[Mm][Ii][Rr][Rr][Oo][Rr][Ee][Xx][Ii][Tt]|\
[Mm][Oo][Nn][Ee][Yy]|\
[Mm][Rr][Uu]|\
[Nn][Aa][Tt][Ii][Oo][Nn][Aa][Ll]|\
[Nn][Cc][Hh][Aa][Rr]|\
[Nn][Oo]_[Ee][Rr][Rr][Oo][Rr]|\
[Nn][Oo][Cc][Oo][Uu][Nn][Tt]|\
[Nn][Oo][Ee][Xx][Ee][Cc]|\
[Nn][Oo][Hh][Oo][Ll][Dd][Ll][Oo][Cc][Kk]|\
[Nn][Oo][Nn][Cc][Ll][Uu][Ss][Tt][Ee][Rr][Ee][Dd]|\
[Nn][Oo][Tt]|\
[Nn][Uu][Ll][Ll]|\
[Nn][Uu][Mm][Ee][Rr][Ii][Cc]|\
[Nn][Uu][Mm][Ee][Rr][Ii][Cc]_[Tt][Rr][Uu][Nn][Cc][Aa][Tt][Ii][Oo][Nn]|\
[Nn][Vv][Aa][Rr][Cc][Hh][Aa][Rr]|\
[Oo][Bb][Jj][Ee][Cc][Tt]_[Ii][Dd]|\
[Oo][Bb][Jj][Ee][Cc][Tt]_[Nn][Aa][Mm][Ee]|\
[Oo][Ff]|\
[Oo][Ff][Ff]|\
[Oo][Ff][Ff][Ss][Ee][Tt][Ss]|\
[Oo][Nn]|\
[Oo][Nn][Cc][Ee]|\
[Oo][Nn][Ll][Yy]|\
[Oo][Pp][Ee][Nn]|\
[Oo][Pp][Tt][Ii][Oo][Nn]|\
[Oo][Rr]|\
[Oo][Rr][Dd][Ee][Rr]|\
[Oo][Vv][Ee][Rr]|\
[Pp][Aa][Rr][Aa][Mm]|\
[Pp][Aa][Rr][Ss][Ee][Oo][Nn][Ll][Yy]|\
[Pp][Aa][Tt][Ii][Nn][Dd][Ee][Xx]|\
[Pp][Ee][Rr][Mm][Aa][Nn][Ee][Nn][Tt]|\
[Pp][Ii]|\
[Pp][Ll][Aa][Nn]|\
[Pp][Oo][Ww][Ee][Rr]|\
[Pp][Rr][Ee][Cc][Ii][Ss][Ii][Oo][Nn]|\
[Pp][Rr][Ee][Ff][Ee][Tt][Cc][Hh]|\
[Pp][Rr][Ee][Pp][Aa][Rr][Ee]|\
[Pp][Rr][Ii][Mm][Aa][Rr][Yy]|\
[Pp][Rr][Ii][Nn][Tt]|\
[Pp][Rr][Ii][Vv][Ii][Ll][Ee][Gg][Ee][Ss]|\
[Pp][Rr][Oo][Cc]|\
[Pp][Rr][Oo][Cc][Ii][Dd]|\
[Pp][Rr][Oo][Cc]_[Rr][Oo][Ll][Ee]|\
[Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee]|\
[Pp][Rr][Oo][Cc][Ee][Ss][Ss][Ee][Xx][Ii][Tt]|\
[Pp][Uu][Bb][Ll][Ii][Cc]|\
[Qq][Uu][Oo][Tt][Ee][Dd]_[Ii][Dd][Ee][Nn][Tt][Ii][Ff][Ii][Ee][Rr]|\
[Rr][Aa][Dd][Ii][Aa][Nn][Ss]|\
[Rr][Aa][Ii][Ss][Ee][Rr][Rr][Oo][Rr]|\
[Rr][Aa][Nn][Dd]|\
[Rr][Ee][Aa][Dd]|\
[Rr][Ee][Aa][Dd][Tt][Ee][Xx][Tt]|\
[Rr][Ee][Aa][Ll]|\
[Rr][Ee][Cc][Oo][Nn][Ff][Ii][Gg][Uu][Rr][Ee]|\
[Rr][Ee][Ff][Ee][Rr][Ee][Nn][Cc][Ee][Ss]|\
[Rr][Ee][Pp][Ll][Aa][Cc][Ee]|\
[Rr][Ee][Pp][Ll][Ii][Cc][Aa][Tt][Ee]|\
[Rr][Ee][Ss][Ee][Rr][Vv][Ee][Dd]_[Pp][Gg][Ss]|\
[Rr][Ee][Ss][Tt][Rr][Ee][Ee]|\
[Rr][Ee][Tt][Uu][Rr][Nn]|\
[Rr][Ee][Vv][Ee][Rr][Ss][Ee]|\
[Rr][Ee][Vv][Oo][Kk][Ee]|\
[Rr][Ii][Gg][Hh][Tt]|\
[Rr][Oo][Ll][Ee]|\
[Rr][Oo][Ll][Ll][Bb][Aa][Cc][Kk]|\
[Rr][Oo][Uu][Nn][Dd]|\
[Rr][Oo][Ww][Cc][Nn][Tt]|\
[Rr][Oo][Ww][Cc][Oo][Uu][Nn][Tt]|\
[Rr][Oo][Ww][Ss]|\
[Rr][Tt][Rr][Ii][Mm]|\
[Rr][Uu][Ll][Ee]|\
[Ss][Aa][Vv][Ee]|\
[Ss][Cc][Hh][Ee][Mm][Aa]|\
[Ss][Ee][Ll][Ee][Cc][Tt]|\
[Ss][Ee][Ll][Ff]_[Rr][Ee][Cc][Uu][Rr][Ss][Ii][Oo][Nn]|\
[Ss][Ee][Tt]|\
[Ss][Ee][Tt][Uu][Ss][Ee][Rr]|\
[Ss][Hh][Aa][Rr][Ee][Dd]|\
[Ss][Hh][Oo][Ww]_[Rr][Oo][Ll][Ee]|\
[Ss][Hh][Oo][Ww][Pp][Ll][Aa][Nn]|\
[Ss][Hh][Uu][Tt][Dd][Oo][Ww][Nn]|\
[Ss][Ii][Gg][Nn]|\
[Ss][Ii][Nn]|\
[Ss][Mm][Aa][Ll][Ll][Dd][Aa][Tt][Ee][Tt][Ii][Mm][Ee]|\
[Ss][Mm][Aa][Ll][Ll][Ii][Nn][Tt]|\
[Ss][Mm][Aa][Ll][Ll][Mm][Oo][Nn][Ee][Yy]|\
[Ss][Oo][Uu][Nn][Dd][Ee][Xx]|\
[Ss][Pp][Aa][Cc][Ee]|\
[Ss][Qq][Rr][Tt]|\
[Ss][Tt][Aa][Tt][Ee][Mm][Ee][Nn][Tt]|\
[Ss][Tt][Aa][Tt][Ii][Ss][Tt][Ii][Cc][Ss]|\
[Ss][Tt][Rr]|\
[Ss][Tt][Rr][Ii][Nn][Gg]_[Rr][Tt][Rr][Uu][Nn][Cc][Aa][Tt][Ii][Oo][Nn]|\
[Ss][Tt][Rr][Ii][Pp][Ee]|\
[Ss][Tt][Uu][Ff][Ff]|\
[Ss][Uu][Bb][Qq][Uu][Ee][Rr][Yy][Cc][Aa][Cc][Hh][Ee]|\
[Ss][Uu][Bb][Ss][Tt][Rr][Ii][Nn][Gg]|\
[Ss][Uu][Mm]|\
[Ss][Uu][Ss][Ee][Rr]_[Ii][Dd]|\
[Ss][Uu][Ss][Ee][Rr]_[Nn][Aa][Mm][Ee]|\
[Ss][Yy][Bb]_[Ii][Dd][Ee][Nn][Tt][Ii][Tt][Yy]|\
[Tt][Aa][Bb][Ll][Ee]|\
[Tt][Aa][Nn]|\
[Tt][Ee][Mm][Pp][Oo][Rr][Aa][Rr][Yy]|\
[Tt][Ee][Rr][Mm][Ii][Nn][Aa][Tt][Ee]|\
[Tt][Ee][Xx][Tt]|\
[Tt][Ee][Xx][Tt][Ss][Ii][Zz][Ee]|\
[Tt][Ii][Mm][Ee]|\
[Tt][Ii][Nn][Yy][Ii][Nn][Tt]|\
[Tt][Oo]|\
[Tt][Rr][Aa][Nn][Ss][Aa][Cc][Tt][Ii][Oo][Nn]|\
[Tt][Rr][Ii][Gg][Gg][Ee][Rr]|\
[Tt][Rr][Uu][Nn][Cc][Aa][Tt][Ee]|\
[Tt][Ss][Ee][Qq][Uu][Aa][Ll]|\
[Uu][Nn][Ii][Oo][Nn]|\
[Uu][Nn][Ii][Qq][Uu][Ee]|\
[Uu][Pp][Dd][Aa][Tt][Ee]|\
[Uu][Pp][Pp][Ee][Rr]|\
[Uu][Ss][Ee]|\
[Uu][Ss][Ee][Dd]_[Pp][Gg][Ss]|\
[Uu][Ss][Ee][Rr]|\
[Uu][Ss][Ee][Rr]_[Ii][Dd]|\
[Uu][Ss][Ee][Rr]_[Nn][Aa][Mm][Ee]|\
[Uu][Ss][Ee][Rr]_[Oo][Pp][Tt][Ii][Oo][Nn]|\
[Uu][Ss][Ii][Nn][Gg]|\
[Vv][Aa][Ll][Ii][Dd]_[Nn][Aa][Mm][Ee]|\
[Vv][Aa][Ll][Ii][Dd]_[Uu][Ss][Ee][Rr]|\
[Vv][Aa][Ll][Uu][Ee][Ss]|\
[Vv][Aa][Rr][Bb][Ii][Nn][Aa][Rr][Yy]|\
[Vv][Aa][Rr][Cc][Hh][Aa][Rr]|\
[Vv][Aa][Rr][Yy][Ii][Nn][Gg]|\
[Vv][Ii][Ee][Ww]|\
[Ww][Aa][Ii][Tt][Ff][Oo][Rr]|\
[Ww][Hh][Ee][Rr][Ee]|\
[Ww][Hh][Ii][Ll][Ee]|\
[Ww][Ii][Tt][Hh]|\
[Ww][Oo][Rr][Kk]|\
[Ww][Rr][Ii][Tt][Ee][Tt][Ee][Xx][Tt]\
)\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}



/**
 * Name: states
 * Description: States program's definition files.
 * Author: Markku Rossi <mtr@iki.fi>
 */

state states_regexp
{
  /\\\\./ {
    language_print ($0);
  }
  /\// {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state states
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Regular expressions. */
  /\\\// {
    string_face (true);
    language_print ($0);
    call (states_regexp);
    string_face (false);
  }

  /* Subroutine definitions. */
  /\b(sub)([ \t]+)([$a-zA-Z_][$a-zA-Z_0-9]*)([ \t]*\()/ {
    keyword_face (true);
    language_print ($1);
    keyword_face (false);

    language_print ($2);

    function_name_face (true);
    language_print ($3);
    function_name_face (false);

    language_print ($4);
  }

  /* Keywords.
     (build-re '(BEGIN END div else for if local namerules return start
     startrules state sub while))
   */
  /\b(BEGIN|END|div|else|for|if|local|namerules|return\
|s(ta(rt(|rules)|te)|ub)|while)\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  /* Build-ins:
     (build-re '(call check_namerules check_startrules concat getenv int
     length list panic prereq print regmatch regsub regsuball sprintf
     strcmp string strncmp substring))
   */
  /\b(c(all|heck_(namerules|startrules)|oncat)|getenv|int|l(ength|ist)\
|p(anic|r(ereq|int))|reg(match|sub(|all))\
|s(printf|tr(cmp|ing|ncmp)|ubstring))([ \t]*\()/ {
    builtin_face (true);
    language_print ($1);
    builtin_face (false);
    language_print (substring ($0, length ($1), length ($0)));
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: synopsys
 * Description: Synopsys dc shell scripting language
 *
 * Author: Brian Silveira  (brian@nortel.ca)
 *	   Hartley Horwitz (hars@nortel.ca)
 */
state synopsys
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /*
   * Synopsys allows globing...so pick out constructs like
   * /foo/bar/* and just print them out.  i.e. don't treat the
   * ending like a comment!
   */
  /[A-z0-9_-]\/\*/{
    language_print($0);
  }


  /* Comments.
   * Synopsys DC-shell uses C-style comments
   */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* I use make-regexp in emacs which uses a list of strings to
     generate a	 regular expression.
     (setq synopsys-keywords-enscript
      '("alias" "all_connected" "analyze" "balance_buffer"
	"balance_registers" "break" "cd" "change_link" "change_names"
	"characterize" "check_design" "check_test" "check_timing"
	"continue" "compile" "copy_design" "create_clock" "drive_of"
	"echo" "elaborate" "else" "exit" "get_attribute" "get_license"
	"get_unix_variable" "group" "group_path" "include"
	"insert_scan" "insert_test" "link" "list_designs"
	"list_instances" "list_libs" "load_of" "quit" "read"
	"read_lib" "read_timing" "remove_attribute"
	"remove_constraint" "remove_design" "remove_input_delay"
	"remove_lib" "remove_clock" "remove_cell" "remove_license"
	"remove_output_delay" "remove_unconnected_ports"
	"rename_design" "reoptimize_design" "report_area"
	"report_attribute" "report_cell" "report_constraint"
	"report_design" "report_design_lib" "report_hierarchy"
	"report_internal_loads" "report_lib" "report_multicycles"
	"report_net" "report_port" "report_power" "report_reference"
	"report_resources" "report_test" "report_timing"
	"reset_design" "set_attribute" "set_boundary_optimization"
	"set_clock_skew" "set_dont_touch" "set_dont_touch_network"
	"set_dont_use" "set_drive" "set_driving_cell" "set_equal"
	"set_disable_timing" "set_false_path" "set_flatten"
	"set_implementation" "set_fix_hold" "set_input_delay"
	"set_load" "set_logic_one" "set_logic_zero" "set_max_area"
	"set_max_capacitance" "set_max_fanout" "set_max_transition"
	"set_multicycle_path" "set_operating_conditions"
	"set_output_delay" "set_scan_style" "set_signal_type"
	"set_structure" "set_test_methodology" "set_unconnected"
	"set_wire_load" "unalias" "sh" "ungroup" "uniquify"
	"update_lib" "which" "write" "write_constraints"
	"write_script" "write_timing" "if" "foreach" "find" "while"
	"-all" "-all_violators" "-allowed" "-attributes" "-base_name"
	"-boundary_optimization" "-cell" "-cell_name" "-clock"
	"-context" "-connections" "-constraints" "-delay" "-design"
	"-design_name" "-depth" "-drive" "-except" "-f" "-fall_delay"
	"-flat" "-format" "-from" "-hierarchy" "-hier" "-hold"
	"-incremental_mapping" "-ideal" "-ignored" "-in_place"
	"-logic" "-library" "-map_effort" "-mode" "-max_paths"
	"-max_scan_chain_length" "-no_disable" "-methodology" "-name"
	"-net" "-new_name" "-none" "-nosplit" "-nworst" "-output"
	"-path" "-parameters" "-period" "-pin_load" "-propagated"
	"-reference" "-rise_delay" "-rules" "-skew" "-setup"
	"-through" "-to" "-type" "-uncertainty" "-plus_uncertainty"
	"-minus_uncertainty" "-update" "-verify" "-verbose"
	"-waveform" "-wire_load" "-work" "-weight" "-worst"
	"actel_qbar_opto" "actel_seq_opto" "auto_link_disable"
	"auto_link_options" "auto_wire_load_selection"
	"bc_enable_chaining" "bc_enable_multi_cycle"
	"bc_enable_speculative_execution" "bc_fsm_coding_style"
	"bc_time_all_sequential_op_bindings" "bus_extraction_style"
	"bus_inference_style" "bus_naming_style"
	"change_names_dont_change_bus_members"
	"change_names_update_inst_tree" "command_log_file" "company"
	"compatibility_version"
	"compile_assume_fully_decoded_three_state_busses"
	"compile_create_mux_op_hierarchy"
	"compile_default_critical_range"
	"compile_disable_area_opt_during_inplace_opt"
	"compile_disable_hierarchical_inverter_opt"
	"compile_dont_touch_annotated_cell_during_inplace_opt"
	"compile_fix_multiple_port_nets"
	"compile_ignore_area_during_inplace_opt"
	"compile_ignore_footprint_during_inplace_opt"
	"compile_implementation_selection"
	"compile_inplace_changed_list_file_name"
	"compile_instance_name_prefix" "compile_instance_name_suffix"
	"compile_mux_no_boundary_optimization"
	"compile_negative_logic_methodology"
	"compile_no_new_cells_at_top_level"
	"compile_ok_to_buffer_during_inplace_opt"
	"compile_preserve_subdesign_interfaces"
	"compile_preserve_sync_resets"
	"compile_update_annotated_delays_during_inplace_opt"
	"compile_use_fast_delay_mode" "compile_use_low_timing_effort"
	"context_check_status" "current_design" "current_instance"
	"dc_shell_status" "default_name_rules" "design_library_file"
	"designer" "duplicate_ports" "echo_include_commands"
	"enable_page_mode" "exit_delete_filename_log_file"
	"filename_log_file" "find_converts_name_lists"
	"find_ignore_case" "hdl_keep_licenses" "hdl_naming_threshold"
	"hdl_preferred_license" "hdl_variables"
	"hdlin_advisor_directory" "hdlin_auto_save_templates"
	"hdlin_check_no_latch"
	"hdlin_dont_infer_mux_for_resource_sharing"
	"hdlin_enable_advisor" "hdlin_ff_always_async_set_reset"
	"hdlin_ff_always_sync_set_reset" "hdlin_files"
	"hdlin_hide_resource_line_numbers" "hdlin_infer_mux"
	"hdlin_keep_feedback" "hdlin_keep_inv_feedback"
	"hdlin_mux_size_limit" "hdlin_reg_report_length"
	"hdlin_replace_synthetic" "hdlin_report_inferred_modules"
	"hdlin_resource_allocation" "hdlin_resource_implementation"
	"hdlin_source_to_gates_mode" "hdlin_sync_set_reset"
	"hdlin_synch_set_reset" "hdlin_translate_off_skip_text"
	"link_force_case" "link_library"
	"port_complement_naming_style"
	"reoptimize_design_changed_list_file_name"
	"sdfin_fall_cell_delay_type" "sdfin_fall_net_delay_type"
	"sdfin_min_fall_cell_delay" "sdfin_min_fall_net_delay"
	"sdfin_min_rise_cell_delay" "sdfin_min_rise_net_delay"
	"sdfin_rise_cell_delay_type" "sdfin_rise_net_delay_type"
	"sdfin_top_instance_name"
	"sdfout_allow_non_positive_constraints"
	"sdfout_min_fall_cell_delay" "sdfout_min_fall_net_delay"
	"sdfout_min_rise_cell_delay" "sdfout_min_rise_net_delay"
	"sdfout_time_scale" "sdfout_top_instance_name"
	"sdfout_write_to_output" "search_path" "shell_prompt"
	"suppress_errors" "synlib_dont_get_license"
	"syntax_check_status" "synthetic_library" "target_library"
	"uniquify_naming_style" "verbose_messages"))
	*/

  /\ba(l(ias|l_connected)|nalyze|uto_(link_(disable|options)\
|wire_load_selection))|b(alance_(buffer|registers)\
|c_(enable_(chaining|multi_cycle|speculative_execution)\
|fsm_coding_style|time_all_sequential_op_bindings)|reak\
|us_(extraction_style|inference_style|naming_style))\
|c(d|h(a(nge_(link|names(|_(dont_change_bus_members|update_inst_tree)))\
|racterize)|eck_(design|t(est|iming)))|o(m(mand_log_file|p(a(ny\
|tibility_version)|ile(|_(assume_fully_decoded_three_state_busses\
|create_mux_op_hierarchy|d(efault_critical_range\
|isable_(area_opt_during_inplace_opt|hierarchical_inverter_opt)\
|ont_touch_annotated_cell_during_inplace_opt)|fix_multiple_port_nets\
|i(gnore_(area_during_inplace_opt|footprint_during_inplace_opt)\
|mplementation_selection|n(place_changed_list_file_name\
|stance_name_(prefix|suffix)))|mux_no_boundary_optimization\
|n(egative_logic_methodology|o_new_cells_at_top_level)\
|ok_to_buffer_during_inplace_opt|preserve_s(ubdesign_interfaces\
|ync_resets)|u(pdate_annotated_delays_during_inplace_opt\
|se_(fast_delay_mode|low_timing_effort))))))|nt(ext_check_status|inue)\
|py_design)|reate_clock|urrent_(design|instance))|d(c_shell_status\
|e(fault_name_rules|sign(_library_file|er))|rive_of|uplicate_ports)|e(cho(\
|_include_commands)|l(aborate|se)|nable_page_mode|xit(\
|_delete_filename_log_file))|f(i(lename_log_file|nd(|_(converts_name_lists\
|ignore_case)))|oreach)|g(et_(attribute|license|unix_variable)|roup(\
|_path))|hdl(_(keep_licenses|naming_threshold|preferred_license|variables)\
|in_(a(dvisor_directory|uto_save_templates)|check_no_latch\
|dont_infer_mux_for_resource_sharing|enable_advisor\
|f(f_always_(async_set_reset|sync_set_reset)|iles)\
|hide_resource_line_numbers|infer_mux|keep_(feedback|inv_feedback)\
|mux_size_limit|re(g_report_length|p(lace_synthetic|ort_inferred_modules)\
|source_(allocation|implementation))|s(ource_to_gates_mode|ync(_set_reset\
|h_set_reset))|translate_off_skip_text))|i(f|n(clude|sert_(scan|test)))\
|l(i(nk(|_(force_case|library))|st_(designs|instances|libs))|oad_of)\
|port_complement_naming_style|quit|re(ad(|_(lib|timing))|move_(attribute\
|c(ell|lock|onstraint)|design|input_delay|li(b|cense)|output_delay\
|unconnected_ports)|name_design|optimize_design(|_changed_list_file_name)\
|port_(a(rea|ttribute)|c(ell|onstraint)|design(|_lib)|hierarchy\
|internal_loads|lib|multicycles|net|po(rt|wer)|re(ference|sources)|t(est\
|iming))|set_design)|s(df(in_(fall_(cell_delay_type|net_delay_type)\
|min_(fall_(cell_delay|net_delay)|rise_(cell_delay|net_delay))\
|rise_(cell_delay_type|net_delay_type)|top_instance_name)\
|out_(allow_non_positive_constraints|min_(fall_(cell_delay|net_delay)\
|rise_(cell_delay|net_delay))|t(ime_scale|op_instance_name)\
|write_to_output))|e(arch_path|t_(attribute|boundary_optimization\
|clock_skew|d(isable_timing|ont_(touch(|_network)|use)|riv(e|ing_cell))\
|equal|f(alse_path|ix_hold|latten)|i(mplementation|nput_delay)|lo(ad\
|gic_(one|zero))|m(ax_(area|capacitance|fanout|transition)|ulticycle_path)\
|o(perating_conditions|utput_delay)|s(can_style|ignal_type|tructure)\
|test_methodology|unconnected|wire_load))|h(|ell_prompt)|uppress_errors\
|yn(lib_dont_get_license|t(ax_check_status|hetic_library)))|target_library\
|u(n(alias|group|iquify(|_naming_style))|pdate_lib)|verbose_messages\
|w(hi(ch|le)|rite(|_(constraints|script|timing)))\b/{
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }

}


/**
 * Name: tcl
 * Description: Tcl programming language.
 * Author: Markku Rossi <mtr@iki.fi>
 */

state tcl_comment
{
  /[^\\\\]\n/ {
    language_print ($0);
    return;
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}

state tcl_proc_arglist
{
  /* List of arguments. */
  /{/ {
    language_print ($0);
    variable_name_face (true);
    str = match_balanced_block (/{/, /}/);
    variable_name_face (false);
    language_print (str);
    return;
  }
  /* Only one argument. */
  /[A-Za-z0-9]+/ {
    variable_name_face (true);
    language_print ($0);
    variable_name_face (false);
    return;
  }
  /* No idea what this is??? */
  /[.\n]/ {
    language_print ($0);
    return;
  }
}

state tcl
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /#/ {
    comment_face (true);
    language_print ($0);
    call (tcl_comment);
    comment_face (false);
  }
  /#\n/ {
    comment_face (true);
    language_print ($0);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Procedure definitions. */
  /\b(proc)([ \t]+)([A-Za-z_0-9]+)([ \t]+)/ {
    /* Keyword `proc'. */
    keyword_face (true);
    language_print ($1);
    keyword_face (false);

    /* Middle garbage. */
    language_print ($2);

    /* Function name. */
    function_name_face (true);
    language_print ($3);
    function_name_face (false);

    /* Second middle garbage. */
    language_print ($4);

    /* Function argument list. */
    call (tcl_proc_arglist);
  }

  /* Simple variable reference. */
  /(\$)([A-Za-z_0-9]+)/ {
    language_print ($1);
    variable_name_face (true);
    language_print ($2);
    variable_name_face (false);
  }

  /* {}-enclosed variable reference. */
  /\${/ {
    language_print ($0);
    variable_name_face (true);
    str = match_balanced_block (/{/, /}/);
    variable_name_face (false);
    language_print (str);
  }

  /* Keywords.
     (build-re '(
     ;; Tcl:
     Http Tcl after append array bgerror break case catch cd clock
     concat continue eof error eval exec exit expr fblocked fconfigure file
     fileevent filename flush for foreach format gets glob global history
     if incr info interp join lappend library lindex linsert list llength
     load lose lrange lreplace lsearch lsort open package pid pkg_mkIndex
     proc puts pwd read regexp regsub rename return scan seek set socket
     source split string subst switch tclvars tell time trace unknown unset
     update uplevel upvar vwait while

     ;; Tk:
     bell bind bindtags bitmap button canvas checkbutton clipboard destroy
     entry event focus font frame grab grid image label listbox lower menu
     menubutton message option options pack photo place radiobutton raise
     scale scrollbar selection send text tk tk_bindForTraversal tk_bisque
     tk_chooseColor tk_dialog tk_focusFollowsMouse tk_focusNext
     tk_focusPrev tk_getOpenFile tk_getSaveFile tk_menuBar tk_messageBox
     tk_optionMenu tk_popup tk_setPalette tkerror tkvars tkwait toplevel
     winfo wm
     ))
   */
  /\b(Http|Tcl|a(fter|ppend|rray)\
|b(ell|gerror|i(nd(|tags)|tmap)|reak|utton)\
|c(a(nvas|se|tch)|d|heckbutton|l(ipboard|ock)|on(cat|tinue))|destroy\
|e(ntry|of|rror|v(al|ent)|x(ec|it|pr))\
|f(blocked|configure|ile(|event|name)|lush|o(cus|nt|r(|each|mat))|rame)\
|g(ets|lob(|al)|r(ab|id))|history|i(f|mage|n(cr|fo|terp))|join\
|l(a(bel|ppend)|i(brary|n(dex|sert)|st(|box))|length|o(ad|se|wer)\
|r(ange|eplace)|s(earch|ort))\
|me(nu(|button)|ssage)|op(en|tion(|s))\
|p(ack(|age)|hoto|id|kg_mkIndex|lace|roc|uts|wd)\
|r(a(diobutton|ise)|e(ad|g(exp|sub)|name|turn))\
|s(c(a(le|n)|rollbar)|e(ek|lection|nd|t)|o(cket|urce)|plit|tring|ubst\
|witch)\
|t(clvars|e(ll|xt)|ime\
|k(\
|_(bi(ndForTraversal|sque)|chooseColor|dialog\
|focus(FollowsMouse|Next|Prev)|get(OpenFile|SaveFile)\
|me(nuBar|ssageBox)|optionMenu|popup|setPalette)\
|error|vars|wait)\
|oplevel|race)\
|u(n(known|set)|p(date|level|var))|vwait|w(hile|info|m))\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }
  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: verilog
 * Description: Verilog hardware description language
 * Author: Edward Arthur <eda@ultranet.com>
 */
state verilog
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Verilog takes C++ style comments */

  /* Comments. */
  /\/\*/ {
    comment_face (true);
    language_print ($0);
    call (c_comment);
    comment_face (false);
  }
  /\/\// {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Macro expansions start with '`' and continue one word. */
  /`([a-zA-Z_0-9]+)/ {
    reference_face (true);
    language_print ($0);
    reference_face (false);
  }

  /* Keywords.
     (build-re '(always and assign begin buf bufif0 bufif1 case casex
     casez cmos deassign default defparam disable edge else end endcase
     endmodule endfunction endprimitive endspecify endtable endtask event
     for force forever fork function highz0 highz1 if initial inout input
     integer join large macromodule medium module nand negedge nmos nor
     not notif0 notif1 or output parameter pmos posedge primitive pull0
     pull1 pullup pulldown rcmos reg release repeat rnmos rpmos rtran
     rtranif0 rtranif1 scalared small specify specparam strength strong0
     strong1 supply0 supply1 table task time tran tranif0 tranif1 tri tri0
     tri1 triand trior trireg vectored wait wand weak0 weak1 while wire wor
     xnor xor
     $bitstoreal $countdrivers $display $fclose $fdisplay $fmonitor
     $fopen $fstrobe $fwrite $finish $getpattern $history $incsave $input
     $itor $key $list $log $monitor $monitoroff $monitoron $nokey $nolog
     $printtimescale $readmemb $readmemh $realtime $realtobits $reset
     $reset_count $reset_value $restart $rtoi $save $scale $scope
     $showscopes $showvariables $showvars $sreadmemb $sreadmemh $stime
     $stop $strobe $time $timeformat $write $vcdpluson $vcdplusoff
     $vcdplustraceon $vcdplustraceoff $dumpvars
     ;; prefix G stands for grave `
     Gaccelerate Gautoexpand_vectornets Gcelldefine Gdefault_nettype Gdefine
     Gelse Gendcelldefine Gendif Gendprotect Gendprotected
     Gexpand_vectornets Gifdef Ginclude Gnoaccelerate
     Gnoexpand_vectornets Gnoremove_gatenames Gnoremove_netnames
     Gnounconnected_drive Gprotect Gprotected Gremove_gatenames
     Gremove_netnames Gresetall Gtimescale Gunconnected_drive
     Guselib
     ))
   */
  /\$(bitstoreal|countdrivers|d(isplay|umpvars)\
|f(close|display|inish|monitor|open|strobe|write)|getpattern|history\
|i(n(csave|put)|tor)|key|l(ist|og)|monitor(|o(ff|n))|no(key|log)\
|printtimescale\
|r(e(a(dmem(b|h)|lt(ime|obits))|s(et(|_(count|value))|tart))|toi)\
|s(ave|c(ale|ope)|how(scopes|var(iables|s))|readmem(b|h)|t(ime|op|robe))\
|time(|format)|vcdplus(o(ff|n)|traceo(ff|n))|write)\b\
|`(a(ccelerate|utoexpand_vectornets)|celldefine|def(ault_nettype|ine)\
|e(lse|nd(celldefine|if|protect(|ed))|xpand_vectornets)|i(fdef|nclude)\
|no(accelerate|expand_vectornets|remove_(gatenames|netnames)\
|unconnected_drive)\
|protect(|ed)|re(move_(gatenames|netnames)|setall)|timescale\
|u(nconnected_drive|selib))\b\
|\b(a(lways|nd|ssign)|b(egin|uf(|if(0|1)))|c(ase(|x|z)|mos)\
|d(e(assign|f(ault|param))|isable)\
|e(dge|lse|nd(|case|function|module|primitive|specify|ta(ble|sk))|vent)\
|f(or(|ce|ever|k)|unction)|highz(0|1)|i(f|n(itial|out|put|teger))|join\
|large|m(acromodule|edium|odule)|n(and|egedge|mos|o(r|t(|if(0|1))))\
|o(r|utput)|p(arameter|mos|osedge|rimitive|ull(0|1|down|up))\
|r(cmos|e(g|lease|peat)|nmos|pmos|tran(|if(0|1)))\
|s(calared|mall|pec(ify|param)|tr(ength|ong(0|1))|upply(0|1))\
|t(a(ble|sk)|ime|r(an(|if(0|1))|i(|0|1|and|or|reg)))|vectored\
|w(a(it|nd)|eak(0|1)|hile|ire|or)|x(nor|or))\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/**
 * Name: vhdl
 * Description: VHSIC Hardware Description Language (VHDL)
 *		Highlights keywords, comments and special vhdl
 *		constructs.  Please send comments or suggestions.
 *
 * Author: Brian Silveira (brian@nortel.ca)
 *
 */
state vhdl
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /--/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\"/ {
    string_face (true);
    language_print ($0);
    call (c_string);
    string_face (false);
  }

  /* Keywords.
     (build-re '(abs access after alias all and architecture array
     assert attribute begin begin block body body buffer bus case
     component configuration configuration constant disconnect downto
     else elsif end entity exit file for function function generate
     generic guarded if in inout is label library linkage loop map
     mod nand new next nor not null of on open or others out package
     port procedure process range record register rem report return
     reverse select severity signal subtype then to transport type
     units until use variable wait when while with with xor)
     t)
   */
  /\b([aA]([bB][sS]|[cC][cC][eE][sS][sS]|[fF][tT][eE][rR]\
|[lL]([iI][aA][sS]|[lL])|[nN][dD]\
|[rR]([cC][hH][iI][tT][eE][cC][tT][uU][rR][eE]|[rR][aA][yY])\
|[sS][sS][eE][rR][tT]|[tT][tT][rR][iI][bB][uU][tT][eE])\
|[bB]([eE][gG][iI][nN]()|[lL][oO][cC][kK]|[oO][dD][yY]()\
|[uU]([fF][fF][eE][rR]|[sS]))\
|[cC]([aA][sS][eE]\
|[oO]([mM][pP][oO][nN][eE][nN][tT]\
|[nN]([fF][iI][gG][uU][rR][aA][tT][iI][oO][nN]()|[sS][tT][aA][nN][tT])))\
|[dD]([iI][sS][cC][oO][nN][nN][eE][cC][tT]|[oO][wW][nN][tT][oO])\
|[eE]([lL][sS]([eE]|[iI][fF])|[nN]([dD]|[tT][iI][tT][yY])|[xX][iI][tT])\
|[fF]([iI][lL][eE]|[oO][rR]|[uU][nN][cC][tT][iI][oO][nN]())\
|[gG]([eE][nN][eE][rR]([aA][tT][eE]|[iI][cC])|[uU][aA][rR][dD][eE][dD])\
|[iI]([fF]|[nN](|[oO][uU][tT])|[sS])\
|[lL]([aA][bB][eE][lL]|[iI]([bB][rR][aA][rR][yY]|[nN][kK][aA][gG][eE])\
|[oO][oO][pP])\
|[mM]([aA][pP]|[oO][dD])\
|[nN]([aA][nN][dD]|[eE]([wW]|[xX][tT])|[oO]([rR]|[tT])|[uU][lL][lL])\
|[oO]([fF]|[nN]|[pP][eE][nN]|[rR]|[tT][hH][eE][rR][sS]|[uU][tT])\
|[pP]([aA][cC][kK][aA][gG][eE]|[oO][rR][tT]\
|[rR][oO][cC][eE]([dD][uU][rR][eE]|[sS][sS]))\
|[rR]([aA][nN][gG][eE]\
|[eE]([cC][oO][rR][dD]|[gG][iI][sS][tT][eE][rR]|[mM]|[pP][oO][rR][tT]\
|[tT][uU][rR][nN]|[vV][eE][rR][sS][eE]))\
|[sS]([eE]([lL][eE][cC][tT]|[vV][eE][rR][iI][tT][yY])|[iI][gG][nN][aA][lL]\
|[uU][bB][tT][yY][pP][eE])\
|[tT]([hH][eE][nN]|[oO]|[rR][aA][nN][sS][pP][oO][rR][tT]|[yY][pP][eE])\
|[uU]([nN]([iI][tT][sS]|[tT][iI][lL])|[sS][eE])\
|[vV][aA][rR][iI][aA][bB][lL][eE]\
|[wW]([aA][iI][tT]|[hH]([eE][nN]|[iI][lL][eE])|[iI][tT][hH]())\
|[xX][oO][rR])\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }


  /<=|=>/
	{
	  reference_face (true);
	  language_print ($0);
	  reference_face(false);
	}
}


/**
 * Name: vba
 * Description: Visual Basic (for Applications)
 * Author: Kevin Grover <grover@wizard.com>
 */

/* To Do
 * - ?Get parser to work for X.X.X.X and not hilight separate Xs
 * - ?recognize type declaration characters ($,%,@, etc.. on variables)
 * - ?Look for line numbers/labels (for Goto's)  /^\s*[0-9A-Za-z]+:/
 */

state vba
{
  BEGIN {
    header ();
  }
  END {
    trailer ();
  }

  /* Comments. */
  /[\']|^\s*Rem/ {
    comment_face (true);
    language_print ($0);
    call (eat_one_line);
    comment_face (false);
  }

  /* String constants. */
  /\".*\"/ {
    string_face (true);
    language_print ($0);
    string_face (false);
  }

  /* Keywords. From:
	       Excel for Windows 95 Power Programming with VGA
	       2nd Ed, John Walkenbach, pg 160

     (build-re '(
     Abs And Any As Boolean ByRef ByVal Call Case CBool CCur CDate
     CDbl CDecl CInt Circle CLng Close Const CSng CStr CurDirrase
     Currency CVar CVDate CVErr Date Debug Declare

     DefBool DefCur DefDate DefDbl DefInt DefLng DefObj DefSng DefStr
     DefVar Dim Dir Do Double Each Else ElsIf Empty End EndIf Eqv Erase
     Error Exit False Fix For Format FreeFile

     Function Get Global GoSub GoTo If Imp In Input InputB Instr InstrB Int
     Integer Is LBound Len LenB Let Like Line Load Local Lock Long Loop
     LSet Me Mid

     MidB Mod Name New Next Not Nothing Null Object On Open Option Optional
     Or Point Preserve Print Private Property PSet Public Put ReDim Rem
     Resume Return RSet Scale Seek

     Select Set Sgn Shared Single Spc Static Stop StrComp String Sub Tab
     Then TO True Type TypeOf UBound Unload Unlock Until Variant Wend While
     Width With Write Xor))
  */
  /\b(A(bs|n(d|y)|s)|B(oolean|y(Ref|Val))\
|C(Bool|Cur|D(ate|bl|ecl)|Int|Lng|S(ng|tr)|V(Date|Err|ar)|a(ll|se)|ircle\
|lose|onst|ur(Dirrase|rency))\
|D(ate|e(bug|clare|f(Bool|Cur|D(ate|bl)|Int|Lng|Obj|S(ng|tr)|Var))\
|i(m|r)|o(|uble))\
|E(ach|ls(If|e)|mpty|nd(|If)|qv|r(ase|ror)|xit)\
|F(alse|ix|or(|mat)|reeFile|unction)|G(et|lobal|o(Sub|To))\
|I(f|mp|n(|put(|B)|str(|B)|t(|eger))|s)\
|L(Bound|Set|e(n(|B)|t)|i(ke|ne)|o(ad|c(al|k)|ng|op))|M(e|id(|B)|od)\
|N(ame|e(w|xt)|ot(|hing)|ull)|O(bject|n|p(en|tion(|al))|r)\
|P(Set|oint|r(eserve|i(nt|vate)|operty)|u(blic|t))\
|R(Set|e(Dim|m|sume|turn))\
|S(cale|e(ek|lect|t)|gn|hared|ingle|pc|t(atic|op|r(Comp|ing))|ub)\
|T(O|ab|hen|rue|ype(|Of))|U(Bound|n(lo(ad|ck)|til))|Variant\
|W(end|hile|i(dth|th)|rite)|Xor)\b/ {
    keyword_face (true);
    language_print ($0);
    keyword_face (false);
  }

  LANGUAGE_SPECIALS {
    language_print ($0);
  }
}


/*
Local variables:
mode: c
End:
*/
