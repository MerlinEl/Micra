--pressing button programaticaly

mu = (mcDialogEditMode.tag.value.tab_buttons[1].getType()).GetEvent "MouseUp"
--or
btn = mcDialogEditMode.tag.value.tab_buttons[1]
((btn.GetType()).GetEvent("MouseUp")).GetRaiseMethod()

--step by step
btn = mcDialogEditMode.tag.value.tab_buttons[1]
type = btn.getType()
eve = type.GetEvent "MouseUp"
eve.GetRaiseMethod()

eve.DeclaringType
eve.EventHandlerType
eve.DeclaringType.DeclaringMethod --System.Reflection.MethodBase
eve.DeclaringType.Clone()
eve.DeclaringType.GetEvents()
(eve.DeclaringType.GetEvents())[1]

eve.DeclaringType.MakePointerType()
eve.AddEventHandler <System.Object>target <System.Delegate>handler




eve.GetRaiseMethod()



btn.BeginInvoke 


btn.Invoke eve (dotnetClass "EventArgs").empty
btn.Invoke (dotnetClass "EventArgs").empty "MouseUp"

btn.Invoke eve.DeclaringType

.DefaultBinder

st = dotnetclass "System.Type"
st.GetTypeCode
st.DefaultBinder
sd = dotnetclass "system.delegate"
sd.CreateDelegate type btn "MouseUp"

  .[static]<System.Delegate>CreateDelegate <System.Type>type <System.Reflection.MethodInfo>method
  .[static]<System.Delegate>CreateDelegate <System.Type>type <System.Object>target <System.String>method

Theevent = (gather the event from the object ???) as a "system.delegate" witch is a ref to the event.
btn.invoke Theevent 