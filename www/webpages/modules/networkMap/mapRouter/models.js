!function(n){n.su.modelManager.define("deviceNameModel",{type:"model",fields:[{name:"deviceName",mapping:"device_name",vtype:"string_visible_allow_blank",allowBlank:!1}],proxy:{url:n.su.url("/admin/cloud_account?form=get_deviceInfo")}}),n.su.modelManager.define("ipv6NetworkMap",{type:"model",fields:[{name:"mac"},{name:"ip"}],convert:function(e){return{ip:e.lan&&e.lan.ip}},proxy:"ipv6NetworkMapProxy"}),n.su.define("ipv6NetworkMapProxy",{extend:"IPFProxy",url:n.su.url("/admin/network?form=ipv6"),writeFilter:function(e){return e.params||(e.params={"device_mac":"default"}),e}}),n.su.modelManager.define("performanceM",{type:"model",fields:[{name:"cpuUsage",mapping:"cpu_usage"},{name:"memUsage",mapping:"mem_usage"}],convert:function(e){var r=n.extend({},e);return r.cpu_usage=parseInt(100*r.cpu_usage,10)+"%",r.mem_usage=parseInt(100*r.mem_usage,10)+"%",r},preventSuccessEvent:!0,preventFailEvent:!0,preventErrorEvent:!0,proxy:{url:n.su.url("/admin/network?form=performance")}}),n.su.define("getFirmwareListProxy",{extend:"IPFProxy",url:n.su.url("/admin/device?form=device_list"),preventSuccessEvent:!0,preventFailEvent:!0,preventErrorEvent:!0,writeFilter:function(e){return n.extend({operation:"read"},e)}}),n.su.storeManager.define("treeStore",{type:"store",fields:[{name:"name"},{name:"branches"},{name:"modelImg"},{name:"role"},{name:"mac"},{name:"nickname"}],proxy:{url:n.su.url("/admin/folder_sharing?form=tree")},storeConvert:function(e){for(var r=this.getData(),n=0,a=r.length;n<a;n++)for(var t=0,o=r[n].branches.length;t<o;t++)e.path==r[n].branches[t].path&&(r[n].branches[t]=e);return r}})}(jQuery);