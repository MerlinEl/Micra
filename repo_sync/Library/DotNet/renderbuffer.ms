function updateRenderBuffer mat =
(
        
        try (
                _bitmapStream = dotNetObject "System.IO.FileStream" (filename) (dotNetClass "System.IO.FileMode").Open (dotNetClass "System.IO.FileAccess").Read (dotNetClass "System.IO.FileShare").ReadWrite
                local _bitmap = dotNetObject "System.Drawing.Bitmap" _bitmapStream

                _bitmapStream.Dispose()
                return _bitmap.Clone()
                
        
        ) catch
        (
                local _bitmap = dotNetObject "System.Drawing.Bitmap" 1 1
                return _bitmap
        )
        
)