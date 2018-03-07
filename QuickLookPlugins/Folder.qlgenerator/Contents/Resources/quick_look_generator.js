	document.getElementsByClassName = function(cl) {
		var retnode = [];
		var myclass = new RegExp('\\b'+cl+'\\b');
		var elem = this.getElementsByTagName('*');
		for (var i = 0; i < elem.length; i++) {
		var classes = elem[i].className;
		if (myclass.test(classes)) retnode.push(elem[i]);
	}
		return retnode;
	};

	var css_list = document.styleSheets;
	function style_change(style_Discription,style_Context){
		if (css_list) for (var i = 0; i < css_list.length; i++) {
		
			var rule_list = (css_list[i].cssRules) ? css_list[i].cssRules : css_list[i].rules;
		
			for (var ii = 0; ii < rule_list.length; ii++)
			 if (rule_list[ii].selectorText.toLowerCase() == style_Discription)
			 with (rule_list[ii].style) {
			 	eval(style_Context);
			}
		
		}
	}
	

	folderView = document.getElementById("folderView");

	function initialize(){
		if (document.cookie == 'hide_folderviewer=true'){
		//	document.cookie = 'hide_folderviewer=false';
			window.close();
		}
		is_archive();
		document.getElementById('header').focus();
	}

	function hide_folderviewer(){
		document.cookie = 'hide_folderviewer=true';
		location.reload();
	}

	function write_row(NAME){
		if(NAME.match(/^\./)){
			class_str = 'hidden_file';
		} else {
			class_str = 'shown_file';
		}
		row_source = '<tr id="' + NAME + '" class="' + class_str+ '">\n';
		document.write(row_source);
	}
	
	function write_name(NAME){
		orj_str = NAME;
		obj_str = NAME.replace(/\//g,'&zwnj\;');
		obj_str = NAME.replace(/([a-zA-Z0-9])/g,'$1\&shy\;');
		document.write(obj_str);
	}

	function write_size(SIZE){ // formatting file size into nnn.n
		byte_size = SIZE.split(' ')[0];
		if( byte_size <= 1024 ){
			document.write(byte_size + " Bytes");
		} else if( byte_size <= 1048576){
			byte_size = byte_size/1024;
			byte_size = (Math.round((byte_size * 10)))/10;
			document.write( byte_size + " KB");
		} else if( byte_size <= 1073741824){
			byte_size = byte_size/1048576;
			byte_size = (Math.round((byte_size * 10)))/10;
			document.write( byte_size + " MB");
		} else if( byte_size <= 1099511627776){
			byte_size = byte_size/1073741824;
			byte_size = (Math.round((byte_size * 10)))/10;
			document.write( byte_size + " GB");
		} else {
			document.write(byte_size);
		}
	}

	function show_time(){
		if(document.getElementById('show_time').checked){
			style_str = ' display = "inline"';
			style_change('.time',style_str);
		} else {
			style_str = ' display = "none"';
			style_change('.time',style_str);
		}
	}

	function show_hidden_file(){
		if(document.getElementById('show_hidden_file').checked){
			style_str = ' display = "table-row"';
			style_change('.hidden_file',style_str);
		} else {
			style_str = ' display = "none"';
			style_change('.hidden_file',style_str);
		}
	}

	function show_size(){
		if(document.getElementById('show_size').checked){
			style_str = ' display = "table-cell"';
			style_change('.file_size',style_str);
		} else {
			style_str = ' display = "none"';
			style_change('.file_size',style_str);
		}
	}

	function is_archive(){
		//Archive parameter visivility setting
		var is_archive = "<IDENTIFIER/>";
		if( is_archive == 'com.mac.xdd.archivequicklookgenerator'){
			style_str = 'backgroundColor = "transparent"';
			style_change('.file_list tr:hover', style_str);
			style_str = 'cursor = "default"';
			style_change('.file_name td.go_finder', style_str);

			style_str = 'display = "block"';
			style_change('.active_archive', style_str);
			style_str = 'display = "inline"';
			style_change('.active_archive_linine', style_str);
			style_str = 'display = "table-celll"';
			style_change('.active_archive_cell', style_str);
			style_str = 'display = "none"';
			style_change('.hide_archive', style_str);
			style_change('.hide_archive_inline', style_str);
			style_change('.hide_archive_cell', style_str);
			style_change('.file_modified', style_str);
			style_change('.file_name td.go_finder', style_str);
			}
	}