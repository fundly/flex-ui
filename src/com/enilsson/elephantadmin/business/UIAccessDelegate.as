package com.enilsson.elephantadmin.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephantadmin.models.EAModelLocator;
	import com.enilsson.elephantadmin.vo.UIAccessVO;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class UIAccessDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:EAModelLocator = EAModelLocator.getInstance();
		
		public function UIAccessDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getUIAccess( userId : Number ) : void {
			if(_model.debug){ Logger.info('Get UI Access Rights'); }
			
			this.service = ServiceLocator.getInstance().getRemoteObject('access');
			var token : AsyncToken = service.get_ui_access( userId );
			token.addResponder( responder );
		}
		
		public function setUIAccess( vo : UIAccessVO ) : void {
			if(_model.debug){ Logger.info('Set UI Access Rights'); }
			if(!vo) return;
			
			this.service = ServiceLocator.getInstance().getRemoteObject('access');
			var token : AsyncToken = service.set_ui_access( vo );
			token.addResponder( responder );
		}
	}
}