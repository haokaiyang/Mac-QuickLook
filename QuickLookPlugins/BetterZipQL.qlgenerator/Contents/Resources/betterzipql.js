// Copyright (c) 2007-2014, MacItBetter, Robert Rezabek

var simple = 0;


// Unfortunately cookies don't work in Quick Look generators
function getCookie (cname, deflt)
{
	// if (document.cookie.length > 0)
	// {
	// 	idx = document.cookie.indexOf (cname + "=");
	// 	if (idx != -1)
	// 	{ 
	// 		idx += cname.length + 1; 
	// 		idx2 = document.cookie.indexOf (";", idx);
	// 		if (idx2 == -1) 
	// 			idx2 = document.cookie.length;
	// 		return unescape (document.cookie.substring (idx, idx2)) == 'true' ? 1 : 0;
	// 	} 
	// }
	return deflt;
}

function setCookie (cname, value, expiredays)
{
	// var exdate = new Date ();
	// exdate.setDate (exdate.getDate () + expiredays);
	// document.cookie = cname + "=" + escape (value) + ((expiredays == null) ? "" : ";expires="+exdate.toGMTString());
}

var hiddenFiles, packages;
var columns = new Array ("colDate", "colSize", "colPacked", "colKind", "colAttributes");

function loadDone ()
{
	$("keepHeaderFixed").checked = getCookie ('keepHeaderFixed', keepHeaderFixed);
	$("showHiddenFiles").checked = getCookie ('showHiddenFiles', showHiddenFiles);
	$("showPackageContents").checked = getCookie ('showPackageContents', showPackageContents);

	for (iii = 0; iii < columns.length; iii++)
		$(columns[iii]).checked = getCookie (columns[iii], eval(columns[iii]));

	tgglHead ();

	if (!simple)
	{
		packages = $$('#data_table tr.p');
		hiddenFiles = $$('#data_table tr.h');
		for (iii = 0, len = hiddenFiles.length; iii < len; ++iii)
			hiddenFiles[iii].toggle();

		tgglPackageDingers ();
		tgglColumns ();
		setRowClasses ();
	}
	
 	syncTableWidths ();
}

function syncTableWidths ()
{
	var cs = $("data_table").rows[0].cells.length;
	for (iii = 0; iii < cs; iii++)
		$("header_table").rows[0].cells[iii].style.width = $("data_table").rows[0].cells[iii].clientWidth - 16 /* 2*8px padding */ + 'px';
}

function tgglColumns ()
{
	if (simple)
		return;
		
	r = $("data_table").rows;
	rh = $("header_table").rows[0];
	for (iii = 0; iii < columns.length; iii++)
	{
		a = $(columns[iii]).checked;
		setCookie (columns[iii], a, 365);

		if (rh.cells[iii + 1])
			a ? rh.cells[iii + 1].show () : rh.cells[iii + 1].hide ();

		for (jjj = 0; jjj < r.length; jjj++)
		{
			td = r[jjj].cells[iii + 1]; // select ("." + columns[iii])[0];
			if (td)
			{
				a ? td.show () : td.hide ();
			}
		}
	}
}

function tgglHead ()
{
	setCookie ('keepHeaderFixed', $("keepHeaderFixed").checked, 365);
	$("headwrap").className = $("keepHeaderFixed").checked ? "fix" : "abs";
}

function tgglHidden ()
{
	setCookie ('showHiddenFiles', $("showHiddenFiles").checked, 365);
	setRowClasses ();
}

function tgglPackages ()
{
	pc = $("showPackageContents").checked;
	setCookie ('showPackageContents', pc, 365);

	tgglPackageDingers ();
	setRowClasses ();
}

function tgglPackageDingers ()
{
	if (simple)
		return;
		
	pc = $("showPackageContents").checked;

	for (iii = 0, len = packages.length; iii < len; ++iii)
		if (icon = packages[iii].select ("div.open")[0])
			pc ? icon.show () : icon.hide ();
}

function tggl (a)
{
	a.innerHTML = a.innerHTML.indexOf ("▼") > -1 ? "▶" : "▼";
	setRowClasses ();
}

function setRowClasses ()
{
	if (simple)
		return;
		
	hf = $("showHiddenFiles").checked;
	pc = $("showPackageContents").checked;

	r = $("data_table").rows;
	closeLvl = -1;
	for (iii = 0; iii < r.length; iii++)
	{
		pad = parseInt (r[iii].getElementsByTagName ("td")[0].style.paddingLeft);
		icon = r[iii].select ("div.open")[0]; 

		if (icon && (pad <= closeLvl || closeLvl == -1))
		{
			if (icon.innerHTML.indexOf ("▶") > -1 || !hf && r[iii].hasClassName ("h") || !pc && r[iii].hasClassName ("p"))
			{
				closeLvl = pad;
			}
			else
				closeLvl = -1;
		}

		if (pad > closeLvl && closeLvl > -1 || !hf && r[iii].hasClassName ("h"))
			r[iii].style.display = "none";
		else
			r[iii].style.display = "table-row";
	}

	v = 0;
	for (iii = 0; iii < r.length; iii++)
	{
		r[iii].removeClassName ("row0");
		r[iii].removeClassName ("row1");
		if (r[iii].style.display != "none")
			r[iii].addClassName ("row" + (++v % 2));
	}
}

