// Windows-only verification for untrusted test certificates. Never changes trust stores.
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

public static class AuthenticodeIntegrity
{
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct FileInfo
    {
        public uint Size;
        [MarshalAs(UnmanagedType.LPWStr)] public string Path;
        public IntPtr File;
        public IntPtr KnownSubject;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct TrustData
    {
        public uint Size;
        public IntPtr PolicyCallback;
        public IntPtr SipClient;
        public uint UIChoice;
        public uint RevocationChecks;
        public uint UnionChoice;
        public IntPtr File;
        public uint StateAction;
        public IntPtr State;
        public IntPtr Url;
        public uint ProviderFlags;
        public uint UIContext;
        public IntPtr SignatureSettings;
    }

    [DllImport("wintrust.dll", ExactSpelling = true)]
    private static extern int WinVerifyTrust(IntPtr window, ref Guid action, ref TrustData data);

    [DllImport("crypt32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool CryptQueryObject(uint type, [MarshalAs(UnmanagedType.LPWStr)] string file,
        uint contentFlags, uint formatFlags, uint flags, out uint encoding, out uint content,
        out uint format, out IntPtr store, out IntPtr message, IntPtr context);

    [DllImport("crypt32.dll", SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool CryptMsgGetParam(IntPtr message, uint type, uint index,
        [Out] byte[] data, ref uint size);

    [DllImport("crypt32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool CryptMsgClose(IntPtr message);

    [DllImport("crypt32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool CertCloseStore(IntPtr store, uint flags);

    public static byte[] ReadEmbeddedSignature(string path)
    {
        IntPtr store = IntPtr.Zero, message = IntPtr.Zero;
        try
        {
            uint encoding, content, format;
            // FILE; PKCS7_SIGNED_EMBED only (no catalog fallback); BINARY.
            if (!CryptQueryObject(1, path, 1u << 10, 1u << 1, 0,
                out encoding, out content, out format, out store, out message, IntPtr.Zero))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "Cannot read embedded Authenticode signature");
            uint size = 0;
            const uint EncodedMessage = 29; // CMSG_ENCODED_MESSAGE
            if (!CryptMsgGetParam(message, EncodedMessage, 0, null, ref size))
                throw new Win32Exception(Marshal.GetLastWin32Error());
            var bytes = new byte[size];
            if (!CryptMsgGetParam(message, EncodedMessage, 0, bytes, ref size))
                throw new Win32Exception(Marshal.GetLastWin32Error());
            return bytes;
        }
        finally
        {
            if (message != IntPtr.Zero) CryptMsgClose(message);
            if (store != IntPtr.Zero) CertCloseStore(store, 0);
        }
    }

    public static void VerifyFileDigest(string path)
    {
        var info = new FileInfo { Size = (uint)Marshal.SizeOf<FileInfo>(), Path = path };
        IntPtr memory = Marshal.AllocHGlobal(Marshal.SizeOf<FileInfo>());
        var data = new TrustData {
            Size = (uint)Marshal.SizeOf<TrustData>(), UIChoice = 2, UnionChoice = 1,
            File = memory, StateAction = 1,
            // HASH_ONLY | REVOCATION_CHECK_NONE | CACHE_ONLY_URL_RETRIEVAL.
            // This checks covered file contents, not publisher or chain trust.
            ProviderFlags = 0x200 | 0x10 | 0x1000
        };
        var action = new Guid("00AAC56B-CD44-11d0-8CC2-00C04FC295EE");
        try
        {
            Marshal.StructureToPtr(info, memory, false);
            int result = WinVerifyTrust(new IntPtr(-1), ref action, ref data);
            if (result != 0)
                throw new InvalidOperationException("Authenticode file digest verification failed: 0x" + result.ToString("X8"));
        }
        finally
        {
            data.StateAction = 2;
            WinVerifyTrust(new IntPtr(-1), ref action, ref data);
            Marshal.DestroyStructure<FileInfo>(memory);
            Marshal.FreeHGlobal(memory);
        }
    }
}
