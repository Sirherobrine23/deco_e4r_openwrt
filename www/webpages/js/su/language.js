!function(r){var e;r.su=r.su||{},r.su.Language=((e=function(e){this.settings=r.extend({},{locale:"en_US",URL_LAN_CHECK:r.su.url("/system?form=envar"),DEFAULT_LAN_TYPE:"en_US",URL_JS:"./locale/%LAN_TYPE%/lan.js",URL_CSS:"./locale/%LAN_TYPE%/lan.css",URL_HELP:"./locale/%LAN_TYPE%/help.js",LAN_AVAILABLE:["en_US"]},e),this.init()}).prototype.init=function(){this.getLocale()},e.prototype.getLocale=function(){var a=this,s=this.settings,e=s.URL_LAN_CHECK.toStringURL?s.URL_LAN_CHECK.toStringURL():s.URL_LAN_CHECK.toStringURL;return this.locale||r.ajax({type:"POST",url:e,async:!1,contentType:"application/json",data:JSON.stringify({"operation":"read"}),success:function(e){if(0===e.error_code&&e.result&&e.result.locale){var t=e.result.locale.split("_"),n=t[0].toLowerCase()+"_"+t[1];return r.inArray(n,s.LAN_AVAILABLE)<0&&(n="en_US"),a.locale=n,a.changeType(n),a.locale}a.reset()},error:function(){a.reset()}}),this.locale},e.prototype.defineGlobal=function(){},e.prototype.getDeviceLanguage=function(){},e.prototype.getClientLanguage=function(){},e.prototype.reset=function(){this.changeType(this.settings.DEFAULT_LAN_TYPE)},e.prototype.switchTo=function(e,t,n){var a=this,s=this.settings;if(e){var o=s.URL_LAN_CHECK;r.ajax({type:"POST",url:o,async:!1,dataType:"json",cache:!1,data:{"operation":"write","locale":e},success:function(e){location.reload(),t&&t.call(a)},error:function(){a.reset(),n&&n.call(a)}})}},e.prototype.changeType=function(e){var t=this.settings;lanType=e||t.DEFAULT_LAN_TYPE;var n=t.URL_JS.replace("%LAN_TYPE%",lanType),a=t.URL_CSS.replace("%LAN_TYPE%",lanType);r("script#lan-js").remove(),r("link#lan-css").remove(),r("head").append('<script id="lan-js" type="text/javascript" src="'+n+' "><\/script>').append('<link id="lan-css" type="text/css" rel="stylesheet" href="'+a+' "/>').append('<script type="text/javascript" src="./locale/language.js" ><\/script>')},e)}(jQuery);