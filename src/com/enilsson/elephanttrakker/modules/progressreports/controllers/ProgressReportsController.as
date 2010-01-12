package com.enilsson.elephanttrakker.modules.progressreports.controllers
{
	import com.enilsson.common.events.GetEvent;
	import com.enilsson.common.events.GetEventHandler;
	import com.enilsson.common.utils.DictionaryUtil;
	import com.enilsson.common.utils.GenericResponder;
	import com.enilsson.elephanttrakker.modules.progressreports.business.IProgressReportsDelegate;
	
	import flash.events.Event;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	public class ProgressReportsController
	{
		public function getFundraiserStats( event : Event ) : void {
			if( _delegate == null || event == null ) return;

			var t : AsyncToken = _delegate.getFundraiserStats();
			t.addResponder( new GenericResponder( handleGetFundraiserStatsResult, handleGetFundraiserStatsFault ) );
			_tokenEventDict.add( t, event );
		}
		public function handleGetFundraiserStatsResult( result : ResultEvent ) : void {
			var t : AsyncToken = result.token;
			GetEventHandler.handleResult( _tokenEventDict.getItem(t) as GetEvent, result );
			_tokenEventDict.remove(t);
		}
		public function handleGetFundraiserStatsFault( fault : FaultEvent ) : void {
			_tokenEventDict.remove( fault.token );			
		}
		
		
		public function getGroupStats( event : Event ) : void {
			if( _delegate == null || event == null ) return;
			
			var t : AsyncToken = _delegate.getGroupStats();
			t.addResponder( new GenericResponder( handleGetGroupStatsResult, handleGetGroupStatsFault ) );
			_tokenEventDict.add( t, event );
		}
		public function handleGetGroupStatsResult( result : ResultEvent ) : void {
			var t : AsyncToken = result.token;
			GetEventHandler.handleResult( _tokenEventDict.getItem(t) as GetEvent, result );
			_tokenEventDict.remove(t);
		}
		public function handleGetGroupStatsFault( fault : FaultEvent ) : void {
			_tokenEventDict.remove( fault.token );
		}


		private var _tokenEventDict : DictionaryUtil = new DictionaryUtil();
		
		public function set delegate( val : IProgressReportsDelegate ) : void { _delegate = val; }
		private var _delegate : IProgressReportsDelegate;
		
	}
}