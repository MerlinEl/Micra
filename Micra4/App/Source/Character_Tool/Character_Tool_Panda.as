package {
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class Character_Tool_Panda extends MovieClip {
		
		public function Character_Tool_Panda() {addEventListener(Event.ADDED_TO_STAGE, init)}
		private function init(e:Event):void {
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			registerButtons();
		}
		
		private function registerButtons():void {
			
			ftrace("Register button Events...");
			for (var i:int = 0; i < numChildren; i++) {
				
				if (getChildAt(i) is SimpleButton) {
					
					var btn:SimpleButton = getChildAt(i) as SimpleButton;
					if(btn.hasEventListener(MouseEvent.MOUSE_UP)) continue; //skip already registred buttons
					btn.addEventListener(MouseEvent.MOUSE_UP, executeCommand);
					ftrace("\t%", btn.name);
				}
			}
		}
		
		function goToInterface(index:int) {
			
			gotoAndStop(index);
			registerButtons();
		}
		
		public function executeCommand(e:MouseEvent) {
			
			//if (!ExternalInterface.available) return;
			var key:String = e.target.name;
			ftrace("key:%", key);
			switch (key) {
				
				//WEIGHT
				case "btn_increase_weight"	: ExternalInterface.call("scaleWeight", "up"); break;
				case "btn_decrease_weight"	: ExternalInterface.call("scaleWeight", "down"); break;
				case "btn_setWeight_000"	: ExternalInterface.call("setWeight", "0.0"); break;
				case "btn_setWeight_010"	: ExternalInterface.call("setWeight", "0.1"); break;
				case "btn_setWeight_025"	: ExternalInterface.call("setWeight", "0.25"); break;
				case "btn_setWeight_050"	: ExternalInterface.call("setWeight", "0.5"); break;
				case "btn_setWeight_075"	: ExternalInterface.call("setWeight", "0.75"); break;
				case "btn_setWeight_090"	: ExternalInterface.call("setWeight", "0.9"); break;
				case "btn_setWeight_100"	: ExternalInterface.call("setWeight", "1"); break;
				
				//SELECTION
				case "btn_sel_bone_verts"	: ExternalInterface.call("selBoneVerts", "true"); break;
				case "btn_unsel_bone_verts"	: ExternalInterface.call("selBoneVerts", "false"); break;
				case "btn_sel_all"			: ExternalInterface.call("select", "all"); break;
				case "btn_canvas"			: ExternalInterface.call("select", "none"); break;
					//Center
				case "btn_Head"         	: ExternalInterface.call("select", "Head"         ); break;
				case "btn_Neck"         	: ExternalInterface.call("select", "Neck"         ); break;
				case "btn_Spine"        	: ExternalInterface.call("select", "Spine"        ); break;
				case "btn_Spine1"       	: ExternalInterface.call("select", "Spine1"       ); break;
				case "btn_Spine2"       	: ExternalInterface.call("select", "Spine2"       ); break;
				case "btn_Spine3"       	: ExternalInterface.call("select", "Spine3"       ); break;
				case "btn_Spine4"       	: ExternalInterface.call("select", "Spine4"       ); break;
				case "btn_Bip"       		: ExternalInterface.call("select", "Bip"          ); break;
				case "btn_Pelvis"       	: ExternalInterface.call("select", "Pelvis"   	  ); break;
					//Left
				case "btn_LeftClavicle"     : ExternalInterface.call("select", "LeftClavicle" ); break;
				case "btn_LeftUpperArm" 	: ExternalInterface.call("select", "LeftUpperArm" ); break;
				case "btn_LeftForeArm"  	: ExternalInterface.call("select", "LeftForeArm"  ); break;
				case "btn_LeftHand"     	: ExternalInterface.call("select", "LeftHand"     ); break;
					case "LeftHandThumb1"     	: ExternalInterface.call("select", "LeftHandThumb1"); break;
					case "LeftHandThumb2"     	: ExternalInterface.call("select", "LeftHandThumb2"); break;
					case "LeftHandThumb3"     	: ExternalInterface.call("select", "LeftHandThumb3"); break;
					case "LeftHandIndex1"     	: ExternalInterface.call("select", "LeftHandIndex1"); break;
					case "LeftHandIndex2"     	: ExternalInterface.call("select", "LeftHandIndex2"); break;
					case "LeftHandIndex3"     	: ExternalInterface.call("select", "LeftHandIndex3"); break;
					case "LeftHandMiddle1"     	: ExternalInterface.call("select", "LeftHandMiddle1"); break;
					case "LeftHandMiddle2"     	: ExternalInterface.call("select", "LeftHandMiddle2"); break;
					case "LeftHandMiddle3"     	: ExternalInterface.call("select", "LeftHandMiddle3"); break;
					case "LeftHandRing1"     	: ExternalInterface.call("select", "LeftHandRing1"); break;
					case "LeftHandRing2"     	: ExternalInterface.call("select", "LeftHandRing2"); break;
					case "LeftHandRing3"     	: ExternalInterface.call("select", "LeftHandRing3"); break;
					case "LeftHandPinky1"     	: ExternalInterface.call("select", "LeftHandPinky1"); break;
					case "LeftHandPinky2"     	: ExternalInterface.call("select", "LeftHandPinky2"); break;
					case "LeftHandPinky3"     	: ExternalInterface.call("select", "LeftHandPinky3"); break;
				case "btn_LeftUpLeg"    	: ExternalInterface.call("select", "LeftUpLeg"    ); break;
				case "btn_LeftLeg"      	: ExternalInterface.call("select", "LeftLeg"      ); break;
				case "btn_LeftFoot"     	: ExternalInterface.call("select", "LeftFoot"     ); break;
				
					//Right
				case "btn_RightClavicle"     : ExternalInterface.call("select", "RightClavicle" ); break;
				case "btn_RightUpperArm" 	: ExternalInterface.call("select", "RightUpperArm" ); break;
				case "btn_RightForeArm"  	: ExternalInterface.call("select", "RightForeArm"  ); break;
				case "btn_RightHand"     	: ExternalInterface.call("select", "RightHand"     ); break;
					case "RightHandThumb1"     	: ExternalInterface.call("select", "RightHandThumb1"); break;
					case "RightHandThumb2"     	: ExternalInterface.call("select", "RightHandThumb2"); break;
					case "RightHandThumb3"     	: ExternalInterface.call("select", "RightHandThumb3"); break;
					case "RightHandIndex1"     	: ExternalInterface.call("select", "RightHandIndex1"); break;
					case "RightHandIndex2"     	: ExternalInterface.call("select", "RightHandIndex2"); break;
					case "RightHandIndex3"     	: ExternalInterface.call("select", "RightHandIndex3"); break;
					case "RightHandMiddle1"     : ExternalInterface.call("select", "RightHandMiddle1"); break;
					case "RightHandMiddle2"     : ExternalInterface.call("select", "RightHandMiddle2"); break;
					case "RightHandMiddle3"     : ExternalInterface.call("select", "RightHandMiddle3"); break;
					case "RightHandRing1"     	: ExternalInterface.call("select", "RightHandRing1"); break;
					case "RightHandRing2"     	: ExternalInterface.call("select", "RightHandRing2"); break;
					case "RightHandRing3"     	: ExternalInterface.call("select", "RightHandRing3"); break;
					case "RightHandPinky1"     	: ExternalInterface.call("select", "RightHandPinky1"); break;
					case "RightHandPinky2"     	: ExternalInterface.call("select", "RightHandPinky2"); break;
					case "RightHandPinky3"     	: ExternalInterface.call("select", "RightHandPinky3"); break;
				case "btn_RightUpLeg"    	: ExternalInterface.call("select", "RightUpLeg"    ); break;
				case "btn_RightLeg"      	: ExternalInterface.call("select", "RightLeg"      ); break;
				case "btn_RightFoot"     	: ExternalInterface.call("select", "RightFoot"     ); break;

					//Face
						//Center
					case "btn_Hat"     		: ExternalInterface.call("select", "Hat" ); break;
					case "gathers"     		: ExternalInterface.call("select", "gathers" ); break;
					case "lips_middle_up"   : ExternalInterface.call("select", "lips_middle_up" ); break;
					case "lips_middle_down" : ExternalInterface.call("select", "lips_middle_down" ); break;
					case "nose"     		: ExternalInterface.call("select", "nose" ); break;
					case "jaw"     			: ExternalInterface.call("select", "jaw" ); break;
						//Right
					case "brow_out_R"     	: ExternalInterface.call("select", "brow_out_R" ); break;
					case "blink01_upper_R"  : ExternalInterface.call("select", "blink01_upper_R" ); break;
					case "brow_mid_R"     	: ExternalInterface.call("select", "brow_mid_R" ); break;
					case "blink01_lower_R"  : ExternalInterface.call("select", "blink01_lower_R" ); break;
					case "cheekbone_R"     	: ExternalInterface.call("select", "cheekbone_R" ); break;
					case "nose_R"     		: ExternalInterface.call("select", "nose_R" ); break;
					case "cheek_R"     		: ExternalInterface.call("select", "cheek_R" ); break;
					case "lips_midle_R"    	: ExternalInterface.call("select", "lips_midle_R" ); break;
					case "RightEye"     	: ExternalInterface.call("select", "RightEye" ); break;
					case "RightEar"     	: ExternalInterface.call("select", "RightEar" ); break;
						//Left
					case "brow_out_L"     	: ExternalInterface.call("select", "brow_out_L" ); break;
					case "blink01_upper_L"  : ExternalInterface.call("select", "blink01_upper_L" ); break;
					case "brow_mid_L"     	: ExternalInterface.call("select", "brow_mid_L" ); break;
					case "blink01_lower_L"  : ExternalInterface.call("select", "blink01_lower_L" ); break;
					case "cheekbone_L"     	: ExternalInterface.call("select", "cheekbone_L" ); break;
					case "nose_L"     		: ExternalInterface.call("select", "nose_L" ); break;
					case "cheek_L"     		: ExternalInterface.call("select", "cheek_L" ); break;
					case "lips_midle_L"     : ExternalInterface.call("select", "lips_midle_L" ); break;
					case "LeftEye"     		: ExternalInterface.call("select", "LeftEye" ); break;
					case "LeftEar"     		: ExternalInterface.call("select", "LeftEar" ); break;

					
				//ZOOM				
				case "btn_zoom_body"    	: goToInterface(1); ExternalInterface.call("zoom", "Body")		; break;
				case "btn_zoom_rhand"    	: goToInterface(2); ExternalInterface.call("zoom", "RightHand")	; break;
				case "btn_zoom_lhand"    	: goToInterface(3); ExternalInterface.call("zoom", "LeftHand")	; break;
				case "btn_zoom_head"    	: goToInterface(4); ExternalInterface.call("zoom", "Head")		; break;
				case "btn_zoom_rfoot"    	: goToInterface(5); ExternalInterface.call("zoom", "RightFoot")	; break;
				case "btn_zoom_lfoot"    	: goToInterface(6); ExternalInterface.call("zoom", "LeftFoot")	; break;
				
				//POSE
				case "btn_copy_lr"    	: ExternalInterface.call("pose", "lr"); break;
				case "btn_copy_rl"    	: ExternalInterface.call("pose", "rl"); break;
			}
		}
	}
}


/*
--Send
ExternalInterface.call("key", "val");
--Receive
ExternalInterface.addCallback("flashCallback", onCsharpDataRecive);
function onCsharpDataRecive(str_data:String):void {
			
	var data:iuCsharpGetArgs = new iuCsharpGetArgs(str_data);
	//iuGlobal.log("( Flash < C# ) > onDataRecive > " + data);
	switch (data.Process_Type) {
	case "check_internet": // get true if internet is aviable else false
		// true - false
		onInternetChecked(data.Value_Str)
		break;
	case "send_customer_email":
		iuGlobal.log("( Flash < C# ) > Email was sended:" + data.Value_Str, false, true);
		onEmailSend(data.Value_Str);
		break;
	}
}
*/