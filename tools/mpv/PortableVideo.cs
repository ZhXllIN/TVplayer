using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

public sealed class PortableVideo : IDisposable {
    const string Lib = "libmpv-2.dll";
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern IntPtr LoadLibrary(string path);
    [DllImport(Lib, CallingConvention=CallingConvention.Cdecl)] static extern IntPtr mpv_create();
    [DllImport(Lib, CallingConvention=CallingConvention.Cdecl)] static extern int mpv_initialize(IntPtr h);
    [DllImport(Lib, CallingConvention=CallingConvention.Cdecl)] static extern int mpv_set_option_string(IntPtr h,string name,string value);
    [DllImport(Lib, CallingConvention=CallingConvention.Cdecl)] static extern int mpv_command(IntPtr h, IntPtr[] args);
    [DllImport(Lib, CallingConvention=CallingConvention.Cdecl)] static extern IntPtr mpv_wait_event(IntPtr h,double timeout);
    [DllImport(Lib, CallingConvention=CallingConvention.Cdecl)] static extern void mpv_terminate_destroy(IntPtr h);
    IntPtr handle;

    public static void Load(string path) {
        if(LoadLibrary(path)==IntPtr.Zero) throw new System.ComponentModel.Win32Exception();
    }
    public PortableVideo(string path, long window) {
        handle=mpv_create();
        if(handle==IntPtr.Zero) throw new InvalidOperationException("mpv_create");
        try {
            Check(mpv_set_option_string(handle,"wid",window.ToString()));
            Check(mpv_initialize(handle));
            var args=new IntPtr[3];
            try {
                args[0]=Marshal.StringToHGlobalAnsi("loadfile");
                byte[] bytes=Encoding.UTF8.GetBytes(Path.GetFullPath(path)+"\0");
                args[1]=Marshal.AllocHGlobal(bytes.Length);
                Marshal.Copy(bytes,0,args[1],bytes.Length);
                Check(mpv_command(handle,args));
            } finally { Marshal.FreeHGlobal(args[0]); Marshal.FreeHGlobal(args[1]); }
        } catch { Dispose(); throw; }
    }
    static void Check(int value) {
        if(value<0) throw new InvalidOperationException("mpv error "+value);
    }
    public int Poll() {
        while(true) {
            IntPtr evt=mpv_wait_event(handle,0);
            int id=Marshal.ReadInt32(evt);
            if(id==0) return 0;
            if(id==7) {
                IntPtr end=Marshal.ReadIntPtr(evt,16);
                return Marshal.ReadInt32(end)==4 ? -1 : 1;
            }
        }
    }
    public void Dispose() {
        if(handle!=IntPtr.Zero) { mpv_terminate_destroy(handle); handle=IntPtr.Zero; }
    }
}
