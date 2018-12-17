IsValidNode $

isGroupHead $ -- Returns true if node is group head, false otherwise.

isGroupMember $ --Returns true if node is in a group, false otherwise.

isOpenGroupMember $ --Returns true if <node> is a member of a group, and that group is open.

isOpenGroupHead $ --Returns true if <node> is the head of a group, and that group is open.


IsValidNode $
for i in $selection do if (isGroupHead i == true) do GroupItem= i --find "node head" in group
GroupItemsAll =for i in $selection collect i --collect objects in group and "node head"
GroupItems = deleteItem GroupItems (findItem GroupItemsAll GroupItem) --collect only objects in group
GroupName = GroupItem.name --group name

for i in $objects do if isGroupHead i do print i --find groups heads

-->find and collect groups heads
GroupsHeads=#()
for i in $objects do if isGroupHead i do append GroupsHeads i

-->find and collect groups members 
GroupsMembers=#()
for i in $objects do if isGroupMember i do append GroupsMembers i


select (getNodeByName "aa")

--------------
		Try( ParamCollectorOps.doLinkToObjectDialog() )
		Catch()
-------------
		Try( ParamCollectorOps.RemoveLinkToObject() )
		Catch() 