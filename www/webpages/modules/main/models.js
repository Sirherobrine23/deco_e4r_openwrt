$.su.define("firmwareProxy",{extend:"IPFProxy",url:$.su.url("/admin/firmware?form=upgrade"),preventFailEvent:!0,preventErrorEvent:!0,readFilter:function(r){return{isDefault:r.data.is_default}}});