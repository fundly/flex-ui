package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.utils.ObjectUtil;
	
	import org.osflash.thunderbolt.Logger;
	
	public class MessageCenterDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function MessageCenterDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getMessages():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');

			var where:Object = {'statement':'(1 AND 2)',
				'1':{ 
				'what' : 'msgs.sent',
				'val' : 0,
				'op' : '='
				},
				'2':{ 
					'what' : 'msgs.to_id',
					'val' : _model.session.user_id,
					'op' : '='
				}};
			var sort:String = 'msgs.created_on DESC';

			var token:AsyncToken = service.record_tree('msgs', where, sort);
			token.addResponder(responder);
		}
		
		public function getSent():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');

			var where:Object = {'statement':'(1)','1':{ 
				'what' : 'msgs.sent',
				'val' : 1,
				'op' : '='
			},
				'2':{ 
					'what' : 'msgs.from_id',
					'val' : _model.session.user_id,
					'op' : '='
				}};
			var sort:String = 'msgs.created_on DESC';

			var token:AsyncToken = service.record_tree('msgs', where, sort);
			token.addResponder(responder);
		}		
		
		public function getUnread():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');

			var where:Object = {'statement':'(1 AND 2 AND 3)',
				'1':{ 
					'what' : 'msgs.viewed',
					'val' : 0,
					'op' : '='
				},
				'2':{ 
					'what' : 'msgs.sent',
					'val' : 0,
					'op' : '='
				},
				'3':{ 
					'what' : 'msgs.to_id',
					'val' : _model.session.user_id,
					'op' : '='
				}
			};

			var token:AsyncToken = service.record_tree('msgs<sent>', where);
			token.addResponder(responder);
		}
		
		public function acceptRequest(tablename:String, data:Object):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');
			
			var token:AsyncToken;
			switch (tablename) 
			{
				case 'contacts':	
					token = service.upsert('contacts_sharing',{ 'share_id' : data.from_id });
				break;
				case 'downline':
					token = service.upsert('downline',{'user_id':data.from_id, 'child_id':data.to_id});
				break;
				
			}
			token.addResponder(responder);
		}
		 
		
		public function deleteMessage(msgID:uint):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');
			
			var token:AsyncToken = service.del('msgs',msgID);
			token.addResponder(responder);
		}
		
		
		public function setMessageStatus(msgID:uint, viewed:uint):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');
			
			var token:AsyncToken = service.upsert('msgs',{'id':msgID,'viewed':viewed});
			token.addResponder(responder);
		}
		

		public function searchFundRaisers( searchTerm:String, iFrom:int, iCount:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSearch');
			
			var token:AsyncToken = service.table('tr_users_details', searchTerm, null, iFrom, iCount);
			token.addResponder(responder);
		}			

		public function sendMessage( to_id:Number, subject:String, text:String, action:String ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorPluginsMsgs');
			
			var token:AsyncToken = service.send_message(to_id, subject, text, action);
			token.addResponder(responder);
		}
		
		public function getUser( userID:Number ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree( 'tr_users_details', userID );
			token.addResponder(responder);
		}
	}
}