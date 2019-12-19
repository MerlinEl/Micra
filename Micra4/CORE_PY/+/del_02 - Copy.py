import MaxPlus
# create a sphere node
node_name = "my_sphere"
obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Sphere)
node = MaxPlus.Factory.CreateNode(obj, node_name)
result = MaxPlus.FPValue()
# get one FPValue pointer to the object by running some MAXScript
evaluation_success = MaxPlus.Core.EvalMAXScript('$%s' % node_name, result)
handle1 =  result.Get()
# get a second pointer to the same object
evaluation_success = MaxPlus.Core.EvalMAXScript('$%s' % node_name, result)
handle2 = result.Get()

# this prints True:
print 'Objects are equal: %s' % (handle1 == handle2)
# this prints False:
print 'Objects are not equal: %s' % (handle1 != handle2)
# this prints False:
print 'Objects are identical: %s' % (handle1 is handle2)
# this prints True:
print 'Objects are not identical: %s' % (handle1 is not handle2)