using Autodesk.Max;
/*
 This might be a bit of a long shot but I have noticed that in the Autodesk.max.dll from 2014+ the [] operator has gone missing from IBitArray. I know you no longer develop this so I’ve got a question about a workaround I was trying to use:

I wanted to use EnumSet(IBitArrayCallback cb) method. However I seem to be unable to create a valid class that inherits from IBitArrayCallback. I get a 'System.InvalidCastException' error: Unable to cast object of type 'TestNewAssembly.TestCallback' to type 'Autodesk.Max.IImplementable'.

IBitArray selVert = mesh.VertSel;
TestCallback test = new TestCallback();
selVert.EnumSet(test);

...

public class TestCallback : IBitArrayCallback
{
public void Proc(int n)
{}

public bool Equals(IBitArrayCallback other)
{return false;}

public void Dispose()
{}

public IntPtr NativePointer
{get { return IntPtr.Zero; }}
}

    Solution bellow
*/
namespace Micra.Core {
    public static class IBitArrayExtensions { //not tested //not used
        private const int NSHIFT = 6;
        private const int CHAR_BIT = 8;
        private const int kMAX_LOCALBITS = CHAR_BIT * sizeof(ulong);

        private const int BITS_PER_DWORD_PTR = ( CHAR_BIT * sizeof(ulong) );
        private const int BITS_PER_DWORD_PTR_MASK = BITS_PER_DWORD_PTR - 1;

        public static unsafe int GetBit(this IBitArray bitArray, int index) {
            //Number of bits in the bitArray
            int numBits = bitArray.Size;

            //Pointer to the start of either DWORD_PTR* bits or DWORD_PTR localBits
            //DWORD_PTR is of type ulong
            void* nativePtr = bitArray.NativePointer.ToPointer();

            //Determines whether we use bits or localBits
            bool useLocal = numBits <= kMAX_LOCALBITS;

            if ( useLocal ) {
                ulong localBits = ( (ulong*)nativePtr )[0];
                ulong bitMask = ( index < kMAX_LOCALBITS ) ? ( ( (ulong)1 ) << index ) : 0;
                return ( ( localBits & bitMask ) != 0 ) ? 1 : 0;
            } else {
                ulong* bits = ( (ulong**)nativePtr )[0];
                int bitIndex = index >> NSHIFT;
                var bitMaskParameter = index & BITS_PER_DWORD_PTR_MASK;
                ulong bitMask = ( bitMaskParameter < kMAX_LOCALBITS ) ? ( ( (ulong)1 ) << bitMaskParameter ) : 0;
                return ( ( bits[bitIndex] & bitMask ) != 0 ) ? 1 : 0;
            }
        }
        public static IBitArray BitwiseOR(this IBitArray A, IBitArray B) {
            int sizeA = A.Size;
            int sizeB = B.Size;

            if ( sizeA > sizeB ) {
                B.SetSize(sizeA, 1);
            } else {
                A.SetSize(sizeB, 1);
            }

            return B.BitwiseXor(A.BitwiseXor(A.BitwiseAnd(B)));
        }
    }
}
