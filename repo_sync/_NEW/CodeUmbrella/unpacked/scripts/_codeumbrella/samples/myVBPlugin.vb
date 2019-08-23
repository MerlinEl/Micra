Imports System

Public Class MyVbPlugin
    Public proxy As system.object

    Public Function Main() As System.Single
        Return 1.0F
    End Function

    Public Function giveMeRandomStuff() As Integer()
        Return {New Random().Next, New Random().Next, New Random().Next, New Random().Next}
    End Function

    Public Sub createSimpleBox()
        Try
            proxy.executeMAXScript("myBox=box();myBox.width=20;myBox.height=30;mybox.length=25;")
        Catch ex As Exception
            proxy.executeMAXScript("print " & """" & ex.ToString & """")
        End Try
    End Sub

    Public Function toplevelcall(ByVal e As System.Object)
        proxy = e
        proxy.executeMAXScript("print " _
         & """" & "Greetings from VB.net" & """")
        Return 0
    End Function

End Class