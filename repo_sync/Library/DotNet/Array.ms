dotNetObject "System.Value32" 2
dotNetObject "System.Byte" 12


--Such pure conversion to .NET type is sometimes required, for example in the use of a .NET array:
-- Create a .NET array of 10 integers
intArray = dotNetObject "System.Int32[]" 10

-- Fill array
for idx = 1 to 10 do
(
	intValue = dotNetObject "System.Int32" (random 1 100)
	intIndex = dotNetObject "System.Int32" (idx-1)
	intArray.SetValue intValue intIndex
)

-- Print array data
for idx = 1 to 10 do
(
	intIndex = dotNetObject "System.Int32" (idx-1)
	print (intArray.GetValue intIndex)
)


	---objects
	global buttons = dotNetObject "object[]" buttons_X
	for i = 0 to buttons_X - 1 do
	(
 		local btn = (dotNetObject "Button")
		btn.Width = button_size
		btn.Height = button_size
		btn.Text = i as string
		dotNet.addEventHandler btn "Click" OnButtonClick -- Setup an event handler for buttons
		btn.location = netDrPoint [ i-4, 0 ]
		indx = dotNetObject "System.Int32" i
		buttons.SetValue btn indx
	)
	print buttons
	
	
	 ---strings
	fn dotNetArray mxsArray = 
	(
		netArray = dotNetObject "System.String[]" mxsArray.count
		for i=1 to mxsArray.count do 
		(
			str = dotNetObject "System.String" mxsArray[i]
			indx = dotNetObject "System.Int32" (i-1)
			netArray.SetValue str indx
		)
		netArray
	)
	
	fn sortViaNetArray mxsArray =
	(
		local netArray = dotNetArray mxsArray
		netArray.sort netArray
		mxsArray = for i = 0 to netArray.Length - 1 collect (netArray.Get i)
	)
	
	
	   1.
      -- .NET arrays indexes start at 0!
   2.
       
   3.
      -- Create a .NET array of 10 integers
   4.
      intArray = dotNetObject "System.Int32[]" 10
   5.
       
   6.
      -- Fill array
   7.
      for idx = 1 to 10 do
   8.
      (
   9.
      intValue = dotNetObject "System.Int32" (random 1 100)
  10.
      intIndex = dotNetObject "System.Int32" (idx-1)
  11.
      intArray.SetValue intValue intIndex
  12.
      )
  13.
       
  14.
      -- Print array data
  15.
      for idx = 1 to 10 do
  16.
      (
  17.
      intIndex = dotNetObject "System.Int32" (idx-1)
  18.
      print (intArray.GetValue intIndex)
  19.
      )
	
	
"---------------------------------------------------------------------------"
Info:dotNetObject:System.String[]
"---------------------------------------------------------------------------"
ClassOf: dotNetObject
SuperClassOf: Value
No ShowClass for dotNetObject:System.String[]
No Show for dotNetObject:System.String[]
  .IsFixedSize : <System.Boolean>, read-only
  .IsReadOnly : <System.Boolean>, read-only
  .IsSynchronized : <System.Boolean>, read-only
  .Length : <System.Int32>, read-only
  .LongLength : <System.Int64>, read-only
  .Rank : <System.Int32>, read-only
  .SyncRoot : <System.Object>, read-only
PROPERTIES:
  .<System.String&>Address <System.Int32>
  .[static]<System.Collections.ObjectModel.ReadOnlyCollection`1[T]>AsReadOnly <T[]>array
  .[static]<System.Int32>BinarySearch <T[]>array <T>value
  .[static]<System.Int32>BinarySearch <System.Array>array <System.Object>value
  .[static]<System.Int32>BinarySearch <T[]>array <T>value <IComparer`1>comparer
  .[static]<System.Int32>BinarySearch <System.Array>array <System.Object>value <System.Collections.IComparer>comparer
  .[static]<System.Int32>BinarySearch <T[]>array <System.Int32>index <System.Int32>length <T>value
  .[static]<System.Int32>BinarySearch <System.Array>array <System.Int32>index <System.Int32>length <System.Object>value
  .[static]<System.Int32>BinarySearch <T[]>array <System.Int32>index <System.Int32>length <T>value <IComparer`1>comparer
  .[static]<System.Int32>BinarySearch <System.Array>array <System.Int32>index <System.Int32>length <System.Object>value <System.Collections.IComparer>comparer
  .[static]Clear <System.Array>array <System.Int32>index <System.Int32>length
  .<System.Object>Clone()
  .[static]ConstrainedCopy <System.Array>sourceArray <System.Int32>sourceIndex <System.Array>destinationArray <System.Int32>destinationIndex <System.Int32>length
  .[static]<TOutput[]>ConvertAll <TInput[]>array <Converter`2>converter
  .[static]Copy <System.Array>sourceArray <System.Array>destinationArray <System.Int32>length
  .[static]Copy <System.Array>sourceArray <System.Array>destinationArray <System.Int64>length
  .[static]Copy <System.Array>sourceArray <System.Int64>sourceIndex <System.Array>destinationArray <System.Int64>destinationIndex <System.Int64>length
  .[static]Copy <System.Array>sourceArray <System.Int32>sourceIndex <System.Array>destinationArray <System.Int32>destinationIndex <System.Int32>length
  .CopyTo <System.Array>array <System.Int32>index
  .CopyTo <System.Array>array <System.Int64>index
  .[static]<System.Array>CreateInstance <System.Type>elementType <System.Int32[]>lengths
  .[static]<System.Array>CreateInstance <System.Type>elementType <System.Int32>length
  .[static]<System.Array>CreateInstance <System.Type>elementType <System.Int64[]>lengths
  .[static]<System.Array>CreateInstance <System.Type>elementType <System.Int32[]>lengths <System.Int32[]>lowerBounds
  .[static]<System.Array>CreateInstance <System.Type>elementType <System.Int32>length1 <System.Int32>length2
  .[static]<System.Array>CreateInstance <System.Type>elementType <System.Int32>length1 <System.Int32>length2 <System.Int32>length3
  .<System.Boolean>Equals <System.Object>obj
  .[static]<System.Boolean>Equals <System.Object>objA <System.Object>objB
  .[static]<System.Boolean>Exists <T[]>array <Predicate`1>match
  .[static]<T>Find <T[]>array <Predicate`1>match
  .[static]<T[]>FindAll <T[]>array <Predicate`1>match
  .[static]<System.Int32>FindIndex <T[]>array <Predicate`1>match
  .[static]<System.Int32>FindIndex <T[]>array <System.Int32>startIndex <Predicate`1>match
  .[static]<System.Int32>FindIndex <T[]>array <System.Int32>startIndex <System.Int32>count <Predicate`1>match
  .[static]<T>FindLast <T[]>array <Predicate`1>match
  .[static]<System.Int32>FindLastIndex <T[]>array <Predicate`1>match
  .[static]<System.Int32>FindLastIndex <T[]>array <System.Int32>startIndex <Predicate`1>match
  .[static]<System.Int32>FindLastIndex <T[]>array <System.Int32>startIndex <System.Int32>count <Predicate`1>match
  .[static]ForEach <T[]>array <Action`1>action
  .<System.String>Get <System.Int32>
  .<System.Collections.IEnumerator>GetEnumerator()
  .<System.Int32>GetHashCode()
  .<System.Int32>GetLength <System.Int32>dimension
  .<System.Int64>GetLongLength <System.Int32>dimension
  .<System.Int32>GetLowerBound <System.Int32>dimension
  .<System.Type>GetType()
  .<System.Int32>GetUpperBound <System.Int32>dimension
  .<System.Object>GetValue <System.Int32>index
  .<System.Object>GetValue <System.Int64[]>indices
  .<System.Object>GetValue <System.Int64>index
  .<System.Object>GetValue <System.Int32[]>indices
  .<System.Object>GetValue <System.Int64>index1 <System.Int64>index2
  .<System.Object>GetValue <System.Int32>index1 <System.Int32>index2
  .<System.Object>GetValue <System.Int32>index1 <System.Int32>index2 <System.Int32>index3
  .<System.Object>GetValue <System.Int64>index1 <System.Int64>index2 <System.Int64>index3
  .[static]<System.Int32>IndexOf <T[]>array <T>value
  .[static]<System.Int32>IndexOf <System.Array>array <System.Object>value
  .[static]<System.Int32>IndexOf <System.Array>array <System.Object>value <System.Int32>startIndex
  .[static]<System.Int32>IndexOf <T[]>array <T>value <System.Int32>startIndex
  .[static]<System.Int32>IndexOf <T[]>array <T>value <System.Int32>startIndex <System.Int32>count
  .[static]<System.Int32>IndexOf <System.Array>array <System.Object>value <System.Int32>startIndex <System.Int32>count
  .Initialize()
  .[static]<System.Int32>LastIndexOf <T[]>array <T>value
  .[static]<System.Int32>LastIndexOf <System.Array>array <System.Object>value
  .[static]<System.Int32>LastIndexOf <System.Array>array <System.Object>value <System.Int32>startIndex
  .[static]<System.Int32>LastIndexOf <T[]>array <T>value <System.Int32>startIndex
  .[static]<System.Int32>LastIndexOf <System.Array>array <System.Object>value <System.Int32>startIndex <System.Int32>count
  .[static]<System.Int32>LastIndexOf <T[]>array <T>value <System.Int32>startIndex <System.Int32>count
  .[static]<System.Boolean>ReferenceEquals <System.Object>objA <System.Object>objB
  .[static]Resize <T[]&>array <System.Int32>newSize
  .[static]Reverse <System.Array>array
  .[static]Reverse <System.Array>array <System.Int32>index <System.Int32>length
  .Set <System.Int32> <System.String>
  .SetValue <System.Object>value <System.Int64[]>indices
  .SetValue <System.Object>value <System.Int32[]>indices
  .SetValue <System.Object>value <System.Int32>index
  .SetValue <System.Object>value <System.Int64>index
  .SetValue <System.Object>value <System.Int64>index1 <System.Int64>index2
  .SetValue <System.Object>value <System.Int32>index1 <System.Int32>index2
  .SetValue <System.Object>value <System.Int32>index1 <System.Int32>index2 <System.Int32>index3
  .SetValue <System.Object>value <System.Int64>index1 <System.Int64>index2 <System.Int64>index3
  .[static]Sort <System.Array>array
  .[static]Sort <T[]>array
  .[static]Sort <T[]>array <IComparer`1>comparer
  .[static]Sort <T[]>array <Comparison`1>comparison
  .[static]Sort <System.Array>keys <System.Array>items
  .[static]Sort <System.Array>array <System.Collections.IComparer>comparer
  .[static]Sort <TKey[]>keys <TValue[]>items
  .[static]Sort <System.Array>keys <System.Array>items <System.Collections.IComparer>comparer
  .[static]Sort <System.Array>array <System.Int32>index <System.Int32>length
  .[static]Sort <T[]>array <System.Int32>index <System.Int32>length
  .[static]Sort <TKey[]>keys <TValue[]>items <IComparer`1>comparer
  .[static]Sort <System.Array>array <System.Int32>index <System.Int32>length <System.Collections.IComparer>comparer
  .[static]Sort <System.Array>keys <System.Array>items <System.Int32>index <System.Int32>length
  .[static]Sort <T[]>array <System.Int32>index <System.Int32>length <IComparer`1>comparer
  .[static]Sort <TKey[]>keys <TValue[]>items <System.Int32>index <System.Int32>length
  .[static]Sort <TKey[]>keys <TValue[]>items <System.Int32>index <System.Int32>length <IComparer`1>comparer
  .[static]Sort <System.Array>keys <System.Array>items <System.Int32>index <System.Int32>length <System.Collections.IComparer>comparer
  .<System.String>ToString()
  .[static]<System.Boolean>TrueForAll <T[]>array <Predicate`1>match
METHODS:
EVENTS:
PropNames: #(#IsFixedSize, #isReadOnly, #IsSynchronized, #length, #LongLength, #rank, #SyncRoot)
No Interface for dotNetObject:System.String[]
  System.String[] <System.Int32>
Constructors: true