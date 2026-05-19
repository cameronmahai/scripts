function inc_Flash( arg ){
	var tmp = arg.split(' ');
	var parm=new Array();
	for(var i=0; i<tmp.length;i++) {
		parm[parm.length] = (["_"+tmp[i].split('="')[0],tmp[i].split('="')[1].split('"')[0]]);
	}
	for( i = 0 ; i < parm.length ; i++ ){
		switch (parm[i][0].toLowerCase()){
		case '_src'     : var _src = parm[i][1] ; break ;
		case '_base'    : var _base = parm[i][1] ; break ;
		case '_quality' : var _quality = parm[i][1] ; break ;
		case '_loop'    : var _loop = parm[i][1] ; break ;
		case '_bgcolor' : var _bgcolor = parm[i][1] ; break ;
		case '_wmode'   : var _wmode = parm[i][1] ; break ;
		case '_play'    : var _play = parm[i][1] ; break ;
		case '_menu'    : var _menu = parm[i][1] ; break ;
		case '_scale'   : var _scale = parm[i][1] ; break ;
		case '_salign'  : var _salign = parm[i][1] ; break ;
		case '_height'  : var _height = parm[i][1] ; break ;
		case '_width'   : var _width = parm[i][1] ; break ;
		case '_hspace'  : var _hspace = parm[i][1] ; break ;
		case '_vspace'  : var _vspace = parm[i][1] ; break ;
		case '_align'   : var _align = parm[i][1] ; break ;
		case '_class'   : var _class = parm[i][1] ; break ;
		case '_id'      : var _id = parm[i][1] ; break ;
		case '_name'    : var _name = parm[i][1] ; break ;
		case '_style'   : var _style = parm[i][1] ; break ;
		case '_declare' : var _declare = parm[i][1] ; break ;
		case '_flashvars' : var _flashvars = parm[i][1] ;break ;//flashvars
		case '_allowscriptaccess' : var _allowscriptaccess = parm[i][1] ;break ;//allowScriptAccess
		default        :;
		}
	}
	var htm = "";
	htm+="<object classid='clsid:d27cdb6e-ae6d-11cf-96b8-444553540000'";
	htm+=" codebase='http://download.macromedia.com/pub/shockwave/";
	htm+="cabs/flash/swflash.cab'";
	if(!!_width)htm+=" width='" + _width + "'";
	if(!!_height)htm+=" height='" + _height + "'";
	if(!!_hspace)htm+=" hspace='" + _hspace + "'";
	if(!!_vspace)htm+=" vspace='" + _vspace + "'";
	if(!!_align)htm+=" align='" + _align + "'";
	if(!!_class)htm+=" class='" + _class + "'";
	if(!!_id)htm+=" id='" + _id + "'";
	if(!!_name)htm+=" name='" + _name + "'";
	if(!!_style)htm+=" style='" + _style + "'";
	if(!!_declare)htm+=" " + _declare + "'";
	htm+=">";
	if(!!_src)htm+="<param name='movie' value ='" + _src + "'>";
	if(!!_base)htm+="<param name='base' value ='" + _base + "'>";
	if(!!_quality)htm+="<param name='quality' value ='" + _quality + "'>";
	if(!!_loop)htm+="<param name='loop' value ='" + _loop + "'>";
	if(!!_bgcolor)htm+="<param name='bgcolor' value ='" + _bgcolor + "'>";
	if(!!_play)htm+="<param name='play' value ='" + _play + "'>";
	if(!!_menu)htm+="<param name='menu' value ='" + _menu + "'>";
	if(!!_scale)htm+="<param name='scale' value ='" + _scale + "'>";
	if(!!_salign)htm+="<param name='salign' value ='" + _salign + "'>";
	if(!!_wmode)htm+="<param name='wmode' value ='" + _wmode + "'>";
	if(!!_flashvars)htm+="<param name='flashvars' value ='"+ _flashvars + "'>";
	if(!!_allowscriptaccess)htm+="<param name='allowScriptAccess' value ='"+ _allowscriptaccess + "'>";
	htm+="";
	htm+="<embed                          ";
	htm+=" pluginspage='http://www.macromedia.com/go/getflashplayer'";
	if(!!_width)htm+=" width='" + _width + "'";
	if(!!_height)htm+=" height='" + _height + "'";
	if(!!_hspace)htm+=" hspace='" + _hspace + "'";
	if(!!_vspace)htm+=" vspace='" + _vspace + "'";
	if(!!_align)htm+=" align='" + _align + "'";
	if(!!_class)htm+=" class='" + _class + "'";
	if(!!_id)htm+=" id='" + _id + "'";
	if(!!_name)htm+=" name='" + _name + "'";
	if(!!_style)htm+=" style='" + _style + "'";
	htm+=" type='application/x-shockwave-flash' ";
	if(!!_flashvars)htm+=" flashvars= '" + _flashvars+ "'";
	if(!!_allowscriptaccess)htm+=" allowscriptaccess= '" + _allowscriptaccess+ "'";
	if(!!_declare)htm+=" " + _declare;
	if(!!_src)htm+=" src='" + _src + "'";
	if(!!_base)htm+=" base='" + _base + "'";
	if(!!_quality)htm+=" quality='" + _quality + "'";
	if(!!_loop)htm+=" loop='" + _loop + "'";
	if(!!_bgcolor)htm+=" bgcolor='" + _bgcolor + "'";
	if(!!_play)htm+=" play='" + _play + "'";
	if(!!_menu)htm+=" menu='" + _menu + "'";
	if(!!_scale)htm+=" scale='" + _scale + "'";
	if(!!_salign)htm+=" salign='" + _salign + "'";
	htm+="></embed>";
	htm+="</object>";
	document.write(htm);
}