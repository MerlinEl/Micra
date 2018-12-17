MemberwiseClone

The following code example shows how to copy an instance of a class using Object.MemberwiseClone.

using System;

class MyBaseClass {
   public static string CompanyName = "My Company";
   public int age;
   public string name;
}

class MyDerivedClass: MyBaseClass {

   static void Main() {
   
   // Creates an instance of MyDerivedClass and assign values to its fields.
   MyDerivedClass m1 = new MyDerivedClass();
   m1.age = 42;
   m1.name = "Sam";

   // Performs a shallow copy of m1 and assign it to m2.
   MyDerivedClass m2 = (MyDerivedClass) m1.MemberwiseClone();
   }
}

    