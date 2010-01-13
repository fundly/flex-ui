package com.enilsson.elephanttrakker.modules.progressreports.controllers
{
	import com.enilsson.common.events.GetEvent;
	import com.enilsson.common.events.GetEventHandler;
	import com.enilsson.common.utils.DictionaryUtil;
	import com.enilsson.common.utils.GenericResponder;
	import com.enilsson.elephanttrakker.modules.progressreports.business.IProgressReportsDelegate;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	public class ProgressReportsController
	{
		public function getGroupStats( event : GetEvent ) : void {
			if( _delegate && event )
				executeGet( event, _delegate.getGroupStats );
		}
		
		public function getTopFundraisers( event : GetEvent ) : void {
			if( _delegate && event )
				executeGet( event, _delegate.getTopFundraisers );
		}
		
		public function getTopFundraisersByDownlineContributions( event : GetEvent ) : void {
			if( _delegate && event )
				executeGet( event, _delegate.getTopFundraisersByDownlineContributions );
		}
		
		public function getTopFundraisersByDownlineUsers( event : GetEvent ) : void {
			if( _delegate && event )
				executeGet( event, _delegate.getTopFundraisersByDownlineUsers );
		}
		
		
		public function executeGet( event : GetEvent, delegateFunction : Function ) : void {
			if( event == null || delegateFunction == null ) return;
			
			var t : AsyncToken = delegateFunction() as AsyncToken;
			t.addResponder( new GenericResponder( handleGetEventResult, handleGetEventFault ) );
			_tokenEventDict.add( t, event ); 			
		}
		
		public function handleGetEventResult( result : ResultEvent ) : void {
			var t : AsyncToken = result.token;
			GetEventHandler.handleResult( _tokenEventDict.getItem(t) as GetEvent, result );
			_tokenEventDict.remove(t);
		}
		public function handleGetEventFault( fault : FaultEvent ) : void {
			_tokenEventDict.remove( fault.token );			
		}



		private var _tokenEventDict : DictionaryUtil = new DictionaryUtil();
		
		public function set delegate( val : IProgressReportsDelegate ) : void { _delegate = val; }
		private var _delegate : IProgressReportsDelegate;
		
	}
}